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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'severity': severity,
      'domain_targets': domainTargets,
    };
  }

  factory DailyRisk.fromJson(Map<String, dynamic> json) {
    return DailyRisk(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      severity: (json['severity'] ?? 'low').toString(),
      domainTargets:
          ((json['domain_targets'] ?? json['domainTargets']) as List?)
                  ?.map((item) => item.toString())
                  .toList(growable: false) ??
              const <String>[],
    );
  }
}
