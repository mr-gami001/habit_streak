# Project Rule: AppSnackBar Policy

Always use `AppSnackBar` (`lib/ui/widgets/app_snackbar.dart`) whenever displaying SnackBars, toast messages, info alerts, or errors in the UI across this application.

### Usage Guidelines:
- **Success Messages**: Use `AppSnackBar.showSuccess(context, message)`
- **Error Messages**: Use `AppSnackBar.showError(context, message)`
- **Info Messages**: Use `AppSnackBar.showInfo(context, message)`

Do NOT create separate ad-hoc `SnackBar` or `ScaffoldMessenger` implementations anywhere in the codebase.
