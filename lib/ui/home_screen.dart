import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../bloc/theme_cubit.dart';
import '../l10n/app_strings.dart';
import '../models/habit.dart';
import '../services/ad_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'add_habit_modal.dart';
import 'habit_details_screen.dart';
import 'widgets/app_logo_widget.dart';
import 'widgets/banner_ad_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddHabitModal(BuildContext context) {
    AddHabitModal.show(context);
  }

  void _navigateToDetails(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HabitDetailsScreen(habit: habit),
      ),
    );
  }

  void _triggerStreakRecovery(BuildContext context, Habit habit) {
    AdHelper.showRewardedAd(
      onRewardEarned: () {
        context.read<HabitBloc>().add(RecoverStreakEvent(habit.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.streakRecoveredToast),
            backgroundColor: AppColors.completedGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onAdFailedToLoad: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.rewardedAdFailedHome),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogoWidget(size: 32, borderRadius: 8),
            SizedBox(width: 10),
            Text(
              AppStrings.appHeaderTitle,
              style: AppTextStyles.appBarTitle,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : theme.colorScheme.onSurface,
            ),
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddHabitModal(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addHabit, style: AppTextStyles.buttonLabel),
      ),
      // Persistent Banner Ad at bottom (Strict AdMob placement policy compliance)
      bottomNavigationBar: const BannerAdWidget(),
      body: BlocConsumer<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HabitLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HabitLoaded) {
            if (state.habits.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.streakFireBgDark : AppColors.streakFireBgLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          size: 64,
                          color: AppColors.streakFire,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.noHabitsTitle,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.noHabitsSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _openAddHabitModal(context),
                        icon: const Icon(Icons.add),
                        label: const Text(AppStrings.createFirstHabit),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 96),
              itemCount: state.habits.length,
              itemBuilder: (context, index) {
                final habit = state.habits[index];
                final isCompletedToday = state.todayCompletedHabitIds.contains(habit.id);
                final canRecover = !isCompletedToday && habit.currentStreak == 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isCompletedToday
                        ? BorderSide(
                            color: isDark
                                ? AppColors.completedGreenBgDark
                                : AppColors.completedGreenBgLight,
                            width: 1.5,
                          )
                        : AppColors.cardBorder(context),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _navigateToDetails(context, habit),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Streak Counter Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCompletedToday
                                  ? (isDark ? AppColors.streakFireBgDark : AppColors.streakFireBgLight)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.currentStreak}',
                                  style: AppTextStyles.streakBadgeText.copyWith(
                                    color: isCompletedToday
                                        ? AppColors.streakFire
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Habit Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: isCompletedToday
                                      ? AppTextStyles.titleMediumCompleted.copyWith(
                                          color: theme.colorScheme.outline,
                                        )
                                      : AppTextStyles.titleMedium.copyWith(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isCompletedToday ? AppStrings.doneToday : AppStrings.tapCheckboxToMarkDone,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isCompletedToday
                                        ? AppColors.completedGreen
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (canRecover) ...[
                            TextButton.icon(
                              onPressed: () => _triggerStreakRecovery(context, habit),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.recoveryAmber,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              icon: const Icon(Icons.ondemand_video, size: 18),
                              label: const Text(
                                AppStrings.recover,
                                style: AppTextStyles.recoverButtonText,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],

                          // Toggle Check-in Button
                          IconButton.filledTonal(
                            iconSize: 26,
                            style: IconButton.styleFrom(
                              backgroundColor: isCompletedToday
                                  ? (isDark
                                      ? AppColors.completedGreenBgDark
                                      : AppColors.completedGreenBgLight)
                                  : theme.colorScheme.surfaceContainerHigh,
                              foregroundColor: isCompletedToday
                                  ? AppColors.completedGreen
                                  : theme.colorScheme.outline,
                            ),
                            icon: Icon(
                              isCompletedToday
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                            ),
                            onPressed: () {
                              context.read<HabitBloc>().add(ToggleCheckInEvent(habit.id));
                            },
                            tooltip: isCompletedToday
                                ? AppStrings.markAsIncomplete
                                : AppStrings.markCompletedToday,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
