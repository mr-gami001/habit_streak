import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../constants/app_constants.dart';
import '../l10n/app_strings.dart';
import '../models/habit.dart';
import '../services/ad_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'add_habit_modal.dart';
import 'habit_details_screen.dart';
import 'profile_screen.dart';
import 'widgets/app_logo_widget.dart';
import 'widgets/app_snackbar.dart';
import 'widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategoryFilter = AppStrings.allCategoryFilter;

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
        AppSnackBar.showSuccess(context, AppStrings.streakRecoveredToast);
      },
      onAdFailedToLoad: () {
        AppSnackBar.showError(context, AppStrings.rewardedAdFailedHome);
      },
    );
  }


  List<String> _getAvailableCategories(List<Habit> habits) {
    final categoriesSet = <String>{
      AppStrings.allCategoryFilter,
      ...AppStrings.defaultCategories,
    };
    for (final habit in habits) {
      if (habit.category.isNotEmpty) {
        categoriesSet.add(habit.category);
      }
    }
    return categoriesSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person_rounded),
          tooltip: AppStrings.profileAndSettings,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddHabitModal(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addHabit, style: AppTextStyles.buttonLabel),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: BlocConsumer<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitError) {
            AppSnackBar.showError(context, state.message);
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

            final categories = _getAvailableCategories(state.habits);
            final filteredHabits = _selectedCategoryFilter == AppStrings.allCategoryFilter
                ? state.habits
                : state.habits.where((h) => h.category == _selectedCategoryFilter).toList();

            return Column(
              children: [
                // Horizontal Category Filter Bar
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategoryFilter == cat;

                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        showCheckmark: false,
                        labelStyle: (isSelected
                                ? AppTextStyles.filterChipSelected
                                : AppTextStyles.filterChipUnselected)
                            .copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        selectedColor: AppColors.primarySeed,
                        backgroundColor: isDark
                            ? AppColors.darkSurface
                            : theme.colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: isSelected
                              ? BorderSide.none
                              : BorderSide(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryFilter = cat;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Habit List
                Expanded(
                  child: filteredHabits.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              AppStrings.noHabitsInCategory(_selectedCategoryFilter),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 96),
                          itemCount: filteredHabits.length,
                          itemBuilder: (context, index) {
                            final habit = filteredHabits[index];
                            final isCompletedToday = state.todayCompletedHabitIds.contains(habit.id);
                            final canRecover = !isCompletedToday && habit.currentStreak == 0;
                            final customColor = AppConstants.parseColorHex(habit.colorHex);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [
                                    customColor.withValues(alpha: isDark ? 0.16 : 0.08),
                                    isDark ? AppColors.darkSurface : AppColors.pureWhite,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: customColor.withValues(alpha: isDark ? 0.15 : 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: isCompletedToday
                                      ? customColor
                                      : customColor.withValues(alpha: 0.35),
                                  width: isCompletedToday ? 1.5 : 1.0,
                                ),
                              ),
                              child: Material(
                                color: AppColors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _navigateToDetails(context, habit),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        // Creative Left Vertical Color Stripe Accent
                                        Container(
                                          width: 5,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: customColor,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: customColor.withValues(alpha: 0.6),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Streak Counter Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: customColor.withValues(alpha: isDark ? 0.25 : 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: customColor.withValues(alpha: 0.4),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text('🔥', style: AppTextStyles.emojiInline),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${habit.currentStreak}',
                                                style: AppTextStyles.streakBadgeText.copyWith(
                                                  color: isCompletedToday ? AppColors.streakFire : customColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Habit Info & Category Tag
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                habit.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: isCompletedToday
                                                    ? AppTextStyles.titleMediumCompleted.copyWith(
                                                        color: theme.colorScheme.outline,
                                                      )
                                                    : AppTextStyles.titleMedium.copyWith(
                                                        color: theme.colorScheme.onSurface,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  // Category Tag Chip
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: customColor.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      habit.category,
                                                      style: AppTextStyles.cardTag.copyWith(color: customColor),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      isCompletedToday
                                                          ? AppStrings.doneToday
                                                          : AppStrings.tapCheckboxToMarkDone,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: AppTextStyles.bodySmall.copyWith(
                                                        color: isCompletedToday
                                                            ? AppColors.completedGreen
                                                            : theme.colorScheme.outline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        if (canRecover) ...[
                                          TextButton.icon(
                                            onPressed: () => _triggerStreakRecovery(context, habit),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.recoveryAmber,
                                              padding: const EdgeInsets.symmetric(horizontal: 6),
                                            ),
                                            icon: const Icon(Icons.ondemand_video, size: 16),
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
                                                ? customColor
                                                : theme.colorScheme.surfaceContainerHigh,
                                            foregroundColor: isCompletedToday
                                                ? AppColors.pureWhite
                                                : customColor,
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
