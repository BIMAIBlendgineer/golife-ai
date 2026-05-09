class ShoppingNeed {
  const ShoppingNeed({
    required this.id,
    required this.userId,
    required this.needType,
    required this.title,
    required this.sourceDomain,
    required this.sourceEventIds,
    required this.urgencyScore,
    required this.budgetHint,
    required this.currency,
    required this.sustainabilityPreference,
    required this.state,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.trace,
  });

  final String id;
  final String userId;
  final String needType;
  final String title;
  final String sourceDomain;
  final List<String> sourceEventIds;
  final double urgencyScore;
  final double? budgetHint;
  final String? currency;
  final String? sustainabilityPreference;
  final String state;
  final String createdAtIso;
  final String updatedAtIso;
  final Map<String, Object?> trace;

  ShoppingNeed copyWith({
    String? state,
    String? updatedAtIso,
    Map<String, Object?>? trace,
  }) {
    return ShoppingNeed(
      id: id,
      userId: userId,
      needType: needType,
      title: title,
      sourceDomain: sourceDomain,
      sourceEventIds: sourceEventIds,
      urgencyScore: urgencyScore,
      budgetHint: budgetHint,
      currency: currency,
      sustainabilityPreference: sustainabilityPreference,
      state: state ?? this.state,
      createdAtIso: createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      trace: trace ?? this.trace,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'need_type': needType,
      'title': title,
      'source_domain': sourceDomain,
      'source_event_ids': sourceEventIds,
      'urgency_score': urgencyScore,
      'budget_hint': budgetHint,
      'currency': currency,
      'sustainability_preference': sustainabilityPreference,
      'state': state,
      'created_at_iso': createdAtIso,
      'updated_at_iso': updatedAtIso,
      'trace': trace,
    };
  }

  factory ShoppingNeed.fromJson(Map<String, dynamic> json) {
    return ShoppingNeed(
      id: (json['id'] ?? json['need_id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      needType: (json['need_type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      sourceDomain: (json['source_domain'] ?? 'shopping').toString(),
      sourceEventIds: ((json['source_event_ids'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      urgencyScore: (json['urgency_score'] as num?)?.toDouble() ?? 0.0,
      budgetHint: (json['budget_hint'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      sustainabilityPreference: json['sustainability_preference']?.toString(),
      state: (json['state'] ?? 'draft').toString(),
      createdAtIso: (json['created_at_iso'] ?? '').toString(),
      updatedAtIso: (json['updated_at_iso'] ?? '').toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}
