import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository repository;

  HabitBloc({required this.repository}) : super(HabitInitial()) {
    on<LoadHabitsEvent>(_onLoadHabits);
    on<AddHabitEvent>(_onAddHabit);
    on<ToggleCheckInEvent>(_onToggleCheckIn);
    on<RecoverStreakEvent>(_onRecoverStreak);
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
      await repository.addHabit(event.name);
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
