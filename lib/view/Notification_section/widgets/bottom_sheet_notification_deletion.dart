import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmDeleteSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDeleteSheet({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Color(0xFF00FF00).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00FF00).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Delete Notification',
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00FF00),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Are you sure you want to delete this notification?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: 'Cancel',
                    onPressed: onCancel,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                    text: 'Delete',
                    onPressed: onConfirm,
                    isDelete: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
    bool isDelete = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDelete 
                ? Color(0xFF00FF00).withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        color: isDelete 
            ? Color(0xFF00FF00).withOpacity(0.1)
            : Colors.grey[900],
        elevation: 0,
        highlightElevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          text,
          style: GoogleFonts.syne(
            color: isDelete ? Color(0xFF00FF00) : Colors.grey[300],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}