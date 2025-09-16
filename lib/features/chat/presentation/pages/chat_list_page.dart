import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/chats_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'chat_page.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsProvider);
    final currentUser = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement chat search
            },
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation from a listing or user profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              
              // Get the other participant's ID (not the current user)
              final otherUserId = chat.participants
                  .firstWhere((id) => id != currentUser!.id);

              // We'll use FutureBuilder to get the other user's details
              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserDetails(otherUserId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: LinearProgressIndicator(),
                    );
                  }

                  final userData = snapshot.data!;
                  final isUnread = chat.isUnread && 
                      chat.lastMessageSenderId != currentUser!.id;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['avatarUrl'] != null
                          ? NetworkImage(userData['avatarUrl'])
                          : null,
                      child: userData['avatarUrl'] == null
                          ? Text(userData['name'][0].toUpperCase())
                          : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            userData['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          timeago.format(chat.lastMessageTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnread ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isUnread ? Colors.black87 : Colors.grey[600],
                              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '•',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chatId: chat.id,
                            otherUser: userData,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading chats: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(chatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        return {
          'name': 'Unknown User',
          'avatarUrl': null,
        };
      }

      final data = doc.data()!;
      return {
        'name': data['name'] ?? 'Unknown User',
        'avatarUrl': data['avatarUrl'],
        'college': data['college'],
        'rating': data['rating'] ?? 0.0,
      };
    } catch (e) {
      return {
        'name': 'Error loading user',
        'avatarUrl': null,
      };
    }
  }
}
