import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class CalendarItem {
  const CalendarItem({
    required this.id,
    required this.title,
    required this.startIso,
    required this.endIso,
    this.location = '',
    this.energy = 'steady',
  });

  final String id;
  final String title;
  final String startIso;
  final String endIso;
  final String location;
  final String energy;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'start_iso': startIso,
      'end_iso': endIso,
      'location': location,
      'energy': energy,
    };
  }

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    return CalendarItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      startIso: (json['start_iso'] ?? json['startIso'] ?? '').toString(),
      endIso: (json['end_iso'] ?? json['endIso'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      energy: (json['energy'] ?? 'steady').toString(),
    );
  }

  LifeEvent toLifeEvent(String type, {String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'week',
      type: type,
      summary: title,
      privacyLevel: privacyLevel,
      payload: {
        'calendarItemId': id,
        'startIso': startIso,
        'endIso': endIso,
        'location': location,
        'energy': energy,
      },
    );
  }
}
