import 'package:flutter/material.dart';

/// Reusable App Logo Widget designed for perfect contrast and visibility across both Light and Dark themes.
class AppLogoWidget extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showBackground;

  const AppLogoWidget({
    super.key,
    this.size = 28,
    this.borderRadius = 8,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!showBackground) {
      return Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFFFFFFFF).withValues(alpha: 0.45) // Soft contrast backdrop for dark theme
            : const Color(0xFFFFFFFF), // Crisp pure white tile for light theme
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            '🔥',
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );
  }
}
