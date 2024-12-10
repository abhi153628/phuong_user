import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';

class UserOrganizerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<OrganizerProfile?> fetchOrganizerProfile(String organizerId) async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection('organizers').doc(organizerId).get();

      if (!snapshot.exists) {
        log('No data found for organizer with ID: $organizerId');
        return null;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final links = (data['links'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList();

      // Fetch the posts
      final posts = await fetchPostsByOrganizer(organizerId);

      final org = OrganizerProfile(
        id: organizerId,
        name: data['name'] ?? 'No Name Provided',
        links: links ?? [],

        bio: data['bio'] ?? 'No Bio Provided',
        imageUrl: data['imageUrl'] ?? '',
        posts: posts,
      );

      return org;
    } catch (apiError) {
      log('Error fetching organizer profile: $apiError');
      return null;
    }
  }

  Future<List<Post>> fetchPostsByOrganizer(String organizerId) async {
    try {
      log('Fetching posts for organizer: $organizerId');

      final QuerySnapshot snapshot = await _firestore
          .collection('posts')
         
          .orderBy('timestamp', descending: true)
          .get();

      log('Found ${snapshot.docs.length} posts');
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post(

          id: doc.id,
          userId: data['userId'] ?? '',
          
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (error) {
      log('Error fetching posts: $error');
      return [];
    }
  }
}