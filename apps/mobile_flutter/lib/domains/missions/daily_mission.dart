class MissionRanking {
  const MissionRanking({
    required this.impactScore,
    required this.urgencyScore,
    required this.effortScore,
    required this.confidenceScore,
    required this.privacyScore,
    required this.feedbackScore,
    required this.noveltyScore,
    required this.finalScore,
    required this.rankingReason,
    required this.evidenceRefs,
  });

  final double impactScore;
  final double urgencyScore;
  final double effortScore;
  final double confidenceScore;
  final double privacyScore;
  final double feedbackScore;
  final double noveltyScore;
  final double finalScore;
  final String rankingReason;
  final List<String> evidenceRefs;

  Map<String, Object?> toJson() {
    return {
      'impact_score': impactScore,
      'urgency_score': urgencyScore,
      'effort_score': effortScore,
      'confidence_score': confidenceScore,
      'privacy_score': privacyScore,
      'feedback_score': feedbackScore,
      'novelty_score': noveltyScore,
      'final_score': finalScore,
      'ranking_reason': rankingReason,
      'evidence_refs': evidenceRefs,
    };
  }

  factory MissionRanking.fromJson(Map<String, dynamic> json) {
    return MissionRanking(
      impactScore: (json['impact_score'] as num?)?.toDouble() ?? 0,
      urgencyScore: (json['urgency_score'] as num?)?.toDouble() ?? 0,
      effortScore: (json['effort_score'] as num?)?.toDouble() ?? 0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0,
      privacyScore: (json['privacy_score'] as num?)?.toDouble() ?? 0,
      feedbackScore: (json['feedback_score'] as num?)?.toDouble() ?? 0,
      noveltyScore: (json['novelty_score'] as num?)?.toDouble() ?? 0,
      finalScore: (json['final_score'] as num?)?.toDouble() ?? 0,
      rankingReason: (json['ranking_reason'] ?? '').toString(),
      evidenceRefs: ((json['evidence_refs'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}

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
    required this.ranking,
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
  final MissionRanking? ranking;
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
      'ranking': ranking?.toJson(),
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
      requiresConfirmation: (json['requires_confirmation'] ??
              json['requiresConfirmation'] ??
              true) ==
          true,
      domainTargets:
          ((json['domain_targets'] ?? json['domainTargets']) as List?)
                  ?.map((item) => item.toString())
                  .toList(growable: false) ??
              const <String>[],
      recommendationType: (json['recommendation_type'] ??
              json['recommendationType'] ??
              'mission')
          .toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      ranking: json['ranking'] is Map<String, dynamic>
          ? MissionRanking.fromJson(json['ranking'] as Map<String, dynamic>)
          : json['ranking'] is Map
              ? MissionRanking.fromJson(
                  Map<String, dynamic>.from(
                    (json['ranking'] as Map).cast<String, Object?>(),
                  ),
                )
              : null,
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}
