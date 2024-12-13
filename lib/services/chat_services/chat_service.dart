// chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phuong/modal/chat_modal.dart';
import 'package:phuong/modal/user_profile_modal.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';


class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 final UserProfileService _userProfileService = UserProfileService();
  

  //! Create or get existing chat room
  Future<String> createChatRoom(String organizerId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      //! Check if chat room already exists
      final existingRoomQuery = await _firestore
          .collection('chatRooms')
          .where('userId', isEqualTo: currentUser.uid)
          .where('organizerId', isEqualTo: organizerId)
          .limit(1)
          .get();

      if (existingRoomQuery.docs.isNotEmpty) {
        return existingRoomQuery.docs.first.id;
      }

      //! Create new chat room
      final chatRoomRef = await _firestore.collection('chatRooms').add({
        'userId': currentUser.uid,
        'organizerId': organizerId,
        'lastMessageTimestamp': Timestamp.now(),
        'lastMessage': 'Chat started',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return chatRoomRef.id;
    } catch (e) {
      print('Error creating chat room: $e');
      rethrow;
    }
  }

  //! Send message in a chat room
  Future<void> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

    //! Fetch current user's profile name

      final userProfile = await _userProfileService.getUserProfile();
      final curentUserName = userProfile?.name ?? 'User';
      final message = ChatMessage(
        id: '', //! Firestore will generate ID
        senderId: currentUser.uid,
        senderName: curentUserName ?? 'User',
        receiverId: receiverId,
        content: content,
        timestamp: Timestamp.now(),
        isRead: false,
      );

      //! Add message to chat room
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toMap());

      //! Update last message in chat room
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': content,
        'lastMessageTimestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  //! Stream messages for a specific chat room
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList()
        );
  }

  //! Stream all chat rooms for a user
  Stream<List<ChatRoom>> getUserChatRooms() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chatRooms')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList()
        );
  }

  //! Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Get unread messages
      final unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('receiverId', isEqualTo: currentUser.uid)
          .get();

      // Batch update to mark as read
      WriteBatch batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
}