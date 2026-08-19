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

  String _formatDate(DateTime dt) {
    return '${AppStrings.monthsShort[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        appBar: AppBar(
          title: Text(_currentHabit.name, style: AppTextStyles.appBarTitle),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Streak Header Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: theme.colorScheme.primaryContainer,
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
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.currentStreak,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
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
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.black,
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

            // Metadata card
            Card(
              elevation: 1,
              shape: AppColors.cardBorder(context) == BorderSide.none
                  ? null
                  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: AppColors.cardBorder(context),
                    ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(AppStrings.createdOn, style: AppTextStyles.bodyMedium),
                subtitle: Text(_formatDate(_currentHabit.creationDate), style: AppTextStyles.bodySmall),
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
                        AppStrings.checkInFromHomeHint,
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
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.completedGreen,
                        child: Icon(Icons.check, color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
