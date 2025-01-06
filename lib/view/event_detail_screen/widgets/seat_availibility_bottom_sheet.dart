import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/booking_service.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/payment_sucess_page/payment_sucess_page.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookingBottomSheet extends StatefulWidget {
  final EventModel event;


  BookingBottomSheet({Key? key, required this.event}) : super(key: key);

  @override
  _BookingBottomSheetState createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
      final BookingService _bookingService = BookingService();
  int _selectedSeats = 0;
  String? _errorMessage;
  double _totalPrice = 0.0;
  late Razorpay _razorpay;
    bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  //! Initialize Razorpay instance
  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  //! Handle successful payments
void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  if (mounted) {
    setState(() {
      _isLoading = true;  
    });
  }

  try {
    final DateTime paymentDateTime = DateTime.now();
    // Create booking after successful payment
    final success = await _bookingService.bookEvent(
      widget.event,
      _selectedSeats
    );

    if (success) {

      await Future.delayed(const Duration(seconds: 2));
      
      Fluttertoast.showToast(
        msg: "Booking Successful!",
        toastLength: Toast.LENGTH_LONG,
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          GentlePageTransition(
            page: MinimalistSuccessPage(
              event: widget.event,
              selectedSeats: _selectedSeats,
              dateTime: paymentDateTime,
              transactionId: response.paymentId ?? 'N/A',
              key: GlobalKey(),
              totalPrice: _totalPrice,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Fluttertoast.showToast(
        msg: "Booking failed. Please try again.",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    Fluttertoast.showToast(
      msg: "Error: ${e.toString()}",
      toastLength: Toast.LENGTH_LONG,
    );
  }
}

  // Handle payment failures
  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Failed: ${response.message}",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  // Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External Wallet Selected: ${response.walletName}",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  // Create order options for Razorpay
  void _createOrder() {
    var options = {
      'key': 'rzp_test_jIotm3SaZbXO9x', // Razorpay Key
      'amount': (_totalPrice * 100).toInt(), // Amount in smallest currency unit
      'name': ' Phuong Booking',
      'description': '${widget.event.eventName} - $_selectedSeats seats',
      'prefill': {
        'contact': '', //user's phone number if available
        'email': ''  ,  // Add user's email if available
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // Previous methods remain the same
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
    } else {
      _errorMessage = 'You cannot select less than 0 seats';
    }
  });
}


  void _calculateTotalPrice() {
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

    HapticFeedback.lightImpact();
    _createOrder(); 
  }

  @override
  void dispose() {
    _razorpay.clear(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventModel?>(
    stream: EventService().getEventStream(widget.event.eventId!),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return  Center(child: Lottie.asset('assets/animations/Animation - 1736144056346.json',height: 170,width: 170));
      }
         if (_isLoading) {
          return Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 Lottie.asset('assets/animations/Animation - 1736144056346.json',height: 170,width: 170),
                  const SizedBox(height: 20),
                  Text(
                    'Processing your booking...',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

      final updatedEvent = snapshot.data!;
      final noSeatsAvailable = updatedEvent.seatAvailabilityCount == 0;

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
                    'Available Seats: ${updatedEvent.seatAvailabilityCount}',
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
                  if (!noSeatsAvailable) // Only show payment button if seats are available
                    ElevatedButton(
                      onPressed: _selectedSeats > 0
                          ? () => _confirmBooking()
                          : () {
                              setState(() {
                                _errorMessage = 'Please select at least one seat';
                              });
                            },
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
                  if (noSeatsAvailable) // Show sold out message when no seats available
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SOLD OUT',
                        style: GoogleFonts.notoSans(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
           
}