import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phuong/modal/event_modal.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EventModel>> getEvents() async {
    try {
      final snapshot = await _firestore
          .collection('eventCollection')
          .orderBy('date', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      rethrow;
    }
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore
          .collection('eventCollection')
          .doc(eventId)
          .get();
      
      if (doc.exists) {
        return EventModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching event: $e');
      rethrow;
    }
  }
}