import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../data/habit_repository.dart';
import '../l10n/app_strings.dart';
import '../models/check_in.dart';
import '../models/habit.dart';
import '../services/ad_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.streakRecoveredDetailsToast),
            backgroundColor: AppColors.completedGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onAdFailedToLoad: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.rewardedAdFailedDetails),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  String _formatDate(DateTime dt) {
    return '${AppStrings.monthsShort[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatReminderTime(int hour, int minute) {
    final dt = DateTime(2026, 1, 1, hour, minute);
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
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
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 Reminder set for ${_formatReminderTime(picked.hour, picked.minute)}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleReminder(BuildContext context, bool enable) {
    if (enable) {
      _pickAndSetReminder(context);
    } else {
      context.read<HabitBloc>().add(
            UpdateHabitReminderEvent(_currentHabit.id, reminderHour: null, reminderMinute: null),
          );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔕 Reminder turned off'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditHabitModal(BuildContext context) {
    final nameController = TextEditingController(text: _currentHabit.name);
    String selectedCategory = _currentHabit.category;
    String selectedColorHex = _currentHabit.colorHex;

    final categories = [
      'Health',
      'Fitness',
      'Productivity',
      'Study',
      'Mindfulness',
      'Finance',
      'General',
    ];

    final presetColors = [
      '#00BFA5',
      '#7C4DFF',
      '#FF6E40',
      '#2ECC71',
      '#FFB300',
      '#29B6F6',
      '#EC407A',
      '#5C6BC0',
    ];

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
                          'Edit Habit Details',
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
                        labelText: 'Habit Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.edit_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Selector
                    Text(
                      'Category',
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
                      'Theme Color',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: presetColors.map((hex) {
                        final color = _parseColorHex(hex);
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
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Habit details updated successfully!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
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
                        label: const Text('Save Changes', style: AppTextStyles.buttonLabel),
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

  Color _parseColorHex(String hexString) {
    try {
      final cleanHex = hexString.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF00BFA5);
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
                color: Colors.redAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Habit?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_currentHabit.name}"? This action will permanently remove this habit and all check-in history.',
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
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<HabitBloc>().add(DeleteHabitEvent(_currentHabit.id));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_currentHabit.name}" deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = _parseColorHex(_currentHabit.colorHex);

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
              tooltip: 'Edit Habit',
              onPressed: () => _showEditHabitModal(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              tooltip: 'Delete Habit',
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
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentHabit.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentHabit.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
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
                            style: TextStyle(fontSize: 32),
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
                            style: TextStyle(fontSize: 32),
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
                    title: Text('Category & Custom Theme Color', style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurface)),
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
                    title: Text(
                      'Daily Reminder',
                      style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      _currentHabit.hasReminder
                          ? 'Scheduled for ${_formatReminderTime(_currentHabit.reminderHour!, _currentHabit.reminderMinute!)}'
                          : 'No reminder scheduled',
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
                          label: const Text('Change Time', style: TextStyle(fontSize: 12)),
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
                    subtitle: Text(_formatDate(_currentHabit.creationDate), style: AppTextStyles.bodySmall.copyWith(color: theme.colorScheme.outline)),
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
                  '${_checkIns.length} Total',
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
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      title: Text(
                        _formatDate(checkIn.date),
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
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.redAccent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                label: const Text(
                  'Delete This Habit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
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
