import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/auth_screens/auth_screen.dart';

import 'package:phuong/view/onboarding_page/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _numPages = 3;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 20.0 : 26.0,
      decoration: BoxDecoration(
        color: isActive ? const Color.fromARGB(255, 255, 0, 0) : Colors.grey.shade300,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_currentPage < _numPages - 1) _buildSkipButton(),
                Expanded(
                  child: PageView(
                    physics: const ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: <Widget>[
                      PageContent(
                        title: 'Your Local Music Scene, \nat Your Fingertips',
                        description: 'Discover and connect with talented musicians and bands right in your neighborhood.',
                        image1: 'assets/welcomepageassets/flavio-anibal-p1J1-o6nV8I-unsplash.jpg',
                        image2: 'assets/welcomepageassets/william-recinos-qtYhAQnIwSE-unsplash.jpg',
                        isSmallScreen: isSmallScreen,
                        fadeAnimation: _fadeAnimation,
                        slideAnimation: _slideAnimation,
                      ),
                      PageContent(
                        title: 'Connect with Musicians',
                        description: 'Easily find and connect with bands and musicians for your events.',
                        image1: 'assets/welcomepageassets/band-6568049.jpg',
                        image2: 'assets/welcomepageassets/singer-5467009.jpg',
                        isSmallScreen: isSmallScreen,
                        fadeAnimation: _fadeAnimation,
                        slideAnimation: _slideAnimation,
                      ),
                      PageContent(
                        title: "Ready to Rock ?",
                        description: 'Sign up now to start booking and discovering amazing musical talents',
                        image1: 'assets/welcomepageassets/josh-rocklage-qE851OTuYIk-unsplash.jpg',
                        image2: 'assets/welcomepageassets/nadia-sitova-Tlwrp8ThUg8-unsplash.jpg',
                        isSmallScreen: isSmallScreen,
                        fadeAnimation: _fadeAnimation,
                        slideAnimation: _slideAnimation,
                      ),
                    ],
                  ),
                ),
                _buildBottomSection(isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Opacity(
          opacity: 0.99,
          child: Image.asset(
            'assets/welcomepageassets/concert-601537.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: 0.5,
            child: Container(
              height: 350,
              width: 600,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () {
          _pageController.animateToPage(
            _numPages - 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
        child: const Text('Skip', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
    );
  }

  Widget _buildBottomSection(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildPageIndicator(),
          ),
          SizedBox(height: isSmallScreen ? 10.0 : 20.0),
          _buildActionButton(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isSmallScreen) {
    return ElevatedButton(
      child: Text(
        _currentPage == _numPages - 1 ? "Let's Start" : "Let's Go",
        style: GoogleFonts.slabo27px(
          fontSize: isSmallScreen ? 20.0 : 18.0,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      onPressed: () {
        if (_currentPage < _numPages - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        } else {
          Navigator.of(context).push(GentlePageTransition(page: Helo(),));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3432C),
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 13.0 : 8.0,
          horizontal: isSmallScreen ? 30.0 : 15.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.lerp(const Radius.circular(80),
                    const Radius.circular(65), 4.3) ??
                const Radius.circular(15),
            bottomLeft: const Radius.circular(15),
            bottomRight: const Radius.circular(15),
            topLeft: const Radius.circular(15),
          ),
        ),
      ),
    );
  }
}