import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';

class LikesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Post>> getLikedPosts() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value([]);

      return _firestore
          .collection('likes')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .switchMap((likesSnapshot) {
        if (likesSnapshot.docs.isEmpty) return Stream.value([]);

        // Get all liked post IDs and their organizer IDs
        final likedDocs = likesSnapshot.docs;
        
        // Group likes by organizer ID to match your data structure
        final organizerIds = likedDocs
            .map((doc) => doc.data()['organizerId'] as String)
            .toSet()
            .toList();

        // Fetch all relevant organizer documents
        return _firestore
            .collection('organizers')
            .where(FieldPath.documentId, whereIn: organizerIds)
            .snapshots()
            .map((organizerSnapshot) {
          final List<Post> likedPosts = [];

          for (var organizerDoc in organizerSnapshot.docs) {
            final organizerData = organizerDoc.data();
            final List<dynamic> posts = organizerData['posts'] ?? [];

            for (var postData in posts) {
              // Check if this post is liked by comparing IDs
              final isLiked = likedDocs.any((likeDoc) =>
                  likeDoc.data()['postId'] == postData['id'] &&
                  likeDoc.data()['organizerId'] == organizerDoc.id);

              if (isLiked) {
                try {
                  final post = Post.fromJson({
                    ...Map<String, dynamic>.from(postData),
                    'id': postData['id'],
                    'organizerId': organizerDoc.id,
                    'organizerName': organizerData['name'] ?? 'Unknown Organizer',
                    'organizerImageUrl': organizerData['imageUrl'] ?? '',
                  });
                  likedPosts.add(post);
                } catch (e) {
                  print('Error parsing post: $e');
                }
              }
            }
          }

          // Sort by like timestamp
          likedPosts.sort((a, b) {
            final aLike = likedDocs.firstWhere(
                (doc) => doc.data()['postId'] == a.id,
                orElse: () => likedDocs.first);
            final bLike = likedDocs.firstWhere(
                (doc) => doc.data()['postId'] == b.id,
                orElse: () => likedDocs.first);

            final aTimestamp = aLike.data()['timestamp'] as Timestamp?;
            final bTimestamp = bLike.data()['timestamp'] as Timestamp?;

            if (aTimestamp == null || bTimestamp == null) return 0;
            return bTimestamp.compareTo(aTimestamp);
          });

          return likedPosts;
        });
      });
    });
  }

  Future<void> toggleLike(Post post) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final likeDoc = _firestore
        .collection('likes')
        .doc('${userId}_${post.id}');
    
    final organizerDoc = _firestore.collection('organizers').doc(post.organizerId);

    try {
      await _firestore.runTransaction((transaction) async {
        final likeSnapshot = await transaction.get(likeDoc);
        final organizerSnapshot = await transaction.get(organizerDoc);

        if (!organizerSnapshot.exists) {
          throw Exception('Organizer no longer exists');
        }

        if (likeSnapshot.exists) {
          // Unlike
          transaction.delete(likeDoc);
          // Update like count in the post within organizer document
          final organizerData = organizerSnapshot.data()!;
          final posts = List<dynamic>.from(organizerData['posts'] ?? []);
          final postIndex = posts.indexWhere((p) => p['id'] == post.id);
          
          if (postIndex != -1) {
            posts[postIndex]['likeCount'] = (posts[postIndex]['likeCount'] ?? 1) - 1;
            transaction.update(organizerDoc, {'posts': posts});
          }
        } else {
          // Like
          transaction.set(likeDoc, {
            'userId': userId,
            'postId': post.id,
            'organizerId': post.organizerId,
            'timestamp': FieldValue.serverTimestamp(),
          });
          
          // Update like count in the post within organizer document
          final organizerData = organizerSnapshot.data()!;
          final posts = List<dynamic>.from(organizerData['posts'] ?? []);
          final postIndex = posts.indexWhere((p) => p['id'] == post.id);
          
          if (postIndex != -1) {
            posts[postIndex]['likeCount'] = (posts[postIndex]['likeCount'] ?? 0) + 1;
            transaction.update(organizerDoc, {'posts': posts});
          }
        }
      });
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Failed to toggle like');
    }
  }

  Stream<bool> isPostLiked(String postId) {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value(false);

      return _firestore
          .collection('likes')
          .doc('${user.uid}_$postId')
          .snapshots()
          .map((doc) => doc.exists);
    });
  }
}