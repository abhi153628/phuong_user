import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/modal/user_profile_modal.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/event_detail_screen/widgets/seat_availibility_bottom_sheet.dart';
import 'package:phuong/view/homepage/homepage.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

// Move enum to top-level
enum AuthenticationState {
  phoneInput,
  otpInput,
  loading
}
class PhoneAuthBottomSheet extends StatefulWidget {
  final EventModel? event;
  final void Function(String)? onPhoneVerified;

  const PhoneAuthBottomSheet({
    Key? key,
    this.event,
    this.onPhoneVerified,
  }) : super(key: key);

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
    String phoneNumber = '+91${_phoneController.text.trim()}';
    
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
          // Auto-verification handled here if needed
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _currentState = AuthenticationState.otpInput;
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
    String phoneNumber = '+91${_phoneController.text.trim()}';

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _currentState = AuthenticationState.loading;
      _errorMessage = null;
    });

    try {
      final userProfileService = UserProfileService();
      await userProfileService.updatePhoneNumber(phoneNumber);

      // Close the bottom sheet
      if (mounted) {
        Navigator.pop(context);
      }

      // Handle callback if it exists
      if (widget.onPhoneVerified != null) {
        widget.onPhoneVerified!(phoneNumber);
      } 
      // Handle event booking if event exists
      else if (widget.event != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.activeGreen,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading booking details...',
                      style: GoogleFonts.notoSans(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save phone number: $e';
          _currentState = AuthenticationState.otpInput;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
void _resendOTP() {
    // Implement OTP resend logic
    _sendOTP();
  }

 @override
  Widget build(BuildContext context) {
    // Get the keyboard height and screen padding
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight > 0 ? keyboardHeight : 0,
      ),
      child: SingleChildScrollView(
        child: Container(
          // Limit maximum height to prevent overflow
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
          ),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.activeGreen.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
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
                    
                    // State-based content
                    if (_currentState == AuthenticationState.loading)
                      _buildLoadingWidget()
                    else if (_currentState == AuthenticationState.phoneInput)
                      _buildPhoneInputWidget()
                    else if (_currentState == AuthenticationState.otpInput)
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              child: TextFormField(
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
                // Auto-focus when shown
                autofocus: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'Send OTP',
              style: GoogleFonts.notoSans(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOTPInputWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 10,
          ),
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: TextStyle(
              color: Colors.white54,
              letterSpacing: 10,
            ),
            counterText: '',
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          // Auto-focus when OTP screen is shown
          autofocus: true,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _resendOTP,
              child: Text(
                'Resend OTP',
                style: GoogleFonts.notoSans(
                  color: AppColors.activeGreen,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Verify',
                style: GoogleFonts.notoSans(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.activeGreen,
          ),
          const SizedBox(height: 20),
          Text(
            'Verifying...',
            style: GoogleFonts.notoSans(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}