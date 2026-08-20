import 'package:flutter/material.dart';

class AppTextStyles {
  // App Bar & Main Titles
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );

  static const TextStyle appBarEmoji = TextStyle(
    fontSize: 24,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  // Section & Card Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMediumCompleted = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.lineThrough,
  );

  // Body & Subtitles
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Streak & Badge Text Styles
  static const TextStyle streakBadgeText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle adBadgeText = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle recoverButtonText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle categoryChip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.1,
  );

  static const TextStyle filterChipSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle filterChipUnselected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle emojiHeader = TextStyle(
    fontSize: 32,
  );

  static const TextStyle emojiInline = TextStyle(
    fontSize: 18,
  );

  static const TextStyle cardTag = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 12,
  );

  static const TextStyle actionButtonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle heroTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle snackBarText = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}
