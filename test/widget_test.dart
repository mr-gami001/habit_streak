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
