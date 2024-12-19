class UserProfile {
  final String userId;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? address;

  const UserProfile({
    required this.userId,
    required this.name,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}