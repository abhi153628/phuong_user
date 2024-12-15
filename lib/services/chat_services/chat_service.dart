// chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phuong/modal/chat_modal.dart';
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

    // Check if chat room already exists
    final existingRoomQuery = await _firestore
        .collection('chatRooms')
        .where('userId', isEqualTo: currentUser.uid)
        .where('organizerId', isEqualTo: organizerId)
        .limit(1)
        .get();

    if (existingRoomQuery.docs.isNotEmpty) {
      return existingRoomQuery.docs.first.id;
    }

    final userProfile = await _userProfileService.getUserProfile();
    final currentUserName = userProfile?.name ?? 'User';

    // Create new chat room
    final chatRoomRef = await _firestore.collection('chatRooms').add({
      'userId': currentUser.uid,
      'organizerId': organizerId,
      'senderName': currentUserName ?? 'User',  
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
        //  .where('deletedFor', arrayContains: FirebaseAuth.instance.currentUser!.uid) // used for delete for me 
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
  //! Delete functionality
 void deleteMessageForMe(String chatRoomId, ChatMessage message) {
  try {
    // Ensure the user is authenticated
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No authenticated user found');
      return;
    }

    // Update the message document to add the current user's ID to a 'deletedFor' array
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(message.id)
        .update({
      'deletedFor': FieldValue.arrayUnion([currentUser.uid])
    }).catchError((error) {
      print('Error deleting message for me: $error');
    });
  } catch (e) {
    print('Unexpected error in deleteMessageForMe: $e');
  }
}
//! Delete for me
  void deleteMessageForEveryone(String chatRoomId, ChatMessage message) {
    // Implement logic to delete message for all users
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(message.id)
        .delete();
  }
   Future<void> restoreMessage(Map<String, dynamic> messageData) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // Remove the current user from deletedFor array
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(messageData['chatRoomId'])
          .collection('messages')
          .doc(messageData['id'])
          .update({
        'deletedFor': FieldValue.arrayRemove([currentUserId])
      });
    } catch (e) {
      print('Error restoring message: $e');
    }
  }
}
