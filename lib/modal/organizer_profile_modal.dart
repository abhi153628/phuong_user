import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

//! Post Model
class Post {
  final String id;
  final String imageUrl;
  final String? description;
  final DateTime timestamp;
  final int likes;

  Post({
    required this.id,
    required this.imageUrl,
    this.description,
    required this.timestamp,
    this.likes = 0,
  });

  //! Factory constructor to create a Post from a map
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'],
      timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp']) 
        : DateTime.now(),
      likes: json['likes'] ?? 0,
    );
  }

  //! Converting Post to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }
}

//! Organizer Profile Model
class OrganizerProfile {
  final String id;
  final String name;
  final String bio;
  final String imageUrl;
  final List<String> links;
  final List<Post> posts;

  OrganizerProfile({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
    required this.links,
    required this.posts,
  });

  //! Factory constructor to create OrganizerProfile from a map
  factory OrganizerProfile.fromJson(Map<String, dynamic> json) {
    return OrganizerProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name Provided',
      bio: json['bio'] ?? 'No Bio Provided',
      imageUrl: json['imageUrl'] ?? '',
      links: json['links'] != null 
        ? List<String>.from(json['links']) 
        : [],
      posts: json['posts'] != null
        ? (json['posts'] as List)
            .map((postJson) => Post.fromJson(postJson))
            .toList()
        : [],
    );
  }
}