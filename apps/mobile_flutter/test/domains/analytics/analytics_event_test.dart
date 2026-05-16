import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/analytics/analytics_event.dart';

void main() {
  test('serializes analytics event with sanitized metadata', () {
    const event = AnalyticsEvent(
      eventId: 'analytics-1',
      eventName: 'mission_set_generated',
      timestampIso: '2026-05-16T18:00:00Z',
      locale: 'en',
      source: 'mission_planner',
      metadata: <String, Object?>{
        'mission_set_id': 'set-1',
        'mission_count': 3,
        'body': 'Should be removed.',
      },
    );

    final restored = AnalyticsEvent.fromJson(
      Map<String, dynamic>.from(event.toJson()),
    );

    expect(restored.eventId, 'analytics-1');
    expect(restored.eventName, 'mission_set_generated');
    expect(restored.metadata['mission_set_id'], 'set-1');
    expect(restored.metadata['mission_count'], 3);
    expect(restored.metadata.containsKey('body'), isFalse);
    expect(restored.metadata['has_text'], true);
  });
}
