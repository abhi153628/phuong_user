import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';

class UserOrganizerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<OrganizerProfile?> fetchOrganizerProfile(String organizerId) async {
  try {log('1');
    final DocumentSnapshot snapshot =
        await _firestore.collection('organizers').doc(organizerId).get();
log('2');

    if (!snapshot.exists) {
      log('No data found for organizer with ID: $organizerId');
      log('3');
      return null;
      
    }
    log('4');

    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      log('5');
      print('Document Data:');
      data.forEach((key, value) {
        print('$key: $value');
      });log('6');

      // Safely handle the 'links' field
      List<String>? links = (data['links'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList();
log('7');
OrganizerProfile org=OrganizerProfile(id: '',name: '');
 print('d');
      // Handle null or missing fields with default values
     org= OrganizerProfile(
        id: organizerId,
        name: data['name'] ?? 'No Name Provided', // Default value for name
        links: links ?? [], // Default empty list if links is null
        bio: data['bio'] ?? 'No Bio Provided', // Default value for bio
        imageUrl: data['imageUrl'] ?? '', // Default empty string for imageUrl
      );
  
    log('printing org');
    return org;
   
    } else {
      log('8');
      print('No data found in the document.');
      return null;
    }


  }
  
  
   catch (apiError) {
    log('9');
    log('$apiError');
    return null;
  }
  
}
 

}

