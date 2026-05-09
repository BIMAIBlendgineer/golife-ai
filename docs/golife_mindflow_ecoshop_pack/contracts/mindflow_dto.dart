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
      trace: _map(json['trace']),
    );
  }

  Map<String, Object?> toJson() => {
        'ai_enabled': aiEnabled,
        'sent_event_count': sentEventCount,
        'blocked_event_count': blockedEventCount,
        'allowed_domains': allowedDomains,
        'blocked_domains': blockedDomains,
        'local_only_collections': localOnlyCollections,
        'trace': trace,
      };
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
      actionType: (json['action_type'] ?? 'none').toString(),
      requiresConfirmation: json['requires_confirmation'] != false,
      destructive: json['destructive'] == true,
      external: json['external'] == true,
      payloadPreview: _map(json['payload_preview']),
      forbiddenActions: _stringList(json['forbidden_actions']),
    );
  }

  Map<String, Object?> toJson() => {
        'action_type': actionType,
        'requires_confirmation': requiresConfirmation,
        'destructive': destructive,
        'external': external,
        'payload_preview': payloadPreview,
        'forbidden_actions': forbiddenActions,
      };
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
  final Map<String, Object?> trace;

  factory MentalLoadItemDto.fromJson(Map<String, dynamic> json) {
    return MentalLoadItemDto(
      itemId: (json['item_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      sourceEventId: json['source_event_id']?.toString(),
      type: (json['type'] ?? 'note').toString(),
      domain: (json['domain'] ?? 'system').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      urgencyScore: _double(json['urgency_score']),
      effortScore: _double(json['effort_score']),
      confidence: _double(json['confidence']),
      state: (json['state'] ?? 'inbox').toString(),
      dueHint: json['due_hint']?.toString(),
      amountHint: _nullableDouble(json['amount_hint']),
      currencyHint: json['currency_hint']?.toString(),
      evidenceRefs: _stringList(json['evidence_refs']),
      privacyLevel: (json['privacy_level'] ?? 'local_only').toString(),
      requiresConfirmation: json['requires_confirmation'] != false,
      trace: _map(json['trace']),
    );
  }

  Map<String, Object?> toJson() => {
        'item_id': itemId,
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
        'trace': trace,
      };
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
  final Map<String, Object?> trace;

  factory DecisionCardDto.fromJson(Map<String, dynamic> json) {
    return DecisionCardDto(
      decisionId: (json['decision_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      recommendedAction: (json['recommended_action'] ?? '').toString(),
      alternatives: _stringList(json['alternatives']),
      domainTargets: _stringList(json['domain_targets']),
      sourceItems: _stringList(json['source_items']),
      evidence: _evidenceClaims(json['evidence']),
      confidence: _double(json['confidence']),
      uncertainty: (json['uncertainty'] ?? '').toString(),
      privacySummary: PrivacySummaryDto.fromJson(
        Map<String, dynamic>.from((json['privacy_summary'] as Map?) ?? const {}),
      ),
      confirmationRequired: json['confirmation_required'] != false,
      actionContract: ActionContractDto.fromJson(
        Map<String, dynamic>.from((json['action_contract'] as Map?) ?? const {}),
      ),
      status: (json['status'] ?? 'draft').toString(),
      trace: _map(json['trace']),
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

  factory ShoppingNeedDto.fromJson(Map<String, dynamic> json) {
    return ShoppingNeedDto(
      needId: (json['need_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      needType: (json['need_type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      sourceDomain: (json['source_domain'] ?? '').toString(),
      sourceEventIds: _stringList(json['source_event_ids']),
      urgencyScore: _double(json['urgency_score']),
      budgetHint: _nullableDouble(json['budget_hint']),
      currency: json['currency']?.toString(),
      sustainabilityPreference: json['sustainability_preference']?.toString(),
      state: (json['state'] ?? 'draft').toString(),
    );
  }
}

class ProductEvidenceCardDto {
  const ProductEvidenceCardDto({
    required this.productName,
    required this.brand,
    required this.merchantName,
    required this.price,
    required this.currency,
    required this.source,
    required this.checkedAt,
    required this.reviewSummary,
    required this.sustainabilityStatus,
    required this.confidence,
    required this.disclaimer,
    required this.trace,
  });

  final String productName;
  final String? brand;
  final String? merchantName;
  final double? price;
  final String? currency;
  final String? source;
  final String? checkedAt;
  final String? reviewSummary;
  final String sustainabilityStatus;
  final double confidence;
  final String disclaimer;
  final Map<String, Object?> trace;

  factory ProductEvidenceCardDto.fromJson(Map<String, dynamic> json) {
    return ProductEvidenceCardDto(
      productName: (json['product_name'] ?? '').toString(),
      brand: json['brand']?.toString(),
      merchantName: json['merchant_name']?.toString(),
      price: _nullableDouble(json['price']),
      currency: json['currency']?.toString(),
      source: json['source']?.toString(),
      checkedAt: json['checked_at']?.toString(),
      reviewSummary: json['review_summary']?.toString(),
      sustainabilityStatus:
          (json['sustainability_status'] ?? 'not_checked').toString(),
      confidence: _double(json['confidence']),
      disclaimer: (json['disclaimer'] ?? '').toString(),
      trace: _map(json['trace']),
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }
  return const <String>[];
}

Map<String, Object?> _map(Object? value) {
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, Object?>{};
}

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

double? _nullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

List<String> _evidenceClaims(Object? value) {
  if (value is List) {
    return value.map((item) {
      if (item is Map && item['claim'] != null) {
        return item['claim'].toString();
      }
      return item.toString();
    }).toList(growable: false);
  }
  return const <String>[];
}
