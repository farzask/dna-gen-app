import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryCyan = Color(0xFF00B4D8);
  static const Color primaryPurple = Color(0xFF9D4EDD);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0A1628);
  static const Color backgroundLight = Color(0xFF1A2942);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static final Color textSecondary = Colors.white.withOpacity(0.6);
  static final Color textTertiary = Colors.white.withOpacity(0.3);

  // Border Colors
  static final Color borderLight = Colors.white.withOpacity(0.1);
  static final Color borderCyan = primaryCyan.withOpacity(0.3);

  // Status Colors
  static const Color error = Color(0xFFFF4444);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);

  // Icon Colors
  static final Color iconPrimary = Colors.white.withOpacity(0.5);
  static final Color iconSecondary = Colors.white.withOpacity(0.3);
}
