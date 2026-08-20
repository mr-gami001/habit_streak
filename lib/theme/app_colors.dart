import 'package:flutter/material.dart';

/// App color palette extracted directly from the app launcher logo:
/// - Lime/Emerald Green progress ring (#10B981 / #22C55E)
/// - Midnight Navy checkmark (#0F2B48 / #1B365D)
/// - Warm Sunset Orange arc (#F97316 / #FF5722)
/// - Golden Amber dots (#F59E0B)
class AppColors {
  // Brand Seeds extracted from Logo
  static const Color primarySeed = Color(0xFF10B981); // Emerald Green (Logo Ring)
  static const Color secondarySeed = Color(0xFFF97316); // Sunset Orange (Logo Arc)
  static const Color accentNavy = Color(0xFF0F2B48); // Midnight Navy (Logo Checkmark)
  static const Color accentAmber = Color(0xFFF59E0B); // Golden Amber (Logo Dots)

  // Streak & Fire Colors (Logo Orange Arc & Fire)
  static const Color streakFire = Color(0xFFF97316);
  static const Color streakFireBgLight = Color(0xFFFFF7ED); // Warm orange tint
  static Color streakFireBgDark = const Color(0xFFF97316).withValues(alpha: 0.25);

  // Status & Completion Colors (Logo Emerald Green)
  static const Color completedGreen = Color(0xFF10B981);
  static const Color completedGreenBgLight = Color(0xFFECFDF5); // Soft emerald tint
  static Color completedGreenBgDark = const Color(0xFF10B981).withValues(alpha: 0.25);

  // Streak Recovery Colors (Logo Golden Amber)
  static const Color recoveryAmber = Color(0xFFF59E0B);
  static const Color recoveryAmberBgLight = Color(0xFFFFFBEB);
  static Color recoveryAmberBgDark = const Color(0xFFF59E0B).withValues(alpha: 0.22);
  static Color recoveryAmberBorder = const Color(0xFFF59E0B).withValues(alpha: 0.5);

  // Ad Badge
  static const Color adBadgeBg = Color(0xFFF59E0B);
  static const Color adBadgeText = Colors.black;

  // General & Utility Colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const Color dangerRed = Color(0xFFFF5252);
  static const Color infoBlue = Color(0xFF0288D1);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color securityBlue = Colors.blue;

  // Habit Swatch Theme Palette Colors
  static const Color swatchTeal = Color(0xFF00BFA5);
  static const Color swatchPurple = Color(0xFF7C4DFF);
  static const Color swatchCoral = Color(0xFFFF6E40);
  static const Color swatchEmerald = Color(0xFF2ECC71);
  static const Color swatchAmber = Color(0xFFFFB300);
  static const Color swatchOcean = Color(0xFF29B6F6);
  static const Color swatchRose = Color(0xFFEC407A);
  static const Color swatchIndigo = Color(0xFF5C6BC0);

  // Swatch Hex Strings
  static const String hexTeal = '#00BFA5';
  static const String hexPurple = '#7C4DFF';
  static const String hexCoral = '#FF6E40';
  static const String hexEmerald = '#2ECC71';
  static const String hexAmber = '#FFB300';
  static const String hexOcean = '#29B6F6';
  static const String hexRose = '#EC407A';
  static const String hexIndigo = '#5C6BC0';

  // Light Theme Colors (Matching Logo's crisp white tile & navy accents)
  static const Color lightBackground = Color(0xFFF4F7F6); // Soft fresh slate background
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white cards (like logo base)
  static const Color lightCardBorder = Color(0xFFE2E8F0); // Subtle divider line
  static const Color lightTextPrimary = Color(0xFF0F2B48); // Midnight Navy (Logo checkmark)
  static const Color lightTextSecondary = Color(0xFF64748B); // Muted slate

  // Dark Theme Colors (Deep Midnight Navy inspired by logo checkmark)
  static const Color darkBackground = Color(0xFF0B1726); // Deepest Midnight Navy
  static const Color darkSurface = Color(0xFF15263A); // Dark Navy Surface
  static const Color darkCardBorder = Color(0xFF223A56); // Navy Card Border
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Soft White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Soft Navy Slate

  /// Helper method for adaptive card borders
  static BorderSide cardBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BorderSide(
      color: isDark ? darkCardBorder : lightCardBorder,
      width: 1,
    );
  }
}
