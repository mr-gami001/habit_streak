import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/check_in.dart';
import '../models/habit.dart';

class HabitStorageException implements Exception {
  final String message;
  final dynamic originalError;

  HabitStorageException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

abstract class HabitRepository {
  Future<void> init();
  Future<List<Habit>> getHabits();
  Future<Habit> addHabit(
    String name, {
    int? reminderHour,
    int? reminderMinute,
    String? category,
    String? colorHex,
  });
  Future<Habit> toggleCheckInToday(String habitId);
  Future<Habit> toggleCheckInForDate(String habitId, DateTime date);
  Future<Habit> recoverStreak(String habitId);
  Future<void> deleteHabit(String habitId);
  Future<Habit> updateHabitReminder(String habitId, {int? reminderHour, int? reminderMinute});
  Future<Habit> updateHabitDetails(
    String habitId, {
    required String name,
    required String category,
    required String colorHex,
    required DateTime creationDate,
  });
  Future<Habit> updateCalendarEventId(String habitId, String? calendarEventId);
  Future<List<CheckIn>> getCheckInsForHabit(String habitId);
  Future<void> restoreBackupData({required List<Habit> habits, required List<CheckIn> checkIns});
}

class HiveHabitRepository implements HabitRepository {
  static const String habitBoxName = 'habits_box';
  static const String checkInBoxName = 'checkins_box';

  late Box<Habit> _habitBox;
  late Box<CheckIn> _checkInBox;
  final _uuid = const Uuid();

