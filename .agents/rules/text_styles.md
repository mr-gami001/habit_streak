# Project Rule: AppTextStyles Centralized Typography

Always use `AppTextStyles` (`lib/theme/app_text_styles.dart`) for all typography and text styling across this application.

### Usage Guidelines:
- Do NOT define ad-hoc inline `TextStyle(...)` objects inside UI widgets.
- Reuse or extend existing `AppTextStyles` constants (using `.copyWith(...)` if modifying color or font weight dynamically).
- Add any new baseline text styles to `AppTextStyles` (`lib/theme/app_text_styles.dart`).
