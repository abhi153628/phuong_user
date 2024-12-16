// screens/booked_events_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import '../services/booking_service.dart';


class BookedEventsScreen extends StatefulWidget {
  @override
  _BookedEventsScreenState createState() => _BookedEventsScreenState();
}

class _BookedEventsScreenState extends State<BookedEventsScreen> {
  final BookingService _bookingService = BookingService();
  late Future<List<EventModel>> _bookedEventsFuture;

  @override
  void initState() {
    super.initState();
    _bookedEventsFuture = _bookingService.getUserBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'My Bookings',
          style: GoogleFonts.syne(
            color: AppColors.activeGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _bookedEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.activeGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading bookings',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final bookedEvents = snapshot.data ?? [];

          if (bookedEvents.isEmpty) {
            return Center(
              child: Text(
                'No bookings found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookedEvents.length,
            itemBuilder: (context, index) {
              final event = bookedEvents[index];
              return BookedEventCard(event: event);
            },
          );
        },
      ),
    );
  }
}

class BookedEventCard extends StatelessWidget {
  final EventModel event;

  const BookedEventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              event.imageUrl ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[800],
                  child: Icon(Icons.error, color: Colors.white),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventName ?? '',
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.activeGreen,
                  ),
                ),
                SizedBox(height: 8),
                _buildInfoRow(Icons.calendar_today, 
                  'Date: ${event.date?.toString().split(' ')[0] ?? 'N/A'}'),
                _buildInfoRow(Icons.location_on, 
                  'Location: ${event.location ?? 'N/A'}'),
                _buildInfoRow(Icons.event_seat, 
                  'Booked Seats: ${event.bookedSeats ?? 'N/A'}'),
                _buildInfoRow(Icons.attach_money, 
                  'Total Amount: ₹${event.totalAmount?.toStringAsFixed(2) ?? 'N/A'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
