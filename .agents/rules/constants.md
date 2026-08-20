# Project Rule: AppConstants Centralized Utilities

Always use `AppConstants` (`lib/constants/app_constants.dart`) for all shared utility functions and helper methods across the application.

### Reusable Utility Methods:
- **`AppConstants.parseColorHex(hexString)`**: Parses hex color strings into `Color`.
- **`AppConstants.formatDate(dateTime)`**: Formats `DateTime` into readable date strings (e.g. `"Jan 15, 2026"`).
- **`AppConstants.formatMonthYear(dateTime)`**: Formats `DateTime` into month & year headers (e.g. `"January 2026"`).
- **`AppConstants.formatReminderTime(hour, minute)`**: Formats time integers into 12-hour AM/PM strings (e.g. `"8:30 AM"`).
- **`AppConstants.formatTimeOfDay(timeOfDay)`**: Formats Flutter `TimeOfDay` into 12-hour AM/PM strings.

Do NOT duplicate hex parsing or date/time formatting functions inside individual UI classes.
