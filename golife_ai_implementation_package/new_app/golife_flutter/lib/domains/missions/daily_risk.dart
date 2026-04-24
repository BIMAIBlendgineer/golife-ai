class DailyRisk {
  const DailyRisk({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    required this.domainTargets,
  });

  final String id;
  final String title;
  final String summary;
  final String severity;
  final List<String> domainTargets;
}
