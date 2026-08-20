import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

enum SnackBarType { success, error, info }

/// Reusable global constant SnackBar helper for consistent notifications across the app
class AppSnackBar {
  AppSnackBar._();

  static const Duration defaultDuration = Duration(seconds: 2);

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = defaultDuration,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.successGreen;
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        backgroundColor = AppColors.dangerRed;
        icon = Icons.error_rounded;
        break;
      case SnackBarType.info:
        backgroundColor = AppColors.infoBlue;
        icon = Icons.info_rounded;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.pureWhite, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.snackBarText,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message, {Duration duration = defaultDuration}) {
    show(context, message: message, type: SnackBarType.success, duration: duration);
  }

  static void showError(BuildContext context, String message, {Duration duration = defaultDuration}) {
    show(context, message: message, type: SnackBarType.error, duration: duration);
  }

  static void showInfo(BuildContext context, String message, {Duration duration = defaultDuration}) {
    show(context, message: message, type: SnackBarType.info, duration: duration);
  }
}
