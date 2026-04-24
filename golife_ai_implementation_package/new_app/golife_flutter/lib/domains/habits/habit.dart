// Clean-room rewrite for GoLife after auditing Habo (GPL-3.0).
// No GPL source copied into this file.

import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

enum HabitCadence { daily, weekdays, weekly }

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.cue,
    required this.streak,
    required this.cadence,
  });

  final String id;
  final String title;
  final String cue;
  final int streak;
  final HabitCadence cadence;

  String get streakLabel => '$streak-day streak';

  LifeEvent toLifeEvent(String type) {
    return LifeEventFactory.create(
      domain: 'habit',
      type: type,
      summary: title,
      payload: {
        'habitId': id,
        'cue': cue,
        'streak': streak,
        'cadence': cadence.name,
      },
    );
  }
}
