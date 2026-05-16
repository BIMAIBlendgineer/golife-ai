import '../../core/analytics/analytics_sanitizer.dart';

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.eventId,
    required this.eventName,
    required this.timestampIso,
    required this.locale,
    required this.source,
    this.metadata = const <String, Object?>{},
  });

  final String eventId;
  final String eventName;
  final String timestampIso;
  final String locale;
  final String source;
  final Map<String, Object?> metadata;

  AnalyticsEvent sanitized() {
    return AnalyticsEvent(
      eventId: eventId,
      eventName: eventName,
      timestampIso: timestampIso,
      locale: locale,
      source: source,
      metadata: sanitizeAnalyticsMetadata(metadata),
    );
  }

  Map<String, Object?> toJson() {
    final normalizedEvent = sanitized();
    return <String, Object?>{
      'event_id': normalizedEvent.eventId,
      'event_name': normalizedEvent.eventName,
      'timestamp_iso': normalizedEvent.timestampIso,
      'locale': normalizedEvent.locale,
      'source': normalizedEvent.source,
      'metadata': normalizedEvent.metadata,
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      eventId: (json['event_id'] ?? json['eventId'] ?? '').toString(),
      eventName: (json['event_name'] ?? json['eventName'] ?? '').toString(),
      timestampIso:
          (json['timestamp_iso'] ?? json['timestampIso'] ?? '').toString(),
      locale: (json['locale'] ?? 'en').toString(),
      source: (json['source'] ?? 'app').toString(),
      metadata: sanitizeAnalyticsMetadata(
        Map<String, Object?>.from(
          (json['metadata'] as Map?)?.cast<String, Object?>() ??
              const <String, Object?>{},
        ),
      ),
    );
  }
}
