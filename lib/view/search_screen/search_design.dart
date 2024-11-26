import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class StunningSearchField extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  StunningSearchField({
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: Colors.grey[600], size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
                hintText: '', // leave blank for animated text hint
              ),
            ),
          ),
          Positioned(
            left: 60,
            child: SizedBox(
              height: 30,
              child: AnimatedTextKit(
                repeatForever: true,
                pause: const Duration(seconds: 2),
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Search for events...',
                    textStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    speed: const Duration(milliseconds: 100),
                  ),
                  TypewriterAnimatedText(
                    'Find something amazing...',
                    textStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    speed: const Duration(milliseconds: 100),
                  ),
                  TypewriterAnimatedText(
                    'Discover your next adventure...',
                    textStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
