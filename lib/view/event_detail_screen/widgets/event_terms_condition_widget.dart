import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventTermsAndConditions extends StatelessWidget {
  final List<String> eventRules;

  const EventTermsAndConditions({
    Key? key,
    required this.eventRules,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:  Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          SizedBox(height: screenHeight * 0.01),
          ...eventRules.map((rule) => _buildRuleItem(rule, screenWidth, screenHeight)).toList(),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              rule,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}