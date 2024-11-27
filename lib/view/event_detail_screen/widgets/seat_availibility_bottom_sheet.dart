import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/payment_sucess_page/payment_sucess_pag.dart';

import 'package:phuong/view/welcomepage/welcomes_screen.dart'; // Assuming you'll create a payment screen

class BookingBottomSheet extends StatefulWidget {
  final EventModel event;

  const BookingBottomSheet({Key? key, required this.event}) : super(key: key);

  @override
  _BookingBottomSheetState createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _selectedSeats = 0;
  String? _errorMessage;
  double _totalPrice = 0.0;

  void _incrementSeats() {
    setState(() {
      if (_selectedSeats < widget.event.seatAvailabilityCount!) {
        _selectedSeats++;
        _calculateTotalPrice();
        _errorMessage = null;
      } else {
        _errorMessage = 'Maximum ${widget.event.seatAvailabilityCount} seats available';
      }
    });
  }

  void _decrementSeats() {
    setState(() {
      if (_selectedSeats > 0) {
        _selectedSeats--;
        _calculateTotalPrice();
        _errorMessage = null;
      }
    });
  }

  void _calculateTotalPrice() {
    // Ensure ticket price is not null before calculation
    setState(() {
      _totalPrice = (widget.event.ticketPrice ?? 0.0) * _selectedSeats;
    });
  }

  void _confirmBooking() {
    if (_selectedSeats == 0) {
      setState(() {
        _errorMessage = 'Please select at least one seat';
      });
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();

    //! Navigate to Payment Screen
    Navigator.of(context).push(GentlePageTransition(page: PaymentSuccessScreen(event: EventModel(),selectedSeats: _selectedSeats,totalAmount: _totalPrice,key: GlobalKey(),)));
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
            color: AppColors.activeGreen.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Book Seats',
              style: GoogleFonts.syne(
                color: AppColors.activeGreen,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Seats: ${widget.event.seatAvailabilityCount}',
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                // Price Per Ticket Display
                Text(
                  'Price: ₹${widget.event.ticketPrice?.toStringAsFixed(2) ?? '0.00'}/seat',
                  style: GoogleFonts.notoSans(
                    color: white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: Colors.white),
                  onPressed: _selectedSeats > 0 ? _decrementSeats : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '$_selectedSeats',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppColors.activeGreen),
                  onPressed: _selectedSeats < widget.event.seatAvailabilityCount!
                      ? _incrementSeats 
                      : null,
                ),
              ],
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 10),
            // Total Price Display
            Text(
              'Total Price: ₹${_totalPrice.toStringAsFixed(2)}',
              style: GoogleFonts.notoSans(
                color: AppColors.activeGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.notoSans(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed to Payment',
                    style: GoogleFonts.notoSans(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}