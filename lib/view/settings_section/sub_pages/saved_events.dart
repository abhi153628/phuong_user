import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/view/event_detail_screen/widgets/fields_event_details_widget.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:shimmer/shimmer.dart';

class SavedEventsPage extends StatefulWidget {
  final String? userId;

  SavedEventsPage({Key? key, this.userId}) : super(key: key);

  @override
  _SavedEventsPageState createState() => _SavedEventsPageState();
}

class _SavedEventsPageState extends State<SavedEventsPage> {
  final EventService _eventService = EventService();
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
          
            Expanded(child: _buildSavedEventsList()),
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
            'Saved Events',
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.activeGreen,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

 

  Widget _buildSavedEventsList() {
    return StreamBuilder<List<EventModel>>(
      stream: _eventService.getSavedEvents(widget.userId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error loading saved events');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final events = snapshot.data ?? [];
        final filteredEvents = _filterEvents(events);

        if (filteredEvents.isEmpty) {
          return _buildEmptyState();
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              return _buildEventCard(filteredEvents[index]);
            },
          ),
        );
      },
    );
  }

  List<EventModel> _filterEvents(List<EventModel> events) {
    if (_searchQuery.isEmpty) return events;

    return events.where((event) {
      final nameMatch = event.eventName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final locationMatch = event.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      return nameMatch || locationMatch;
    }).toList();
  }

  Widget _buildEventCard(EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(event: event),
          ),
        );
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
                Expanded(
                  child: Text(
                    event.eventName ?? 'Untitled Event',
                    style: GoogleFonts.syne(
                      color: AppColors.activeGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.activeGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Saved',
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
            if (event.date != null)
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: Colors.white.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Date: ${event.date?.day}/${event.date?.month}/${event.date?.year}',
                    style: GoogleFonts.notoSans(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on,
                    color: Colors.white.withOpacity(0.7), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location ?? 'Location TBA',
                    style: GoogleFonts.notoSans(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().shimmer(duration: 1500.ms);
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
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No saved events',
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