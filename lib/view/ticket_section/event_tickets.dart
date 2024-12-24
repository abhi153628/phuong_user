// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dotted_line/dotted_line.dart';
// import 'package:phuong/modal/booking_modal.dart';
// import 'package:phuong/modal/event_modal.dart';
// import 'package:phuong/view/homepage/widgets/colors.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'dart:ui' as ui;
// import 'dart:io';

// class EventTicketScreen extends StatelessWidget {
//   final BookingModel booking;
//   final EventModel event;
//   final GlobalKey _globalKey = GlobalKey();

//   EventTicketScreen({
//     Key? key,
//     required this.booking,
//     required this.event,
//   }) : super(key: key);

//   // Add GlobalKey for RepaintBoundary


//   // Function to capture and share screenshot
//   Future<void> _shareTicket() async {
//     try {
//       // Find the RepaintBoundary
//       RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

//       // Convert to image
//       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
//       if (byteData != null) {
//         // Convert to bytes
//         Uint8List pngBytes = byteData.buffer.asUint8List();
        
//         // Get temporary directory
//         final tempDir = await getTemporaryDirectory();
//         final file = File('${tempDir.path}/ticket.png');
        
//         // Write file
//         await file.writeAsBytes(pngBytes);
        
//         // Share file
//         await Share.shareXFiles(
//           [XFile(file.path)],
//           text: 'My Event Ticket',
//         );
//       }
//     } catch (e) {
//       debugPrint('Error sharing ticket: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.share, color: AppColors.white),
//             onPressed: _shareTicket,
//           ),
//         ],
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: RepaintBoundary(
//           key: _globalKey,
//           child: Container(
//             color: Colors.black,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   // Status Bar
//                   Container(
//                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: AppColors.activeGreen.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.check_circle,
//                           color: AppColors.activeGreen,
//                           size: 16,
//                         ),
//                         SizedBox(width: 8),
//                     Text(
//                       'Ticket Confirmed',
//                       style: GoogleFonts.notoSans(
//                         color: AppColors.activeGreen,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 24),
//               // Ticket Card
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[900],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   children: [
//                     // Event Header
//                     Container(
//                       width: 800,

//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.black, Colors.grey[900]!],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                       ),
//                       padding: EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'TECH SUMMIT 2024',
//                             style: GoogleFonts.syne(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.activeGreen,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'The Future of Technology',
//                             style: GoogleFonts.notoSans(
//                               color: Colors.grey[400],
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Dotted Line Separator
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: DottedLine(
//                         direction: Axis.horizontal,
//                         lineLength: double.infinity,
//                         lineThickness: 1.0,
//                         dashLength: 4.0,
//                         dashColor: Colors.grey[700]!,
//                         dashGapLength: 4.0,
//                       ),
//                     ),
//                     // Ticket Details
//                     Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           // Primary Details Grid
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TicketDetailBox(
//                                   title: 'DATE',
//                                   value: 'DEC 25, 2024',
//                                   icon: Icons.calendar_today,
//                                 ),
//                               ),
//                               SizedBox(width: 16),
//                               Expanded(
//                                 child: TicketDetailBox(
//                                   title: 'TIME',
//                                   value: '10:00 AM',
//                                   icon: Icons.access_time,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 16),
//                           // Venue Information
//                           Container(
//                             padding: EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.location_on,
//                                       color: AppColors.activeGreen,
//                                       size: 20,
//                                     ),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'VENUE',
//                                       style: GoogleFonts.syne(
//                                         color: Colors.grey[400],
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Tech Hub Convention Center',
//                                   style: GoogleFonts.notoSans(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 Text(
//                                   '123 Innovation Street, Silicon Valley, CA 94025',
//                                   style: GoogleFonts.notoSans(
//                                     color: Colors.grey[400],
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 24),

//                           Text(
//                             '#TICKET-2024-001',
//                             style: GoogleFonts.notoSans(
//                               color: AppColors.grey,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 16),
//                           // Attendee Information
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 2),
//                             child: DottedLine(
//                               direction: Axis.horizontal,
//                               lineLength: double.infinity,
//                               lineThickness: 1.0,
//                               dashLength: 5.0,
//                               dashColor: Colors.grey[700]!,
//                               dashGapLength: 4.0,
//                             ),
//                           ),
//                           SizedBox(height: 16),
//                           Container(
//                             padding: EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.grey[800]!,
//                                 width: 1,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'ATTENDEE DETAILS',
//                                   style: GoogleFonts.syne(
//                                     color: Colors.grey[400],
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'John Doe',
//                                   style: GoogleFonts.notoSans(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 Text(
//                                   'john.doe@example.com',
//                                   style: GoogleFonts.notoSans(
//                                     color: Colors.grey[400],
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//         ))  );
//   }
// }

// class TicketDetailBox extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;

//   const TicketDetailBox({
//     Key? key,
//     required this.title,
//     required this.value,
//     required this.icon,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 icon,
//                 color: AppColors.activeGreen,
//                 size: 20,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 title,
//                 style: GoogleFonts.syne(
//                   color: Colors.grey[400],
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: GoogleFonts.notoSans(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TicketInfo extends StatelessWidget {
//   final String label;
//   final String value;

//   const TicketInfo({
//     Key? key,
//     required this.label,
//     required this.value,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.syne(
//             color: Colors.grey[400],
//             fontSize: 12,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           value,
//           style: GoogleFonts.notoSans(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }
