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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'cue': cue,
      'streak': streak,
      'cadence': cadence.name,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      cue: (json['cue'] ?? '').toString(),
      streak: ((json['streak']) as num?)?.toInt() ?? 0,
      cadence: HabitCadence.values.firstWhere(
        (value) => value.name == (json['cadence'] ?? 'daily').toString(),
        orElse: () => HabitCadence.daily,
      ),
    );
  }

  String get streakLabel => '$streak-day streak';

  LifeEvent toLifeEvent(String type, {String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'habit',
      type: type,
      summary: title,
      privacyLevel: privacyLevel,
      payload: {
        'habitId': id,
        'cue': cue,
        'streak': streak,
        'cadence': cadence.name,
      },
    );
  }
}
