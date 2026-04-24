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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'evidence': evidence,
      'uncertainty': uncertainty,
      'requires_confirmation': requiresConfirmation,
      'domain_targets': domainTargets,
      'recommendation_type': recommendationType,
      'confidence': confidence,
      'trace': trace,
    };
  }

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      evidence: ((json['evidence'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      uncertainty: (json['uncertainty'] ?? '').toString(),
      requiresConfirmation:
          (json['requires_confirmation'] ?? json['requiresConfirmation'] ?? true) == true,
      domainTargets: ((json['domain_targets'] ?? json['domainTargets']) as List?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[],
      recommendationType:
          (json['recommendation_type'] ?? json['recommendationType'] ?? 'mission')
              .toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}
