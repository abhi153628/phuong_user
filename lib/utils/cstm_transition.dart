import 'dart:ui';

import 'package:flutter/material.dart';

class GentlePageTransition extends PageRouteBuilder {
  final Widget page;

  GentlePageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Create multiple animations
            var fadeAnimation = Tween<double>(
              begin: 0.2,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            var scaleAnimation = Tween<double>(
              begin: 0.98,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            // Reduced blur effect
            var blurAnimation = Tween<double>(
              begin: 2.0,
              end: 0.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurAnimation.value,
                sigmaY: blurAnimation.value,
              ),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          opaque: false,
          barrierColor: Colors.black.withOpacity(0.1),
        );
}
