import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phuong/compensation_terms_condition.dart';


import 'package:phuong/view/homepage/widgets/colors.dart';

import 'package:super_ticket_package/super_ticket_package_view.dart';


class CompensationPage extends StatefulWidget {
  // Changed to StatefulWidget
  const CompensationPage({
    Key? key,
    required this.eventName,
    required this.bookingId,
    required this.seatsBooked,
    required this.totalAmount,
    required this.timestamp,
  }) : super(key: key);

  final String eventName;
  final String bookingId;
  final int seatsBooked;
  final double totalAmount;
  final DateTime timestamp;

  @override
  State<CompensationPage> createState() => _CompensationPageState();
}

class _CompensationPageState extends State<CompensationPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  late AnimationController _animationController;
  bool _showTicket = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const neonGreen = AppColors.activeGreen;
    final white = Colors.white; // Define white color

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios, color: white),
                  ),
                  Text(
                    'Event Cancelled!',
                    style: GoogleFonts.syne(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activeGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We sincerely apologize for the inconvenience',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),

              // Event Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: neonGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventName.isNotEmpty
                          ? '${widget.eventName[0].toUpperCase()}${widget.eventName.substring(1)}'
                          : 'Event Name',
                      style: GoogleFonts.syne(
                        fontSize: 24,
                        color: AppColors.activeGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Booking ID', widget.bookingId),
                    _buildDetailRow(
                        'Seats Booked', widget.seatsBooked.toString()),
                    _buildDetailRow('Total Amount',
                        '\$${widget.totalAmount.toStringAsFixed(2)}'),
                    _buildDetailRow('Booked Date',
                        DateFormat('MMM d, y').format(widget.timestamp)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Compensation Options Title
              Text(
                'Choose Your Compensation',
                style: GoogleFonts.syne(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Compensation Cards
              _buildCompensationCard(
                icon: Icons.confirmation_number_outlined,
                title: 'Voucher for Next Event',
                description:
                    'Get a voucher of equal value for any upcoming event',
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => TermsDialog(
                      terms: [
                        'This voucher is non-transferable and can only be redeemed by the user.',
                        'It cannot be exchanged for cash.',
                        'The voucher must be redeemed within the validity period mentioned.',
                        'If the new ticket price exceeds the voucher value, the user must pay the difference.',
                      ],
                      onAccept: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  );

                  if (result == true) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    await Future.delayed(const Duration(seconds: 3));

                    if (context.mounted) {
                      Navigator.of(context).pop();

                      _confettiController.play(); // Play confetti
                      // Wait for confetti
                      _showVoucherDetails(context);
                    }
                  }
                },
              ),

              _buildCompensationCard(
                icon: Icons.money,
                title: 'Request Refund',
                description:
                    'Get a full refund to your original payment method',
                onTap: () => _showRefundUnavailableMessage(context),
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompensationCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.activeGreen.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 void _showVoucherDetails(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (!_showTicket) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() => _showTicket = true);
                  _confettiController.play();
                }
              });
            }

            return Stack(
              children: [
                AnimatedOpacity(
                  opacity: _showTicket ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 20),
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5),
                      child: SuperTicket(
                        itemCount: 1,
                        arcColor: Colors.black,
                        ticketText: 'Event Voucher',
                        colors: const [
                          AppColors.activeGreen,
                          AppColors.activeGreen,
                        ],
                        ticketTextStyle: GoogleFonts.syne(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                        ticketTitleText: widget.eventName.toUpperCase(),
                        ticketTitleTextStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: 0.8,
                          overflow: TextOverflow.ellipsis, // Added overflow protection
                        ),
                        firstIcon: Icons.verified,
                        firstIconsText:
                            'VALID UNTIL: ${DateFormat('MMM d, y').format(DateTime.now().add(const Duration(days: 547))).toUpperCase()}',
                        firstIconsTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          overflow: TextOverflow.ellipsis, 
                        ),
                        ticketHeight: MediaQuery.of(context).size.height * 0.35,
                        secondIcon: Icons.qr_code,
                        secondIconsText: '''VOUCHER ID: ${widget.bookingId}V 
SEATS: ${widget.seatsBooked}
INIT. BOOKING: ${DateFormat('MMM d, y').format(widget.timestamp).toUpperCase()}
''',
                        secondIconsTextStyle: TextStyle(fontSize: 13,
                          height: 2,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 0.2,
                          overflow: TextOverflow.ellipsis, // Added overflow protection
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 2.0,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ],
                          decorationColor: Colors.black,
                          decorationThickness: 3,),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisSize: MainAxisSize.min, // Added to prevent row overflow
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white),
                                  const SizedBox(width: 12),
                                  Flexible( // Wrapped in Flexible to prevent text overflow
                                    child: Text(
                                      'Voucher details saved!',
                                      style: GoogleFonts.syne(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.activeGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        buttonBg: Colors.black87,
                        buttonBorderColor: AppColors.activeGreen,
                        buttonText:
                            '₹ ${widget.totalAmount.toStringAsFixed(2)}',
                        buttonIcon: Icons.stars_rounded,
                        buttonIconColor: AppColors.activeGreen,
                        buttonTextStyle: GoogleFonts.notoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.activeGreen,
                          
                           // Added overflow protection
                        ),
                        firstIconColor: Colors.black87,
                        secondIconColor: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: pi / 2,
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 50,
                    gravity: 0.2,
                    shouldLoop: false,
                    colors: const [
                      AppColors.activeGreen,
                      Colors.blue,
                      Colors.purple,
                      Colors.orange,
                      AppColors.activeGreen,
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showRefundUnavailableMessage(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.1,
        left: 16,
        right: 16,
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.activeGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.activeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: AppColors.activeGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Feature Unavailable',
                          style: GoogleFonts.syne(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Direct refund is not available at the moment. Please choose another compensation option.',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 3000), overlayEntry.remove);
  }


}
