import 'package:flutter/material.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/utils/cstm_text.dart';
import 'package:phuong/modal/event_modal.dart';

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

    return Scaffold(backgroundColor: scaffoldColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.01,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MainContentWidget(
                screenWidth: screenWidth,
                event: event,
              ),
              SizedBox(height: 20),
              EventNameWidget(
                screenWidth: screenWidth,
                event: event,
              ),
              SizedBox(height: 20),
              CstmText(text: 'Quick Outlook', fontSize: 20),
              EventDetailsCard(
                screenWidth: screenWidth,
                event: event,
              ),
            ],
          ),
        ),
      ),
    );
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
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: green, size: screenWidth * 0.04),
                  SizedBox(width: screenWidth * 0.02),
                  CstmText(
                    text: 'Bookings Open Till',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              Text(
                event.date != null
                    ? '${event.date!.day} ${_getMonthName(event.date!.month)}, '
                        '${event.date!.year}  '
                        '${event.time?.format(context) ?? "TBA"}'
                    : 'Date TBA',
                style: TextStyle(fontWeight: FontWeight.bold),
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
          color: Colors.white.withOpacity(0.2),
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
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventDetails(),
          SizedBox(width: screenWidth * 0.03),
          _buildPriceContainer(),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Expanded(
      flex: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Text(
              event.eventName ?? 'Untitled Event',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Container(
            width: double.infinity,
            child: Text(
              event.location ?? 'Location TBA',
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceContainer() {
    if (event.ticketPrice == null) return SizedBox.shrink();

    return Container(
      width: screenWidth * 0.2,
      height: screenWidth * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.orange,
      ),
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${event.ticketPrice!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Colors.white,
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
                color: Colors.white,
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
              title: 'CATEGORIES',
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
              content: event.eventRules!.join('\n'),
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
            color: const Color(0xFF2A2D31),
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