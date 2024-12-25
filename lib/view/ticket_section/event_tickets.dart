import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:intl/intl.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/booking_modal.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/modal/user_profile_modal.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:io';

class EventTicketScreen extends StatelessWidget {
  final BookingModel booking;
  final EventModel event;
  final GlobalKey _globalKey = GlobalKey();
  final UserProfileService _userProfileService = UserProfileService();

  EventTicketScreen({
    Key? key,
    required this.booking,
    required this.event,
  }) : super(key: key);

  // Add GlobalKey for RepaintBoundary

  // Function to capture and share screenshot
   Future<void> _shareTicket() async {
    try {
      // Delay to ensure widget is rendered
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find the RepaintBoundary
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Convert to image with higher quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // Convert to bytes
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/ticket.png');

        // Write file
        await file.writeAsBytes(pngBytes);

        // Share file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'My Event Ticket for ${booking.eventName}',
        );
      }
    } catch (e) {
      debugPrint('Error sharing ticket: $e');
      // Show error message to user
      ScaffoldMessenger.of(_globalKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Failed to share ticket. Please try again.'),
        ),
      );
    }
  }
  @override
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareTicket),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _globalKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
              // Status Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ticket Confirmed',
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
          
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Movie Info Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Movie Poster
                              Container(
                                // Add elevation with a shadow
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: event.imageUrl!,
                                    height: 120,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 120,
                                      width: 80,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 120,
                                      width: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.movie,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Movie Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.eventName,
                                      style: GoogleFonts.syne(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.location!,
                                      style: GoogleFonts.notoSans(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM d, yyyy')
                                          .format(event.date ?? DateTime.now())
                                          .toUpperCase(), // Convert DateTime to formatted string
                                      style: GoogleFonts.notoSans(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Ticket Divider
                    SizedBox(
                      height: 40,
                      child: Stack(
                        children: [
                          // Left Circle
                          Positioned(
                            left: -20,
                            top: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          // Right Circle
                          Positioned(
                            right: -20,
                            top: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          // Dotted Line
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 95, right: 95,top: 5,bottom: 5),
                                      child: Text(
                                        'Confirmed Ticket',
                                        style: GoogleFonts.notoSans(
                                            fontWeight: FontWeight.bold),
                                      ))),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Ticket Details
                    Column(
                      children: [
                        Text(
                          '₹ ${NumberFormat('#,##,###').format(booking.totalPrice)}', 
                          style: GoogleFonts.notoSans(
                            color: Colors
                                .black87, 
                            fontSize:
                                20, 
                            fontWeight: FontWeight
                                .w600, 
                            letterSpacing:
                                0.5, 
                          ),
                        ),
                                         
                        // Seats Booked
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text(
                              'Seats Booked :',
                              style: GoogleFonts.notoSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),SizedBox(width: 5,),
                            Text(
                              booking.seatsBooked.toString(),
                              style: GoogleFonts.notoSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                    
                        // QR Code
                        QrImageView(
                          data: booking.bookingId!,
                          version: QrVersions.auto,
                          size: 130,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BOOKING ID: ${booking.bookingId}',
                          style: GoogleFonts.sourceCodePro(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Cancel Notice
                        Text(
                          'This event is non-refundable and cancellations are not allowed.',
                          style: GoogleFonts.notoSans(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Action Buttons
                       
                        // Price Details
                        const Divider(),
                        // const SizedBox(height: 16),
                        Container(decoration: BoxDecoration(color: black.withOpacity(0.05)),
                          child: Column(
                            children: [
                              _buildPriceRow(
                                'Total Amount',
                                booking.totalPrice.toString(),
                                isTotal: true,
                              ),
                                const SizedBox(height: 8),
                        _buildPriceRow(
                          'Ticket(s) price (${booking.seatsBooked})',
                          booking.totalPrice.toString(),
                        ),
                        _buildPriceRow('Convenience fee', 'null value'),
                        _buildPriceRow('Discount', 'null value'),
                            ],
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
      ),
     ) );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              color: Colors.grey[800],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.notoSans(
              color: Colors.grey[800],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

