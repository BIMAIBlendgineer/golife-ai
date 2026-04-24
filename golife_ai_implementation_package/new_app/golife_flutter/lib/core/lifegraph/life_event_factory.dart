import 'life_event.dart';

class LifeEventFactory {
  static LifeEvent create({
    required String domain,
    required String type,
    required String summary,
    String privacyLevel = 'local_only',
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    return LifeEvent(
      id: '$domain-$type-${DateTime.now().microsecondsSinceEpoch}',
      domain: domain,
      type: type,
      occurredAtIso: DateTime.now().toUtc().toIso8601String(),
      summary: summary,
      privacyLevel: privacyLevel,
      payload: payload,
    );
  }
}
