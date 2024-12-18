// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:phuong/modal/event_modal.dart';
// import 'package:phuong/modal/organizer_profile_modal.dart';
// import 'package:phuong/services/organizer_profile_firebase_service.dart';
// import 'package:phuong/services/user_profile_firebase_service.dart';
// import 'package:phuong/view/chat_section/chat_listing_screen.dart';
// import 'package:phuong/view/chat_section/chat_view_screen.dart';
// import 'package:phuong/view/event_detail_screen/widgets/fields_event_details_widget.dart';

// import 'package:phuong/view/homepage/homepage.dart';
// import 'package:phuong/view/homepage/text_styles.dart';
// import 'package:phuong/view/homepage/widgets/colors.dart';
// import 'package:phuong/view/onboarding_page/onboarding_page.dart';
// import 'package:phuong/view/settings/settings_page.dart';
// import 'package:phuong/view/social_feed/widgets/main_post_screen.dart';
// import 'package:phuong/view/welcomepage/welcomes_screen.dart';


// class BottomNavbar extends StatefulWidget {
//   const BottomNavbar({super.key});

//   @override
//   State<BottomNavbar> createState() => _BottomNavbarState();
// }

// // var to track current index or (page)
// var currentIndex = 0;

// class _BottomNavbarState extends State<BottomNavbar> {
//    final UserProfileService _organizerService = UserProfileService();
//     late Stream<List<Post>> _allPostsStream;
//      @override
//   void initState() {
//     super.initState();
//     // Initialize the stream for all posts
//     _allPostsStream = _organizerService.fetchAllPosts();
//   }
//   static  List<Widget> screens = [
//     DiscoverScreen(),
//    FeedPage(postsStream: _allPostsStream,),
//     UserChatListScreen(),
//     SettingsPage()
   
//   ];

//   static const List<String> listOfStrings = [
//     'Home',
//     'Favorite',
//     'Cart',
//     'Account'
//   ];

//   static const List<IconData> listOfIcons = [
//     Icons.home_sharp,
//     Icons.favorite_sharp,
//     Icons.shopping_cart_rounded,
//     Icons.manage_accounts_sharp
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
//     double displayWidth = MediaQuery.sizeOf(context).width;

//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 800),
//       switchInCurve: Curves.easeInOut,
//       switchOutCurve: Curves.easeInOut,
//       transitionBuilder: (Widget child, Animation<double> animation) {
//         return FadeTransition(
//           opacity: CurvedAnimation(
//             parent: animation,
//             curve: Curves.easeInOut,
//           ),
//           child: ScaleTransition(
//             scale: Tween<double>(
//               begin: 0.98,
//               end: 1.0,
//             ).animate(CurvedAnimation(
//               parent: animation,
//               curve: Curves.easeInOut,
//             )),
//             child: child,
//           ),
//         );
//       },
//       child: Scaffold(
//         key: ValueKey(isLightTheme), // Key based on theme to trigger animation
//         body: screens[currentIndex],
//         backgroundColor: AppColors.scafoldColor,
//         bottomNavigationBar: Container(
//           margin: EdgeInsets.symmetric(
//               vertical: displayWidth * 0.02, horizontal: displayWidth * 0.03),
//           height: displayWidth * .15,
//           decoration: BoxDecoration(
//               color: isLightTheme
//                   ? AppColors.activeGreen
//                   : AppColors.activeGreen,
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black.withOpacity(.1),
//                     blurRadius: 30,
//                     offset: const Offset(0, 10))
//               ],
//               borderRadius: BorderRadius.circular(50)),
//           child: ListView.builder(
//               itemCount: 4,
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
//               itemBuilder: (context, index) => InkWell(
//                     onTap: () {
//                       setState(() {
//                         currentIndex = index;
//                         HapticFeedback.heavyImpact();
//                       });
//                     },
//                     splashColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                     child: Stack(
//                       children: [
//                         AnimatedContainer(
//                           duration: const Duration(seconds: 1),
//                           curve: Curves.fastLinearToSlowEaseIn,
//                           width: index == currentIndex
//                               ? displayWidth * .32
//                               : displayWidth * .18,
//                           alignment: Alignment.center,
//                           child: AnimatedContainer(
//                             duration: const Duration(seconds: 1),
//                             curve: Curves.fastLinearToSlowEaseIn,
//                             height:
//                                 index == currentIndex ? displayWidth * .12 : 0,
//                             width:
//                                 index == currentIndex ? displayWidth * .32 : 0,
//                             decoration: BoxDecoration(
//                                 color: index == currentIndex
//                                     ? isLightTheme
//                                         ? AppColors.scafoldColor
//                                         : AppColors.scafoldColor
//                                     : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(50)),
//                           ),
//                         ),
//                         AnimatedContainer(
//                           duration: const Duration(seconds: 1),
//                           curve: Curves.fastLinearToSlowEaseIn,
//                           width: index == currentIndex
//                               ? displayWidth * .31
//                               : displayWidth * .18,
//                           alignment: Alignment.center,
//                           child: Stack(children: [
//                             Row(
//                               children: [
//                                 AnimatedContainer(
//                                   duration: const Duration(seconds: 1),
//                                   curve: Curves.fastLinearToSlowEaseIn,
//                                   width: index == currentIndex
//                                       ? displayWidth * .12
//                                       : 0,
//                                 ),
//                                 AnimatedOpacity(
//                                   opacity: index == currentIndex ? 1 : 0,
//                                   duration: const Duration(seconds: 1),
//                                   curve: Curves.fastLinearToSlowEaseIn,
//                                   child: Text(
//                                       index == currentIndex
//                                           ? listOfStrings[index]
//                                           : '',style: GoogleFonts.syne(color: Colors.white,letterSpacing: 0.1,fontSize: 15,fontWeight: FontWeight.bold),
//                                      ),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 AnimatedContainer(
//                                   duration: const Duration(seconds: 1),
//                                   curve: Curves.fastLinearToSlowEaseIn,
//                                   width: index == currentIndex
//                                       ? displayWidth * .03
//                                       : 20,
//                                 ),
//                                 Icon(
//                                   listOfIcons[index],
//                                   size: displayWidth * .076,
//                                   color: index == currentIndex
//                                       ? AppColors.activeGreen
//                                       : AppColors.scafoldColor,
//                                 ),
//                               ],
//                             )
//                           ]),
//                         ),
//                       ],
//                     ),
//                   )),
//         ),
//       ),
//     );
//   }
// }