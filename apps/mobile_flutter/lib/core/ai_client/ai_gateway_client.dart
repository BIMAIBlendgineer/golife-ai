import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/mission_set.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import 'dto/ai_gateway_dto.dart';

abstract class AiGatewayClient {
  Future<MissionPlanDto> fetchDailyPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  });

  Future<MissionSuggestionDto> fetchDailyMission({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    final plan = await fetchDailyPlan(
      locale: locale,
      privacySettings: privacySettings,
      lifeEvents: lifeEvents,
    );
    return plan.primarySuggestion;
  }

  Future<CaptureClassificationDto> classifyCapture({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  });

  Future<CaptureParseResponseDto?> parseCapture({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    return null;
  }

  Future<MindFlowParseResponseDto?> parseMindFlowInbox({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    return null;
  }

  Future<DecisionPlanDto> fetchDecisionPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> mentalLoadItems,
  });

  Future<ShoppingPlanDto> optimizeShoppingList({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> shoppingNeeds,
    List<Map<String, Object?>> pantryContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> financeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> wardrobeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> homememoryContext =
        const <Map<String, Object?>>[],
  });

  Future<ProductEvidenceCardDto?> fetchProductEvidence({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String productName,
    String? merchantName,
  });

  Future<void> submitMissionFeedback({
    String locale = 'en',
    required MissionFeedback feedback,
  });
}

class MockAiGatewayClient extends AiGatewayClient {
  MockAiGatewayClient();

  @override
  Future<MissionPlanDto> fetchDailyPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    final allowedDomains = privacySettings.aiAllowedWireDomains.toSet();
    final sortedDomains = allowedDomains.toList()..sort();

    if (allowedDomains.isEmpty) {
      return MissionPlanDto(
        missionSetId: 'mission-set-local-empty',
        date: _todayIsoDate(),
        sourceState: MissionSourceState.local,
        fallbackUsed: true,
        policyVersion: 'policy_v1',
        rankingVersion: 'mission_ranker_v1',
        suggestions: [
          MissionSuggestionDto(
            id: 'mission-paused',
            title: 'Copilot paused',
            body:
                'Enable AI on at least one domain to generate daily missions.',
            evidence: const ['No domain is currently marked as AI-allowed.'],
            uncertainty: 'No cross-domain inference was attempted.',
            requiresConfirmation: true,
            domainTargets: const ['mission'],
            recommendationType: 'warning',
            confidence: 0.95,
            ranking: null,
            trace: const {
              'mock': true,
              'allowedDomains': <String>[],
            },
          ),
        ],
        trace: const {
          'mock': true,
          'allowedDomains': <String>[],
          'sourceState': 'local',
          'fallbackUsed': true,
          'policyVersion': 'policy_v1',
          'rankingVersion': 'mission_ranker_v1',
        },
      );
    }

    if (allowedDomains.contains('task') && allowedDomains.contains('habit')) {
      return _plan(
        allowedDomains: sortedDomains,
        lifeEvents: lifeEvents,
        suggestions: [
          _mission(
            id: 'mission-task-habit',
            title: 'Close one task, protect one ritual',
            body:
                'Finish the shortest critical task first, then log one low-friction habit so the day ends with traction instead of spillover.',
            evidence: const [
              'Tasks and habits are both AI-allowed.',
              'The life graph already has events in both domains.',
            ],
            uncertainty:
                'Mock mission based on consented domains, not a real remote call.',
            domainTargets: const ['task', 'habit'],
            confidence: 0.82,
          ),
          _mission(
            id: 'mission-task-focus',
            title: 'Reduce friction in one important task',
            body:
                'Define the next visible step for one task and finish that block before opening another thread.',
            evidence: const [
              'Task activity is available for AI.',
            ],
            uncertainty: 'Mock mission with local prioritization only.',
            domainTargets: const ['task'],
            confidence: 0.74,
          ),
          _mission(
            id: 'mission-habit-recovery',
            title: 'Keep one recovery habit alive',
            body:
                'Protect a 5 to 10 minute habit so the day does not become pure reaction mode.',
            evidence: const [
              'Habit continuity is visible in the local graph.',
            ],
            uncertainty:
                'Mock mission; the final effort still depends on energy.',
            domainTargets: const ['habit'],
            confidence: 0.71,
          ),
        ],
      );
    }

    if (allowedDomains.contains('finance') &&
        allowedDomains.contains('pantry')) {
      return _plan(
        allowedDomains: sortedDomains,
        lifeEvents: lifeEvents,
        suggestions: [
          _mission(
            id: 'mission-finance-pantry',
            title: 'Use what is already paid for',
            body:
                'Before adding anything to a shopping list, build one meal around an ingredient you already have at home.',
            evidence: const [
              'Finance and pantry are both AI-allowed.',
              'The mission avoids purchase advice and focuses on using existing items.',
            ],
            uncertainty:
                'Mock mission; pantry availability still needs human confirmation.',
            domainTargets: const ['finance', 'pantry'],
            confidence: 0.81,
          ),
          _mission(
            id: 'mission-finance-pause',
            title: 'Pause one avoidable spend',
            body:
                'Delay one small non-urgent purchase until you review whether it solves a real need today.',
            evidence: const [
              'Finance is AI-allowed.',
            ],
            uncertainty:
                'Mock reflection; this is not financial advice or a universal rule.',
            domainTargets: const ['finance'],
            recommendationType: 'reflection',
            confidence: 0.72,
          ),
          _mission(
            id: 'mission-pantry-rescue',
            title: 'Rescue one ingredient first',
            body:
                'Turn one existing ingredient into a low-effort meal before opening a new buying decision.',
            evidence: const [
              'Pantry activity is visible to AI.',
            ],
            uncertainty: 'Mock mission; confirm real stock locally first.',
            domainTargets: const ['pantry'],
            confidence: 0.7,
          ),
        ],
      );
    }

