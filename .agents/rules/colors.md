# Project Rule: AppColors Centralized Theme Palette

Always use `AppColors` (`lib/theme/app_colors.dart`) for all color definitions, backgrounds, borders, badge backgrounds, and status colors across this application.

### Usage Guidelines:
- Do NOT hardcode inline `Color(0x...)` or raw `Colors.<colorName>` values inside UI components.
- Add any missing colors as `static const Color` fields in `AppColors` (`lib/theme/app_colors.dart`).
- Reference `AppColors.<colorName>` directly in all widgets.
