import 'package:equatable/equatable.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabitsEvent extends HabitEvent {}

class AddHabitEvent extends HabitEvent {
  final String name;

  const AddHabitEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class ToggleCheckInEvent extends HabitEvent {
  final String habitId;

  const ToggleCheckInEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class RecoverStreakEvent extends HabitEvent {
  final String habitId;

  const RecoverStreakEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}
