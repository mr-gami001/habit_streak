import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/notification_cubit.dart';
import '../bloc/theme_cubit.dart';
import '../data/habit_repository.dart';
import '../l10n/app_strings.dart';
import '../services/backup_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/app_logo_widget.dart';
import 'widgets/banner_ad_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _exportBackup(BuildContext context) async {
    final repository = RepositoryProvider.of<HabitRepository>(context);
    final success = await BackupService.instance.exportBackup(repository);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.exportSuccessToast),
          backgroundColor: AppColors.completedGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmAndImportBackup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.importConfirmTitle),
        content: const Text(AppStrings.importConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primarySeed,
            ),
            child: const Text(AppStrings.confirmImportAction),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final repository = RepositoryProvider.of<HabitRepository>(context);
      final success = await BackupService.instance.importBackup(repository);
      if (context.mounted) {
        if (success) {
          context.read<HabitBloc>().add(LoadHabitsEvent());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.importSuccessToast),
              backgroundColor: AppColors.completedGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.importErrorToast),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      appBar: AppBar(
        title: const Text(AppStrings.profileAndSettings, style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Profile Banner
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: AppColors.cardBorder(context),
            ),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const AppLogoWidget(size: 64, borderRadius: 16),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appHeaderTitle,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.appTagline,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section 1: Notifications
          Text(
            AppStrings.notificationsSection,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: AppColors.cardBorder(context),
            ),
            child: BlocBuilder<NotificationCubit, bool>(
              builder: (context, isEnabled) {
                return SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppColors.primarySeed.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      color: isEnabled
                          ? AppColors.primarySeed
                          : theme.colorScheme.outline,
                    ),
                  ),
                  title: Text(
                    AppStrings.enableNotifications,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.enableNotificationsSubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  value: isEnabled,
                  activeTrackColor: AppColors.primarySeed,
                  onChanged: (val) {
                    context.read<NotificationCubit>().toggleNotifications(val);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? AppStrings.notificationsEnabledToast
                            : AppStrings.notificationsDisabledToast),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Appearance & Theme
          Text(
            AppStrings.appearanceSection,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: AppColors.cardBorder(context),
            ),
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, currentMode) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondarySeed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.palette_rounded,
                              color: AppColors.secondarySeed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.themeModeLabel,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_rounded),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_rounded),
                          ),
                        ],
                        selected: {
                          currentMode == ThemeMode.light
                              ? ThemeMode.light
                              : ThemeMode.dark
                        },
                        onSelectionChanged: (newSelection) {
                          final selected = newSelection.first;
                          context.read<ThemeCubit>().setTheme(selected);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Data Backup & Restore
          Text(
            AppStrings.dataManagementSection,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
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
                      color: AppColors.primarySeed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: AppColors.primarySeed,
                    ),
                  ),
                  title: Text(
                    AppStrings.exportBackup,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.exportBackupSubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _exportBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySeed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: AppColors.secondarySeed,
                    ),
                  ),
                  title: Text(
                    AppStrings.importBackup,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.importBackupSubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _confirmAndImportBackup(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 4: About & Privacy
          Text(
            AppStrings.aboutSection,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: AppColors.cardBorder(context),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                AppStrings.appTitle,
                style: AppTextStyles.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                AppStrings.appVersion,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
