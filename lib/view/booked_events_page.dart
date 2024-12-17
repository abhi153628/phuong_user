import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuong/modal/booking_modal.dart';
import 'package:phuong/services/booking_service.dart';

class UserBookingsPage extends StatelessWidget {
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Bookings')),
      body: StreamBuilder<List<BookingModel>>(
        stream: _bookingService.getUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];
          
          if (bookings.isEmpty) {
            return Center(child: Text('No bookings found'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingCard(booking: booking);
            },
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(booking.eventName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seats: ${booking.seatsBooked}'),
            Text('Total: ₹${booking.totalPrice}'),
            Text('Booked on: ${DateFormat('dd MMM yyyy').format(booking.bookingTime)}'),
          ],
        ),
      ),
    );
  }
}
