import 'package:equatable/equatable.dart';
import '../models/habit.dart';

abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  final Set<String> todayCompletedHabitIds;

  const HabitLoaded({
    required this.habits,
    required this.todayCompletedHabitIds,
  });

  @override
  List<Object?> get props => [habits, todayCompletedHabitIds];
}

class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object?> get props => [message];
}
