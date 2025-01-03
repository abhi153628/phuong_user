// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/view/auth_screens/auth_screen.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/welcomepage/widgets/widgets.dart';

class WelcomesScreen extends StatelessWidget {
  const WelcomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                top: -10,
                left: -160,
                child: Row(
                  children: [
                    ScrollingImages(startingIndex: 0),
                    ScrollingImages(startingIndex: 1),
                    ScrollingImages(startingIndex: 2),
                  ],
                ),
              ),
              Positioned(
                top: size.height * 0.05,
                child: Text(
                  'Phuong',
                  style: GoogleFonts.greatVibes(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: size.height * 0.6,
                  width: size.width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black38,
                        Colors.black,
                        Colors.black
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.15),
                      Text(
                        "Vibe. Connect. Live \nOnly on Phuong",
                        style: GoogleFonts.syne(
                          color: AppColors.activeGreen,
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                        child: Text(
                          "Discover the Rhythm, Connect with the Talent, Experience the Music",
                          style: GoogleFonts.notoSans(
                            color: const Color.fromARGB(255, 139, 139, 139),
                            fontSize: size.width * 0.05,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Helo()),
                          );
                        },
                        child: Container(
                          height: size.height * 0.08,
                          width: size.width * 0.8,
                          margin: EdgeInsets.only(
                            bottom: size.height * 0.03,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.activeGreen,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Center(
                            child: Text(
                              "Book Your Band",
                              style: GoogleFonts.syne(
                                color: AppColors.scafoldColor,
                                fontSize: size.width * 0.050,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}