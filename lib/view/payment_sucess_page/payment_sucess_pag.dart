// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:intl/intl.dart';
// import 'package:phuong/view/homepage/homepage.dart';

// class EventModel {
//   final String? eventName;
//   final DateTime? date;

//   EventModel({this.eventName, this.date});
// }

// class PaymentSuccessScreen extends StatefulWidget {
//   final EventModel event;
//   final int selectedSeats;
//   final double totalAmount;

//   const PaymentSuccessScreen({
//     Key? key,
//     required this.event,
//     required this.selectedSeats,
//     required this.totalAmount,
//   }) : super(key: key);

//   @override
//   _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
// }

// class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black,
//                     Colors.black.withOpacity(0.9),
//                     const Color(0xFFAFEB2B).withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     minHeight: constraints.maxHeight,
//                     minWidth: constraints.maxWidth,
//                   ),
//                   child: IntrinsicHeight(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const SizedBox(height: 40),
//                           // Success Animation
//                           ScaleTransition(
//                             scale: Tween<double>(begin: 0.5, end: 1.0).animate(
//                               CurvedAnimation(
//                                 parent: _controller,
//                                 curve: Curves.elasticOut,
//                               ),
//                             ),
//                             child: SizedBox(
//                               width: constraints.maxWidth * 0.6,
//                               height: constraints.maxWidth * 0.6,
//                               child: FittedBox(
//                                 fit: BoxFit.contain,
//                                 child: Lottie.asset(
//                                   'assets/animations/Animation - 1732732261990 (1).json',
//                                   repeat: false,
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 24),

//                           // Success Message
//                           FittedBox(
//                             fit: BoxFit.scaleDown,
//                             child: Text(
//                               'Payment Successful!',
//                               style: GoogleFonts.syne(
//                                 color: const Color(0xFFAFEB2B),
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 24),

//                           // Event Details Container
//                           Container(
//                             width: double.infinity,
//                             constraints: BoxConstraints(
//                               maxWidth: constraints.maxWidth * 0.9,
//                             ),
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.black87,
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(
//                                 color: const Color(0xFFAFEB2B).withOpacity(0.3),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Event Name
//                                 Text(
//                                   widget.event.eventName ?? 'Event Name',
//                                   style: GoogleFonts.notoSans(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),

//                                 const SizedBox(height: 16),

//                                 // Details
//                                 _buildDetailRow('Seats Booked:', 
//                                   '${widget.selectedSeats}'),
//                                 _buildDetailRow('Total Amount:', 
//                                   '₹${widget.totalAmount.toStringAsFixed(2)}'),
//                                 _buildDetailRow('Date & Time:', 
//                                   _formatDateTime(widget.event.date)),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(height: 32),

//                           // Back to Home Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.of(context).pushAndRemoveUntil(
//                                   MaterialPageRoute(
//                                     builder: (context) => const Homepage(),
//                                   ),
//                                   (route) => false,
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFAFEB2B),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Back to Home',
//                                 style: GoogleFonts.syne(
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(
//               label,
//               style: GoogleFonts.notoSans(
//                 color: Colors.grey,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               value,
//               style: GoogleFonts.notoSans(
//                 color: label.contains('Total') 
//                   ? const Color(0xFFAFEB2B)
//                   : Colors.white70,
//                 fontSize: label.contains('Total') ? 18 : 16,
//                 fontWeight: label.contains('Total') 
//                   ? FontWeight.bold 
//                   : FontWeight.normal,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(DateTime? date) {
//     if (date == null) return 'Not Specified';
//     return DateFormat('dd MMM yyyy, HH:mm').format(date);
//   }
// }

