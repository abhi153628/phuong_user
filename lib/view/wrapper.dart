import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phuong/services/auth_services.dart';

import 'package:phuong/view/auth_screens/auth_screen.dart';
import 'package:phuong/view/bottom_nav_bar.dart';



class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  FirebaseAuthServices authServices = FirebaseAuthServices();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate splash screen duration or other initializations
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

 @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return const Center(
          child: Text(
            'Something went wrong. Please try again later.',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
      }
      
      if (snapshot.hasData && snapshot.data != null) {
        // Log current user details when authenticated
        print('Authenticated User ID: ${snapshot.data!.uid}');
        print('Authenticated User Email: ${snapshot.data!.email}');
     
    

        
        return const MainScreen();
      } else {
        return const Helo();
      }
    },
  );
}}