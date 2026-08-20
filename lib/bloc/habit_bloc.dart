import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository repository;

  HabitBloc({required this.repository}) : super(HabitInitial()) {
    on<LoadHabitsEvent>(_onLoadHabits);
    on<AddHabitEvent>(_onAddHabit);
    on<ToggleCheckInEvent>(_onToggleCheckIn);
    on<ToggleCheckInDateEvent>(_onToggleCheckInDate);
    on<RecoverStreakEvent>(_onRecoverStreak);
    on<DeleteHabitEvent>(_onDeleteHabit);
    on<UpdateHabitReminderEvent>(_onUpdateHabitReminder);
    on<EditHabitEvent>(_onEditHabit);
  }

  Future<void> _onLoadHabits(LoadHabitsEvent event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    try {
      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Unexpected error occurred while reading local data.'));
    }
  }

  Future<void> _onAddHabit(AddHabitEvent event, Emitter<HabitState> emit) async {
    try {
      final newHabit = await repository.addHabit(
        event.name,
        reminderHour: event.reminderHour,
        reminderMinute: event.reminderMinute,
        category: event.category,
        colorHex: event.colorHex,
      );

      if (newHabit.hasReminder) {
        await NotificationService.instance.scheduleDailyHabitReminder(newHabit);
        final eventId = await CalendarService.instance.createHabitReminder(newHabit);
        if (eventId != null) {
          await repository.updateCalendarEventId(newHabit.id, eventId);
        }
      }

      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Failed to create new habit.'));
    }
  }

  Future<void> _onToggleCheckIn(ToggleCheckInEvent event, Emitter<HabitState> emit) async {
    try {
      await repository.toggleCheckInToday(event.habitId);
      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Failed to update check-in status.'));
    }
  }

  Future<void> _onToggleCheckInDate(ToggleCheckInDateEvent event, Emitter<HabitState> emit) async {
    try {
      await repository.toggleCheckInForDate(event.habitId, event.date);
      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Failed to update date check-in status.'));
    }
  }

  Future<void> _onRecoverStreak(RecoverStreakEvent event, Emitter<HabitState> emit) async {
    try {
      await repository.recoverStreak(event.habitId);
      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Failed to recover streak.'));
    }
  }

  Future<void> _onDeleteHabit(DeleteHabitEvent event, Emitter<HabitState> emit) async {
    try {
      final habitsBeforeDelete = await repository.getHabits();
      final habitToDelete = habitsBeforeDelete.firstWhere(
        (h) => h.id == event.habitId,
        orElse: () => Habit(id: event.habitId, name: '', creationDate: DateTime.now()),
      );

      await CalendarService.instance.deleteHabitReminder(habitToDelete);
      await NotificationService.instance.cancelHabitReminder(event.habitId);
      await repository.deleteHabit(event.habitId);

      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Failed to delete habit.'));
    }
  }

  Future<void> _onUpdateHabitReminder(
      UpdateHabitReminderEvent event, Emitter<HabitState> emit) async {
    try {
      final updatedHabit = await repository.updateHabitReminder(
        event.habitId,
        reminderHour: event.reminderHour,
        reminderMinute: event.reminderMinute,
      );

      if (updatedHabit.hasReminder) {
        await NotificationService.instance.scheduleDailyHabitReminder(updatedHabit);
        final eventId = await CalendarService.instance.updateHabitReminder(updatedHabit);
        if (eventId != null) {
          await repository.updateCalendarEventId(updatedHabit.id, eventId);
        }
      } else {
        await NotificationService.instance.cancelHabitReminder(updatedHabit.id);
        await CalendarService.instance.deleteHabitReminder(updatedHabit);
        await repository.updateCalendarEventId(updatedHabit.id, null);
      }

      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Failed to update habit reminder.'));
    }
  }

  Future<void> _onEditHabit(EditHabitEvent event, Emitter<HabitState> emit) async {
    try {
      final updatedHabit = await repository.updateHabitDetails(
        event.habitId,
        name: event.name,
        category: event.category,
        colorHex: event.colorHex,
        creationDate: event.creationDate,
      );

      if (updatedHabit.hasReminder) {
        await NotificationService.instance.scheduleDailyHabitReminder(updatedHabit);
        final eventId = await CalendarService.instance.updateHabitReminder(updatedHabit);
        if (eventId != null) {
          await repository.updateCalendarEventId(updatedHabit.id, eventId);
        }
      }

      final habits = await repository.getHabits();
      final completedToday = await _getTodayCompletedHabitIds(habits);
      emit(HabitLoaded(habits: habits, todayCompletedHabitIds: completedToday));
    } on HabitStorageException catch (e) {
      emit(HabitError(e.message));
    } catch (e) {
      emit(const HabitError('Failed to update habit details.'));
    }
  }

  Future<Set<String>> _getTodayCompletedHabitIds(List<Habit> habits) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final completedIds = <String>{};
    for (final habit in habits) {
      final checkIns = await repository.getCheckInsForHabit(habit.id);
      final hasToday = checkIns.any((c) =>
          c.date.year == today.year &&
          c.date.month == today.month &&
          c.date.day == today.day);
      if (hasToday) {
        completedIds.add(habit.id);
      }
    }
    return completedIds;
  }
}
