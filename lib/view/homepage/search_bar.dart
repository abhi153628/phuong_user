

import 'package:flutter/material.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Search all events...',
          hintStyle: TextStyle(color: AppColors.grey),
          prefixIcon: Icon(Icons.search, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        ),
      ),
    );
  }
}
