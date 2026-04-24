// Clean-room rewrite for GoLife after auditing WeekToDo (GPL-3.0).
// No GPL source copied into this file.

import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class DayPlan {
  const DayPlan({
    required this.label,
    required this.focus,
    this.recurringAnchors = const <String>[],
  });

  final String label;
  final String focus;
  final List<String> recurringAnchors;
}

class WeekPlan {
  const WeekPlan({
    required this.id,
    required this.theme,
    required this.days,
    required this.colorToken,
  });

  final String id;
  final String theme;
  final List<DayPlan> days;
  final String colorToken;

  String get energyNote => days.isEmpty ? 'No focus blocks yet.' : days.first.focus;

  LifeEvent toLifeEvent(String type) {
    return LifeEventFactory.create(
      domain: 'week',
      type: type,
      summary: theme,
      payload: {
        'weekPlanId': id,
        'dayCount': days.length,
        'colorToken': colorToken,
      },
    );
  }
}
