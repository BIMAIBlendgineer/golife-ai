class MentalLoadItem {
  const MentalLoadItem({
    required this.id,
    required this.userId,
    required this.sourceEventId,
    required this.type,
    required this.domain,
    required this.title,
    required this.summary,
    required this.urgencyScore,
    required this.effortScore,
    required this.confidence,
    required this.state,
    required this.dueHint,
    required this.amountHint,
    required this.currencyHint,
    required this.evidenceRefs,
    required this.privacyLevel,
    required this.requiresConfirmation,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.trace,
  });

  final String id;
  final String userId;
  final String? sourceEventId;
  final String type;
  final String domain;
  final String title;
  final String summary;
  final double urgencyScore;
  final double effortScore;
  final double confidence;
  final String state;
  final String? dueHint;
  final double? amountHint;
  final String? currencyHint;
  final List<String> evidenceRefs;
  final String privacyLevel;
  final bool requiresConfirmation;
  final String createdAtIso;
  final String updatedAtIso;
  final Map<String, Object?> trace;

  MentalLoadItem copyWith({
    String? state,
    String? dueHint,
    double? amountHint,
    String? currencyHint,
    List<String>? evidenceRefs,
    String? updatedAtIso,
    Map<String, Object?>? trace,
  }) {
    return MentalLoadItem(
      id: id,
      userId: userId,
      sourceEventId: sourceEventId,
      type: type,
      domain: domain,
      title: title,
      summary: summary,
      urgencyScore: urgencyScore,
      effortScore: effortScore,
      confidence: confidence,
      state: state ?? this.state,
      dueHint: dueHint ?? this.dueHint,
      amountHint: amountHint ?? this.amountHint,
      currencyHint: currencyHint ?? this.currencyHint,
      evidenceRefs: evidenceRefs ?? this.evidenceRefs,
      privacyLevel: privacyLevel,
      requiresConfirmation: requiresConfirmation,
      createdAtIso: createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      trace: trace ?? this.trace,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'source_event_id': sourceEventId,
      'type': type,
      'domain': domain,
      'title': title,
      'summary': summary,
      'urgency_score': urgencyScore,
      'effort_score': effortScore,
      'confidence': confidence,
      'state': state,
      'due_hint': dueHint,
      'amount_hint': amountHint,
      'currency_hint': currencyHint,
      'evidence_refs': evidenceRefs,
      'privacy_level': privacyLevel,
      'requires_confirmation': requiresConfirmation,
      'created_at_iso': createdAtIso,
      'updated_at_iso': updatedAtIso,
      'trace': trace,
    };
  }

  factory MentalLoadItem.fromJson(Map<String, dynamic> json) {
    return MentalLoadItem(
      id: (json['id'] ?? json['item_id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      sourceEventId: json['source_event_id']?.toString(),
      type: (json['type'] ?? 'note').toString(),
      domain: (json['domain'] ?? 'system').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      urgencyScore: (json['urgency_score'] as num?)?.toDouble() ?? 0.0,
      effortScore: (json['effort_score'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      state: (json['state'] ?? 'inbox').toString(),
      dueHint: json['due_hint']?.toString(),
      amountHint: (json['amount_hint'] as num?)?.toDouble(),
      currencyHint: json['currency_hint']?.toString(),
      evidenceRefs: ((json['evidence_refs'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      privacyLevel: (json['privacy_level'] ?? 'local_only').toString(),
      requiresConfirmation: json['requires_confirmation'] != false,
      createdAtIso: (json['created_at_iso'] ?? '').toString(),
      updatedAtIso: (json['updated_at_iso'] ?? '').toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}
