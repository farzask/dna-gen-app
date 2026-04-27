import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showBorder;

  const LogoWidget({super.key, this.size = 80, this.showBorder = false});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://res.cloudinary.com/dzsi6mmmp/image/upload/v1770237619/DNA_Gen-Transp_b4glc0.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image doesn't load
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF00B4D8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(size * 0.25),
            border: Border.all(color: const Color(0xFF00B4D8), width: 2),
          ),
          child: Center(
            child: Text(
              'DG',
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00B4D8),
                letterSpacing: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
