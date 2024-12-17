// import 'dart:async';

// class SeatReservation {
  
//   final String userId;
//   final int seatsReserved;
//   final DateTime reservationTime;

//   SeatReservation({
//     required this.userId,
//     required this.seatsReserved,
//     required this.reservationTime,
//   });
// }

// // In BookingService
// Future<bool> holdSeats(String eventId, int seatsToHold) async {
//   final reservation = SeatReservation(
//     userId: currentUser.uid,
//     seatsReserved: seatsToHold,
//     reservationTime: DateTime.now(),
//   );

//   // Hold seats for 10 minutes
//   await _firestore
//     .collection('eventCollection')
//     .doc(eventId)
//     .collection('reservations')
//     .add(reservation.toMap());

//   // Background job to release unheld seats after 10 minutes
//   Timer(Duration(minutes: 10), () => _releaseUnconfirmedSeats(eventId));
// }

// void _releaseUnconfirmedSeats(String eventId) async {
//   final reservations = await _firestore
//     .collection('eventCollection')
//     .doc(eventId)
//     .collection('reservations')
//     .where('reservationTime', 
//       isLessThan: DateTime.now().subtract(Duration(minutes: 10)))
//     .get();

//   // Release seats back to availability
// }