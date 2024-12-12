// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/view/auth_screens/auth_screen.dart';
import 'package:phuong/view/homepage/homepage.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/signup_page/signup_page.dart';
import 'package:phuong/view/welcomepage/widgets/widgets.dart';

class WelcomesScreen extends StatelessWidget {
  const WelcomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
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
              top: 50,
              child: Text(
                    'Phuong',
                    style: GoogleFonts.greatVibes(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),),
          Positioned(
              bottom: 0,
              child: Container(
                height: h * 0.6,
                width: w,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Colors.black38,
                      Colors.black,
                      Colors.black
                    ], begin: Alignment.topCenter, end: Alignment.center)),
                child: Column(
                  children: [
                    const Spacer(),
                     Text(
                      "Vibe. Connect. Live Only on Phuong",
                      textScaleFactor: 2.5,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.syne(
                  color: AppColors.activeGreen, fontSize: 12,fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Discover the Rhythm, Connect with the Talent, Experience the Music",
                      textScaleFactor: 1.1,
                      textAlign: TextAlign.center,
                      style:GoogleFonts.notoSans(color: const Color.fromARGB(255, 139, 139, 139))
                    ),
                    const SizedBox(height: 50),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>  Helo()),
                        );
                      },
                      child: Container(
                        height: 70,
                        width: w * 0.99,
                        margin:  EdgeInsets.only(
                            bottom: 20, left: 20, right: 20),
                        decoration: const BoxDecoration(
                          color: AppColors.activeGreen,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child:  Center(
                          child: Text(
                            "Book Your Band",
                            textScaleFactor: 1.3,
                            style: GoogleFonts.syne(
                  color: AppColors.scafoldColor, fontSize: 18,fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
