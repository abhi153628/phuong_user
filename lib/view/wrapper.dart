import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/services/auth_services.dart';
import 'package:phuong/view/bottom_nav_bar.dart';
import 'package:phuong/view/welcomepage/welcomes_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with SingleTickerProviderStateMixin {
  FirebaseAuthServices authServices = FirebaseAuthServices();
  bool _isLoading = true;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), 
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start the Lottie animation
    _lottieController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: black,
        body: Center(
          child: Lottie.asset(
            'assets/animations/Animation - 1724667979110 (1).json',
            controller: _lottieController,
            onLoaded: (composition) {
              // Update controller duration to match animation duration
              _lottieController.duration = composition.duration;
              // Restart the animation with correct duration
              _lottieController.forward(from: 0);
            },
            height: 400, // You can adjust this value
            fit: BoxFit.contain,
            repeat: false,
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Scaffold(
            backgroundColor: black,
            body: Center(
              child: Lottie.asset('assets/animations/Animation - 1736144056346.json'),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: black,
            body: Center(
              child: Text(
                'Something went wrong. Please try again later.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          print('Authenticated User ID: ${snapshot.data!.uid}');
          print('Authenticated User Email: ${snapshot.data!.email}');
          return const MainScreen();
        } else {
          return const WelcomesScreen();
        }
      },
    );
  }
}