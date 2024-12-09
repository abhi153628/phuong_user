// models/organizer_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerProfile {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final List<String>? links;

  final List<Post>? posts;

  OrganizerProfile({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.links,

    this.posts,
  });

  factory OrganizerProfile.fromJson(Map<String, dynamic> json) {
    return OrganizerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      links: (json['links'] as List?)?.map((e) => e as String).toList(),
 
      posts: json['posts'] != null
          ? (json['posts'] as List)
              .map((post) => Post.fromJson(post as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
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
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}

