import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:phuong/modal/user_profile_modal.dart';
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
      // First, get the existing data
      final existingDoc = await _firestore.collection('userProfiles').doc(userId).get();
      
      // Prepare the update data
      final Map<String, dynamic> updateData = {
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only update fields that are not null in the userProfile
      if (userProfile.name != null && userProfile.name!.isNotEmpty) {
        updateData['name'] = userProfile.name;
      }
      if (userProfile.latitude != null) {
        updateData['latitude'] = userProfile.latitude;
      }
      if (userProfile.longitude != null) {
        updateData['longitude'] = userProfile.longitude;
      }
      if (userProfile.address != null) {
        updateData['address'] = userProfile.address;
      }
      if (userProfile.phoneNumber != null) {
        updateData['phoneNumber'] = userProfile.phoneNumber;
      }

      // If the document doesn't exist, include all fields
      if (!existingDoc.exists) {
        await _firestore.collection('userProfiles').doc(userId).set(updateData);
      } else {
        // If it exists, merge the updates
        await _firestore.collection('userProfiles').doc(userId).update(updateData);
      }

      debugPrint('UserProfile updated successfully!');
    } catch (e) {
      debugPrint('Error updating UserProfile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    try {
      await _firestore.collection('userProfiles').doc(userId).update({
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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