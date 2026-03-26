import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color primaryMedium = Color(0xFF1B2838);
  static const Color primaryLight = Color(0xFF2C3E50);
  static const Color accent = Color(0xFF00F5D4);
  static const Color accentSecondary = Color(0xFF7B2FF7);
  static const Color gold = Color(0xFFFFD700);
  static const Color danger = Color(0xFFFF4757);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF607D8B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF2C3E50)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00F5D4), Color(0xFF00D4AA)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B2FF7), Color(0xFFFF6B9D)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );

  // Shadows
  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Borders
  static BorderRadius cardRadius = BorderRadius.circular(20);
  static BorderRadius buttonRadius = BorderRadius.circular(16);

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: 1.5,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: primaryDark,
    letterSpacing: 1.0,
  );

  // Decorations
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.08),
    borderRadius: cardRadius,
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.15),
      width: 1,
    ),
  );
}
