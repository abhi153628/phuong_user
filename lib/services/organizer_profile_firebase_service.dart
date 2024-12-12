import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';


class UserOrganizerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<OrganizerProfile?> fetchOrganizerProfile(String organizerId) async {
    try {
       log('Fetching organizer profile for ID: $organizerId'); 
      // Fetch organizer document
      final DocumentSnapshot snapshot =
          await _firestore.collection('organizers').doc(organizerId).get();

      if (!snapshot.exists) {
        log('No data found for organizer with ID: $organizerId');
        return null;
      }

      // Convert snapshot data to Map
      final data = snapshot.data() as Map<String, dynamic>;
      
      // Add the document ID to the data
      data['id'] = organizerId;

      // Create and return OrganizerProfile using factory constructor
      return OrganizerProfile.fromJson(data);
    } catch (apiError) {
      log('Error fetching organizer profile: $apiError');
      return null;
    }
  }

  //! Stream to fetch organizer posts
  Stream<List<Post>> fetchOrganizerPosts(String organizerId) {
    log('Fetching organizer posts for ID: $organizerId');
    return _firestore
        .collection('organizers')
        .doc(organizerId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        log('No organizer found with ID: $organizerId');
        return [];
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final postsList = data['posts'] as List<dynamic>? ?? [];

      return postsList
          .map((postJson) => Post.fromJson(Map<String, dynamic>.from(postJson)))
          .toList();
    });
  }
}

  
  // //! I N S T A G R A M   F E E D
  //  Future<List<Post>> fetchAllPosts(String organizerId) async {
  //   try {
  //     log('Fetching posts for organizer: $organizerId');

  //     final QuerySnapshot snapshot = await _firestore
  //         .collection('posts')
         
  //         .orderBy('timestamp', descending: true)
  //         .get();

  //     log('Found ${snapshot.docs.length} posts');
      
  //     return snapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       return Post(

  //         id: doc.id,
  //         userId: data['userId'] ?? '',
          
  //         imageUrl: data['imageUrl'] ?? '',
  //         description: data['description'] ?? '',
  //         createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(), timestamp: ,
  //       );
  //     }).toList();
  //   } catch (error) {
  //     log('Error fetching posts: $error');
  //     return [];
  //   }
  