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

  const Habit({
    required this.id,
    required this.name,
    required this.creationDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  Habit copyWith({
    String? id,
    String? name,
    DateTime? creationDate,
    int? currentStreak,
    int? longestStreak,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      creationDate: creationDate ?? this.creationDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  List<Object?> get props => [id, name, creationDate, currentStreak, longestStreak];
}
