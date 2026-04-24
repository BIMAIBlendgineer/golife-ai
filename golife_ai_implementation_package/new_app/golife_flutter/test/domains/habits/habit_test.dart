import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/habits/habit.dart';

void main() {
  test('Habit emits habit life events', () {
    const habit = Habit(
      id: 'habit-1',
      title: 'Night reset',
      cue: 'After dinner',
      streak: 3,
      cadence: HabitCadence.daily,
    );

    final event = habit.toLifeEvent('habit_checked');

    expect(event.domain, 'habit');
    expect(event.type, 'habit_checked');
    expect(event.payload['streak'], 3);
  });
}
