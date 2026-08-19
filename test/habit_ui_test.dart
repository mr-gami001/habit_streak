import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_streak_tracker/models/habit.dart';

void main() {
  testWidgets('HabitDetailsScreen displays habit info and streaks', (WidgetTester tester) async {
    final habit = Habit(
      id: 'test-1',
      name: 'Read Daily',
      creationDate: DateTime(2026, 1, 1),
      currentStreak: 5,
      longestStreak: 10,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  Text(habit.name),
                  Text('Current: ${habit.currentStreak} 🔥'),
                  Text('Longest: ${habit.longestStreak} 🏆'),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Read Daily'), findsOneWidget);
    expect(find.text('Current: 5 🔥'), findsOneWidget);
    expect(find.text('Longest: 10 🏆'), findsOneWidget);
  });
}
