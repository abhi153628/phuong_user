import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/search_screen/search_page.dart';

class SearchBarHomeScreen extends StatefulWidget {
  const SearchBarHomeScreen({Key? key}) : super(key: key);

  @override
  State<SearchBarHomeScreen> createState() => _SearchBarHomeScreenState();
}

class _SearchBarHomeScreenState extends State<SearchBarHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: (){ Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventSearchScreen(),
          ),
        );},
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFF545f72),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.activeGreen.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.activeGreen.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.activeGreen.withOpacity(0.8),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DefaultTextStyle(
                        style: GoogleFonts.syne(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 1),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          pause: const Duration(milliseconds: 1000),
                          animatedTexts: [
                            FadeAnimatedText(
                              'Search for events...',
                              duration: const Duration(milliseconds: 5000),
                              fadeOutBegin: 0.8,
                              fadeInEnd: 0.1,
                            ),
                            FadeAnimatedText(
                              'Discover live performances',
                              duration: const Duration(milliseconds: 5000),
                              fadeOutBegin: 0.8,
                              fadeInEnd: 0.1,
                            ),
                            FadeAnimatedText(
                              'Find upcoming shows',
                              duration: const Duration(milliseconds: 5000),
                              fadeOutBegin: 0.8,
                              fadeInEnd: 0.1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
