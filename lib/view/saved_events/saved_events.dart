// Now let's create the SavedEventsPage
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/view/event_detail_screen/widgets/fields_event_details_widget.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class SavedEventsPage extends StatelessWidget {
  final EventService _eventService = EventService();
  final String? userId; // You'll need to pass this from your auth service

  SavedEventsPage({Key? key,  this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildSavedEventsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
    );
  }

  Widget _buildSavedEventsList() {
    return StreamBuilder<List<EventModel>>(
      stream: _eventService.getSavedEvents(userId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading saved events',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final savedEvents = snapshot.data ?? [];

        if (savedEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border,
                    size: 64, color: Colors.white.withOpacity(0.5)),
                SizedBox(height: 16),
                Text(
                  'No saved events yet',
                  style: GoogleFonts.syne(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: savedEvents.length,
          itemBuilder: (context, index) {
            final event = savedEvents[index];
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
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1D21),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.imageUrl != null)
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          event.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.eventName ?? 'Untitled Event',
                            style: GoogleFonts.syne(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.activeGreen,
                            ),
                          ),
                          SizedBox(height: 8),
                          if (event.date != null)
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.white70),
                                SizedBox(width: 8),
                                // Text(
                                //   '${event.date!.day} ${_getMonthName(event.date!.month)} ${event.date!.year}',
                                //   style: TextStyle(color: Colors.white70),
                                // ),
                              ],
                            ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.location ?? 'Location TBA',
                                  style: TextStyle(color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}