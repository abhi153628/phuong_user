import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  final String image1;
  final String image2;

  const ImageContainer({
    Key? key,
    required this.image1,
    required this.image2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double containerWidth = screenSize.width * 0.8;
    final double containerHeight = containerWidth * (320 / 310);
    final double largeContainerWidth = containerWidth * (185 / 310);
    final double largeContainerHeight = containerHeight * (250 / 320);

    return Container(
      height: containerHeight,
      width: containerWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _buildImageBox(
              image: image1,
              width: largeContainerWidth,
              height: largeContainerHeight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(largeContainerWidth * (125 / 185)),
                topRight: Radius.circular(largeContainerWidth * (125 / 185)),
                bottomLeft: Radius.circular(largeContainerWidth * (31.67 / 185)),
                bottomRight: Radius.circular(largeContainerWidth * (31.67 / 185)),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildImageBox(
              image: image2,
              width: largeContainerWidth,
              height: largeContainerHeight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(largeContainerWidth * (31.67 / 185)),
                topRight: Radius.circular(largeContainerWidth * (31.67 / 185)),
                bottomRight: Radius.circular(largeContainerWidth * (95 / 185)),
                bottomLeft: Radius.circular(largeContainerWidth * (95 / 185)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBox({
    required String image,
    required double width,
    required double height,
    required BorderRadius borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: const Color.fromARGB(255, 51, 51, 51), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          image,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}