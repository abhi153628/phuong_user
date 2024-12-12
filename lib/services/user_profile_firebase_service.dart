import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:phuong/modal/user_profile_modal.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    return user.uid;
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore.collection('userProfiles').doc(userId).set({
        'name': userProfile.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('UserProfile updated successfully!');
    } catch (e) {
      debugPrint('Error updating UserProfile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      final doc = await _firestore.collection('userProfiles').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching UserProfile: $e');
      return null;
    }
  }
}