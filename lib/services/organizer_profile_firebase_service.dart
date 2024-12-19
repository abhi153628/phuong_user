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
   //! Function to fetch all organizers
  Future<List<OrganizerProfile>> getAllOrganizers() async {
    try {
      log('Fetching all organizers from the database');
      // Query all documents from the 'organizers' collection
      final QuerySnapshot querySnapshot =
          await _firestore.collection('organizers').get();

      if (querySnapshot.docs.isEmpty) {
        log('No organizers found');
        return [];
      }

      // Map each document to an OrganizerProfile
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Add the document ID to the data
        data['id'] = doc.id;

        // Create and return OrganizerProfile
        return OrganizerProfile.fromJson(data);
      }).toList();
    } catch (error) {
      log('Error fetching all organizers: $error');
      return [];
    }
  }

   Stream<List<Post>> fetchAllPosts() {
  try {
    return _firestore
        .collection('organizers')
        .snapshots()
        .map((snapshot) {
      List<Post> allPosts = [];

      for (var doc in snapshot.docs) {
        final organizerData = doc.data();
        final posts = organizerData['posts'] as List<dynamic>? ?? [];

        for (var postData in posts) {
          try {
            final post = Post.fromJson({
              ...Map<String, dynamic>.from(postData),
              'id': postData['id'],
              'organizerId': doc.id,
              'organizerName': organizerData['name'] ?? 'Unknown Organizer',
              'organizerImageUrl': organizerData['imageUrl'] ?? '',
            });
            allPosts.add(post);
          } catch (e) {
            log('Error converting post in organizer ${doc.id}: $e');
            continue;
          }
        }
      }

      // Sort all posts by timestamp
      allPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allPosts;
    });
  } catch (e) {
    log('Error in fetchAllPosts: $e');
    return Stream.value([]);
  }
}
}

  


  // Stream to fetch all posts from all organizers
 


  