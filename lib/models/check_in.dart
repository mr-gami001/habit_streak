import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'check_in.g.dart';

@HiveType(typeId: 1)
class CheckIn extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime date;

  const CheckIn({
    required this.id,
    required this.habitId,
    required this.date,
  });

  @override
  List<Object?> get props => [id, habitId, date];
}
