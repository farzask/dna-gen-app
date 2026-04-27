import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final bool isAuthenticated;
  final double? fontSize;

  const StatusBadge({super.key, required this.isAuthenticated, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAuthenticated ? AppColors.primaryCyan : AppColors.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAuthenticated ? Icons.check_circle : Icons.cancel,
            size: fontSize ?? 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            isAuthenticated ? 'Authenticated' : 'Not Authenticated',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
