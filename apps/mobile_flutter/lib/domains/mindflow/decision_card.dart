import 'action_contract.dart';
import 'privacy_summary.dart';

class DecisionCard {
  const DecisionCard({
    required this.id,
    required this.userId,
    required this.title,
    required this.recommendedAction,
    required this.alternatives,
    required this.domainTargets,
    required this.sourceItems,
    required this.evidence,
    required this.confidence,
    required this.uncertainty,
    required this.privacySummary,
    required this.confirmationRequired,
    required this.actionContract,
    required this.status,
    required this.evidenceStatus,
    required this.rankingScore,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.trace,
  });

  final String id;
  final String userId;
  final String title;
  final String recommendedAction;
  final List<String> alternatives;
  final List<String> domainTargets;
  final List<String> sourceItems;
  final List<String> evidence;
  final double confidence;
  final String uncertainty;
  final PrivacySummary privacySummary;
  final bool confirmationRequired;
  final ActionContract actionContract;
  final String status;
  final String evidenceStatus;
  final double rankingScore;
  final String createdAtIso;
  final String updatedAtIso;
  final Map<String, Object?> trace;

  DecisionCard copyWith({
    String? status,
    String? updatedAtIso,
    Map<String, Object?>? trace,
  }) {
    return DecisionCard(
      id: id,
      userId: userId,
      title: title,
      recommendedAction: recommendedAction,
      alternatives: alternatives,
      domainTargets: domainTargets,
      sourceItems: sourceItems,
      evidence: evidence,
      confidence: confidence,
      uncertainty: uncertainty,
      privacySummary: privacySummary,
      confirmationRequired: confirmationRequired,
      actionContract: actionContract,
      status: status ?? this.status,
      evidenceStatus: evidenceStatus,
      rankingScore: rankingScore,
      createdAtIso: createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      trace: trace ?? this.trace,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'recommended_action': recommendedAction,
      'alternatives': alternatives,
      'domain_targets': domainTargets,
      'source_items': sourceItems,
      'evidence': evidence,
      'confidence': confidence,
      'uncertainty': uncertainty,
      'privacy_summary': privacySummary.toJson(),
      'confirmation_required': confirmationRequired,
      'action_contract': actionContract.toJson(),
      'status': status,
      'evidence_status': evidenceStatus,
      'ranking_score': rankingScore,
      'created_at_iso': createdAtIso,
      'updated_at_iso': updatedAtIso,
      'trace': trace,
    };
  }

  factory DecisionCard.fromJson(Map<String, dynamic> json) {
    return DecisionCard(
      id: (json['id'] ?? json['decision_id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      title: (json['title'] ?? '').toString(),
      recommendedAction: (json['recommended_action'] ?? '').toString(),
      alternatives: ((json['alternatives'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      domainTargets: ((json['domain_targets'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      sourceItems: ((json['source_items'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      evidence: _evidenceClaims(json['evidence']),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      uncertainty: (json['uncertainty'] ?? '').toString(),
      privacySummary: PrivacySummary.fromJson(
        Map<String, dynamic>.from(
          (json['privacy_summary'] as Map?) ?? const {},
        ),
      ),
      confirmationRequired: json['confirmation_required'] != false,
      actionContract: ActionContract.fromJson(
        Map<String, dynamic>.from(
          (json['action_contract'] as Map?) ?? const {},
        ),
      ),
      status: (json['status'] ?? 'draft').toString(),
      evidenceStatus: (json['evidence_status'] ??
              _inferEvidenceStatus(json['evidence']))
          .toString(),
      rankingScore: (json['ranking_score'] as num?)?.toDouble() ??
          (json['ranking'] is Map
              ? (((json['ranking'] as Map)['final_score'] as num?)?.toDouble() ??
                  0.0)
              : 0.0),
      createdAtIso: (json['created_at_iso'] ?? '').toString(),
      updatedAtIso: (json['updated_at_iso'] ?? '').toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}

List<String> _evidenceClaims(Object? raw) {
  if (raw is List) {
    return raw.map((item) {
      if (item is Map && item['claim'] != null) {
        return item['claim'].toString();
      }
      return item.toString();
    }).toList(growable: false);
  }
  return const <String>[];
}

String _inferEvidenceStatus(Object? raw) {
  final items = _evidenceClaims(raw);
  if (items.isEmpty) {
    return 'insufficient_verified_data';
  }
  return 'local_only';
}
