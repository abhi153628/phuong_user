// // constants.dart
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:phuong/modal/social_post_modal.dart';
// import 'package:shimmer/shimmer.dart';

// class AppTheme {
//   static const Color primaryGreen = Color(0xFFAFEB2B);
//   static const Color backgroundColor = Colors.black;
  
//   static final ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: backgroundColor,
//     fontFamily: 'NotoSans',
//     primaryColor: primaryGreen,
//   );
// }
// // widgets/social_post_card.dart


// class SocialPostCard extends StatefulWidget {
//   final Post post;
  
//   const SocialPostCard({Key? key, required this.post}) : super(key: key);

//   @override
//   State<SocialPostCard> createState() => _SocialPostCardState();
// }

// class _SocialPostCardState extends State<SocialPostCard> 
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
    
//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
    
//     _controller.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Card(
//         color: Colors.grey[900],
//         margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             ListTile(
//               leading: CircleAvatar(
//                 backgroundImage: CachedNetworkImageProvider(
//                   widget.post.organizerProfilePic,
//                 ),
//               ),
//               title: Text(
//                 widget.post.organizerName,
//                 style: TextStyle(
//                   fontFamily: 'Syne',
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               trailing: Icon(Icons.more_vert),
//             ),
            
//             // Image
//             Hero(
//               tag: widget.post.id,
//               child: CachedNetworkImage(
//                 imageUrl: widget.post.imageUrl,
//                 placeholder: (context, url) => ShimmerLoading(),
//                 errorWidget: (context, url, error) => Icon(Icons.error),
//                 fit: BoxFit.cover,
//               ),
//             ),
            
//             // Actions
//             Padding(
//               padding: EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   _buildActionButton(Icons.favorite_border, widget.post.likes),
//                   SizedBox(width: 16),
//                   _buildActionButton(Icons.comment_outlined, widget.post.comments),
//                   SizedBox(width: 16),
//                   _buildActionButton(Icons.share_outlined, widget.post.shares),
//                 ],
//               ),
//             ),
            
//             // Description
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Text(
//                 widget.post.description,
//                 style: TextStyle(fontFamily: 'NotoSans'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(IconData icon, int count) {
//     return Row(
//       children: [
//         Icon(icon, color: AppTheme.primaryGreen),
//         SizedBox(width: 4),
//         Text('$count'),
//       ],
//     );
//   }
// }


// class ShimmerLoading extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[900]!,
//       highlightColor: AppTheme.primaryGreen.withOpacity(0.1),
//       child: Container(
//         height: 300,
//         color: Colors.white,
//       ),
//     );
//   }
// }
