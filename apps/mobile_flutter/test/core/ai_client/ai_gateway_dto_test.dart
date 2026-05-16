import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/dto/ai_gateway_dto.dart';
import 'package:golife_flutter/domains/missions/mission_set.dart';

void main() {
  group('Mission DTOs', () {
    test('parses mission set contract fields from gateway JSON', () {
      final plan = MissionPlanDto.fromGatewayJson({
        'mission_set_id': 'mission-set-2026-05-16',
        'date': '2026-05-16',
        'source_state': 'live',
        'fallback_used': false,
        'policy_version': 'policy_v1',
        'ranking_version': 'mission_ranker_v1',
        'suggestions': [
          {
            'suggestion_id': 'mission-1',
            'title': 'Close one task block',
            'domain_targets': ['task'],
            'recommendation_type': 'mission',
            'body': 'Finish one visible task block.',
            'evidence': [
              {'claim': 'Task evidence exists.'},
            ],
            'confidence': 0.81,
            'uncertainty': 'medium',
            'requires_confirmation': true,
          },
        ],
        'trace': {
          'active_provider': 'openrouter',
        },
      });

      expect(plan.missionSetId, 'mission-set-2026-05-16');
      expect(plan.date, '2026-05-16');
      expect(plan.sourceState, MissionSourceState.live);
      expect(plan.fallbackUsed, isFalse);
      expect(plan.policyVersion, 'policy_v1');
      expect(plan.rankingVersion, 'mission_ranker_v1');
      expect(plan.trace['sourceState'], 'live');
    });

    test('mergeTrace upgrades plan to client fallback source state', () {
      final plan = MissionPlanDto.fromGatewayJson({
        'mission_set_id': 'mission-set-2026-05-16',
        'date': '2026-05-16',
        'source_state': 'live',
        'suggestions': [
          {
            'suggestion_id': 'mission-1',
            'title': 'Close one task block',
            'domain_targets': ['task'],
            'recommendation_type': 'mission',
            'body': 'Finish one visible task block.',
            'evidence': [
              {'claim': 'Task evidence exists.'},
            ],
            'confidence': 0.81,
            'uncertainty': 'medium',
            'requires_confirmation': true,
          },
        ],
        'trace': const {},
      }).mergeTrace(const {
        'clientFallback': true,
        'fallbackReason': 'no_connection',
      });

      expect(plan.sourceState, MissionSourceState.fallback);
      expect(plan.fallbackUsed, isTrue);
      expect(plan.trace['fallbackReason'], 'no_connection');
    });
  });

  group('MindFlow DTOs', () {
    test('parses MindFlow parse responses from gateway JSON', () {
      final response = MindFlowParseResponseDto.fromGatewayJson({
        'items': [
          {
            'item_id': 'mental-1',
            'user_id': 'user-1',
            'source_event_id': 'evt-1',
            'type': 'maintenance_due',
            'domain': 'homememory',
            'title': 'Replace air filter',
            'summary': 'The filter should be checked this week.',
            'urgency_score': 0.71,
            'effort_score': 0.35,
            'confidence': 0.82,
            'state': 'pending',
            'due_hint': '2026-05-14',
            'amount_hint': '19.95',
            'currency_hint': 'EUR',
            'evidence_refs': ['evt-1'],
            'privacy_level': 'local_only',
            'requires_confirmation': true,
            'created_at_iso': '2026-05-09T10:00:00Z',
            'updated_at_iso': '2026-05-09T10:30:00Z',
            'trace': {
              'provider': 'mock',
              'nested': {
                'sources': ['local'],
              },
            },
          },
        ],
        'trace': {
          'graph': 'mindflow',
          'fallback': false,
        },
      });

      expect(response.items, hasLength(1));
      expect(response.items.first.itemId, 'mental-1');
      expect(response.items.first.amountHint, 19.95);
      expect(response.items.first.currencyHint, 'EUR');
      expect(response.items.first.trace['nested'], isA<Map<String, Object?>>());
      expect(response.trace['graph'], 'mindflow');
    });

    test('parses decision cards including ranking and evidence claims', () {
      final decision = DecisionCardDto.fromJson({
        'decision_id': 'decision-1',
        'user_id': 'user-1',
        'title': 'Repair the vacuum first',
        'recommended_action': 'Book a repair estimate before replacing it.',
        'alternatives': ['Replace immediately'],
        'domain_targets': ['homememory', 'shopping'],
        'source_items': ['mental-1'],
        'evidence': [
          {'claim': 'Warranty may still be active'},
          'Replacement cost is unclear',
        ],
        'confidence': 0.81,
        'uncertainty': 'Seller confirmation still required.',
        'privacy_summary': {
          'ai_enabled': false,
          'sent_event_count': 0,
          'blocked_event_count': 2,
          'allowed_domains': [],
          'blocked_domains': ['homememory'],
          'local_only_collections': ['purchase proofs'],
          'trace': {'source': 'local'},
        },
        'confirmation_required': true,
        'action_contract': {
          'action_type': 'review',
          'requires_confirmation': true,
          'destructive': false,
          'external': false,
          'payload_preview': {'next_step': 'repair_estimate'},
          'forbidden_actions': ['send_email'],
        },
        'status': 'active',
        'ranking': {'final_score': 0.77},
        'created_at_iso': '2026-05-09T10:00:00Z',
        'updated_at_iso': '2026-05-09T10:30:00Z',
        'trace': {'provider': 'gateway'},
      });

      expect(decision.decisionId, 'decision-1');
      expect(decision.evidence, [
        'Warranty may still be active',
        'Replacement cost is unclear',
      ]);
      expect(decision.rankingScore, 0.77);
      expect(decision.evidenceStatus, 'local_only');
      expect(decision.privacySummary.blockedDomains, ['homememory']);
      expect(decision.actionContract.forbiddenActions, ['send_email']);
    });
  });

  group('Shopping DTOs', () {
    test('parses shopping needs with numeric hints', () {
      final need = ShoppingNeedDto.fromJson({
        'need_id': 'need-1',
        'user_id': 'user-1',
        'need_type': 'restock',
        'title': 'Dish soap refill',
        'source_domain': 'pantry',
        'source_event_ids': ['evt-1'],
        'urgency_score': '0.62',
        'budget_hint': '12.5',
        'currency': 'EUR',
        'sustainability_preference': 'refill',
        'state': 'draft',
        'created_at_iso': '2026-05-09T10:00:00Z',
        'updated_at_iso': '2026-05-09T10:30:00Z',
        'trace': {'derived_from': 'pantry'},
      });

      expect(need.needId, 'need-1');
      expect(need.urgencyScore, 0.62);
      expect(need.budgetHint, 12.5);
      expect(need.sustainabilityPreference, 'refill');
    });

    test('parses product evidence cards using checked_at fallback', () {
      final card = ProductEvidenceCardDto.fromJson({
        'product_name': 'Dish soap refill',
        'merchant_name': 'Eco Shop',
        'price': '8.90',
        'currency': 'EUR',
        'source': 'merchant_feed',
        'checked_at': '2026-05-09T11:00:00Z',
        'review_summary': 'Refill option found locally.',
        'sustainability_status': 'insufficient_verified_data',
        'confidence': '0.44',
        'disclaimer': 'Verify independently.',
        'trace': {'provider': 'gateway'},
      });

      expect(card.id, 'Dish soap refill');
      expect(card.checkedAtIso, '2026-05-09T11:00:00Z');
      expect(card.price, 8.9);
      expect(card.sustainabilityStatus, 'insufficient_verified_data');
    });

    test('parses shopping plans with needs evidence and decisions', () {
      final plan = ShoppingPlanDto.fromGatewayJson({
        'needs': [
          {
            'need_id': 'need-2',
            'title': 'Repair kit',
            'source_domain': 'homememory',
            'urgency_score': 0.7,
          },
        ],
        'product_evidence': [
          {
            'id': 'evidence-2',
            'product_name': 'Repair kit',
            'sustainability_status': 'local_only',
            'confidence': 0.5,
            'disclaimer': 'Local proof only.',
          },
        ],
        'decisions': [
          {
            'decision_id': 'decision-2',
            'title': 'Compare repair kits',
            'recommended_action': 'Check local options first.',
            'evidence': ['Local proof available'],
            'privacy_summary': {
              'ai_enabled': false,
              'sent_event_count': 0,
              'blocked_event_count': 1,
              'allowed_domains': [],
              'blocked_domains': ['shopping'],
              'local_only_collections': ['product evidence cards'],
            },
            'action_contract': {
              'action_type': 'review',
              'requires_confirmation': true,
              'destructive': false,
              'external': false,
              'payload_preview': {},
              'forbidden_actions': [],
            },
          },
        ],
        'trace': {'graph': 'shopping'},
      });

      expect(plan.needs, hasLength(1));
      expect(plan.productEvidence, hasLength(1));
      expect(plan.decisions, hasLength(1));
      expect(plan.trace['graph'], 'shopping');
    });
  });
}
