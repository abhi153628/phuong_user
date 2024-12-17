import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phuong/modal/booking_modal.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/auth_services.dart';

class BookingService { 
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final FirebaseAuthServices _auth = FirebaseAuthServices();
  // Modify the bookEvent method to properly handle seat updates
  Future<bool> bookEvent(EventModel event, int seatsToBook) async {
    try {
      final currentUser = _auth.getCurrentUserId();
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      return await _firestore.runTransaction((transaction) async {
        // Get real-time event data
        DocumentReference eventRef = _firestore
            .collection('eventCollection')
            .doc(event.eventId);
        
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);
        
        // Verify event exists and has available seats
        if (!eventSnapshot.exists) {
          throw Exception('Event not found');
        }

        double currentSeats = eventSnapshot.get('seatAvailabilityCount') ?? 0.0;
        
        // Check if enough seats are available
        if (currentSeats < seatsToBook) {
          throw Exception('Not enough seats available');
        }

        // Create booking reference
        DocumentReference bookingRef = _firestore.collection('userBookings').doc();

        // Create booking model
        BookingModel booking = BookingModel(
          bookingId: bookingRef.id,
          eventId: event.eventId!,
          userId: currentUser,
          seatsBooked: seatsToBook,
          totalPrice: (event.ticketPrice ?? 0.0) * seatsToBook,
          bookingTime: DateTime.now(),
          eventName: event.eventName!,
          organizerId: event.organizerId!,
        );

        // Update seats atomically
        transaction.update(eventRef, {
          'seatAvailabilityCount': FieldValue.increment(-seatsToBook)
        });

        // Store booking in user bookings
        transaction.set(bookingRef, booking.toMap());

        // Store booking in event's booking subcollection
        DocumentReference eventBookingRef = eventRef
            .collection('bookings')
            .doc(bookingRef.id);
        transaction.set(eventBookingRef, booking.toMap());

        return true;
      });
    } catch (e) {
      print('Booking error: $e');
      return false;
    }
  }
    // Fetch user's bookings
  Stream<List<BookingModel>> getUserBookings() {
 final currentUser = _auth.getCurrentUserId();;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('userBookings')
        .where('userId', isEqualTo: currentUser)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList());
  }

  // Fetch bookings for a specific event (for organizer)
  Stream<List<BookingModel>> getEventBookings(String eventId) {
    return _firestore
        .collection('eventCollection')
        .doc(eventId)
        .collection('bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList());
  }
}
