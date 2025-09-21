import 'package:flutter/material.dart';

class AppColors {
  // Teal-Indigo Palette (Option A)
  static const Color primary = Color(0xFF96A78D);
  static const Color primaryDark = Color(0xFFB6CEB4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color.fromARGB(255, 129, 154, 214);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color success = Color(0xFF059669);
  static const Color danger = Color(0xFFEF4444);
  
  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5E7EB);
  
  // Text colors
  static const Color textPrimary = Color.fromRGBO(244, 247, 253,5);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  static Color? get accent => null;
}
