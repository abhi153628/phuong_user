import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerProfile {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final List<String>? links;
  final List<Post> posts;

  OrganizerProfile({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.links,
    required this.posts,
  });
}

class Post {
  final String id;
  final String userId;
  final String imageUrl;
  final String description;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}