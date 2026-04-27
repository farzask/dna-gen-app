import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DnaPatternBackground extends StatelessWidget {
  final Widget child;

  const DnaPatternBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative circles
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryCyan.withValues(alpha: 0.1),
                width: 40,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                width: 50,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
