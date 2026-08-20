import 'package:equatable/equatable.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabitsEvent extends HabitEvent {}

class AddHabitEvent extends HabitEvent {
  final String name;
  final int? reminderHour;
  final int? reminderMinute;
  final String? category;
  final String? colorHex;

  const AddHabitEvent(
    this.name, {
    this.reminderHour,
    this.reminderMinute,
    this.category,
    this.colorHex,
  });

  @override
  List<Object?> get props => [name, reminderHour, reminderMinute, category, colorHex];
}

class ToggleCheckInEvent extends HabitEvent {
  final String habitId;

  const ToggleCheckInEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class ToggleCheckInDateEvent extends HabitEvent {
  final String habitId;
  final DateTime date;

  const ToggleCheckInDateEvent(this.habitId, this.date);

  @override
  List<Object?> get props => [habitId, date];
}

class RecoverStreakEvent extends HabitEvent {
  final String habitId;

  const RecoverStreakEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class DeleteHabitEvent extends HabitEvent {
  final String habitId;

  const DeleteHabitEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class UpdateHabitReminderEvent extends HabitEvent {
  final String habitId;
  final int? reminderHour;
  final int? reminderMinute;

  const UpdateHabitReminderEvent(
    this.habitId, {
    this.reminderHour,
    this.reminderMinute,
  });

  @override
  List<Object?> get props => [habitId, reminderHour, reminderMinute];
}

class EditHabitEvent extends HabitEvent {
  final String habitId;
  final String name;
  final String category;
  final String colorHex;
  final DateTime creationDate;

  const EditHabitEvent({
    required this.habitId,
    required this.name,
    required this.category,
    required this.colorHex,
    required this.creationDate,
  });

  @override
  List<Object?> get props => [habitId, name, category, colorHex, creationDate];
}
