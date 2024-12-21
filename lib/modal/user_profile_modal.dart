class UserProfile {
  final String userId;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? phoneNumber; // Changed to String type for phone numbers

  const UserProfile({
    required this.userId,
    required this.name,
    this.latitude,
    this.longitude,
    this.address,
    this.phoneNumber,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }
}