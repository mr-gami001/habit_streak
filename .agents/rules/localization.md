# Project Rule: AppStrings Centralized Labels & Localization

Always use `AppStrings` (`lib/l10n/app_strings.dart`) for all user-facing UI text, titles, labels, tooltips, dialog messages, button texts, category names, and toast strings across this application.

### Usage Guidelines:
- Do NOT hardcode raw string literals (e.g. `'Delete'`, `'Save'`, `'Category'`) inside UI files or widgets.
- Add any new user-facing text strings as `static const String` constants in `AppStrings` (`lib/l10n/app_strings.dart`).
- Reference `AppStrings.<propertyName>` directly in all widgets.
