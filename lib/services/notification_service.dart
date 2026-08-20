import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize timezone database
    tz.initializeTimeZones();
    try {
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = 'UTC';
      if (tzResult is String) {
        timeZoneName = tzResult;
      } else if (tzResult != null) {
        try {
          timeZoneName = tzResult.identifier?.toString() ??
              tzResult.id?.toString() ??
              tzResult.name?.toString() ??
              tzResult.toString();
        } catch (_) {
          timeZoneName = tzResult.toString();
        }
      }
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Configure Android & Darwin Initialization Settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    // 3. Android-specific channel creation & permissions
    if (!kIsWeb && Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        const channel = AndroidNotificationChannel(
          'habit_reminders_channel',
          'Daily Habit Reminders',
          description: 'Notifications reminding you to complete your daily habits.',
          importance: Importance.max,
        );
        await androidImplementation.createNotificationChannel(channel);
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }

    _isInitialized = true;
  }

  /// Schedule a daily recurring local alarm for a habit
  Future<void> scheduleDailyHabitReminder(Habit habit) async {
    if (habit.reminderHour == null || habit.reminderMinute == null) return;
    await initialize();

    final int notificationId = habit.id.hashCode.abs() % 2147483647;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      habit.reminderHour!,
      habit.reminderMinute!,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_channel',
      'Daily Habit Reminders',
      channelDescription: 'Notifications reminding you to complete your daily habits.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: '🔥 Habit Streak Reminder',
        body: 'Time to complete: ${habit.name}! Keep your daily streak alive!',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: habit.id,
      );
    } catch (e) {
      debugPrint('Exact alarm scheduling failed ($e), using inexact schedule.');
      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: '🔥 Habit Streak Reminder',
        body: 'Time to complete: ${habit.name}! Keep your daily streak alive!',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: habit.id,
      );
    }
  }

  /// Cancel a scheduled habit reminder notification
  Future<void> cancelHabitReminder(String habitId) async {
    await initialize();
    final int notificationId = habitId.hashCode.abs() % 2147483647;
    await _notificationsPlugin.cancel(id: notificationId);
  }

  /// Cancel all scheduled local notifications
  Future<void> cancelAllReminders() async {
    await initialize();
    await _notificationsPlugin.cancelAll();
  }

  /// Re-schedule notifications for all habits with reminders enabled
  Future<void> rescheduleAllHabitReminders(List<Habit> habits) async {
    await cancelAllReminders();
    for (final habit in habits) {
      if (habit.hasReminder) {
        await scheduleDailyHabitReminder(habit);
      }
    }
  }
}
