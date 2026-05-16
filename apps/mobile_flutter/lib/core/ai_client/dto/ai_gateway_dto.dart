import '../../../domains/missions/mission_set.dart';

class MissionRankingDto {
  const MissionRankingDto({
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

  factory MissionRankingDto.fromJson(Map<String, dynamic> json) {
    return MissionRankingDto(
      impactScore: _asDouble(json['impact_score']) ?? 0,
      urgencyScore: _asDouble(json['urgency_score']) ?? 0,
      effortScore: _asDouble(json['effort_score']) ?? 0,
      confidenceScore: _asDouble(json['confidence_score']) ?? 0,
      privacyScore: _asDouble(json['privacy_score']) ?? 0,
      feedbackScore: _asDouble(json['feedback_score']) ?? 0,
      noveltyScore: _asDouble(json['novelty_score']) ?? 0,
      finalScore: _asDouble(json['final_score']) ?? 0,
      rankingReason: (json['ranking_reason'] ?? '').toString(),
      evidenceRefs: ((json['evidence_refs'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}

class MissionSuggestionDto {
  const MissionSuggestionDto({
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
  final MissionRankingDto? ranking;
  final Map<String, Object?> trace;

  MissionSuggestionDto copyWith({
    String? id,
    String? title,
    String? body,
    List<String>? evidence,
    String? uncertainty,
    bool? requiresConfirmation,
    List<String>? domainTargets,
    String? recommendationType,
    double? confidence,
    MissionRankingDto? ranking,
    Map<String, Object?>? trace,
  }) {
    return MissionSuggestionDto(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      evidence: evidence ?? this.evidence,
      uncertainty: uncertainty ?? this.uncertainty,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      domainTargets: domainTargets ?? this.domainTargets,
      recommendationType: recommendationType ?? this.recommendationType,
      confidence: confidence ?? this.confidence,
      ranking: ranking ?? this.ranking,
      trace: trace ?? this.trace,
    );
  }

  factory MissionSuggestionDto.fromJson(
    Map<String, dynamic> suggestionJson, {
    Map<String, Object?> trace = const <String, Object?>{},
  }) {
    final rawEvidence =
        suggestionJson['evidence'] as List<dynamic>? ?? const [];
    final evidence = rawEvidence.map((item) {
      if (item is Map && item['claim'] != null) {
        return item['claim'].toString();
      }
      return item.toString();
    }).toList(growable: false);

    final rawDomainTargets =
        suggestionJson['domain_targets'] as List<dynamic>? ?? const [];
    final rankingJson = suggestionJson['ranking'];

    return MissionSuggestionDto(
      id: (suggestionJson['suggestion_id'] ?? 'mission-unknown').toString(),
      title: (suggestionJson['title'] ?? 'Mission unavailable').toString(),
      body: (suggestionJson['body'] ??
              'The gateway did not return a mission body.')
          .toString(),
      evidence: evidence,
      uncertainty: (suggestionJson['uncertainty'] ?? 'No uncertainty provided.')
          .toString(),
      requiresConfirmation:
          (suggestionJson['requires_confirmation'] as bool?) ?? true,
      domainTargets: rawDomainTargets
          .map((item) => item.toString())
          .toList(growable: false),
      recommendationType:
          (suggestionJson['recommendation_type'] ?? 'mission').toString(),
      confidence: _asDouble(suggestionJson['confidence']) ?? 0.5,
      ranking: rankingJson is Map<String, dynamic>
          ? MissionRankingDto.fromJson(rankingJson)
          : rankingJson is Map
              ? MissionRankingDto.fromJson(
                  Map<String, dynamic>.from(rankingJson),
                )
              : null,
      trace: trace,
    );
  }
}

class MissionPlanDto {
  const MissionPlanDto({
    required this.missionSetId,
    required this.date,
    required this.sourceState,
    required this.fallbackUsed,
    required this.policyVersion,
    required this.rankingVersion,
    required this.suggestions,
    required this.trace,
  });

  final String missionSetId;
  final String date;
  final MissionSourceState sourceState;
  final bool fallbackUsed;
  final String? policyVersion;
  final String? rankingVersion;
  final List<MissionSuggestionDto> suggestions;
  final Map<String, Object?> trace;

  MissionSuggestionDto get primarySuggestion {
    if (suggestions.isEmpty) {
      throw const FormatException('Gateway returned no suggestions.');
    }
    return suggestions.first;
  }

  MissionPlanDto mergeTrace(Map<String, Object?> extraTrace) {
    final fallbackUsed =
        this.fallbackUsed || extraTrace['clientFallback'] == true;
    final mergedTrace = <String, Object?>{
      ...trace,
      'missionSetId': missionSetId,
      'date': date,
      'sourceState': fallbackUsed
          ? MissionSourceState.fallback.storageKey
          : sourceState.storageKey,
      'fallbackUsed': fallbackUsed,
      if (policyVersion != null) 'policyVersion': policyVersion,
      if (rankingVersion != null) 'rankingVersion': rankingVersion,
      ...extraTrace,
    };

    return MissionPlanDto(
      missionSetId: missionSetId,
      date: date,
      sourceState: fallbackUsed ? MissionSourceState.fallback : sourceState,
      fallbackUsed: fallbackUsed,
      policyVersion:
          policyVersion ?? _stringOrNull(mergedTrace['policyVersion']),
      rankingVersion:
          rankingVersion ?? _stringOrNull(mergedTrace['rankingVersion']),
      suggestions: suggestions
          .map(
            (suggestion) => suggestion.copyWith(
              trace: <String, Object?>{
                ...suggestion.trace,
                ...mergedTrace,
              },
            ),
          )
          .toList(growable: false),
      trace: mergedTrace,
    );
  }

  factory MissionPlanDto.fromGatewayJson(Map<String, dynamic> responseJson) {
    final rawSuggestions =
        responseJson['suggestions'] as List<dynamic>? ?? const [];
    final baseTrace = _normalizeTrace(
      Map<String, dynamic>.from(
        (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
    final missionSetId = _stringOrNull(
          responseJson['mission_set_id'] ?? responseJson['missionSetId'],
        ) ??
        'mission-set-local';
    final date = _stringOrNull(responseJson['date']) ?? _todayIsoDate();
    final policyVersion = _stringOrNull(
      responseJson['policy_version'] ??
          responseJson['policyVersion'] ??
          baseTrace['policyVersion'] ??
          baseTrace['policy_version'],
    );
    final rankingVersion = _stringOrNull(
      responseJson['ranking_version'] ??
          responseJson['rankingVersion'] ??
          baseTrace['rankingVersion'] ??
          baseTrace['ranking_version'],
    );
    final fallbackUsed = responseJson['fallback_used'] == true ||
        responseJson['fallbackUsed'] == true ||
        baseTrace['fallbackUsed'] == true ||
        baseTrace['fallback_used'] == true ||
        baseTrace['clientFallback'] == true;
    final sourceState = _resolveMissionSourceState(
      responseJson: responseJson,
      trace: baseTrace,
      fallbackUsed: fallbackUsed,
    );
    final trace = <String, Object?>{
      ...baseTrace,
      'missionSetId': missionSetId,
      'date': date,
      'sourceState': sourceState.storageKey,
      'fallbackUsed': fallbackUsed,
      if (policyVersion != null) 'policyVersion': policyVersion,
      if (rankingVersion != null) 'rankingVersion': rankingVersion,
    };

    final suggestions = <MissionSuggestionDto>[];
    for (final item in rawSuggestions) {
      if (item is! Map) {
        continue;
      }
      suggestions.add(
        MissionSuggestionDto.fromJson(
          Map<String, dynamic>.from(item),
          trace: trace,
        ),
      );
    }

    if (suggestions.isEmpty) {
      throw const FormatException('Gateway returned no suggestions.');
    }

    return MissionPlanDto(
      missionSetId: missionSetId,
      date: date,
      sourceState: sourceState,
      fallbackUsed: fallbackUsed,
      policyVersion: policyVersion,
      rankingVersion: rankingVersion,
      suggestions: suggestions,
      trace: trace,
    );
  }
}

MissionSourceState _resolveMissionSourceState({
  required Map<String, dynamic> responseJson,
  required Map<String, Object?> trace,
  required bool fallbackUsed,
}) {
  final rawValue = responseJson['source_state'] ??
      responseJson['sourceState'] ??
      trace['sourceState'] ??
      trace['source_state'];
  if (rawValue is String && rawValue.trim().isNotEmpty) {
    return missionSourceStateFromStorage(rawValue);
  }
  if (trace['clientFallback'] == true || fallbackUsed) {
    return MissionSourceState.fallback;
  }
  if (trace['mock'] == true || trace['mock_mode'] == true) {
    return MissionSourceState.local;
  }
  return MissionSourceState.live;
}

class CaptureClassificationDto {
  const CaptureClassificationDto({
    required this.domain,
    required this.eventType,
    required this.confidence,
    required this.rationale,
    required this.trace,
  });

  final String domain;
  final String eventType;
  final double confidence;
  final String rationale;
  final Map<String, Object?> trace;

  CaptureClassificationDto copyWith({
    String? domain,
    String? eventType,
    double? confidence,
    String? rationale,
    Map<String, Object?>? trace,
  }) {
    return CaptureClassificationDto(
      domain: domain ?? this.domain,
      eventType: eventType ?? this.eventType,
      confidence: confidence ?? this.confidence,
      rationale: rationale ?? this.rationale,
      trace: trace ?? this.trace,
    );
  }

  factory CaptureClassificationDto.fromGatewayJson(
    Map<String, dynamic> responseJson,
  ) {
    return CaptureClassificationDto(
      domain: (responseJson['domain'] ?? 'task').toString(),
      eventType: (responseJson['event_type'] ?? 'task_captured').toString(),
      confidence: _asDouble(responseJson['confidence']) ?? 0.5,
      rationale: (responseJson['rationale'] ?? 'No rationale was returned.')
          .toString(),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class CaptureParseItemDto {
  const CaptureParseItemDto({
    required this.text,
    required this.domain,
    required this.eventType,
    required this.confidence,
    required this.rationale,
    required this.hints,
  });

  final String text;
  final String domain;
  final String eventType;
  final double confidence;
  final String rationale;
  final Map<String, Object?> hints;

  factory CaptureParseItemDto.fromGatewayJson(
      Map<String, dynamic> responseJson) {
    return CaptureParseItemDto(
      text: (responseJson['text'] ?? '').toString(),
      domain: (responseJson['domain'] ?? 'task').toString(),
      eventType: (responseJson['event_type'] ?? 'task_captured').toString(),
      confidence: _asDouble(responseJson['confidence']) ?? 0.5,
      rationale: (responseJson['rationale'] ?? 'No rationale was returned.')
          .toString(),
      hints: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['hints'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class CaptureParseResponseDto {
  const CaptureParseResponseDto({
    required this.items,
    required this.trace,
  });

  final List<CaptureParseItemDto> items;
  final Map<String, Object?> trace;

  factory CaptureParseResponseDto.fromGatewayJson(
    Map<String, dynamic> responseJson,
  ) {
    final rawItems = responseJson['items'] as List<dynamic>? ?? const [];
    return CaptureParseResponseDto(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => CaptureParseItemDto.fromGatewayJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.text.isNotEmpty)
          .toList(growable: false),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

Map<String, Object?> _normalizeTrace(Map<String, dynamic> rawTrace) {
  return rawTrace.map<String, Object?>(
    (key, value) => MapEntry(key, _normalizeJsonValue(value)),
  );
}

Object? _normalizeJsonValue(Object? value) {
  if (value is Map) {
    return value.map<String, Object?>(
      (key, item) => MapEntry(key.toString(), _normalizeJsonValue(item)),
    );
  }
  if (value is List) {
    return value.map(_normalizeJsonValue).toList(growable: false);
  }
  return value;
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

String? _stringOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}

String _todayIsoDate() {
  final now = DateTime.now().toUtc();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

class PrivacySummaryDto {
  const PrivacySummaryDto({
    required this.aiEnabled,
    required this.sentEventCount,
    required this.blockedEventCount,
    required this.allowedDomains,
    required this.blockedDomains,
    required this.localOnlyCollections,
    required this.trace,
  });

  final bool aiEnabled;
  final int sentEventCount;
  final int blockedEventCount;
  final List<String> allowedDomains;
  final List<String> blockedDomains;
  final List<String> localOnlyCollections;
  final Map<String, Object?> trace;

  factory PrivacySummaryDto.fromJson(Map<String, dynamic> json) {
    return PrivacySummaryDto(
      aiEnabled: json['ai_enabled'] == true,
      sentEventCount: (json['sent_event_count'] as num?)?.toInt() ?? 0,
      blockedEventCount: (json['blocked_event_count'] as num?)?.toInt() ?? 0,
      allowedDomains: _stringList(json['allowed_domains']),
      blockedDomains: _stringList(json['blocked_domains']),
      localOnlyCollections: _stringList(json['local_only_collections']),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (json['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class ActionContractDto {
  const ActionContractDto({
    required this.actionType,
    required this.requiresConfirmation,
    required this.destructive,
    required this.external,
    required this.payloadPreview,
    required this.forbiddenActions,
  });

  final String actionType;
  final bool requiresConfirmation;
  final bool destructive;
  final bool external;
  final Map<String, Object?> payloadPreview;
  final List<String> forbiddenActions;

  factory ActionContractDto.fromJson(Map<String, dynamic> json) {
    return ActionContractDto(
      actionType: (json['action_type'] ?? 'review').toString(),
      requiresConfirmation: json['requires_confirmation'] != false,
      destructive: json['destructive'] == true,
      external: json['external'] == true,
      payloadPreview: _normalizeTrace(
        Map<String, dynamic>.from(
          (json['payload_preview'] as Map?)?.cast<String, dynamic>() ??
              const {},
        ),
      ),
      forbiddenActions: _stringList(json['forbidden_actions']),
    );
  }
}

class MentalLoadItemDto {
  const MentalLoadItemDto({
    required this.itemId,
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

  final String itemId;
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

  factory MentalLoadItemDto.fromJson(Map<String, dynamic> json) {
    return MentalLoadItemDto(
      itemId: (json['item_id'] ?? json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      sourceEventId: json['source_event_id']?.toString(),
      type: (json['type'] ?? 'note').toString(),
      domain: (json['domain'] ?? 'system').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      urgencyScore: _asDouble(json['urgency_score']) ?? 0.0,
      effortScore: _asDouble(json['effort_score']) ?? 0.0,
      confidence: _asDouble(json['confidence']) ?? 0.0,
      state: (json['state'] ?? 'inbox').toString(),
      dueHint: json['due_hint']?.toString(),
      amountHint: _asDouble(json['amount_hint']),
      currencyHint: json['currency_hint']?.toString(),
      evidenceRefs: _stringList(json['evidence_refs']),
      privacyLevel: (json['privacy_level'] ?? 'local_only').toString(),
      requiresConfirmation: json['requires_confirmation'] != false,
      createdAtIso: (json['created_at_iso'] ?? '').toString(),
      updatedAtIso: (json['updated_at_iso'] ?? '').toString(),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (json['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class DecisionCardDto {
  const DecisionCardDto({
    required this.decisionId,
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

  final String decisionId;
  final String userId;
  final String title;
  final String recommendedAction;
  final List<String> alternatives;
  final List<String> domainTargets;
  final List<String> sourceItems;
  final List<String> evidence;
  final double confidence;
  final String uncertainty;
  final PrivacySummaryDto privacySummary;
  final bool confirmationRequired;
  final ActionContractDto actionContract;
  final String status;
  final String evidenceStatus;
  final double rankingScore;
  final String createdAtIso;
  final String updatedAtIso;
  final Map<String, Object?> trace;

  factory DecisionCardDto.fromJson(Map<String, dynamic> json) {
    final ranking = json['ranking'];
    final finalScore =
        ranking is Map ? _asDouble(ranking['final_score']) : null;
    return DecisionCardDto(
      decisionId: (json['decision_id'] ?? json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      title: (json['title'] ?? '').toString(),
      recommendedAction: (json['recommended_action'] ?? '').toString(),
      alternatives: _stringList(json['alternatives']),
      domainTargets: _stringList(json['domain_targets']),
      sourceItems: _stringList(json['source_items']),
      evidence: _evidenceClaims(json['evidence']),
      confidence: _asDouble(json['confidence']) ?? 0.0,
      uncertainty: (json['uncertainty'] ?? '').toString(),
      privacySummary: PrivacySummaryDto.fromJson(
        Map<String, dynamic>.from(
          (json['privacy_summary'] as Map?) ?? const {},
        ),
      ),
      confirmationRequired: json['confirmation_required'] != false,
      actionContract: ActionContractDto.fromJson(
        Map<String, dynamic>.from(
          (json['action_contract'] as Map?) ?? const {},
        ),
      ),
      status: (json['status'] ?? 'draft').toString(),
      evidenceStatus: (json['evidence_status'] ??
              (_evidenceClaims(json['evidence']).isEmpty
                  ? 'insufficient_verified_data'
                  : 'local_only'))
          .toString(),
      rankingScore: _asDouble(json['ranking_score']) ?? finalScore ?? 0.0,
      createdAtIso: (json['created_at_iso'] ?? '').toString(),
      updatedAtIso: (json['updated_at_iso'] ?? '').toString(),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (json['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class MindFlowParseResponseDto {
  const MindFlowParseResponseDto({
    required this.items,
    required this.trace,
  });

  final List<MentalLoadItemDto> items;
  final Map<String, Object?> trace;

  factory MindFlowParseResponseDto.fromGatewayJson(
    Map<String, dynamic> responseJson,
  ) {
    final rawItems = responseJson['items'] as List<dynamic>? ?? const [];
    return MindFlowParseResponseDto(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => MentalLoadItemDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class DecisionPlanDto {
  const DecisionPlanDto({
    required this.decisions,
    required this.trace,
  });

  final List<DecisionCardDto> decisions;
  final Map<String, Object?> trace;

  factory DecisionPlanDto.fromGatewayJson(Map<String, dynamic> responseJson) {
    final rawDecisions =
        responseJson['decisions'] as List<dynamic>? ?? const [];
    return DecisionPlanDto(
      decisions: rawDecisions
          .whereType<Map>()
          .map(
            (item) => DecisionCardDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class ShoppingNeedDto {
  const ShoppingNeedDto({
    required this.needId,
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

  final String needId;
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

  factory ShoppingNeedDto.fromJson(Map<String, dynamic> json) {
    return ShoppingNeedDto(
      needId: (json['need_id'] ?? json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      needType: (json['need_type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      sourceDomain: (json['source_domain'] ?? 'shopping').toString(),
      sourceEventIds: _stringList(json['source_event_ids']),
      urgencyScore: _asDouble(json['urgency_score']) ?? 0.0,
      budgetHint: _asDouble(json['budget_hint']),
      currency: json['currency']?.toString(),
      sustainabilityPreference: json['sustainability_preference']?.toString(),
      state: (json['state'] ?? 'draft').toString(),
      createdAtIso: (json['created_at_iso'] ?? '').toString(),
      updatedAtIso: (json['updated_at_iso'] ?? '').toString(),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (json['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class ProductEvidenceCardDto {
  const ProductEvidenceCardDto({
    required this.id,
    required this.userId,
    required this.productName,
    required this.brand,
    required this.merchantName,
    required this.price,
    required this.currency,
    required this.source,
    required this.checkedAtIso,
    required this.reviewSummary,
    required this.sustainabilityStatus,
    required this.confidence,
    required this.disclaimer,
    required this.trace,
  });

  final String id;
  final String userId;
  final String productName;
  final String? brand;
  final String? merchantName;
  final double? price;
  final String? currency;
  final String? source;
  final String? checkedAtIso;
  final String? reviewSummary;
  final String sustainabilityStatus;
  final double confidence;
  final String disclaimer;
  final Map<String, Object?> trace;

  factory ProductEvidenceCardDto.fromJson(Map<String, dynamic> json) {
    return ProductEvidenceCardDto(
      id: (json['id'] ?? '${json['product_name'] ?? 'evidence'}').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      productName: (json['product_name'] ?? '').toString(),
      brand: json['brand']?.toString(),
      merchantName: json['merchant_name']?.toString(),
      price: _asDouble(json['price']),
      currency: json['currency']?.toString(),
      source: json['source']?.toString(),
      checkedAtIso: (json['checked_at_iso'] ?? json['checked_at'])?.toString(),
      reviewSummary: json['review_summary']?.toString(),
      sustainabilityStatus:
          (json['sustainability_status'] ?? 'not_checked').toString(),
      confidence: _asDouble(json['confidence']) ?? 0.0,
      disclaimer: (json['disclaimer'] ?? '').toString(),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (json['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class ShoppingPlanDto {
  const ShoppingPlanDto({
    required this.needs,
    required this.productEvidence,
    required this.decisions,
    required this.trace,
  });

  final List<ShoppingNeedDto> needs;
  final List<ProductEvidenceCardDto> productEvidence;
  final List<DecisionCardDto> decisions;
  final Map<String, Object?> trace;

  factory ShoppingPlanDto.fromGatewayJson(Map<String, dynamic> responseJson) {
    final rawNeeds = responseJson['needs'] as List<dynamic>? ?? const [];
    final rawEvidence =
        responseJson['product_evidence'] as List<dynamic>? ?? const [];
    final rawDecisions =
        responseJson['decisions'] as List<dynamic>? ?? const [];
    return ShoppingPlanDto(
      needs: rawNeeds
          .whereType<Map>()
          .map((item) =>
              ShoppingNeedDto.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      productEvidence: rawEvidence
          .whereType<Map>()
          .map(
            (item) => ProductEvidenceCardDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      decisions: rawDecisions
          .whereType<Map>()
          .map(
            (item) => DecisionCardDto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
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

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }
  return const <String>[];
}
