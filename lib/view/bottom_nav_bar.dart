import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/view/chat_section/chat_listing_screen/chat_listing_screen.dart';
import 'package:phuong/view/homepage/homepage.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/post_feed_page/post_feed_page.dart';
import 'package:phuong/view/settings_section/settings_page.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Move currentIndex inside the State class
  int currentIndex = 0;
  
  final UserOrganizerProfileService _organizerService = UserOrganizerProfileService();
  late Stream<List<Post>> _allPostsStream;
  
  // Move screens to a late initialized list
  late final List<Widget> screens;

  // Constants can remain static
  static const List<String> listOfStrings = [
    'Home',
    'Posts',
    'Chat',
    'Account'
  ];

  static const List<IconData> listOfIcons = [
    Icons.home_sharp,
    Icons.image_search,
    Icons.forum,
    Icons.manage_accounts_sharp
   
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the stream
    _allPostsStream = _organizerService.fetchAllPosts();
    screens = [
      const Homepage(),
      FeedPage(postsStream: _allPostsStream, ),
      UserChatListScreen(),
SettingsPage()
    ];
  }

  @override
 Widget build(BuildContext context) {
  final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
  double displayWidth = MediaQuery.sizeOf(context).width;
  
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.98,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
      child: Scaffold(
        key: ValueKey(isLightTheme),
      
     body: screens[currentIndex],
        backgroundColor: AppColors.scafoldColor,
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + displayWidth * 0.02,
            left: displayWidth * 0.03,
            right: displayWidth * 0.03,
            top: displayWidth * 0.02
          ),
          height: displayWidth * .15,
          decoration: BoxDecoration(
              color: isLightTheme
                  ? AppColors.activeGreen
                  : AppColors.activeGreen,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10))
              ],
              borderRadius: BorderRadius.circular(50)),
          child: ListView.builder(
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
              itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                        HapticFeedback.heavyImpact();
                      });
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn,
                          width: index == currentIndex
                              ? displayWidth * .32
                              : displayWidth * .18,
                          alignment: Alignment.center,
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            height:
                                index == currentIndex ? displayWidth * .12 : 0,
                            width:
                                index == currentIndex ? displayWidth * .32 : 0,
                            decoration: BoxDecoration(
                                color: index == currentIndex
                                    ? isLightTheme
                                        ? AppColors.scafoldColor
                                        : AppColors.scafoldColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn,
                          width: index == currentIndex
                              ? displayWidth * .31
                              : displayWidth * .18,
                          alignment: Alignment.center,
                          child: Stack(children: [
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  width: index == currentIndex
                                      ? displayWidth * .12
                                      : 0,
                                ),
                                AnimatedOpacity(
                                  opacity: index == currentIndex ? 1 : 0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  child: Text(
                                      index == currentIndex
                                          ? listOfStrings[index]
                                          : '',style: GoogleFonts.syne(color: Colors.white,letterSpacing: 0.1,fontSize: 15,fontWeight: FontWeight.bold),
                                     ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  width: index == currentIndex
                                      ? displayWidth * .03
                                      : 20,
                                ),
                                Icon(
                                  listOfIcons[index],
                                  size: displayWidth * .076,
                                  color: index == currentIndex
                                      ? AppColors.activeGreen
                                      : AppColors.scafoldColor,
                                ),
                              ],
                            )
                          ]),
                        ),
                      ],
                    ),
                  )),
        ),
      ),
   ) );
  }
}