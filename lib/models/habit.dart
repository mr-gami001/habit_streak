import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime creationDate;

  @HiveField(3)
  final int currentStreak;

  @HiveField(4)
  final int longestStreak;

  @HiveField(5)
  final int? reminderHour;

  @HiveField(6)
  final int? reminderMinute;

  @HiveField(7)
  final String category;

  @HiveField(8)
  final String colorHex;

  @HiveField(9)
  final String? calendarEventId;

  const Habit({
    required this.id,
    required this.name,
    required this.creationDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.reminderHour,
    this.reminderMinute,
    this.category = 'Health',
    this.colorHex = '#00BFA5',
    this.calendarEventId,
  });

  bool get hasReminder => reminderHour != null && reminderMinute != null;

  Habit copyWith({
    String? id,
    String? name,
    DateTime? creationDate,
    int? currentStreak,
    int? longestStreak,
    int? reminderHour,
    int? reminderMinute,
    String? category,
    String? colorHex,
    String? calendarEventId,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      creationDate: creationDate ?? this.creationDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      calendarEventId: calendarEventId ?? this.calendarEventId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        creationDate,
        currentStreak,
        longestStreak,
        reminderHour,
        reminderMinute,
        category,
        colorHex,
        calendarEventId,
      ];
}
