import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/habit_repository.dart';
import '../models/check_in.dart';
import '../models/habit.dart';
import 'notification_service.dart';

class BackupService {
  static final BackupService instance = BackupService._internal();
  BackupService._internal();

  /// Exports all habits and check-ins into a formatted JSON backup file and opens native Share Sheet.
  Future<bool> exportBackup(HabitRepository repository) async {
    try {
      final habits = await repository.getHabits();
      final allCheckIns = <CheckIn>[];

      for (final habit in habits) {
        final checkIns = await repository.getCheckInsForHabit(habit.id);
        allCheckIns.addAll(checkIns);
      }

      final backupData = {
        'version': 1,
        'appName': 'Habit Streak Tracker',
        'exportDate': DateTime.now().toIso8601String(),
        'habits': habits
            .map((h) => {
                  'id': h.id,
                  'name': h.name,
                  'creationDate': h.creationDate.toIso8601String(),
                  'currentStreak': h.currentStreak,
                  'longestStreak': h.longestStreak,
                  'reminderHour': h.reminderHour,
                  'reminderMinute': h.reminderMinute,
                  'category': h.category,
                  'colorHex': h.colorHex,
                })
            .toList(),
        'checkIns': allCheckIns
            .map((c) => {
                  'id': c.id,
                  'habitId': c.habitId,
                  'date': c.date.toIso8601String(),
                })
            .toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'habit_streak_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Habit Streak Tracker Backup JSON File',
        ),
      );

      return true;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  /// Opens FilePicker to pick a JSON backup file and restores data safely into local storage.
  Future<bool> importBackup(HabitRepository repository) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return false;
      }

      final file = files.first;
      String jsonString;

      if (file.path != null) {
        jsonString = await File(file.path!).readAsString();
      } else {
        try {
          final bytes = await file.readAsBytes();
          jsonString = utf8.decode(bytes);
        } catch (_) {
          return false;
        }
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (!data.containsKey('habits') || !data.containsKey('checkIns')) {
        return false;
      }

      final habitsJson = data['habits'] as List;
      final checkInsJson = data['checkIns'] as List;

      final habits = habitsJson.map((h) {
        return Habit(
          id: h['id'] as String,
          name: h['name'] as String,
          creationDate: DateTime.parse(h['creationDate'] as String),
          currentStreak: (h['currentStreak'] as num?)?.toInt() ?? 0,
          longestStreak: (h['longestStreak'] as num?)?.toInt() ?? 0,
          reminderHour: (h['reminderHour'] as num?)?.toInt(),
          reminderMinute: (h['reminderMinute'] as num?)?.toInt(),
          category: h['category'] as String? ?? 'Health',
          colorHex: h['colorHex'] as String? ?? '#00BFA5',
        );
      }).toList();

      final checkIns = checkInsJson.map((c) {
        return CheckIn(
          id: c['id'] as String,
          habitId: c['habitId'] as String,
          date: DateTime.parse(c['date'] as String),
        );
      }).toList();

      await repository.restoreBackupData(habits: habits, checkIns: checkIns);

      // Re-schedule daily notifications for habits with reminders
      for (final habit in habits) {
        if (habit.hasReminder) {
          await NotificationService.instance.scheduleDailyHabitReminder(habit);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }
}
