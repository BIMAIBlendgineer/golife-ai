class LifeEvent {
  const LifeEvent({
    required this.id,
    required this.domain,
    required this.type,
    required this.occurredAtIso,
    required this.summary,
    this.privacyLevel = 'local_only',
    this.payload = const <String, Object?>{},
  });

  final String id;
  final String domain;
  final String type;
  final String occurredAtIso;
  final String summary;
  final String privacyLevel;
  final Map<String, Object?> payload;
}
