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

Map<String, Object?> sanitizeAnalyticsMetadata(Map<String, Object?> raw) {
  return _sanitizeMap(raw, depth: 0);
}

const Set<String> _blockedAnalyticsMetadataKeys = <String>{
  'body',
  'content',
  'evidence',
  'message',
  'notes',
  'payload',
  'rationale',
  'raw',
  'raw_text',
  'summary',
  'text',
  'title',
  'uncertainty',
};

Map<String, Object?> _sanitizeMap(
  Map<String, Object?> raw, {
  required int depth,
}) {
  if (depth > 3) {
    return const <String, Object?>{};
  }

  final sanitized = <String, Object?>{};
  for (final entry in raw.entries) {
    final normalizedKey = entry.key.trim();
    if (normalizedKey.isEmpty || _isBlockedAnalyticsKey(normalizedKey)) {
      continue;
    }
    final nextValue = _sanitizeValue(
      entry.value,
      key: normalizedKey,
      depth: depth + 1,
    );
    if (nextValue == null) {
      continue;
    }
    sanitized[normalizedKey] = nextValue;
  }
  return sanitized;
}

Object? _sanitizeValue(
  Object? value, {
  required String key,
  required int depth,
}) {
  if (value == null || value is num || value is bool) {
    return value;
  }
  if (value is String) {
    return _sanitizeString(value);
  }
  if (value is List) {
    final items = value
        .take(20)
        .map(
          (item) => _sanitizeValue(
            item,
            key: key,
            depth: depth + 1,
          ),
        )
        .where((item) => item != null)
        .cast<Object?>()
        .toList(growable: false);
    return items;
  }
  if (value is Map) {
    return _sanitizeMap(
      value.map<String, Object?>(
        (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
      ),
      depth: depth + 1,
    );
  }
  return _sanitizeString(value.toString());
}

String? _sanitizeString(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final looksFreeText =
      trimmed.contains('\n') || trimmed.contains('\r') || trimmed.length > 80;
  if (looksFreeText) {
    return null;
  }
  return trimmed;
}

bool _isBlockedAnalyticsKey(String rawKey) {
  final normalized = rawKey.trim().toLowerCase();
  if (_blockedAnalyticsMetadataKeys.contains(normalized)) {
    return true;
  }
  return _blockedAnalyticsMetadataKeys.any(
    (key) => normalized.endsWith('_$key') || normalized.contains('${key}_'),
  );
}
