import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/view/onboarding_page/widgets/image_container.dart';

class PageContent extends StatelessWidget {
  final String title;
  final String description;
  final String image1;
  final String image2;
  final bool isSmallScreen;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const PageContent({
    Key? key,
    required this.title,
    required this.description,
    required this.image1,
    required this.image2,
    required this.isSmallScreen,
    required this.fadeAnimation,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 35.0 : 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: ImageContainer(image1: image1, image2: image2),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 70.0 : 30.0),
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.philosopher(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 25.0 : 29.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 10.0 : 15.0),
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  description,
                  style: GoogleFonts.faunaOne(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 12.0 : 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}