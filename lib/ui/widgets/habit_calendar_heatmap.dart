import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/habit_bloc.dart';
import '../../bloc/habit_event.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_strings.dart';
import '../../models/check_in.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'app_snackbar.dart';

class HabitCalendarHeatmap extends StatefulWidget {
  final String habitId;
  final List<CheckIn> checkIns;
  final Color? activeColor;

  const HabitCalendarHeatmap({
    super.key,
    required this.habitId,
    required this.checkIns,
    this.activeColor,
  });

  @override
  State<HabitCalendarHeatmap> createState() => _HabitCalendarHeatmapState();
}

class _HabitCalendarHeatmapState extends State<HabitCalendarHeatmap> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    if (_focusedMonth.isBefore(currentMonth)) {
      setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }


  void _onDateTap(DateTime date, bool isCompleted, bool isFuture) {
    if (isFuture) return;

    context.read<HabitBloc>().add(ToggleCheckInDateEvent(widget.habitId, date));

    final dateStr = '${AppStrings.monthsShort[date.month - 1]} ${date.day}';
    final msg = isCompleted
        ? '${AppStrings.checkInRemovedToast}$dateStr'
        : '${AppStrings.checkInAddedToast}$dateStr';

    if (isCompleted) {
      AppSnackBar.showInfo(context, '$msg');
    } else {
      AppSnackBar.showSuccess(context, '$msg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = widget.activeColor ?? AppColors.completedGreen;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentMonth = DateTime(now.year, now.month);
    final canGoNext = _focusedMonth.isBefore(currentMonth);

    // Month Grid Calculation
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final leadingPadding = firstWeekday - 1; // 0-based offset for Monday start

    // Set of check-in dates for current habit
    final checkInDates = widget.checkIns.map((c) => DateTime(c.date.year, c.date.month, c.date.day)).toSet();

    int completedCount = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      if (checkInDates.any((d) => _isSameDay(d, date))) {
        completedCount++;
      }
    }
    final int completionPercentage = daysInMonth > 0 ? ((completedCount / daysInMonth) * 100).round() : 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.monthlyConsistency,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.tapDateHint,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _previousMonth,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      AppConstants.formatMonthYear(_focusedMonth),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: canGoNext ? theme.colorScheme.onSurface : theme.colorScheme.outlineVariant,
                      ),
                      onPressed: canGoNext ? _nextMonth : null,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weekday Headers
            Row(
              children: AppStrings.weekDaysShort.map((dayName) {
                return Expanded(
                  child: Center(
                    child: Text(
                      dayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Monthly Calendar Grid (7 Columns)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leadingPadding + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                if (index < leadingPadding) {
                  return const SizedBox.shrink();
                }

                final dayNumber = index - leadingPadding + 1;
                final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                final isCompleted = checkInDates.any((d) => _isSameDay(d, date));
                final isToday = _isSameDay(date, today);
                final isFuture = date.isAfter(today);

                return InkWell(
                  onTap: () => _onDateTap(date, isCompleted, isFuture),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? accentColor
                          : isFuture
                              ? AppColors.transparent
                              : (isDark ? AppColors.darkSurface : theme.colorScheme.surfaceContainerHigh),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? AppColors.primarySeed
                            : isCompleted
                                ? accentColor
                                : isFuture
                                    ? AppColors.transparent
                                    : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AppColors.pureWhite,
                            )
                          : Text(
                              '$dayNumber',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                color: isFuture
                                    ? theme.colorScheme.outline.withValues(alpha: 0.4)
                                    : (isToday
                                        ? AppColors.primarySeed
                                        : theme.colorScheme.onSurface),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Monthly Completion Summary Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.daysCompleted(completedCount, daysInMonth),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completionPercentage%',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
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
