// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:phuong/modal/event_modal.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';

// class NewEventDetailedPage extends StatelessWidget {
//   final EventModel event;

//   const NewEventDetailedPage({Key? key, required this.event}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // Animated App Bar with Image
//           SliverAppBar(
//             expandedHeight: 300,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Hero(
//                 tag: 'event-${event.eventId}',
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     CachedNetworkImage(
//                       imageUrl: event.imageUrl ?? '',
//                       fit: BoxFit.cover,
//                     ),
//                     // Gradient overlay
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.7),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Event Details
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Event Title with Animation
//                   TweenAnimationBuilder(
//                     duration: const Duration(milliseconds: 800),
//                     tween: Tween<double>(begin: 0, end: 1),
//                     builder: (context, double value, child) {
//                       return Opacity(
//                         opacity: value,
//                         child: Transform.translate(
//                           offset: Offset(0, 20 * (1 - value)),
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Text(
//                       event.eventName ?? 'Event Name',
//                       style: GoogleFonts.poppins(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Date and Time Card
//                   _buildInfoCard(
//                     icon: Icons.calendar_today,
//                     title: 'Date & Time',
//                     content: '${DateFormat('EEEE, MMMM d, y').format(event.date!)} at ${event.time?.format(context)}',
//                   ),

//                   // Location Card
//                   _buildInfoCard(
//                     icon: Icons.location_on,
//                     title: 'Location',
//                     content: event.location ?? 'TBA',
//                   ),

//                   // Price Card
//                   _buildInfoCard(
//                     icon: Icons.attach_money,
//                     title: 'Ticket Price',
//                     content: '\$${event.ticketPrice?.toStringAsFixed(2)}',
//                   ),

//                   // Description Section
//                   const SizedBox(height: 24),
//                   Text(
//                     'About Event',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     event.description ?? 'No description available',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       color: Colors.black87,
//                     ),
//                   ),

//                   // Event Rules
//                   if (event.eventRules != null && event.eventRules!.isNotEmpty) ...[
//                     const SizedBox(height: 24),
//                     Text(
//                       'Event Rules',
//                       style: GoogleFonts.poppins(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ...event.eventRules!.map((rule) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(Icons.check_circle, size: 20, color: Colors.green),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               rule,
//                               style: GoogleFonts.poppins(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )),
//                   ],

//                   // Social Links
//                   const SizedBox(height: 24),
//                   _buildSocialLinks(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomBar(context),
//     );
//   }

//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String content,
//   }) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, size: 24, color: Colors.blue),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 Text(
//                   content,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSocialLinks() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (event.instagramLink != null)
//           IconButton(
//             icon: const Icon(Icons.camera_alt),
//             onPressed: () => _launchURL(event.instagramLink!),
//           ),
//         if (event.facebookLink != null)
//           IconButton(
//             icon: const Icon(Icons.facebook),
//             onPressed: () => _launchURL(event.facebookLink!),
//           ),
//         if (event.email != null)
//           IconButton(
//             icon: const Icon(Icons.email),
//             onPressed: () => _launchURL('mailto:${event.email}'),
//           ),
//       ],
//     );
//   }

//   Widget _buildBottomBar(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               'Available Seats: ${event.seatAvailabilityCount?.toInt() ?? 0}',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Implement booking logic
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Text(
//               'Book Now',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     }
//   }
// }
