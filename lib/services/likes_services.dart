// likes_service.dart
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:rxdart/rxdart.dart';

class LikesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Reference to user's liked posts collection
  CollectionReference get _userLikesRef =>
      _firestore.collection('userLikes');

  // Stream of liked post IDs for the current user
  Stream<Set<String>> get likedPostIds {
    if (_userId == null) return Stream.value({});

    return _userLikesRef
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return <String>{};
          final data = snapshot.data() as Map<String, dynamic>;
          return Set<String>.from(data['likedPosts'] ?? []);
        })
        .onErrorReturn({});
  }

  // Check if a specific post is liked
  Stream<bool> isPostLiked(String postId) {
    if (_userId == null) return Stream.value(false);

    return likedPostIds.map((ids) => ids.contains(postId));
  }

  // Like a post
  Future<void> likePost(String postId) async {
    if (_userId == null) return;

    try {
      await _userLikesRef.doc(_userId).set({
        'likedPosts': FieldValue.arrayUnion([postId])
      }, SetOptions(merge: true));
    } catch (e) {
      log('Error liking post: $e');
      rethrow;
    }
  }

  // Unlike a post
  Future<void> unlikePost(String postId) async {
    if (_userId == null) return;

    try {
      await _userLikesRef.doc(_userId).update({
        'likedPosts': FieldValue.arrayRemove([postId])
      });
    } catch (e) {
      log('Error unliking post: $e');
      rethrow;
    }
  }

  // Get stream of liked posts
  Stream<List<Post>> getLikedPosts() {
    if (_userId == null) return Stream.value([]);

    return Rx.combineLatest2(
      likedPostIds,
      _getAllPosts(),
      (Set<String> likedIds, List<Post> allPosts) {
        return allPosts
            .where((post) => likedIds.contains(post.id))
            .map((post) => post.copyWith(isLiked: true))
            .toList();
      },
    );
  }

  // Helper method to get all posts
  Stream<List<Post>> _getAllPosts() {
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
            log('Error converting post: $e');
            continue;
          }
        }
      }

      allPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allPosts;
    });
  }
}
