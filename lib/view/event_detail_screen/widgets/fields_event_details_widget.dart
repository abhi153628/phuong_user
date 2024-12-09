import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/view/event_detail_screen/widgets/event_terms_condition_widget.dart';
import 'package:phuong/view/event_detail_screen/widgets/ph_no_authentication_botom_sheet.dart';
import 'package:phuong/view/event_detail_screen/widgets/seat_availibility_bottom_sheet.dart';
import 'package:phuong/view/event_organizer_view_page/event_organizer_view_page.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class EventDetailsPage extends StatelessWidget {
  final EventModel event;
  const EventDetailsPage({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: scaffoldColor,
      // Remove the bottom navigation bar from the body
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenHeight * 0.01,
              ).copyWith(
                  bottom: 100), // Add extra bottom padding for the bottom bar
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MainContentWidget(
                    screenWidth: screenWidth,
                    event: event,
                  ),
                  const SizedBox(height: 20),
                  EventNameWidget(
                    screenWidth: screenWidth,
                    event: event,
                  ),
                  const SizedBox(height: 30),
                  //!----------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Outlook',
                        style: GoogleFonts.notoSans(
                            fontSize: 15, color: white, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  EventDetailsCard(
                    screenWidth: screenWidth,
                    event: event,
                  ),
                  //! --------------------------
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Event Terms & Conditions',
                        style: GoogleFonts.notoSans(
                            fontSize: 15, color: white, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  EventTermsAndConditions(
                    eventRules: event.eventRules ?? [],
                  ),
                  // Remove _buildBottomBar from here
                ],
              ),
            ),
          ),

          // Permanent Bottom Bar positioned at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.activeGreen.withOpacity(0.7),
            AppColors.activeGreen.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.activeGreen.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigation to payment page
          HapticFeedback.lightImpact();
          // Add subtle haptic feedback
          _showBookingBottomSheet(context, event);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Book Now',
              style: GoogleFonts.syne(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingBottomSheet(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(event: event),
    );
  }

  void _showPhoneAuthBottomSheet(BuildContext context, EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PhoneAuthBottomSheet(),
        ),
      ),
    ).then((verified) {
      if (verified == true) {
        // User is verified, proceed to seat booking
        // You can add your seat booking logic here
      }
    });
  }
}

class MainContentWidget extends StatelessWidget {
  final double screenWidth;
  final EventModel event;

