// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

// class CharService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   //! Creating chat room

//   Future<String> createChatRoom(String organizerId, dynamic currentUser) async{
//     try{
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         throw Exception('User not authenticated')
        
//       }
//     }

//     //! checking of room already exists 
//     final existingRoomQuery = await _firestore.collection('chatrooms').where('userId',isEqualTo: currentUser.uid).where('organizerId',isEqualTo: organizerId).limit(1).get();
//     if (existingRoomQuery.docs.isNotEmpty) {
//       return existingRoomQuery.docs.first.id;
      
//     }

//     final chatRoomRef = await _firestore.collection('chatRooms').add({
//       'userId':
//     })

//   }
  
// }

