import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/habit_repository.dart';
import '../services/notification_service.dart';

class NotificationCubit extends Cubit<bool> {
  static const String settingsBoxName = 'settings_box';
  static const String notificationsEnabledKey = 'notifications_enabled';

  final HabitRepository repository;

  NotificationCubit({required this.repository}) : super(true) {
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    try {
      final box = await Hive.openBox(settingsBoxName);
      final isEnabled = box.get(notificationsEnabledKey, defaultValue: true) as bool;
      emit(isEnabled);
    } catch (_) {
      emit(true);
    }
  }

  Future<void> toggleNotifications(bool enable) async {
    emit(enable);

    try {
      final box = await Hive.openBox(settingsBoxName);
      await box.put(notificationsEnabledKey, enable);
    } catch (_) {}

    if (!enable) {
      await NotificationService.instance.cancelAllReminders();
    } else {
      final habits = await repository.getHabits();
      await NotificationService.instance.rescheduleAllHabitReminders(habits);
    }
  }
}
