import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';

class SuccessPage extends StatefulWidget {
  final EventModel event;
  final int selectedSeats;
  final double totalPrice;

  const SuccessPage({
    Key? key,
    required this.event,
    required this.selectedSeats,
    required this.totalPrice,
    required double totalAmount,
  }) : super(key: key);

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateAndDownloadTicket() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Event Ticket',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Event: ${widget.event.eventName}'),
                pw.SizedBox(height: 10),
                pw.Text('Seats: ${widget.selectedSeats}'),
                pw.SizedBox(height: 10),
                pw.Text('Amount Paid: ₹${widget.totalPrice.toStringAsFixed(2)}'),
              ],
            ),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ticket.pdf');
    await file.writeAsBytes(await pdf.save());

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket downloaded successfully!')),
    );
  }

  void _shareTicket() {
    Share.share(
      'Check out my ticket for ${widget.event.eventName}!\n'
      'Seats: ${widget.selectedSeats}\n'
      'Amount Paid: ₹${widget.totalPrice.toStringAsFixed(2)}',
    );
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Success Animation
              // FadeTransition(
              //   opacity: _fadeAnimation,
              //   child: Lottie.network(
              //     'assets/animations/Animation - 1732721061827.json',
              //     height: 200,
              //     repeat: false,
              //   ),
              // ),
              

              // Ticket Widget
              ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: TicketWidget(
                    width: 350,
                    height: 480,
                    isCornerRounded: true,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          widget.event.eventName ?? '',
                          style: GoogleFonts.syne(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.activeGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        _buildTicketInfo('Date', widget.event.eventName ?? ''),
                        // _buildTicketInfo('Time', widget.event.time ?? ''),
                        _buildTicketInfo('Seats', '${widget.selectedSeats}'),
                        _buildTicketInfo(
                          'Amount',
                          '₹${widget.totalPrice.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: 20),
                        // QR Code placeholder
                        Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(Icons.qr_code, size: 100),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.download,
                    label: 'Download',
                    onPressed: _generateAndDownloadTicket,
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onPressed: _shareTicket,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
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
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: GoogleFonts.notoSans(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.activeGreen,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
