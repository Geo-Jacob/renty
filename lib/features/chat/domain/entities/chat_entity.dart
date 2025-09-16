import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final bool isUnread;
  final Map<String, dynamic>? metadata; // For additional chat data

  const ChatEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.isUnread,
    this.metadata,
  });

  factory ChatEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatEntity(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      isUnread: data['isUnread'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'isUnread': isUnread,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        lastMessage,
        lastMessageSenderId,
        lastMessageTime,
        isUnread,
        metadata,
      ];
}