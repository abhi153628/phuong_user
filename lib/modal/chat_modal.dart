// chat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final Timestamp timestamp;
  final bool isRead;
  final List<String> deletedFor;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.deletedFor = const [],
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
      deletedFor: List<String>.from(data['deletedFor'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      'deletedFor': deletedFor,
    };
  }
}

class ChatRoom {
  final String id;
  final String userId;
  final String senderName;
  final String organizerId;
  final Timestamp lastMessageTimestamp;
  final String lastMessage;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.senderName,
    required this.organizerId,
    required this.lastMessageTimestamp,
    required this.lastMessage,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      userId: data['userId'] ?? '',
      senderName: data['senderName'] ?? '',
      organizerId: data['organizerId'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
      lastMessage: data['lastMessage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'organizerId': organizerId,
      'senderName': senderName,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessage': lastMessage,
    };
  }
}
