import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/homepage/homepage.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

// Move enum to top-level
enum AuthenticationState {
  phoneInput,
  otpInput,
  loading
}

class PhoneAuthBottomSheet extends StatefulWidget {
  

  const PhoneAuthBottomSheet({Key? key,}) : super(key: key);

  @override
  _PhoneAuthBottomSheetState createState() => _PhoneAuthBottomSheetState();
}

class _PhoneAuthBottomSheetState extends State<PhoneAuthBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;
  
  AuthenticationState _currentState = AuthenticationState.phoneInput;
  String? _errorMessage;

  void _sendOTP() async {
    //? Validating phone number
    String phoneNumber = '+91${_phoneController.text.trim()}'; //?  Indian phone numbers
    
    if (phoneNumber.length != 13) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number';
      });
      return;
    }

    setState(() {
      _currentState = AuthenticationState.loading;
      _errorMessage = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          //? Auto-sign in on Android
          // await _auth.signInWithCredential(credential);
          _proceedToBooking();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            // !THERE IS VERFICATION OF FIREBASE ERROR , SO MANUALY IAM NAVIGATING TO OTP SECTION
             
            // _errorMessage = 'Verification Failed: ${e.message}';

            // _currentState = AuthenticationState.phoneInput;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _currentState = AuthenticationState.otpInput;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: const Duration(minutes: 2),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _currentState = AuthenticationState.phoneInput;
      });
    }
  }

  void _verifyOTP() async {
  String otp = _otpController.text.trim();

  // Validate OTP length
  if (otp.length != 6) {
    setState(() {
      _errorMessage = 'Please enter a valid 6-digit OTP';
    });

    
  }
  else{
    //! N A V I G A T I O N  TO  P A Y M E N T   G A T E W A Y
     Navigator.of(context).pushReplacement(
        GentlePageTransition(page: DiscoverScreen(), ),
      );
  }

  setState(() {
    _currentState = AuthenticationState.loading;
    _errorMessage = null;
  });

  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    // Sign in with the credential
    await _auth.signInWithCredential(credential);
    
    // Proceed to booking or any other screen
    _proceedToBooking();
  } catch (e) {
    setState(() {
      _errorMessage = 'Invalid OTP. Please try again.';
      _currentState = AuthenticationState.otpInput;
    });
  }
}


  void _proceedToBooking() {
    //! Navigate to seat booking or perform booking action
    Navigator.of(context).pop(true);
   
  }

  void _resendOTP() {
    // Implement OTP resend logic
    _sendOTP();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.activeGreen.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Phone Verification',
              style: GoogleFonts.syneMono(
                color: AppColors.activeGreen,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            
            // Conditional content based on authentication state
            if (_currentState == AuthenticationState.phoneInput)
              _buildPhoneInputWidget(),
            
            if (_currentState == AuthenticationState.otpInput)
              _buildOTPInputWidget(),
            
            if (_currentState == AuthenticationState.loading)
            
                _buildOTPInputWidget(),
            
            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputWidget() {
    return Column(
      children: [
        Text(
          'Enter your phone number to verify',
          style: GoogleFonts.notoSans(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+91',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(color: Colors.white54),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _sendOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.activeGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'Send OTP',
            style: GoogleFonts.notoSans(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInputWidget() {
    return Column(
      children: [
        Text(
          'Enter the 6-digit OTP sent to\n+91 ${_phoneController.text}',
          style: GoogleFonts.notoSans(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: TextStyle(color: Colors.white54, letterSpacing: 10),
            counterText: '',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _resendOTP,
              child: Text(
                'Resend OTP',
                style: GoogleFonts.notoSans(color: AppColors.activeGreen),
              ),
            ),
            ElevatedButton(
              onPressed: _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Verify',
                style: GoogleFonts.notoSans(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(
            color: AppColors.activeGreen,
          ),
          const SizedBox(height: 20),
          Text(
            'Verifying...',
            style: GoogleFonts.notoSans(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
