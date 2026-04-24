class DailyMission {
  const DailyMission({
    required this.id,
    required this.title,
    required this.body,
    required this.evidence,
    required this.uncertainty,
    required this.requiresConfirmation,
    required this.domainTargets,
    required this.recommendationType,
    required this.confidence,
    required this.trace,
  });

  final String id;
  final String title;
  final String body;
  final List<String> evidence;
  final String uncertainty;
  final bool requiresConfirmation;
  final List<String> domainTargets;
  final String recommendationType;
  final double confidence;
  final Map<String, Object?> trace;
}
