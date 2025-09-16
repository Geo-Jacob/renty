import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../domain/entities/chat_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChatsNotifier extends StateNotifier<AsyncValue<List<ChatEntity>>> {
  final FirebaseFirestore _firestore;
  final String _userId;
  StreamSubscription<QuerySnapshot>? _chatsSubscription;

  ChatsNotifier(this._firestore, this._userId) : super(const AsyncValue.loading()) {
    _listenToChats();
  }

  void _listenToChats() {
    _chatsSubscription?.cancel();
    
    try {
      final chatStream = _firestore
          .collection('chats')
          .where('participants', arrayContains: _userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots();

      _chatsSubscription = chatStream.listen(
        (snapshot) {
          final chats = snapshot.docs
              .map((doc) => ChatEntity.fromFirestore(doc))
              .toList();
          state = AsyncValue.data(chats);
        },
        onError: (error, stackTrace) {
          state = AsyncValue.error(error, stackTrace);
        },
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }

  // Method to create a new chat or return existing one
  Future<String> getOrCreateChat(String otherUserId) async {
    try {
      // Check if chat already exists
      final querySnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: _userId)
          .get();

      for (final doc in querySnapshot.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new chat if none exists
      final newChatRef = await _firestore.collection('chats').add({
        'participants': [_userId, otherUserId],
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'isUnread': false,
        'metadata': {
          'createdAt': FieldValue.serverTimestamp(),
        },
      });

      return newChatRef.id;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }
}

final chatsProvider =
    StateNotifierProvider<ChatsNotifier, AsyncValue<List<ChatEntity>>>((ref) {
  final userId = ref.read(authStateProvider).user!.id; // Get the current user's ID
  return ChatsNotifier(FirebaseFirestore.instance, userId);
});