import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class CategoryButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryButton({
    Key? key,
    required this.text,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.activeGreen : Color(0xFF1b2533),
          borderRadius: BorderRadius.circular(8),
        
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Icon(
                Icons.bolt,
                color: black,
                size: 18,
              ),
            if (isActive) const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.notoSans(
                color: isActive ? black : AppColors.white,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w400,letterSpacing: 0.8
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