    if (allowedDomains.contains('wardrobe')) {
      return _plan(
        allowedDomains: sortedDomains,
        lifeEvents: lifeEvents,
        suggestions: [
          _mission(
            id: 'mission-wardrobe',
            title: 'Compare before buying',
            body:
                'Review one outfit you already own before acting on any clothing purchase intention today.',
            evidence: const [
              'Wardrobe is AI-allowed.',
              'The mission keeps the final decision with the user.',
            ],
            uncertainty:
                'Mock mission; visual comparison still needs the person.',
            domainTargets: const ['wardrobe'],
            recommendationType: 'reflection',
            confidence: 0.79,
          ),
          _mission(
            id: 'mission-wardrobe-delay',
            title: 'Delay the decision 24 hours',
            body:
                'If the purchase is not solving an immediate gap, wait one day and compare it again with what you already own.',
            evidence: const [
              'Wardrobe intent can benefit from a pause.',
            ],
            uncertainty: 'Mock mission; the decision remains fully manual.',
            domainTargets: const ['wardrobe'],
            recommendationType: 'warning',
            confidence: 0.72,
          ),
          _mission(
            id: 'mission-wardrobe-outfit',
            title: 'Try one existing combination first',
            body:
                'Build one outfit with a piece you already have before creating a new shopping loop.',
            evidence: const [
              'Closet context is available without needing a new purchase.',
            ],
            uncertainty: 'Mock mission; still requires a visual check.',
            domainTargets: const ['wardrobe'],
            confidence: 0.69,
          ),
        ],
      );
    }

    return _plan(
      allowedDomains: sortedDomains,
      lifeEvents: lifeEvents,
      suggestions: [
        _mission(
          id: 'mission-generic',
          title: 'Pick one visible win',
          body:
              'Choose the smallest action that clearly reduces friction in one AI-allowed area and review it once it is done.',
          evidence: const [
            'At least one domain allows AI.',
          ],
          uncertainty: 'Mock mission with limited cross-domain context.',
          domainTargets: const ['mission'],
          confidence: 0.68,
        ),
        _mission(
          id: 'mission-generic-risk',
          title: 'Prevent one small risk from rolling into tomorrow',
          body:
              'Identify one small friction point and take the minimum action that stops it from carrying over.',
          evidence: const [
            'The graph has enough local context for a small preventive action.',
          ],
          uncertainty: 'Mock mission with partial local context.',
          domainTargets: const ['mission'],
          recommendationType: 'warning',
          confidence: 0.62,
        ),
        _mission(
          id: 'mission-generic-close',
          title: 'Leave one clear closing signal',
          body:
              'Finish one small closing action so tomorrow does not start with the same open loop.',
          evidence: const [
            'A small closure often reduces next-day friction.',
          ],
          uncertainty:
              'Mock mission; the exact action still depends on the day.',
          domainTargets: const ['mission'],
          confidence: 0.6,
        ),
      ],
    );
  }

  @override
  Future<CaptureClassificationDto> classifyCapture({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    return _classifyCaptureLocally(
      privacySettings: privacySettings,
      text: text,
      trace: const {'mock': true},
    );
  }

  @override
  Future<CaptureParseResponseDto?> parseCapture({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    return null;
  }

  @override
  Future<MindFlowParseResponseDto?> parseMindFlowInbox({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    return _localMindFlowParse(
      text: text,
      privacySettings: privacySettings,
    );
  }

  @override
  Future<DecisionPlanDto> fetchDecisionPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> mentalLoadItems,
  }) async {
    return _localDecisionPlan(
      privacySettings: privacySettings,
      mentalLoadItems: mentalLoadItems,
    );
  }

  @override
  Future<ShoppingPlanDto> optimizeShoppingList({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> shoppingNeeds,
    List<Map<String, Object?>> pantryContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> financeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> wardrobeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> homememoryContext =
        const <Map<String, Object?>>[],
  }) async {
    return _localShoppingPlan(
      privacySettings: privacySettings,
      shoppingNeeds: shoppingNeeds,
      pantryContext: pantryContext,
      financeContext: financeContext,
      wardrobeContext: wardrobeContext,
      homememoryContext: homememoryContext,
    );
  }

  @override
  Future<ProductEvidenceCardDto?> fetchProductEvidence({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String productName,
    String? merchantName,
  }) async {
    return ProductEvidenceCardDto.fromJson({
      'id': 'evidence-$productName',
      'user_id': 'local-user',
      'product_name': productName,
      'merchant_name': merchantName,
      'sustainability_status': 'insufficient_verified_data',
      'confidence': 0.42,
      'disclaimer':
          'No price, availability, or sustainability claim is shown without verified evidence.',
      'trace': {
        'mock': true,
        'fallback': true,
      },
    });
  }

  @override
  Future<void> submitMissionFeedback({
    String locale = 'en',
    required MissionFeedback feedback,
  }) async {}
}

