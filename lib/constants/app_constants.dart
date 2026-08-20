import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';

/// Centralized utility methods and constants used across the application.
class AppConstants {
  AppConstants._();

  /// Default categories available across the app
  static const List<String> defaultCategories = AppStrings.defaultCategories;

  /// Preset hex color codes for habit custom theme colors
  static const List<String> presetColorHexes = [
    AppColors.hexTeal,
    AppColors.hexPurple,
    AppColors.hexCoral,
    AppColors.hexEmerald,
    AppColors.hexAmber,
    AppColors.hexOcean,
    AppColors.hexRose,
    AppColors.hexIndigo,
  ];

  /// Shared color palette objects (name, hex, and Color object)
  static final List<Map<String, dynamic>> colorPalette = [
    {'name': AppStrings.colorTeal, 'hex': AppColors.hexTeal, 'color': AppColors.swatchTeal},
    {'name': AppStrings.colorPurple, 'hex': AppColors.hexPurple, 'color': AppColors.swatchPurple},
    {'name': AppStrings.colorCoral, 'hex': AppColors.hexCoral, 'color': AppColors.swatchCoral},
    {'name': AppStrings.colorEmerald, 'hex': AppColors.hexEmerald, 'color': AppColors.swatchEmerald},
    {'name': AppStrings.colorAmber, 'hex': AppColors.hexAmber, 'color': AppColors.swatchAmber},
    {'name': AppStrings.colorOcean, 'hex': AppColors.hexOcean, 'color': AppColors.swatchOcean},
    {'name': AppStrings.colorRose, 'hex': AppColors.hexRose, 'color': AppColors.swatchRose},
    {'name': AppStrings.colorIndigo, 'hex': AppColors.hexIndigo, 'color': AppColors.swatchIndigo},
  ];

  /// Parses a hex color string (e.g. "#00BFA5", "00BFA5", "FF00BFA5") into a Flutter [Color].
  /// Returns [fallback] (defaults to [AppColors.primarySeed]) if parsing fails.
  static Color parseColorHex(String hexString, {Color fallback = AppColors.primarySeed}) {
    try {
      final cleanHex = hexString.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  /// Formats a [DateTime] object into a readable date string (e.g. "Jan 15, 2026").
  static String formatDate(DateTime dt) {
    final month = AppStrings.monthsShort[dt.month - 1];
    return '$month ${dt.day}, ${dt.year}';
  }

  /// Formats a [DateTime] into a Month and Year header string (e.g. "January 2026").
  static String formatMonthYear(DateTime dt) {
    final month = AppStrings.monthsFull[dt.month - 1];
    return '$month ${dt.year}';
  }

  /// Formats hour and minute into a 12-hour AM/PM string (e.g. "8:30 AM").
  static String formatReminderTime(int hour, int minute) {
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final formattedMinute = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$formattedHour:$formattedMinute $period';
  }

  /// Formats a Flutter [TimeOfDay] into a 12-hour AM/PM string (e.g. "8:30 AM").
  static String formatTimeOfDay(TimeOfDay time) {
    return formatReminderTime(time.hour, time.minute);
  }
}
