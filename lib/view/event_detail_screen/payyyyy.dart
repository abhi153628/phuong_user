import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class PaymentSuccessPage extends StatelessWidget {
  final EventModel event;
  final int selectedSeats;
  final double totalPrice;

  const PaymentSuccessPage({
    Key? key, 
    required this.event, 
    required this.selectedSeats, 
    required this.totalPrice
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.activeGreen,
              size: 120,
            ),
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: GoogleFonts.syne(
                color: AppColors.activeGreen,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Event: ${event.eventName}',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Seats Booked: $selectedSeats',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Total Paid: ₹${totalPrice.toStringAsFixed(2)}',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}