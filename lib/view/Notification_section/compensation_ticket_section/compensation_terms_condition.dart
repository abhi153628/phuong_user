import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class TermsDialog extends StatefulWidget {
  final VoidCallback onAccept;
  final String title;
  final List<String> terms;

  const TermsDialog({
    Key? key,
    required this.onAccept,
    this.title = 'Terms and Conditions',
    required this.terms,
  }) : super(key: key);

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.99),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:  AppColors.activeGreen.withOpacity(0.8), // Neon green
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration:  BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.activeGreen.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  widget.title,
                  style: GoogleFonts.syne(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:  AppColors.activeGreen.withOpacity(0.8),
                  ),
                ),
              ),
              // Content
              Flexible(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      if (scrollNotification.metrics.pixels >=
                          scrollNotification.metrics.maxScrollExtent * 0.9) {
                      }
                    }
                    return true;
                  },
                  child: SingleChildScrollView(
                    padding:  EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.terms.map((term) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                '•',
                                style: TextStyle(
                                  color: AppColors.activeGreen.withOpacity(0.8),
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  term,
                                  style: GoogleFonts.syne(
                                    fontSize: 16,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration:  BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.activeGreen.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Decline',
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: white
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: widget.onAccept ,
                      style: OutlinedButton.styleFrom(
                        
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Accept',
                        style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: white
                        ),
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
}