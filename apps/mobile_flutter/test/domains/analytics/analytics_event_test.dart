import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/analytics/analytics_event.dart';

void main() {
  test('sanitizes blocked metadata keys and long free-text values', () {
    const event = AnalyticsEvent(
      eventId: 'analytics-1',
      eventName: 'capture_parsed',
      timestampIso: '2026-05-16T18:00:00Z',
      locale: 'en',
      source: 'capture_parser',
      metadata: <String, Object?>{
        'draft_count': 2,
        'domain': 'task',
        'summary': 'This summary should never survive the sanitizer.',
        'trace': <String, Object?>{
          'reason_code': 'gateway_parse_exception',
          'title': 'Raw title should be removed.',
        },
        'long_value':
            'This string is intentionally longer than eighty characters so it gets dropped from analytics metadata.',
      },
    );

    final json = event.toJson();
    final metadata = Map<String, Object?>.from(json['metadata'] as Map);
    final trace = Map<String, Object?>.from(metadata['trace'] as Map);

    expect(metadata['draft_count'], 2);
    expect(metadata['domain'], 'task');
    expect(metadata.containsKey('summary'), isFalse);
    expect(metadata.containsKey('long_value'), isFalse);
    expect(trace['reason_code'], 'gateway_parse_exception');
    expect(trace.containsKey('title'), isFalse);
  });
}
