import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/booking_modal.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/booking_service.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/settings_section/sub_pages/booked_tickets/user_ticket_view_page.dart';
import 'package:shimmer/shimmer.dart';

class TicketListPage extends StatefulWidget {
  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final BookingService _bookingService = BookingService();
  EventModel? event;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildBookingsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Ticket',
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.notoSans(color: Colors.white),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search by event name or date...',
          hintStyle: GoogleFonts.notoSans(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildBookingsList() {
    return StreamBuilder<List<BookingModel>>(
      stream: _bookingService.getUserBookings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final bookings = snapshot.data ?? [];
        final filteredBookings = _filterBookings(bookings);

        if (filteredBookings.isEmpty) {
          return _buildEmptyState();
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(filteredBookings[index]);
            },
          ),
        );
      },
    );
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    if (_searchQuery.isEmpty) return bookings;

    return bookings.where((booking) {
      final eventNameMatch =
          booking.eventName.toLowerCase().contains(_searchQuery.toLowerCase());
      final dateMatch = DateFormat('dd MMM yyyy')
          .format(booking.bookingTime)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return eventNameMatch || dateMatch;
    }).toList();
  }
Widget _buildBookingCard(BookingModel booking) {
  return GestureDetector(
   onTap: () async {
  try {
    final EventService eventService = EventService();
    final EventModel? event = await eventService.getEventById(booking.eventId);
    
    if (event != null && mounted) {
      // Add some debug prints
  
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventTicketScreen(
            booking: booking,
            event: event,
          ),
        ),
      );
    } else {
      print("Event is null or widget not mounted");
    }
  } catch (e) {
    print("Error fetching event: $e");
    if (mounted) {  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load event details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
},

    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //! Event Name
              Text(
                booking.eventName,
                style: GoogleFonts.syne(
                    color: AppColors.activeGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.activeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Confirmed',
                  style: GoogleFonts.notoSans(
                    color: AppColors.activeGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 8),
              Text(
                'Booked on: ${DateFormat('dd MMM yyyy').format(booking.bookingTime)}',
                style: GoogleFonts.notoSans(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seats: ${booking.seatsBooked}',
                style: GoogleFonts.notoSans(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total: ',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '₹ ${booking.totalPrice}',
                      style: GoogleFonts.orbitron(
                        color: AppColors
                            .activeGreen, // Use your desired color for the price
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
     ) ).animate().shimmer(duration: 1500.ms);
  }


  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            height: 120,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No bookings found',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error: $error',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }


}