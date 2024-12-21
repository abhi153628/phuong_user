// post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String? description;
  final DateTime timestamp;
  final String organizerId;
  final String organizerName;
  final String organizerImageUrl;
  final bool isLiked; // Added field

  Post({
    required this.id,
    required this.imageUrl,
    this.description,
    required this.timestamp,
    required this.organizerId,
    required this.organizerName,
    required this.organizerImageUrl,
    this.isLiked = false, // Default value
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
      isLiked: json['isLiked'] ?? false,
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
      'isLiked': isLiked,
    };
  }

  // Create a copy of the post with modified properties
  Post copyWith({
    String? id,
    String? imageUrl,
    String? description,
    DateTime? timestamp,
    String? organizerId,
    String? organizerName,
    String? organizerImageUrl,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerImageUrl: organizerImageUrl ?? this.organizerImageUrl,
      isLiked: isLiked ?? this.isLiked,
    );
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