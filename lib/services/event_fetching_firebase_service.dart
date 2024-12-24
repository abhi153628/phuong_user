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


  Future<List<EventModel>> getEventsByGenre(String genre) async {
    try {
      // If genre is 'My feed', return all events
      if (genre == 'My feed') {
        return getEvents();
      }

      final snapshot = await _firestore
          .collection('eventCollection')
          .where('genre', isEqualTo: genre.toLowerCase())
          .orderBy('date', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching events by genre: $e');
      rethrow;
    }
  }
  Future<void> updateSeatAvailability(String eventId, double newSeatCount) async {
    try {
      await _firestore
          .collection('eventCollection')
          .doc(eventId)
          .update({'seatAvailabilityCount': newSeatCount});
    } catch (e) {
      print('Error updating seat availability: $e');
      rethrow;
    }
  }

  // Stream to get real-time event updates
  Stream<EventModel?> getEventStream(String eventId) {
    return _firestore
        .collection('eventCollection')
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return EventModel.fromMap(snapshot.data()!,);
      }
      return null;
    });
  }
  Future<void> saveEvent(String userId, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedEvents')
          .doc(eventId)
          .set({
        'savedAt': FieldValue.serverTimestamp(),
        'eventId': eventId,
      });
    } catch (e) {
      print('Error saving event: $e');
      rethrow;
    }
  }

  // Unsave event for a user
  Future<void> unsaveEvent(String userId, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedEvents')
          .doc(eventId)
          .delete();
    } catch (e) {
      print('Error removing saved event: $e');
      rethrow;
    }
  }

  // Check if event is saved by user
Stream<bool> isEventSavedStream(String userId, String eventId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('savedEvents')
      .doc(eventId)
      .snapshots()
      .map((doc) => doc.exists);
}
    Stream<List<EventModel>> getSavedEvents(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savedEvents')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<EventModel> savedEvents = [];
      for (var doc in snapshot.docs) {
        final eventId = doc.data()['eventId'] as String;
        final eventDoc = await _firestore
            .collection('eventCollection')
            .doc(eventId)
            .get();
        if (eventDoc.exists) {
          savedEvents.add(EventModel.fromMap(eventDoc.data()!));
        }
      }
      return savedEvents;
    });
  }
}
  



