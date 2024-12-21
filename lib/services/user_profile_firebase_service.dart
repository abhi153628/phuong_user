import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:phuong/modal/user_profile_modal.dart';

// First, add these packages to pubspec.yaml:
// geolocator: ^10.1.0
// geocoding: ^2.1.1

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';



class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    return user.uid;
  }

  // Add this new method to handle location permissions and fetching
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Add this method to get address from coordinates
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.administrativeArea}';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

   Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore.collection('userProfiles').doc(userId).set({
        'userId': userId,
        'name': userProfile.name,
        'latitude': userProfile.latitude,
        'longitude': userProfile.longitude,
        'address': userProfile.address,
        'phoneNumber': userProfile.phoneNumber, // Add this line to save phone number
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('UserProfile updated successfully with phone number!');
    } catch (e) {
      debugPrint('Error updating UserProfile: $e');
      throw Exception('Failed to update user profile');
    }
  }
    Future<void> updatePhoneNumber(String phoneNumber) async {
    try {
      await _firestore.collection('userProfiles').doc(userId).set({
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('Phone number updated successfully!');
    } catch (e) {
      debugPrint('Error updating phone number: $e');
      throw Exception('Failed to update phone number');
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      final doc = await _firestore.collection('userProfiles').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserProfile.fromJson({
          ...data,
          'userId': userId,
        });
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching UserProfile: $e');
      return null;
    }
  }
}
  
  