class HttpAiGatewayClient extends AiGatewayClient {
  HttpAiGatewayClient({
    required Uri baseUri,
    http.Client? httpClient,
    AiGatewayClient? fallbackClient,
    this.userId = 'local-user',
    this.timeout = const Duration(seconds: 4),
  })  : _baseUri = baseUri,
        _httpClient = httpClient ?? http.Client(),
        _fallbackClient = fallbackClient ?? MockAiGatewayClient();

  Uri _baseUri;
  final http.Client _httpClient;
  final AiGatewayClient _fallbackClient;
  final String userId;
  final Duration timeout;

  Uri get baseUri => _baseUri;

  void updateBaseUri(Uri baseUri) {
    _baseUri = baseUri;
  }

  @override
  Future<MissionPlanDto> fetchDailyPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    final allowedDomains = privacySettings.aiAllowedWireDomains;
    final eligibleEvents = _eventsEligibleForAi(
      lifeEvents: lifeEvents,
      privacySettings: privacySettings,
    );
    final requestPayload = {
      'user_id': userId,
      'locale': locale,
      'scope': 'daily',
      'allowed_domains': allowedDomains,
      'life_events': eligibleEvents
          .map(
            (event) => event.toGatewayJson(
              userIdOverride: userId,
            ),
          )
          .toList(growable: false),
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': allowedDomains,
        'allow_cross_domain_patterns': allowedDomains.length > 1,
      },
      'domain_summaries': _buildDomainSummaries(
        lifeEvents: eligibleEvents,
        privacySettings: privacySettings,
      ),
      'constraints': {
        'client': 'golife_flutter',
        'trace_visible': true,
        'fallback_enabled': true,
        'filtered_event_count': lifeEvents.length - eligibleEvents.length,
      },
      'max_suggestions': 3,
    };

    try {
      final response = await _httpClient
          .post(
            _endpoint('/v1/missions/daily'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(requestPayload),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return _fallbackPlan(
          locale: locale,
          privacySettings: privacySettings,
          lifeEvents: lifeEvents,
          reason: _fallbackReasonFromResponse(response),
          endpoint: '/v1/missions/daily',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _fallbackPlan(
          locale: locale,
          privacySettings: privacySettings,
          lifeEvents: lifeEvents,
          reason: 'invalid_json_shape',
          endpoint: '/v1/missions/daily',
        );
      }

      final plan = MissionPlanDto.fromGatewayJson(decoded);
      return plan.mergeTrace(
        <String, Object?>{
          'remote': true,
          'baseUrl': baseUri.toString(),
          'endpoint': '/v1/missions/daily',
          'statusCode': response.statusCode,
          'sentEventCount': eligibleEvents.length,
          'filteredEventCount': lifeEvents.length - eligibleEvents.length,
        },
      );
    } on TimeoutException {
      return _fallbackPlan(
        locale: locale,
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: 'no_connection',
        endpoint: '/v1/missions/daily',
      );
    } on SocketException {
      return _fallbackPlan(
        locale: locale,
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: 'no_connection',
        endpoint: '/v1/missions/daily',
      );
    } on http.ClientException {
      return _fallbackPlan(
        locale: locale,
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: 'no_connection',
        endpoint: '/v1/missions/daily',
      );
    } on FormatException {
      return _fallbackPlan(
        locale: locale,
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: 'invalid_json',
        endpoint: '/v1/missions/daily',
      );
    } catch (error) {
      return _fallbackPlan(
        locale: locale,
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: 'gateway_degraded',
        endpoint: '/v1/missions/daily',
      );
    }
  }

  @override
  Future<CaptureClassificationDto> classifyCapture({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    final payload = {
      'user_id': userId,
      'locale': locale,
      'text': text,
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': privacySettings.aiAllowedWireDomains,
        'allow_cross_domain_patterns':
            privacySettings.aiAllowedWireDomains.length > 1,
      },
    };

    try {
      final response = await _httpClient
          .post(
            _endpoint('/v1/events/classify'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return _fallbackClassification(
          locale: locale,
          privacySettings: privacySettings,
          text: text,
          reason: _fallbackReasonFromResponse(response),
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _fallbackClassification(
          locale: locale,
          privacySettings: privacySettings,
          text: text,
          reason: 'invalid_json_shape',
        );
      }

      final classification = CaptureClassificationDto.fromGatewayJson(decoded);
      return classification.copyWith(
        trace: <String, Object?>{
          ...classification.trace,
          'remote': true,
          'baseUrl': baseUri.toString(),
          'endpoint': '/v1/events/classify',
          'statusCode': response.statusCode,
        },
      );
    } on TimeoutException {
      return _fallbackClassification(
        locale: locale,
        privacySettings: privacySettings,
        text: text,
        reason: 'no_connection',
      );
    } on SocketException {
      return _fallbackClassification(
        locale: locale,
        privacySettings: privacySettings,
        text: text,
        reason: 'no_connection',
      );
    } on http.ClientException {
      return _fallbackClassification(
        locale: locale,
        privacySettings: privacySettings,
        text: text,
        reason: 'no_connection',
      );
    } on FormatException {
      return _fallbackClassification(
        locale: locale,
        privacySettings: privacySettings,
        text: text,
        reason: 'invalid_json',
      );
    } catch (error) {
      return _fallbackClassification(
        locale: locale,
        privacySettings: privacySettings,
        text: text,
        reason: 'gateway_degraded',
      );
    }
  }

  @override
  Future<CaptureParseResponseDto?> parseCapture({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    final payload = {
      'user_id': userId,
      'locale': locale,
      'text': text,
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': privacySettings.aiAllowedWireDomains,
        'allow_cross_domain_patterns':
            privacySettings.aiAllowedWireDomains.length > 1,
      },
    };

    try {
      final response = await _httpClient
          .post(
            _endpoint('/v1/events/parse'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return CaptureParseResponseDto.fromGatewayJson(decoded);
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } on http.ClientException {
      return null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MindFlowParseResponseDto?> parseMindFlowInbox({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    final payload = {
      'user_id': userId,
      'locale': locale,
      'text': text,
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': privacySettings.aiAllowedWireDomains,
        'allow_cross_domain_patterns':
            privacySettings.aiAllowedWireDomains.length > 1,
      },
    };

    try {
      final response = await _httpClient
          .post(
            _endpoint('/v1/mindflow/inbox/parse'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return _localMindFlowParse(
          text: text,
          privacySettings: privacySettings,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _localMindFlowParse(
          text: text,
          privacySettings: privacySettings,
        );
      }

      return MindFlowParseResponseDto.fromGatewayJson(decoded);
    } on TimeoutException {
      return _localMindFlowParse(
        text: text,
        privacySettings: privacySettings,
      );
    } on SocketException {
      return _localMindFlowParse(
        text: text,
        privacySettings: privacySettings,
      );
    } on http.ClientException {
      return _localMindFlowParse(
        text: text,
        privacySettings: privacySettings,
      );
    } on FormatException {
      return _localMindFlowParse(
        text: text,
        privacySettings: privacySettings,
      );
    } catch (_) {
      return _localMindFlowParse(
        text: text,
        privacySettings: privacySettings,
      );
    }
  }

  @override
  Future<DecisionPlanDto> fetchDecisionPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> mentalLoadItems,
  }) async {
    final payload = {
      'user_id': userId,
      'locale': locale,
      'mental_load_items': mentalLoadItems,
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': privacySettings.aiAllowedWireDomains,
        'allow_cross_domain_patterns':
            privacySettings.aiAllowedWireDomains.length > 1,
      },
      'constraints': {
        'client': 'golife_flutter',
        'trace_visible': true,
        'fallback_enabled': true,
      },
      'max_decisions': 3,
    };

    try {
      final response = await _httpClient
          .post(
            _endpoint('/v1/mindflow/decisions/daily'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return _localDecisionPlan(
          privacySettings: privacySettings,
          mentalLoadItems: mentalLoadItems,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _localDecisionPlan(
          privacySettings: privacySettings,
          mentalLoadItems: mentalLoadItems,
        );
      }

      return DecisionPlanDto.fromGatewayJson(decoded);
    } on TimeoutException {
      return _localDecisionPlan(
        privacySettings: privacySettings,
        mentalLoadItems: mentalLoadItems,
      );
    } on SocketException {
      return _localDecisionPlan(
        privacySettings: privacySettings,
        mentalLoadItems: mentalLoadItems,
      );
    } on http.ClientException {
      return _localDecisionPlan(
        privacySettings: privacySettings,
        mentalLoadItems: mentalLoadItems,
      );
    } on FormatException {
      return _localDecisionPlan(
        privacySettings: privacySettings,
        mentalLoadItems: mentalLoadItems,
      );
    } catch (_) {
      return _localDecisionPlan(
        privacySettings: privacySettings,
        mentalLoadItems: mentalLoadItems,
      );
    }
  }

  @override
  Future<ShoppingPlanDto> optimizeShoppingList({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> shoppingNeeds,
    List<Map<String, Object?>> pantryContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> financeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> wardrobeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> homememoryContext =
        const <Map<String, Object?>>[],
  }) async {
    final payload = {
      'user_id': userId,
      'locale': locale,
      'shopping_needs': shoppingNeeds,
      'pantry_context': pantryContext,
      'finance_context': financeContext,
      'wardrobe_context': wardrobeContext,
      'homememory_context': homememoryContext,
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': privacySettings.aiAllowedWireDomains,
        'allow_cross_domain_patterns':
            privacySettings.aiAllowedWireDomains.length > 1,
      },
    };

    try {
      final response = await _httpClient
          .post(
            _endpoint('/v1/shopping/list/optimize'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return _localShoppingPlan(
          privacySettings: privacySettings,
          shoppingNeeds: shoppingNeeds,
          pantryContext: pantryContext,
          financeContext: financeContext,
          wardrobeContext: wardrobeContext,
          homememoryContext: homememoryContext,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _localShoppingPlan(
          privacySettings: privacySettings,
          shoppingNeeds: shoppingNeeds,
          pantryContext: pantryContext,
          financeContext: financeContext,
          wardrobeContext: wardrobeContext,
          homememoryContext: homememoryContext,
        );
      }

      return ShoppingPlanDto.fromGatewayJson(decoded);
    } on TimeoutException {
      return _localShoppingPlan(
        privacySettings: privacySettings,
        shoppingNeeds: shoppingNeeds,
        pantryContext: pantryContext,
        financeContext: financeContext,
        wardrobeContext: wardrobeContext,
        homememoryContext: homememoryContext,
      );
    } on SocketException {
      return _localShoppingPlan(
        privacySettings: privacySettings,
        shoppingNeeds: shoppingNeeds,
        pantryContext: pantryContext,
        financeContext: financeContext,
        wardrobeContext: wardrobeContext,
        homememoryContext: homememoryContext,
      );
    } on http.ClientException {
      return _localShoppingPlan(
        privacySettings: privacySettings,
        shoppingNeeds: shoppingNeeds,
        pantryContext: pantryContext,
        financeContext: financeContext,
        wardrobeContext: wardrobeContext,
        homememoryContext: homememoryContext,
      );
    } on FormatException {
      return _localShoppingPlan(
        privacySettings: privacySettings,
        shoppingNeeds: shoppingNeeds,
        pantryContext: pantryContext,
        financeContext: financeContext,
        wardrobeContext: wardrobeContext,
        homememoryContext: homememoryContext,
      );
    } catch (_) {
      return _localShoppingPlan(
        privacySettings: privacySettings,
        shoppingNeeds: shoppingNeeds,
        pantryContext: pantryContext,
        financeContext: financeContext,
        wardrobeContext: wardrobeContext,
        homememoryContext: homememoryContext,
      );
    }
  }

  @override
  Future<ProductEvidenceCardDto?> fetchProductEvidence({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String productName,
    String? merchantName,
  }) async {
    final payload = {
      'user_id': userId,
      'locale': locale,
      'product_name': productName,
      'merchant_name': merchantName,
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': privacySettings.aiAllowedWireDomains,
        'allow_cross_domain_patterns':
            privacySettings.aiAllowedWireDomains.length > 1,
      },
    };

    try {
      final response = await _httpClient
          .post(
            _endpoint('/v1/shopping/product/evidence'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return await _fallbackClient.fetchProductEvidence(
          locale: locale,
          privacySettings: privacySettings,
          productName: productName,
          merchantName: merchantName,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return await _fallbackClient.fetchProductEvidence(
          locale: locale,
          privacySettings: privacySettings,
          productName: productName,
          merchantName: merchantName,
        );
      }

      return ProductEvidenceCardDto.fromJson(decoded);
    } on TimeoutException {
      return _fallbackClient.fetchProductEvidence(
        locale: locale,
        privacySettings: privacySettings,
        productName: productName,
        merchantName: merchantName,
      );
    } on SocketException {
      return _fallbackClient.fetchProductEvidence(
        locale: locale,
        privacySettings: privacySettings,
        productName: productName,
        merchantName: merchantName,
      );
    } on http.ClientException {
      return _fallbackClient.fetchProductEvidence(
        locale: locale,
        privacySettings: privacySettings,
        productName: productName,
        merchantName: merchantName,
      );
    } on FormatException {
      return _fallbackClient.fetchProductEvidence(
        locale: locale,
        privacySettings: privacySettings,
        productName: productName,
        merchantName: merchantName,
      );
    } catch (_) {
      return _fallbackClient.fetchProductEvidence(
        locale: locale,
        privacySettings: privacySettings,
        productName: productName,
        merchantName: merchantName,
      );
    }
  }

  @override
  Future<void> submitMissionFeedback({
    String locale = 'en',
    required MissionFeedback feedback,
  }) async {
    final payload = {
      'user_id': userId,
      'locale': locale,
      'suggestion_id': feedback.missionId,
      'status': feedback.status.storageKey,
      'notes': feedback.notes,
      'domain_targets': feedback.domainTargets,
      'recommendation_type': feedback.recommendationType,
      'rejection_reason_category': feedback.rejectionReasonCategory?.storageKey,
      'effort_feedback': feedback.effortFeedback?.storageKey,
      'repeated_flag': feedback.repeatedFlag,
      'trace': feedback.trace,
    };

    final response = await _httpClient
        .post(
          _endpoint('/v1/feedback'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Feedback endpoint failed with status ${response.statusCode}.',
      );
    }
  }

  Future<MissionPlanDto> _fallbackPlan({
    required String locale,
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
    required String reason,
    required String endpoint,
    int? statusCode,
  }) async {
    final fallback = await _fallbackClient.fetchDailyPlan(
      locale: locale,
      privacySettings: privacySettings,
      lifeEvents: lifeEvents,
    );
    return fallback.mergeTrace(
      <String, Object?>{
        'clientFallback': true,
        'fallbackReason': reason,
        'statusCode': statusCode,
        'baseUrl': baseUri.toString(),
        'endpoint': endpoint,
      },
    );
  }

  Future<CaptureClassificationDto> _fallbackClassification({
    required String locale,
    required PrivacySettings privacySettings,
    required String text,
    required String reason,
    int? statusCode,
  }) async {
    final fallback = await _fallbackClient.classifyCapture(
      locale: locale,
      privacySettings: privacySettings,
      text: text,
    );
    return fallback.copyWith(
      trace: <String, Object?>{
        ...fallback.trace,
        'clientFallback': true,
        'fallbackReason': reason,
        'statusCode': statusCode,
        'baseUrl': baseUri.toString(),
        'endpoint': '/v1/events/classify',
      },
    );
  }

  Uri _endpoint(String path) {
    final normalizedBase = baseUri.toString().endsWith('/')
        ? baseUri.toString().substring(0, baseUri.toString().length - 1)
        : baseUri.toString();
    return Uri.parse('$normalizedBase$path');
  }

  String _fallbackReasonFromResponse(http.Response response) {
    if (response.statusCode == 503) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final detail = decoded['detail'];
          if (detail is Map && detail['code'] != null) {
            return detail['code'].toString();
          }
        }
      } catch (_) {}
    }
    return 'http_${response.statusCode}';
  }
}

MissionPlanDto _plan({
  required List<String> allowedDomains,
  required List<LifeEvent> lifeEvents,
  required List<MissionSuggestionDto> suggestions,
}) {
  final date = _todayIsoDate();
  final trace = <String, Object?>{
    'mock': true,
    'allowedDomains': allowedDomains,
    'eventCount': lifeEvents.length,
    'planSize': suggestions.length,
    'sourceState': 'local',
    'fallbackUsed': true,
    'policyVersion': 'policy_v1',
    'rankingVersion': 'mission_ranker_v1',
  };
  return MissionPlanDto(
    missionSetId: 'mission-set-local-$date',
    date: date,
    sourceState: MissionSourceState.local,
    fallbackUsed: true,
    policyVersion: 'policy_v1',
    rankingVersion: 'mission_ranker_v1',
    suggestions: suggestions
        .map((suggestion) => suggestion.copyWith(trace: trace))
        .toList(growable: false),
    trace: trace,
  );
}

String _todayIsoDate() {
  final now = DateTime.now().toUtc();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

MissionSuggestionDto _mission({
  required String id,
  required String title,
  required String body,
  required List<String> evidence,
  required String uncertainty,
  required List<String> domainTargets,
  required double confidence,
  String recommendationType = 'mission',
}) {
  return MissionSuggestionDto(
    id: id,
    title: title,
    body: body,
    evidence: evidence,
    uncertainty: uncertainty,
    requiresConfirmation: true,
    domainTargets: domainTargets,
    recommendationType: recommendationType,
    confidence: confidence,
    ranking: null,
    trace: const <String, Object?>{},
  );
}

CaptureClassificationDto _classifyCaptureLocally({
  required PrivacySettings privacySettings,
  required String text,
  Map<String, Object?> trace = const <String, Object?>{},
}) {
  final lowered = text.toLowerCase();

  CaptureClassificationDto response({
    required String domain,
    required String eventType,
    required double confidence,
    required String rationale,
    List<String> matchedKeywords = const <String>[],
  }) {
    return CaptureClassificationDto(
      domain: domain,
      eventType: eventType,
      confidence: confidence,
      rationale: rationale,
      trace: <String, Object?>{
        ...trace,
        'classifier': 'deterministic_capture_router',
        'aiEnabled': privacySettings.aiEnabled,
        'matchedKeywords': matchedKeywords,
      },
    );
  }

  final rules = <({
    String domain,
    String eventType,
    double confidence,
    List<String> keywords,
    String rationale,
  })>[
    (
      domain: 'finance',
      eventType: 'expense_logged',
      confidence: 0.84,
      keywords: const <String>[
        r'$',
        'eur',
        'gaste',
        'compre',
        'coffee',
        'pague',
        'paid',
        'bought',
      ],
      rationale: 'Detected money and purchase language.',
    ),
    (
      domain: 'pantry',
      eventType: 'ingredient_flagged',
      confidence: 0.82,
      keywords: const <String>[
        'vence',
        'expires',
        'fridge',
        'pantry',
        'spinach',
        'lechuga',
        'espinaca',
      ],
      rationale: 'Detected pantry or expiry language.',
    ),
    (
      domain: 'wardrobe',
      eventType: 'purchase_intention',
      confidence: 0.8,
      keywords: const <String>[
        'jacket',
        'shirt',
        'ropa',
        'chaqueta',
        'closet',
        'armario',
        'outfit',
      ],
      rationale: 'Detected wardrobe or clothing intent.',
    ),
    (
      domain: 'habit',
      eventType: 'habit_logged',
      confidence: 0.77,
      keywords: const <String>[
        'habit',
        'streak',
        'meditate',
        'walked',
        'camine',
        'sleep',
        'water',
      ],
      rationale: 'Detected habit continuity language.',
    ),
    (
      domain: 'week',
      eventType: 'week_note_captured',
      confidence: 0.74,
      keywords: const <String>[
        'week',
        'semana',
        'monday',
        'martes',
        'viernes',
        'calendar',
      ],
      rationale: 'Detected planning or weekly framing.',
    ),
  ];

  for (final rule in rules) {
    final matchedKeywords = rule.keywords
        .where((keyword) => lowered.contains(keyword))
        .toList(growable: false);
    if (matchedKeywords.isNotEmpty) {
      return response(
        domain: rule.domain,
        eventType: rule.eventType,
        confidence: rule.confidence,
        rationale: rule.rationale,
        matchedKeywords: matchedKeywords,
      );
    }
  }

  return response(
    domain: 'task',
    eventType: 'task_captured',
    confidence: 0.62,
    rationale: 'Defaulted to task because no stronger domain signal was found.',
  );
}

List<Map<String, Object?>> _buildDomainSummaries({
  required List<LifeEvent> lifeEvents,
  required PrivacySettings privacySettings,
}) {
  final counts = <String, int>{};
  final summaries = <String, String>{};

  for (final event in lifeEvents) {
    final permission = privacySettings.permissionForWireDomain(event.domain);
    if (permission != DataPermission.aiAllowed) {
      continue;
    }
    counts[event.domain] = (counts[event.domain] ?? 0) + 1;
    summaries[event.domain] = event.summary;
  }

  return counts.entries
      .map(
        (entry) => <String, Object?>{
          'domain': entry.key,
          'summary': summaries[entry.key] ??
              '${entry.value} AI-allowed events are available for ${entry.key}.',
          'evidence_count': entry.value,
          'ai_allowed': true,
        },
      )
      .toList(growable: false);
}

List<LifeEvent> _eventsEligibleForAi({
  required List<LifeEvent> lifeEvents,
  required PrivacySettings privacySettings,
}) {
  return lifeEvents.where((event) {
    final permission = privacySettings.permissionForWireDomain(event.domain);
    return permission == DataPermission.aiAllowed &&
        event.privacyLevel == DataPermission.aiAllowed.storageKey;
  }).toList(growable: false);
}

MindFlowParseResponseDto _localMindFlowParse({
  required String text,
  required PrivacySettings privacySettings,
}) {
  final items = text
      .split(RegExp(r'\s*,\s*'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .take(4)
      .toList(growable: false);
  final nowIso = DateTime.now().toUtc().toIso8601String();
  return MindFlowParseResponseDto(
    items: items.asMap().entries.map((entry) {
      final classification = _classifyCaptureLocally(
        privacySettings: privacySettings,
        text: entry.value,
        trace: const {'mock': true},
      );
      return MentalLoadItemDto(
        itemId:
            'mindflow-${entry.key}-${DateTime.now().microsecondsSinceEpoch}',
        userId: 'local-user',
        sourceEventId: null,
        type: _mentalLoadTypeForDomain(classification.domain),
        domain: classification.domain,
        title: entry.value,
        summary: classification.rationale,
        urgencyScore: classification.domain == 'task' ? 0.76 : 0.62,
        effortScore: classification.domain == 'pantry' ? 0.82 : 0.68,
        confidence: classification.confidence,
        state: 'needs_confirmation',
        dueHint: null,
        amountHint: null,
        currencyHint: null,
        evidenceRefs: <String>[classification.eventType],
        privacyLevel: privacySettings
            .permissionForWireDomain(classification.domain)
            .storageKey,
        requiresConfirmation: true,
        createdAtIso: nowIso,
        updatedAtIso: nowIso,
        trace: {
          ...classification.trace,
          'event_type': classification.eventType,
        },
      );
    }).toList(growable: false),
    trace: const {
      'mock': true,
      'clientFallback': true,
      'parser': 'deterministic_mindflow',
    },
  );
}

DecisionPlanDto _localDecisionPlan({
  required PrivacySettings privacySettings,
  required List<Map<String, Object?>> mentalLoadItems,
}) {
  final allowedDomains = privacySettings.aiAllowedWireDomains;
  final blockedDomains = <String>[
    'task',
    'habit',
    'week',
    'finance',
    'pantry',
    'wardrobe',
    'mission',
  ].where((domain) => !allowedDomains.contains(domain)).toList(growable: false);
  final nowIso = DateTime.now().toUtc().toIso8601String();
  final normalizedItems = mentalLoadItems
      .map(
          (item) => MentalLoadItemDto.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
  final selected = normalizedItems.take(3).toList(growable: false);
  return DecisionPlanDto(
    decisions: selected.asMap().entries.map((entry) {
      final item = entry.value;
      final evidence = <String>[
        if (item.summary.isNotEmpty) item.summary,
        if (item.dueHint != null) 'Due hint: ${item.dueHint}',
      ];
      return DecisionCardDto(
        decisionId: 'decision-${entry.key}-${item.itemId}',
        userId: item.userId,
        title: item.title,
        recommendedAction: _localActionForMentalLoad(item),
        alternatives: const <String>[
          'Postpone and create a reminder',
          'Keep local only for now',
        ],
        domainTargets: <String>[item.domain],
        sourceItems: <String>[item.itemId],
        evidence: evidence,
        confidence: item.confidence,
        uncertainty:
            'Local fallback generated this decision from on-device context only.',
        privacySummary: PrivacySummaryDto(
          aiEnabled: privacySettings.aiEnabled,
          sentEventCount: allowedDomains.length,
          blockedEventCount: blockedDomains.length,
          allowedDomains: allowedDomains,
          blockedDomains: blockedDomains,
          localOnlyCollections: const <String>[
            'Journal entries',
            'Quick notes',
            'Owned items',
            'Purchase proofs',
          ],
          trace: const {'clientFallback': true},
        ),
        confirmationRequired: true,
        actionContract: ActionContractDto(
          actionType: 'review_and_confirm',
          requiresConfirmation: true,
          destructive: false,
          external: false,
          payloadPreview: {
            'item_id': item.itemId,
            'domain': item.domain,
          },
          forbiddenActions: const <String>[
            'external_action_without_confirmation',
          ],
        ),
        status: 'shown',
        evidenceStatus:
            evidence.isEmpty ? 'insufficient_verified_data' : 'local_only',
        rankingScore: item.urgencyScore,
        createdAtIso: nowIso,
        updatedAtIso: nowIso,
        trace: {
          ...item.trace,
          'mock': true,
          'clientFallback': true,
        },
      );
    }).toList(growable: false),
    trace: {
      'mock': true,
      'clientFallback': true,
      'decision_count': selected.length,
    },
  );
}

ShoppingPlanDto _localShoppingPlan({
  required PrivacySettings privacySettings,
  required List<Map<String, Object?>> shoppingNeeds,
  required List<Map<String, Object?>> pantryContext,
  required List<Map<String, Object?>> financeContext,
  required List<Map<String, Object?>> wardrobeContext,
  required List<Map<String, Object?>> homememoryContext,
}) {
  final normalizedNeeds = shoppingNeeds
      .map((item) => ShoppingNeedDto.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
  final needs = normalizedNeeds.isEmpty
      ? <ShoppingNeedDto>[
          ShoppingNeedDto(
            needId: 'shopping-fallback',
            userId: 'local-user',
            needType: 'pantry_restock',
            title: 'Review what you already have before adding new purchases.',
            sourceDomain: 'shopping',
            sourceEventIds: const <String>[],
            urgencyScore: 0.55,
            budgetHint: null,
            currency: null,
            sustainabilityPreference: null,
            state: 'draft',
            createdAtIso: DateTime.now().toUtc().toIso8601String(),
            updatedAtIso: DateTime.now().toUtc().toIso8601String(),
            trace: const {'clientFallback': true},
          ),
        ]
      : normalizedNeeds;
  final evidence = needs.map((need) {
    return ProductEvidenceCardDto(
      id: 'evidence-${need.needId}',
      userId: need.userId,
      productName: need.title,
      brand: null,
      merchantName: null,
      price: null,
      currency: need.currency,
      source: null,
      checkedAtIso: null,
      reviewSummary: 'Local-first recommendation. External claims are blocked.',
      sustainabilityStatus: 'insufficient_verified_data',
      confidence: 0.4,
      disclaimer:
          'No price, availability, or sustainability claim is shown without verified evidence.',
      trace: const {
        'clientFallback': true,
        'evidence_status': 'insufficient_verified_data',
      },
    );
  }).toList(growable: false);
  final decisions = needs.take(3).map((need) {
    return DecisionCardDto(
      decisionId: 'shopping-decision-${need.needId}',
      userId: need.userId,
      title: 'Use existing context before buying: ${need.title}',
      recommendedAction:
          'Check pantry, budget, and owned items before confirming this need.',
      alternatives: const <String>[
        'Postpone the purchase',
        'Create reminder instead',
      ],
      domainTargets: <String>[need.sourceDomain, 'shopping'],
      sourceItems: <String>[need.needId],
      evidence: const <String>[
        'Existing-item-first fallback applied locally.',
      ],
      confidence: 0.58,
      uncertainty:
          'External source claims are blocked in fallback mode and sustainability is not verified.',
      privacySummary: PrivacySummaryDto(
        aiEnabled: privacySettings.aiEnabled,
        sentEventCount: 0,
        blockedEventCount: 0,
        allowedDomains: privacySettings.aiAllowedWireDomains,
        blockedDomains: const <String>[],
        localOnlyCollections: const <String>[
          'Pantry',
          'Finance',
          'HomeMemory',
        ],
        trace: {
          'pantry_context_count': pantryContext.length,
          'finance_context_count': financeContext.length,
          'wardrobe_context_count': wardrobeContext.length,
          'homememory_context_count': homememoryContext.length,
        },
      ),
      confirmationRequired: true,
      actionContract: ActionContractDto(
        actionType: 'confirm_shopping_need',
        requiresConfirmation: true,
        destructive: false,
        external: false,
        payloadPreview: {'need_id': need.needId},
        forbiddenActions: const <String>[
          'external_action_without_confirmation',
        ],
      ),
      status: 'shown',
      evidenceStatus: 'insufficient_verified_data',
      rankingScore: need.urgencyScore,
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      trace: const {'clientFallback': true},
    );
  }).toList(growable: false);
  return ShoppingPlanDto(
    needs: needs,
    productEvidence: evidence,
    decisions: decisions,
    trace: const {
      'mock': true,
      'clientFallback': true,
      'shopping_need_count': 1,
    },
  );
}

String _mentalLoadTypeForDomain(String domain) {
  switch (domain) {
    case 'finance':
      return 'money';
    case 'pantry':
    case 'wardrobe':
      return 'shopping';
    case 'week':
      return 'calendar';
    case 'habit':
      return 'reminder';
    case 'task':
      return 'task';
    default:
      return 'note';
  }
}

String _localActionForMentalLoad(MentalLoadItemDto item) {
  switch (item.domain) {
    case 'task':
      return 'Finish the smallest visible next step for this task.';
    case 'pantry':
      return 'Use what you already have before adding a purchase.';
    case 'finance':
      return 'Review whether this spend is still necessary today.';
    case 'wardrobe':
      return 'Compare this purchase against existing items first.';
    case 'week':
      return 'Block a time slot or postpone this intentionally.';
    default:
      return 'Review and confirm the next safe action.';
  }
}
