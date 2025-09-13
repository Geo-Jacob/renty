import 'package:flutter/material.dart';

class AppColors {
  // Teal-Indigo Palette (Option A)
  static const Color primary = Color(0xFF0EA5A4);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0F172A);
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
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  static Color? get accent => null;
}
