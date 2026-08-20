class AppStrings {
  // App General
  static const String appTitle = 'Habit Streak';
  static const String appHeaderTitle = 'Habit Streak';
  static const String appHeaderEmoji = '🔥 ';
  // Splash Screen
  static const String appTagline = 'Build Daily Streaks & Habits';
  static const String loadingHabits = 'Preparing your habits...';
  static const String readyingAds = 'Loading experience...';

  // Home Screen
  static const String addHabit = 'Add Habit';
  static const String noHabitsTitle = 'No Habits Yet';
  static const String noHabitsSubtitle = 'Start building daily streaks by creating your first habit!';
  static const String createFirstHabit = 'Create First Habit';
  static const String doneToday = 'Done today!';
  static const String tapCheckboxToMarkDone = 'Tap checkbox to mark done';
  static const String recover = 'Recover';
  static const String markAsIncomplete = 'Mark as incomplete';
  static const String markCompletedToday = 'Mark completed today';

  // Add Habit Modal
  static const String createNewHabit = 'Create New Habit';
  static const String habitNameLabel = 'Habit Name';
  static const String habitNameHint = 'e.g., Read 20 pages, Morning Exercise';
  static const String habitNameValidationError = 'Please enter a habit name';
  static const String cancel = 'Cancel';
  static const String saveHabit = 'Save Habit';
  static const String setDailyReminder = 'Set Daily Reminder';
  static const String reminderTimeLabel = 'Reminder Time';
  static const String selectTime = 'Select Time';

  // Habit Details Screen
  static const String currentStreak = 'Current Streak';
  static const String longestStreak = 'Longest Streak';
  static const String missedADayTitle = 'Missed a day?';
  static const String missedADaySubtitle = 'Watch a short video ad to restore your current streak!';
  static const String recoverStreakWatchAd = 'Recover Streak (Watch Ad)';
  static const String createdOn = 'Created On';
  static const String checkInHistory = 'Check-in History';
  static const String noCheckInsLogged = 'No check-ins logged yet';
  static const String completed = 'Completed';

  // Heatmap & Calendar View
  static const String monthlyConsistency = 'Monthly Consistency';
  static const String tapDateHint = 'Tap any date to toggle check-in status';
  static const String checkInAddedToast = 'Check-in recorded for ';
  static const String checkInRemovedToast = 'Check-in removed for ';
  static const List<String> weekDaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Snackbars & Ad Messages
  static const String streakRecoveredToast = '🎉 Streak Recovered! Keep up the great work!';
  static const String streakRecoveredDetailsToast = '🎉 Streak Recovered! Keep up your streak!';
  static const String rewardedAdFailedHome = 'Could not load Rewarded Ad. Please try again later.';
  static const String rewardedAdFailedDetails = 'Failed to load Rewarded Video Ad. Please try again.';
  static const String openingSponsorLinkPrefix = 'Opening sponsor link: ';

  // Banner Ads
  static const String adBadge = 'Ad';

  // Profile & Settings
  static const String profileAndSettings = 'Profile & Settings';
  static const String notificationsSection = 'Daily Notifications';
  static const String enableNotifications = 'Enable Notifications';
  static const String enableNotificationsSubtitle =
      'Receive local alarm reminders for your scheduled habits';
  static const String notificationsEnabledToast = '🔔 Daily Notifications Enabled!';
  static const String notificationsDisabledToast = '🔕 Daily Notifications Disabled.';
  static const String appearanceSection = 'Appearance & Theme';
  static const String themeModeLabel = 'Theme Mode';
  static const String dataManagementSection = 'Data & Storage';
  static const String backupAndRestore = 'Backup & Restore';
  static const String exportBackup = 'Export Backup JSON';
  static const String exportBackupSubtitle = 'Save habit progress to a JSON backup file';
  static const String importBackup = 'Import Backup JSON';
  static const String importBackupSubtitle = 'Restore habits and history from a backup file';
  static const String importConfirmTitle = 'Import Backup Data?';
  static const String importConfirmMessage =
      'This will merge imported habits and check-in records into your local database. Current progress will be preserved. Do you wish to continue?';
  static const String confirmImportAction = 'Import Data';
  static const String exportSuccessToast = '✅ Backup JSON exported successfully!';
  static const String importSuccessToast = '🎉 Backup restored successfully!';
  static const String importErrorToast = '❌ Invalid or corrupted backup file.';
  static const String aboutSection = 'About & Privacy';
  static const String appVersion = 'Version 1.0.0 (100% Offline & Private)';

  // Months
  static const List<String> monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}
