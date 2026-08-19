import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primarySeed, // Emerald Green
        onPrimary: Colors.white,
        primaryContainer: AppColors.completedGreenBgLight,
        onPrimaryContainer: const Color(0xFF064E3B),
        secondary: AppColors.secondarySeed, // Sunset Orange
        onSecondary: Colors.white,
        secondaryContainer: AppColors.streakFireBgLight,
        onSecondaryContainer: const Color(0xFF7C2D12),
        tertiary: AppColors.accentNavy, // Midnight Navy Checkmark
        onTertiary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: const Color(0xFFF1F5F9),
        surfaceContainerHigh: const Color(0xFFE2E8F0),
        outline: AppColors.lightTextSecondary,
        outlineVariant: AppColors.lightCardBorder,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: AppColors.primarySeed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primarySeed,
        onPrimary: Colors.white,
        primaryContainer: AppColors.completedGreenBgDark,
        onPrimaryContainer: const Color(0xFFA7F3D0),
        secondary: AppColors.secondarySeed,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.streakFireBgDark,
        onSecondaryContainer: const Color(0xFFFFDBCF),
        tertiary: const Color(0xFF38BDF8),
        onTertiary: Colors.black,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: const Color(0xFF15263A),
        surfaceContainerHigh: const Color(0xFF223A56),
        outline: AppColors.darkTextSecondary,
        outlineVariant: AppColors.darkCardBorder,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: AppColors.primarySeed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
