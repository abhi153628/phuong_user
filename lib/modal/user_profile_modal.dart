class UserProfile {
  final String userId;
  final String name;

  UserProfile({required this.userId, required this.name});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
    };
  }
}
