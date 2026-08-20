import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/habit.dart';

class CalendarService {
  static final CalendarService instance = CalendarService._internal();
  CalendarService._internal();

  /// Dedicated method to create a new habit reminder event in the device calendar
  Future<String?> createHabitReminder(Habit habit) async {
    if (!habit.hasReminder) return null;

    try {
      final targetCalendar = await _getWritableCalendar();
      if (targetCalendar == null) return null;

      final times = _calculateEventTimes(habit);
      final title = '🔥 Habit: ${habit.name}';
      final description =
          'Daily Habit Reminder for "${habit.name}" (${habit.category}). Keep your streak active!';

      // Clean up any duplicate events with matching title before creating new one
      await _cleanupDuplicateEvents(targetCalendar.id, habit.name);

      final newEventId = await DeviceCalendar.instance.createEvent(
        calendarId: targetCalendar.id,
        title: title,
        description: description,
        startDate: times.start,
        endDate: times.end,
        location: 'Habit Streak Tracker App',
        recurrenceRule: const DailyRecurrence(),
      );

      return newEventId;
    } catch (e) {
      debugPrint('Failed to create calendar event: $e');
      return null;
    }
  }

  /// Dedicated method to update an existing habit reminder event in the device calendar
  Future<String?> updateHabitReminder(Habit habit) async {
    if (!habit.hasReminder) {
      await deleteHabitReminder(habit);
      return null;
    }

    try {
      // Safely delete existing event to prevent Android DTEND & DURATION recurrence conflicts
      await deleteHabitReminder(habit);

      // Create updated event with new time and return new calendarEventId
      return await createHabitReminder(habit);
    } catch (e) {
      debugPrint('Error updating habit reminder in calendar: $e');
      return null;
    }
  }

  /// Dedicated method to delete a habit reminder event from the device calendar
  Future<void> deleteHabitReminder(Habit habit) async {
    try {
      final targetCalendar = await _getWritableCalendar();
      if (targetCalendar == null) return;

      if (habit.calendarEventId != null && habit.calendarEventId!.isNotEmpty) {
        try {
          await DeviceCalendar.instance.deleteEvent(eventId: habit.calendarEventId!);
        } catch (e) {
          debugPrint('Failed to delete calendar event: $e');
        }
      }

      await _cleanupDuplicateEvents(targetCalendar.id, habit.name);
    } catch (e) {
      debugPrint('Failed to delete calendar event: $e');
    }
  }

  /// Synchronizes a habit reminder by delegating to create, update, or delete
  Future<String?> syncHabitReminder(Habit habit) async {
    if (!habit.hasReminder) {
      await deleteHabitReminder(habit);
      return null;
    }

    if (habit.calendarEventId != null && habit.calendarEventId!.isNotEmpty) {
      return await updateHabitReminder(habit);
    } else {
      return await createHabitReminder(habit);
    }
  }

  /// Helper to get a writable calendar on the device with permission check
  Future<Calendar?> _getWritableCalendar() async {
    var status = await DeviceCalendar.instance.hasPermissions();
    if (status != CalendarPermissionStatus.granted) {
      status = await DeviceCalendar.instance.requestPermissions();
      if (status != CalendarPermissionStatus.granted) {
        debugPrint('Calendar permissions denied by user.');
        return null;
      }
    }

    final calendars = await DeviceCalendar.instance.listCalendars();
    if (calendars.isEmpty) return null;

    final writableCalendars = calendars.where((c) => !c.readOnly).toList();
    if (writableCalendars.isEmpty) return null;

    return writableCalendars.first;
  }

  /// Helper to compute start & end times for habit reminder
  ({DateTime start, DateTime end}) _calculateEventTimes(Habit habit) {
    final now = DateTime.now();
    var startDate = DateTime(
      now.year,
      now.month,
      now.day,
      habit.reminderHour ?? 8,
      habit.reminderMinute ?? 0,
    );

    if (startDate.isBefore(now)) {
      startDate = startDate.add(const Duration(days: 1));
    }

    final endDate = startDate.add(const Duration(minutes: 30));
    return (start: startDate, end: endDate);
  }

  /// Helper to clean up any duplicate events matching the habit name
  Future<void> _cleanupDuplicateEvents(
    String calendarId,
    String habitName, {
    String? keepEventId,
  }) async {
    try {
      final now = DateTime.now();
      final events = await DeviceCalendar.instance.listEvents(
        now.subtract(const Duration(days: 30)),
        now.add(const Duration(days: 365)),
        calendarIds: [calendarId],
      );

      final deletedIds = <String>{};
      final cleanHabitName = habitName.trim().toLowerCase();

      for (final e in events) {
        if (keepEventId != null && e.eventId == keepEventId) continue;
        if (deletedIds.contains(e.eventId)) continue;

        final t = (e.title).toLowerCase();
        if (t.contains(cleanHabitName) || t.contains('habit:')) {
          try {
            await DeviceCalendar.instance.deleteEvent(eventId: e.eventId);
            deletedIds.add(e.eventId);
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up duplicate calendar events: $e');
    }
  }
}
