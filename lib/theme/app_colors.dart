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
