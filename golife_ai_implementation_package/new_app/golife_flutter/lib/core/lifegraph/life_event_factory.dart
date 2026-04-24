import 'life_event.dart';

class LifeEventFactory {
  static LifeEvent create({
    required String domain,
    required String type,
    required String summary,
    String userId = 'local-user',
    String source = 'manual',
    String privacyLevel = 'local_only',
    String? evidenceHash,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    return LifeEvent(
      eventId: '$domain-$type-${DateTime.now().microsecondsSinceEpoch}',
      userId: userId,
      domain: domain,
      eventType: type,
      timestampIso: DateTime.now().toUtc().toIso8601String(),
      payload: {
        ...payload,
        'summary': summary,
      },
      source: source,
      privacyLevel: privacyLevel,
      evidenceHash: evidenceHash,
    );
  }
}
