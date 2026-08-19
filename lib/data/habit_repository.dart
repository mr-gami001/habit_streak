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
  Future<Habit> addHabit(String name);
  Future<Habit> toggleCheckInToday(String habitId);
  Future<Habit> recoverStreak(String habitId);
  Future<List<CheckIn>> getCheckInsForHabit(String habitId);
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
  Future<Habit> addHabit(String name) async {
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
      );

      await _habitBox.put(newHabit.id, newHabit);
      return newHabit;
    } catch (e) {
      throw HabitStorageException('Failed to save new habit locally.', e);
    }
  }

  @override
  Future<Habit> toggleCheckInToday(String habitId) async {
    try {
      final habit = _habitBox.get(habitId);
      if (habit == null) {
        throw HabitStorageException('Habit not found.');
      }

      final today = _normalizeDate(DateTime.now());

      final existingCheckIns = _checkInBox.values.where(
        (c) => c.habitId == habitId && _normalizeDate(c.date).isAtSameMomentAs(today),
      ).toList();

      if (existingCheckIns.isNotEmpty) {
        for (final checkIn in existingCheckIns) {
          await _checkInBox.delete(checkIn.id);
        }
      } else {
        final checkIn = CheckIn(
          id: _uuid.v4(),
          habitId: habitId,
          date: today,
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
