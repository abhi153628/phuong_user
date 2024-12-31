import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';



class FirebaseAuthServices {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

   Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
        
      );
    print('Email: $email');
      print('Password: $password');
      print('Logged in User ID: ${userCredential.user?.uid}');

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _handleAuthException(e);
      throw errorMessage;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<User?> createUserEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
         _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }



  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
    //!email verfication
  Future<void>sendPasswordResetLink(String email)async{
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
    } catch (e) {
      print(e.toString());
      
    }
  }
    //! Method to get the current user's ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  //! Method to get the current user's email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  //! Method to log current user details
  void logCurrentUserDetails() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      print('Current User ID: ${currentUser.uid}');
      print('Current User Email: ${currentUser.email}');
    } else {
      print('No user is currently logged in.');
    }
  }
    Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during Google sign in';
    }
  }

  // Add sign out method for Google

}