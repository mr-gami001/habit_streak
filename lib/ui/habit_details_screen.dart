import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../data/habit_repository.dart';
import '../constants/app_constants.dart';
import '../l10n/app_strings.dart';
import '../models/check_in.dart';
import '../models/habit.dart';
import '../services/ad_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/app_snackbar.dart';
import 'widgets/banner_ad_widget.dart';
import 'widgets/habit_calendar_heatmap.dart';

class HabitDetailsScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  late Habit _currentHabit;
  List<CheckIn> _checkIns = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _currentHabit = widget.habit;
    _loadCheckInHistory();
  }

  Future<void> _loadCheckInHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final repository = RepositoryProvider.of<HabitRepository>(context);
      final checkIns = await repository.getCheckInsForHabit(_currentHabit.id);
      // Sort newest check-ins first
      checkIns.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) {
        setState(() {
          _checkIns = checkIns;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  void _triggerStreakRecovery() {
    AdHelper.showRewardedAd(
      onRewardEarned: () {
        context.read<HabitBloc>().add(RecoverStreakEvent(_currentHabit.id));
        AppSnackBar.showSuccess(context, AppStrings.streakRecoveredDetailsToast);
      },
      onAdFailedToLoad: () {
        AppSnackBar.showError(context, AppStrings.rewardedAdFailedDetails);
      },
    );
  }

  bool get _hasMissedDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final creationDate = DateTime(
      _currentHabit.creationDate.year,
      _currentHabit.creationDate.month,
      _currentHabit.creationDate.day,
    );

    final checkedDates = _checkIns
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();

    DateTime checkDate = today.subtract(const Duration(days: 1));
    while (!checkDate.isBefore(creationDate)) {
      if (!checkedDates.contains(checkDate)) {
        return true;
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    if (_currentHabit.currentStreak == 0 && !checkedDates.contains(today)) {
      return true;
    }

    return false;
  }


  Future<void> _pickAndSetReminder(BuildContext context) async {
    final initialTime = _currentHabit.hasReminder
        ? TimeOfDay(hour: _currentHabit.reminderHour!, minute: _currentHabit.reminderMinute!)
        : const TimeOfDay(hour: 8, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && context.mounted) {
      context.read<HabitBloc>().add(
            UpdateHabitReminderEvent(
              _currentHabit.id,
              reminderHour: picked.hour,
              reminderMinute: picked.minute,
            ),
          );
      AppSnackBar.showInfo(context, '${AppStrings.reminderSetPrefix}${AppConstants.formatReminderTime(picked.hour, picked.minute)}');
    }
  }

  void _toggleReminder(BuildContext context, bool enable) {
    if (enable) {
      _pickAndSetReminder(context);
    } else {
      context.read<HabitBloc>().add(
            UpdateHabitReminderEvent(_currentHabit.id, reminderHour: null, reminderMinute: null),
          );
      AppSnackBar.showInfo(context, '🔕 Reminder turned off');
    }
  }

  void _showEditHabitModal(BuildContext context) {
    final nameController = TextEditingController(text: _currentHabit.name);
    String selectedCategory = _currentHabit.category;
    String selectedColorHex = _currentHabit.colorHex;

    final categories = AppConstants.defaultCategories;
    final presetColors = AppConstants.presetColorHexes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final theme = Theme.of(modalCtx);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, color: AppColors.primarySeed, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.editHabitDetailsTitle,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Habit Name
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.habitNameLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.edit_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Selector
                    Text(
                      AppStrings.categoryLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (_) {
                                setModalState(() {
                                  selectedCategory = cat;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Color Theme Swatches
                    Text(
                      AppStrings.themeColorLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: presetColors.map((hex) {
                        final color = AppConstants.parseColorHex(hex);
                        final isSelected = selectedColorHex == hex;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedColorHex = hex;
                            });
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: AppColors.pureWhite, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          final newName = nameController.text.trim();
                          if (newName.isNotEmpty) {
                            context.read<HabitBloc>().add(
                                  EditHabitEvent(
                                    habitId: _currentHabit.id,
                                    name: newName,
                                    category: selectedCategory,
                                    colorHex: selectedColorHex,
                                    creationDate: _currentHabit.creationDate,
                                  ),
                                );
                            Navigator.of(modalCtx).pop();
                            AppSnackBar.showSuccess(context, AppStrings.habitDetailsUpdatedToast);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primarySeed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(AppStrings.saveChanges, style: AppTextStyles.buttonLabel),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _confirmAndDelete(BuildContext context) async {
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.dangerRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppStrings.deleteHabitTitle),
          ],
        ),
        content: Text(
          AppStrings.deleteConfirmMessage(_currentHabit.name),
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text(AppStrings.deleteAction),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<HabitBloc>().add(DeleteHabitEvent(_currentHabit.id));
      Navigator.of(context).pop();
      AppSnackBar.showInfo(context, AppStrings.habitDeletedMessage(_currentHabit.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = AppConstants.parseColorHex(_currentHabit.colorHex);

    return BlocListener<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitLoaded) {
          final updated = state.habits.firstWhere(
            (h) => h.id == _currentHabit.id,
            orElse: () => _currentHabit,
          );
          setState(() {
            _currentHabit = updated;
          });
          _loadCheckInHistory();
        }
      },
      child: Scaffold(
        bottomNavigationBar: const BannerAdWidget(),
        appBar: AppBar(
          title: Text(_currentHabit.name, style: AppTextStyles.appBarTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: AppStrings.editHabit,
              onPressed: () => _showEditHabitModal(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.dangerRed),
              tooltip: AppStrings.deleteHabit,
              onPressed: () => _confirmAndDelete(context),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Creative Hero Header Banner
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    habitColor,
                    habitColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: habitColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentHabit.category.toUpperCase(),
                            style: AppTextStyles.categoryChip.copyWith(
                              color: AppColors.pureWhite,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentHabit.name,
                          style: AppTextStyles.heroTitle,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppColors.pureWhite,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            // Streak Header Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: habitColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    color: habitColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        children: [
                          const Text(
                            '🔥',
                            style: AppTextStyles.emojiHeader,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentHabit.currentStreak}',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: habitColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.currentStreak,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    color: theme.colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        children: [
                          const Text(
                            '🏆',
                            style: AppTextStyles.emojiHeader,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentHabit.longestStreak}',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.longestStreak,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interactive Calendar Heatmap View with Custom Habit Color
            HabitCalendarHeatmap(
              habitId: _currentHabit.id,
              checkIns: _checkIns,
              activeColor: habitColor,
            ),

            const SizedBox(height: 16),

            if (_hasMissedDays) ...[
              // Recover Streak Banner Card (Rewarded Video Ad trigger)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.recoveryAmberBorder,
                    width: 1.5,
                  ),
                ),
                color: isDark ? AppColors.recoveryAmberBgDark : AppColors.recoveryAmberBgLight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.ondemand_video_rounded, color: AppColors.recoveryAmber, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.missedADayTitle,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.missedADaySubtitle,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _triggerStreakRecovery,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.adBadgeBg,
                            foregroundColor: AppColors.adBadgeText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: const Text(
                            AppStrings.recoverStreakWatchAd,
                            style: AppTextStyles.buttonLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metadata card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: AppColors.cardBorder(context),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.category_rounded, color: habitColor),
                    ),
                    title: Text(AppStrings.categoryAndCustomThemeColor, style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurface)),
                    subtitle: Text(
                      '${_currentHabit.category} (${_currentHabit.colorHex})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: habitColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _currentHabit.hasReminder
                            ? AppColors.primarySeed.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _currentHabit.hasReminder
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: _currentHabit.hasReminder
                            ? AppColors.primarySeed
                            : theme.colorScheme.outline,
                      ),
                    ),
                    title: const Text(
                      AppStrings.dailyReminderLabel,
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: Text(
                      _currentHabit.hasReminder
                          ? '${AppStrings.scheduledForPrefix}${AppConstants.formatReminderTime(_currentHabit.reminderHour!, _currentHabit.reminderMinute!)}'
                          : AppStrings.noReminderScheduled,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _currentHabit.hasReminder
                            ? AppColors.primarySeed
                            : theme.colorScheme.outline,
                        fontWeight: _currentHabit.hasReminder ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    value: _currentHabit.hasReminder,
                    activeTrackColor: AppColors.primarySeed,
                    onChanged: (val) => _toggleReminder(context, val),
                  ),
                  if (_currentHabit.hasReminder)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickAndSetReminder(context),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                          label: const Text(AppStrings.changeTime, style: AppTextStyles.captionSmall),
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                    ),
                    title: Text(AppStrings.createdOn, style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurface)),
                    subtitle: Text(AppConstants.formatDate(_currentHabit.creationDate), style: AppTextStyles.bodySmall.copyWith(color: theme.colorScheme.outline)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // History Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.checkInHistory,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  AppStrings.totalCount(_checkIns.length),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoadingHistory)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_checkIns.isEmpty)
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.noCheckInsLogged,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.tapDateHint,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _checkIns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final checkIn = _checkIns[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: habitColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: habitColor,
                        child: const Icon(Icons.check, color: AppColors.pureWhite),
                      ),
                      title: Text(
                        AppConstants.formatDate(checkIn.date),
                        style: AppTextStyles.titleMedium,
                      ),
                      subtitle: Text(AppStrings.completed, style: AppTextStyles.bodySmall),
                    ),
                  );
                },
              ),

            Container(
              margin: const EdgeInsets.only(top: 28, bottom: 24),
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () => _confirmAndDelete(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dangerRed,
                  foregroundColor: AppColors.pureWhite,
                  elevation: 4,
                  shadowColor: AppColors.dangerRed.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: AppColors.pureWhite,
                    size: 20,
                  ),
                ),
                label: const Text(
                  AppStrings.deleteThisHabit,
                  style: AppTextStyles.actionButtonLarge,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
