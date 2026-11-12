import 'package:flutter/material.dart';

class AppColors {
  // Primary Dark Cinema Theme Colors
  static const Color background = Color(0xFF121312); // Deep Rich Dark
  static const Color surface = Color(0xFF1E1E1E);    // Card / Container Surface
  static const Color surfaceVariant = Color(0xFF282A28);
  
  // Accents
  static const Color primaryYellow = Color(0xFFF6BD27); // Gold/Yellow Action Accent
  static const Color accentRed = Color(0xFFE50914);     // Netflix / Cinema Red
  static const Color secondaryGold = Color(0xFFFFBB3B);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF757575);
  
  // Component Colors
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color inputBg = Color(0xFF262626);
  static const Color divider = Color(0xFF2D2D2D);
  static const Color starGold = Color(0xFFFFC107);
  
  // Gradients
  static const LinearGradient posterOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x80000000),
      Color(0xFF121312),
    ],
    stops: [0.0, 0.6, 1.0],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF6BD27),
      Color(0xFFFF9800),
    ],
  );
}
