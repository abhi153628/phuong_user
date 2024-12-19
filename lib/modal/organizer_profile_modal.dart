import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String? description;
  final DateTime timestamp;
  final String organizerId; // Added field
  final String organizerName; // Added field
  final String organizerImageUrl; // Added field
  bool isLiked;
  bool isSaved;

  Post({
    required this.id,
    required this.imageUrl,
    this.description,
    required this.timestamp,
    required this.organizerId,
    required this.organizerName,
    required this.organizerImageUrl,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'],
      timestamp: (json['timestamp'] is Timestamp)
          ? (json['timestamp'] as Timestamp).toDate()
          : json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? 'Unknown Organizer',
      organizerImageUrl: json['organizerImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerImageUrl': organizerImageUrl,
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