// services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phuong/modal/event_modal.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createBooking({
    required EventModel event,
    required int selectedSeats,
    required double totalAmount,
    required String paymentId,
  }) async {
    try {
      final String userId = _auth.currentUser!.uid;
      final String bookingId = _firestore.collection('bookings').doc().id;

      await _firestore.collection('bookings').doc(bookingId).set({
        'bookingId': bookingId,
        'eventId': event.eventId,
        'userId': userId,
        'bookedSeats': selectedSeats,
        'totalAmount': totalAmount,
        'bookingDate': DateTime.now(),
        'paymentId': paymentId,
        'bookingStatus': 'confirmed',
        'eventDetails': event.toMap(),
      });
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  Future<List<EventModel>> getUserBookings() async {
    try {
      final String userId = _auth.currentUser!.uid;
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookingDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()['eventDetails']))
          .toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'bookingStatus': 'cancelled',
      });
    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }
}
