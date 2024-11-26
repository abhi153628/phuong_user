
import 'package:flutter/material.dart';
import 'package:phuong/constants/colors.dart';


class CustomTextField extends StatelessWidget {
  final String hintText;
  final double?  maxLines;

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
         hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: grey.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),

        
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(color: grey.withOpacity(0.9))),

        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(color: purple)),

      ),
      style: TextStyle(color: Colors.white),
    );
  }
}