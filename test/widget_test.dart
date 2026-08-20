import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_streak_tracker/models/habit.dart';

void main() {
  test('Habit model streak copyWith check', () {
    final habit = Habit(
      id: 'h1',
      name: 'Exercise',
      creationDate: DateTime(2026, 1, 1),
      currentStreak: 2,
      longestStreak: 5,
    );

    final updated = habit.copyWith(currentStreak: 3, longestStreak: 5);
    expect(updated.currentStreak, 3);
    expect(updated.longestStreak, 5);
    expect(updated.name, 'Exercise');
    expect(updated.category, 'Health');
    expect(updated.colorHex, '#00BFA5');
  });

  test('Habit model category and colorHex check', () {
    final habit = Habit(
      id: 'h2',
      name: 'Coding',
      creationDate: DateTime(2026, 1, 1),
      category: 'Productivity',
      colorHex: '#7C4DFF',
    );

    expect(habit.category, 'Productivity');
    expect(habit.colorHex, '#7C4DFF');

    final updated = habit.copyWith(category: 'Study', colorHex: '#FF6E40');
    expect(updated.category, 'Study');
    expect(updated.colorHex, '#FF6E40');
  });

  test('Habit model reminder copyWith check', () {
    final habit = Habit(
      id: 'h3',
      name: 'Reading',
      creationDate: DateTime(2026, 1, 1),
    );

    expect(habit.hasReminder, false);
    final updated = habit.copyWith(reminderHour: 8, reminderMinute: 30);
    expect(updated.hasReminder, true);
    expect(updated.reminderHour, 8);
    expect(updated.reminderMinute, 30);
  });

  testWidgets('Renders habit tracker text widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Habit Streak Tracker'),
        ),
      ),
    );

    expect(find.text('Habit Streak Tracker'), findsOneWidget);
  });
}
