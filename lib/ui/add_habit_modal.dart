import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../l10n/app_strings.dart';
import '../theme/app_text_styles.dart';

class AddHabitModal extends StatefulWidget {
  const AddHabitModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddHabitModal(),
    );
  }

  @override
  State<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends State<AddHabitModal> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final habitName = _controller.text.trim();
      context.read<HabitBloc>().add(AddHabitEvent(habitName));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.createNewHabit,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.cancel,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: AppStrings.habitNameLabel,
                hintText: AppStrings.habitNameHint,
                prefixIcon: const Icon(Icons.directions_run),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.habitNameValidationError;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancel, style: AppTextStyles.buttonLabel),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text(AppStrings.saveHabit, style: AppTextStyles.buttonLabel),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
