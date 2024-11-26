import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CstmText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final String? fontFamily;
  final FontWeight? fontWeight;

  CstmText(
      {super.key,
      required this.text,
      required this.fontSize,
      this.color,
      this.fontFamily,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    // Set a baseline font size adjustment based on screen width
    double responsiveFontSize = fontSize;

    if (MediaQuery.of(context).size.width < 360) {
      // Small phones
      responsiveFontSize = fontSize * 0.85;
    } else if (MediaQuery.of(context).size.width < 480) {
      // Medium phones
      responsiveFontSize = fontSize * 0.9;
    } else if (MediaQuery.of(context).size.width < 720) {
      // Tablets and large phones
      responsiveFontSize = fontSize;
    } else if (MediaQuery.of(context).size.width < 1080) {
      // Small desktop screens
      responsiveFontSize = fontSize * 1.1;
    } else {
      // Larger desktop screens
      responsiveFontSize = fontSize * 1.2;
    }

    return Text(
      text,
      style: fontFamily != null
          ? GoogleFonts.getFont(
              fontFamily!,
              fontSize: responsiveFontSize,
              fontWeight: fontWeight,
              color: color,
            )
          : GoogleFonts.roboto(
              fontSize: responsiveFontSize,
              color: color,
              fontWeight: fontWeight),
    );
  }
}
