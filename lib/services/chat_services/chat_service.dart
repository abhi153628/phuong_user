// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatService {
//   //get instance of firestore
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   // example 
//   /* <List<Map<String, dynamic>>
//   [ {'email : test@gmail.com,
//         'id'  :''},
//       {'email : abhi@gmail.com'
//         'id'  : ''}]
//   */

//   //! get user stream
//   Stream<List<Map<String, dynamic>> getUserStreams(){
//     return _firestore.collection("Users").snapshots().map(snapshot){
//       return snapshot.doc.map((d))
//     }

//   }
// }