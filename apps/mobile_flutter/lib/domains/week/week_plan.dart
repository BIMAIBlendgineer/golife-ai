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

  Map<String, Object?> toJson() {
    return {
      'label': label,
      'focus': focus,
      'recurring_anchors': recurringAnchors,
    };
  }

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      label: (json['label'] ?? '').toString(),
      focus: (json['focus'] ?? '').toString(),
      recurringAnchors:
          ((json['recurring_anchors'] ?? json['recurringAnchors']) as List?)
                  ?.map((item) => item.toString())
                  .toList(growable: false) ??
              const <String>[],
    );
  }
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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'theme': theme,
      'days': days.map((item) => item.toJson()).toList(growable: false),
      'color_token': colorToken,
    };
  }

  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    return WeekPlan(
      id: (json['id'] ?? '').toString(),
      theme: (json['theme'] ?? '').toString(),
      days: ((json['days'] ?? const <Object?>[]) as List)
          .whereType<Map>()
          .map((item) => DayPlan.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      colorToken: (json['color_token'] ?? json['colorToken'] ?? '').toString(),
    );
  }

  String get energyNote =>
      days.isEmpty ? 'No focus blocks yet.' : days.first.focus;

  LifeEvent toLifeEvent(String type, {String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'week',
      type: type,
      summary: theme,
      privacyLevel: privacyLevel,
      payload: {
        'weekPlanId': id,
        'dayCount': days.length,
        'colorToken': colorToken,
      },
    );
  }
}
