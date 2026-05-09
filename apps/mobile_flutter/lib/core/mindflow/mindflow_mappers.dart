import '../../core/privacy/privacy_models.dart';
import '../../domains/mindflow/action_contract.dart';
import '../../domains/mindflow/decision_card.dart';
import '../../domains/mindflow/mental_load_item.dart';
import '../../domains/mindflow/privacy_summary.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/shopping/product_evidence_card.dart';
import '../../domains/shopping/shopping_need.dart';
import '../../features/capture/capture_parser.dart';

MentalLoadItem mentalLoadItemFromDraft(
  CaptureDraftItem draft, {
  required String userId,
  String? sourceEventId,
  String? createdAtIso,
}) {
  final nowIso = createdAtIso ?? DateTime.now().toUtc().toIso8601String();
  return MentalLoadItem(
    id: 'mli-${DateTime.now().microsecondsSinceEpoch}',
    userId: userId,
    sourceEventId: sourceEventId,
    type: _mentalLoadTypeForDraft(draft),
    domain: draft.domain.wireName,
    title: draft.text,
    summary: draft.rationale,
    urgencyScore: _urgencyFromHints(draft),
    effortScore: _effortFromDraft(draft),
    confidence: draft.confidence,
    state: 'needs_confirmation',
    dueHint: draft.hints['time_hint']?.toString(),
    amountHint: draft.hints['amount'] is num
        ? (draft.hints['amount'] as num).toDouble()
        : null,
    currencyHint: draft.hints['currency']?.toString(),
    evidenceRefs: draft.hints.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList(growable: false),
    privacyLevel: draft.privacyLevel,
    requiresConfirmation: true,
    createdAtIso: nowIso,
    updatedAtIso: nowIso,
    trace: {
      'source': 'capture_draft',
      'event_type': draft.eventType,
      'hints': draft.hints,
    },
  );
}

DecisionCard decisionCardFromMission(
  DailyMission mission, {
  required PrivacySettings privacySettings,
  required int sentEventCount,
  required int blockedEventCount,
  required List<String> localOnlyCollections,
}) {
  final nowIso = DateTime.now().toUtc().toIso8601String();
  return DecisionCard(
    id: mission.id,
    userId: 'local-user',
    title: mission.title,
    recommendedAction: mission.body,
    alternatives: const <String>[],
    domainTargets: mission.domainTargets,
    sourceItems: mission.ranking?.evidenceRefs ?? const <String>[],
    evidence: mission.evidence,
    confidence: mission.confidence,
    uncertainty: mission.uncertainty,
    privacySummary: PrivacySummary(
      aiEnabled: privacySettings.aiEnabled,
      sentEventCount: sentEventCount,
      blockedEventCount: blockedEventCount,
      allowedDomains: privacySettings.aiAllowedWireDomains,
      blockedDomains: DomainKey.values
          .where((domain) => !privacySettings.aiAllowedDomains.contains(domain))
          .map((domain) => domain.wireName)
          .toList(growable: false),
      localOnlyCollections: localOnlyCollections,
      trace: mission.trace,
    ),
    confirmationRequired: mission.requiresConfirmation,
    actionContract: ActionContract(
      actionType: 'review_and_confirm',
      requiresConfirmation: true,
      destructive: false,
      external: false,
      payloadPreview: {
        'title': mission.title,
        'domains': mission.domainTargets,
      },
      forbiddenActions: const <String>[
        'external_action_without_confirmation',
      ],
    ),
    status: 'shown',
    evidenceStatus:
        mission.evidence.isEmpty ? 'insufficient_verified_data' : 'local_only',
    rankingScore: mission.ranking?.finalScore ?? mission.confidence,
    createdAtIso: nowIso,
    updatedAtIso: nowIso,
    trace: mission.trace,
  );
}

DecisionCard decisionCardFromJson(Map<String, dynamic> json) {
  return DecisionCard.fromJson(json);
}

ShoppingNeed shoppingNeedFromJson(Map<String, dynamic> json) {
  return ShoppingNeed.fromJson(json);
}

ProductEvidenceCard productEvidenceFromJson(Map<String, dynamic> json) {
  return ProductEvidenceCard.fromJson(json);
}

String _mentalLoadTypeForDraft(CaptureDraftItem draft) {
  switch (draft.domain) {
    case DomainKey.calendar:
      return 'calendar';
    case DomainKey.finance:
      return 'money';
    case DomainKey.journal:
      return 'journal';
    case DomainKey.pantry:
      return 'shopping';
    case DomainKey.recipes:
      return 'recipes';
    case DomainKey.homememory:
      return 'homememory';
    case DomainKey.shopping:
      return 'shopping';
    case DomainKey.decisions:
      return 'decision';
    case DomainKey.week:
      return 'calendar';
    case DomainKey.wardrobe:
      return 'shopping';
    case DomainKey.habits:
      return 'reminder';
    case DomainKey.tasks:
      return 'task';
    case DomainKey.copilot:
      return 'note';
  }
}

double _urgencyFromHints(CaptureDraftItem draft) {
  if (draft.hints['time_hint'] != null || draft.hints['expiry_hint'] != null) {
    return 0.82;
  }
  if (draft.domain == DomainKey.tasks) {
    return 0.76;
  }
  if (draft.domain == DomainKey.pantry || draft.domain == DomainKey.wardrobe) {
    return 0.68;
  }
  return 0.58;
}

double _effortFromDraft(CaptureDraftItem draft) {
  if (draft.domain == DomainKey.tasks) {
    return 0.64;
  }
  if (draft.domain == DomainKey.pantry || draft.domain == DomainKey.finance) {
    return 0.82;
  }
  return 0.72;
}