  const MainContentWidget({
    Key? key,
    required this.screenWidth,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      //! P A D D I N G
      padding: EdgeInsets.only(top: screenWidth * 0.05),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBackButton(context),
          _buildGradientContainer(),
          _buildBookingStatusBar(context),
          _buildDateOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildGradientContainer() {
    return Container(
      height: screenWidth * 0.99,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.blue.withOpacity(0.6),
          ],
        ),
        image: event.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(event.imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBookingStatusBar(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 320),
        child: Container(
          width: screenWidth * 0.9,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle,
                      color: AppColors.activeGreen, size: screenWidth * 0.04),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Bookings Open Until',
                    style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: white),
                  )
                ],
              ),
              Text(
                event.date != null
                    ? '${event.date!.day} ${_getMonthName(event.date!.month)}, '
                        '${event.date!.year}  '
                        '${event.time?.format(context) ?? "TBA"}'
                    : 'Date TBA',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateOverlay() {
    if (event.date == null) return SizedBox.shrink();

    return Positioned(
      right: screenWidth * 0.04,
      top: screenWidth * 0.04,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          '${_getDayName(event.date!.weekday)}\n'
          '${event.date!.day} ${_getMonthName(event.date!.month)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class EventNameWidget extends StatelessWidget {
  final double screenWidth;
  final EventModel event;

  const EventNameWidget({
    Key? key,
    required this.screenWidth,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventDetails(context),
          SizedBox(width: screenWidth * 0.03),
          _buildPriceContainer(),
        ],
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            //! E V E N T  N A M E
            child: Text(
              event.eventName ?? 'Untitled Event',
              style: GoogleFonts.syne(
                  fontSize: screenWidth * 0.05,
                  color: Colors.white,
                  height: 1.2,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Container(
            width: double.infinity,
            //! E V E N T   L O C A T I O N
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.10,
                  height: screenWidth * 0.10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D31),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: screenWidth * 0.05,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  event.location ?? 'Location TBA',
                  style: GoogleFonts.notoSans(
                    fontSize: screenWidth * 0.04,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          //! O R G A N I Z E R   N A M E
          Container(
              width: double.infinity,
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.10,
                    height: screenWidth * 0.10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2D31),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: screenWidth * 0.05,
                    ),
                  ),
                  SizedBox(width: 10),
                  // In your event detail page widget
                  GestureDetector(
                    onTap: () {
                      if (event.organizerId != null &&
                          event.organizerId!.isNotEmpty) {
                            log('${event.organizerId}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserOrganizerProfileScreen(
                              organizerId: event.organizerId!,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Organizer information not available')),
                        );
                      }
                    },
                    child: Text(
                      event.organizerName ?? 'Unknown Organizer',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceContainer() {
    if (event.ticketPrice == null) return SizedBox.shrink();

    return Container(
      width: screenWidth * 0.29,
      height: screenWidth * 0.19,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
      ),
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            //! P R I C E
            child: Text(
              '\₹ ${event.ticketPrice!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                color: AppColors.activeGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '/person',
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailsCard extends StatelessWidget {
  final double screenWidth;
  final EventModel event;

  const EventDetailsCard({
    Key? key,
    required this.screenWidth,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            icon: Icons.access_time,
            title: 'EVENT TIMINGS',
            content: _getEventTimings(context),
          ),
          SizedBox(height: screenWidth * 0.04),
          if (event.genreType != null) ...[
            _buildSection(
              icon: Icons.category,
              title: 'CATEGORY',
              content: event.genreType!,
            ),
            SizedBox(height: screenWidth * 0.04),
          ],
          _buildSection(
            icon: Icons.person_outline,
            title: 'ORGANISED BY',
            content: event.organizerName ?? 'TBA',
          ),
          if (event.eventRules?.isNotEmpty == true) ...[
            SizedBox(height: screenWidth * 0.04),
            _buildSection(
              icon: Icons.info_outline,
              title: 'IMPORTANT EVENT NOTES',
              content: event.specialInstruction!,
            ),
          ],
        ],
      ),
    );
  }

  String _getEventTimings(BuildContext context) {
    if (event.date == null || event.time == null) return 'TBA';

    final startDateTime = DateTime(
      event.date!.year,
      event.date!.month,
      event.date!.day,
      event.time!.hour,
      event.time!.minute,
    );

    final endDateTime = event.eventDurationTime != null
        ? startDateTime.add(Duration(hours: event.eventDurationTime!.toInt()))
        : null;

    final startFormatted =
        '${_getDayName(startDateTime.weekday)}, ${startDateTime.day} ${_getMonthName(startDateTime.month)} '
        '${event.time!.format(context)}';

    if (endDateTime == null) return startFormatted;

    return '$startFormatted - '
        '${_getDayName(endDateTime.weekday)}, ${endDateTime.day} ${_getMonthName(endDateTime.month)} '
        '${TimeOfDay.fromDateTime(endDateTime).format(context)}';
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth * 0.10,
          height: screenWidth * 0.10,
          decoration: BoxDecoration(
            color: Color(0xFF2A2D31),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white70,
            size: screenWidth * 0.05,
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: screenWidth * 0.030,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: screenWidth * 0.001),
              Text(
                content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Utility functions
String _getDayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'MON';
    case DateTime.tuesday:
      return 'TUE';
    case DateTime.wednesday:
      return 'WED';
    case DateTime.thursday:
      return 'THU';
    case DateTime.friday:
      return 'FRI';
    case DateTime.saturday:
      return 'SAT';
    case DateTime.sunday:
      return 'SUN';
    default:
      return '';
  }
}

String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'JAN';
    case 2:
      return 'FEB';
    case 3:
      return 'MAR';
    case 4:
      return 'APR';
    case 5:
      return 'MAY';
    case 6:
      return 'JUN';
    case 7:
      return 'JUL';
    case 8:
      return 'AUG';
    case 9:
      return 'SEP';
    case 10:
      return 'OCT';
    case 11:
      return 'NOV';
    case 12:
      return 'DEC';
    default:
      return '';
  }
}
