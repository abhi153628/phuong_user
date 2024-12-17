import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:share_plus/share_plus.dart';

class MinimalistSuccessPage extends StatefulWidget {
  final EventModel event;
  final int selectedSeats;
  final double totalPrice;
  final DateTime dateTime;
  final String transactionId;

  const MinimalistSuccessPage(
      {Key? key,
      required this.event,
      required this.selectedSeats,
      required this.totalPrice,
      required this.dateTime,
      required this.transactionId})
      : super(key: key);

  @override
  _MinimalistSuccessPageState createState() => _MinimalistSuccessPageState();
}

class _MinimalistSuccessPageState extends State<MinimalistSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.elasticOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.decelerate));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTicketDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ticket Details',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Event', widget.event.eventName ?? 'N/A'),
              // _buildDetailRow('Date', widget.event.date ?? 'N/A'),
              _buildDetailRow('Seats', '${widget.selectedSeats}'),
              _buildDetailRow(
                  'Total Amount', '₹${widget.totalPrice.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                // Success Animation
                Stack(children: [
                  Lottie.asset(
                    'assets/animations/order_success_lottie.json',
                    height: 350,
                    repeat: false,
                  ),
                  Positioned(
                    top: 280,
                    left: 70,
                    child: Text(
                      'Payment Successful',
                      style: GoogleFonts.syne(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  //! Organizer Name
                  Positioned(
                    top: 310,
                    left: 140,
                    child: Text(
                      'to ${widget.event.organizerName?[0].toUpperCase()}${widget.event.organizerName?.substring(1).toLowerCase()}',
                      style: GoogleFonts.notoSans(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ]),
                //! Total Amount
                Text(
                  '₹ ${widget.totalPrice.toString()}',
                  style: GoogleFonts.roboto(
                    color: AppColors.activeGreen,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Payment Success Title

                const SizedBox(height: 60),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.activeGreen.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Thank you for your purchase',
                      style: GoogleFonts.syne(
                          color: AppColors.activeGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  DateFormat('d MMMM y | h:mm a').format(widget.dateTime),
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'UPI Transaction ID:  ${widget.transactionId}',
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
               InkWell(onTap: () => _showTicketDetails,
                 child: Text(
                      'View Details',
                      style: GoogleFonts.notoSans(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                       
                      ),
                    ),
               ),
                  SizedBox(height: 4,),
                
           Container(height: 2,width: 80,color: white,),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.confirmation_number_outlined,
                      label: 'View Ticket',
                      onPressed: _showTicketDetails,
                    ),
                    const SizedBox(width: 30),
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onPressed: () {
                        Share.share(
                          'Check out my ticket for ${widget.event.eventName}!\n'
                          'Seats: ${widget.selectedSeats}\n'
                          'Amount Paid: ₹${widget.totalPrice.toStringAsFixed(2)}',
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 50,),
               Row(mainAxisAlignment: MainAxisAlignment.center,
                 children: [

                   Text(
                      'Powered by',
                      style: GoogleFonts.notoSans(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                       
                      ),
                    ),SizedBox(width: 10,),
                   Image.asset('assets/welcomepageassets/razorpay_logo.png',height: 20,),
                 ],
               )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black, size: 20),
      label: Text(
        label,
        style: GoogleFonts.notoSans(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
    );
  }
}