  @override
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HabitAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CheckInAdapter());
      }

      _habitBox = await Hive.openBox<Habit>(habitBoxName);
      _checkInBox = await Hive.openBox<CheckIn>(checkInBoxName);
    } catch (e) {
      throw HabitStorageException('Failed to initialize local offline database.', e);
    }
  }

  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  @override
  Future<List<Habit>> getHabits() async {
    try {
      final habits = _habitBox.values.toList();
      final updatedHabits = <Habit>[];

      for (final habit in habits) {
        final updated = await _recalculateStreak(habit);
        updatedHabits.add(updated);
      }
      return updatedHabits;
    } catch (e) {
      throw HabitStorageException('Could not retrieve habits from storage.', e);
    }
  }

  @override
  Future<Habit> addHabit(
    String name, {
    int? reminderHour,
    int? reminderMinute,
    String? category,
    String? colorHex,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw HabitStorageException('Habit name cannot be empty.');
    }

    try {
      final newHabit = Habit(
        id: _uuid.v4(),
        name: trimmedName,
        creationDate: _normalizeDate(DateTime.now()),
        currentStreak: 0,
        longestStreak: 0,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        category: category ?? 'Health',
        colorHex: colorHex ?? '#00BFA5',
      );

      await _habitBox.put(newHabit.id, newHabit);
      return newHabit;
    } catch (e) {
      throw HabitStorageException('Failed to save new habit locally.', e);
    }
  }

  @override
  Future<Habit> toggleCheckInToday(String habitId) async {
    return toggleCheckInForDate(habitId, DateTime.now());
  }

  @override
  Future<Habit> toggleCheckInForDate(String habitId, DateTime date) async {
    try {
      final habit = _habitBox.get(habitId);
      if (habit == null) {
        throw HabitStorageException('Habit not found.');
      }

      final targetDate = _normalizeDate(date);

      final existingCheckIns = _checkInBox.values.where(
        (c) => c.habitId == habitId && _normalizeDate(c.date).isAtSameMomentAs(targetDate),
      ).toList();

      if (existingCheckIns.isNotEmpty) {
        for (final checkIn in existingCheckIns) {
          await _checkInBox.delete(checkIn.id);
        }
      } else {
        final checkIn = CheckIn(
          id: _uuid.v4(),
          habitId: habitId,
          date: targetDate,
        );
        await _checkInBox.put(checkIn.id, checkIn);
      }

      return await _recalculateStreak(habit);
    } catch (e) {
      if (e is HabitStorageException) rethrow;
      throw HabitStorageException('Failed to complete check-in operation.', e);
    }
  }

  @override
  Future<List<CheckIn>> getCheckInsForHabit(String habitId) async {
    try {
      return _checkInBox.values.where((c) => c.habitId == habitId).toList();
    } catch (e) {
      throw HabitStorageException('Failed to load check-in history.', e);
    }
  }

  @override
  Future<Habit> recoverStreak(String habitId) async {
    try {
      final habit = _habitBox.get(habitId);
      if (habit == null) {
        throw HabitStorageException('Habit not found.');
      }

      final today = _normalizeDate(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));

      // Find if yesterday has check-in
      final checkInDates = _checkInBox.values
          .where((c) => c.habitId == habitId)
          .map((c) => _normalizeDate(c.date))
          .toSet();

      // If yesterday was missed, recover yesterday. If today & yesterday missed, add yesterday
      DateTime recoverDate = yesterday;
      if (!checkInDates.contains(yesterday)) {
        recoverDate = yesterday;
      } else if (!checkInDates.contains(today)) {
        recoverDate = today;
      }

      final checkIn = CheckIn(
        id: _uuid.v4(),
        habitId: habitId,
        date: recoverDate,
      );
      await _checkInBox.put(checkIn.id, checkIn);

      return await _recalculateStreak(habit);
    } catch (e) {
      if (e is HabitStorageException) rethrow;
      throw HabitStorageException('Failed to recover streak.', e);
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitBox.delete(habitId);

      final checkInsToDelete = _checkInBox.values
          .where((c) => c.habitId == habitId)
          .map((c) => c.id)
          .toList();

      for (final checkInId in checkInsToDelete) {
        await _checkInBox.delete(checkInId);
      }
    } catch (e) {
      throw HabitStorageException('Failed to delete habit from local storage.', e);
    }
  }

  @override
  Future<Habit> updateHabitReminder(
    String habitId, {
    int? reminderHour,
    int? reminderMinute,
  }) async {
    try {
      final habit = _habitBox.get(habitId);
      if (habit == null) {
        throw HabitStorageException('Habit not found.');
      }

      final updated = habit.copyWith(
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      );

      await _habitBox.put(habitId, updated);
      return updated;
    } catch (e) {
      if (e is HabitStorageException) rethrow;
      throw HabitStorageException('Failed to update habit reminder settings.', e);
    }
  }

  @override
  Future<Habit> updateHabitDetails(
    String habitId, {
    required String name,
    required String category,
    required String colorHex,
    required DateTime creationDate,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw HabitStorageException('Habit name cannot be empty.');
    }

    try {
      final habit = _habitBox.get(habitId);
      if (habit == null) {
        throw HabitStorageException('Habit not found.');
      }

      final updated = habit.copyWith(
        name: trimmedName,
        category: category,
        colorHex: colorHex,
        creationDate: _normalizeDate(creationDate),
      );

      await _habitBox.put(habitId, updated);
      return await _recalculateStreak(updated);
    } catch (e) {
      if (e is HabitStorageException) rethrow;
      throw HabitStorageException('Failed to update habit details.', e);
    }
  }

  @override
  Future<Habit> updateCalendarEventId(String habitId, String? calendarEventId) async {
    try {
      final habit = _habitBox.get(habitId);
      if (habit == null) {
        throw HabitStorageException('Habit not found.');
      }

      final updated = habit.copyWith(calendarEventId: calendarEventId);
      await _habitBox.put(habitId, updated);
      return updated;
    } catch (e) {
      if (e is HabitStorageException) rethrow;
      throw HabitStorageException('Failed to update calendar event ID.', e);
    }
  }

  @override
  Future<void> restoreBackupData({
    required List<Habit> habits,
    required List<CheckIn> checkIns,
  }) async {
    try {
      // Put/merge all habits
      for (final habit in habits) {
        await _habitBox.put(habit.id, habit);
      }
      // Put/merge all check-ins
      for (final checkIn in checkIns) {
        await _checkInBox.put(checkIn.id, checkIn);
      }
      // Recalculate streaks for all habits
      final allHabits = _habitBox.values.toList();
      for (final habit in allHabits) {
        await _recalculateStreak(habit);
      }
    } catch (e) {
      throw HabitStorageException('Failed to restore backup data to local storage.', e);
    }
  }

  Future<Habit> _recalculateStreak(Habit habit) async {
    final checkInDates = _checkInBox.values
        .where((c) => c.habitId == habit.id)
        .map((c) => _normalizeDate(c.date))
        .toSet();

    final today = _normalizeDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    final hasToday = checkInDates.contains(today);
    final hasYesterday = checkInDates.contains(yesterday);

    int currentStreak = 0;

    if (hasToday) {
      currentStreak = 1;
      var checkDate = yesterday;
      while (checkInDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else if (hasYesterday) {
      currentStreak = 1;
      var checkDate = yesterday.subtract(const Duration(days: 1));
      while (checkInDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else {
      currentStreak = 0;
    }

    final longestStreak = currentStreak > habit.longestStreak
        ? currentStreak
        : habit.longestStreak;

    final updatedHabit = habit.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );

    if (updatedHabit != habit) {
      await _habitBox.put(habit.id, updatedHabit);
    }

    return updatedHabit;
  }
}
