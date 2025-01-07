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
      // First check if email exists
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'This email address is already registered. Please try signing in instead, or use a different email address.'
        );
      }
      
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
      await _googleSignIn.signOut();
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
        return e.message ?? 'This email address is already registered. Please try signing in instead, or use a different email address.';
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

  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

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

      // Check if email already exists with different auth provider
      final methods = await _auth.fetchSignInMethodsForEmail(googleUser.email);
      if (methods.isNotEmpty && !methods.contains('google.com')) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'This email is already registered with a different sign-in method. Please use your existing account.'
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during Google sign in';
    }
  }
}