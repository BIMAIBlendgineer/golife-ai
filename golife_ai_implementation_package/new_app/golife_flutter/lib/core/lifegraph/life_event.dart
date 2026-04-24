class LifeEvent {
  const LifeEvent({
    required this.eventId,
    required this.userId,
    required this.domain,
    required this.eventType,
    required this.timestampIso,
    required this.payload,
    required this.source,
    required this.privacyLevel,
    this.evidenceHash,
  });

  final String eventId;
  final String userId;
  final String domain;
  final String eventType;
  final String timestampIso;
  final Map<String, Object?> payload;
  final String source;
  final String privacyLevel;
  final String? evidenceHash;

  String get id => eventId;
  String get type => eventType;
  String get occurredAtIso => timestampIso;
  String get summary =>
      (payload['summary'] as String?) ?? '$domain:$eventType';

  Map<String, Object?> toJson() {
    return {
      'event_id': eventId,
      'user_id': userId,
      'domain': domain,
      'event_type': eventType,
      'timestamp': timestampIso,
      'payload': payload,
      'source': source,
      'privacy_level': privacyLevel,
      'evidence_hash': evidenceHash,
    };
  }

  Map<String, Object?> toGatewayJson({
    String? userIdOverride,
    String? privacyLevelOverride,
  }) {
    return {
      'event_id': eventId,
      'user_id': userIdOverride ?? userId,
      'domain': domain,
      'event_type': eventType,
      'timestamp': timestampIso,
      'payload': payload,
      'source': source,
      'privacy_level': privacyLevelOverride ?? privacyLevel,
      'evidence_hash': evidenceHash,
    };
  }

  factory LifeEvent.fromJson(Map<String, dynamic> json) {
    final payload = Map<String, Object?>.from(
      (json['payload'] as Map?)?.cast<String, Object?>() ?? const {},
    );
    final legacySummary = json['summary'] as String?;
    if (legacySummary != null && legacySummary.isNotEmpty) {
      payload.putIfAbsent('summary', () => legacySummary);
    }

    return LifeEvent(
      eventId: (json['event_id'] ?? json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      domain: (json['domain'] ?? 'system').toString(),
      eventType: (json['event_type'] ?? json['type'] ?? 'logged').toString(),
      timestampIso:
          (json['timestamp'] ?? json['occurredAtIso'] ?? '').toString(),
      payload: payload,
      source: (json['source'] ?? 'manual').toString(),
      privacyLevel:
          (json['privacy_level'] ?? json['privacyLevel'] ?? 'local_only')
              .toString(),
      evidenceHash: json['evidence_hash']?.toString() ??
          json['evidenceHash']?.toString(),
    );
  }
}
