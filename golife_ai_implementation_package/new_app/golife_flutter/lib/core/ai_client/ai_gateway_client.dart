import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domains/missions/mission_feedback.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import 'dto/ai_gateway_dto.dart';

abstract class AiGatewayClient {
  Future<MissionSuggestionDto> fetchDailyMission({
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  });

  Future<void> submitMissionFeedback({
    required MissionFeedback feedback,
  });
}

class MockAiGatewayClient implements AiGatewayClient {
  const MockAiGatewayClient();

  @override
  Future<MissionSuggestionDto> fetchDailyMission({
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    final allowedDomains = privacySettings.aiAllowedWireDomains.toSet();

    if (allowedDomains.isEmpty) {
      return MissionSuggestionDto(
        id: 'mission-paused',
        title: 'Copilot paused',
        body: 'Enable AI on at least one domain to generate a daily mission.',
        evidence: const ['No domain is currently marked as AI-allowed.'],
        uncertainty: 'No cross-domain inference was attempted.',
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': const <String>[],
        },
      );
    }

    if (allowedDomains.contains('task') && allowedDomains.contains('habit')) {
      return MissionSuggestionDto(
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
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': allowedDomains.toList()..sort(),
          'eventCount': lifeEvents.length,
        },
      );
    }

    if (allowedDomains.contains('finance') &&
        allowedDomains.contains('pantry')) {
      return MissionSuggestionDto(
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
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': allowedDomains.toList()..sort(),
          'eventCount': lifeEvents.length,
        },
      );
    }

    if (allowedDomains.contains('wardrobe')) {
      return MissionSuggestionDto(
        id: 'mission-wardrobe',
        title: 'Compare before buying',
        body:
            'Review one outfit you already own before acting on any clothing purchase intention today.',
        evidence: const [
          'Wardrobe is AI-allowed.',
          'The mission keeps the final decision with the user.',
        ],
        uncertainty: 'Mock mission; visual comparison still needs the person.',
        requiresConfirmation: true,
        trace: {
          'mock': true,
          'allowedDomains': allowedDomains.toList()..sort(),
          'eventCount': lifeEvents.length,
        },
      );
    }

    return MissionSuggestionDto(
      id: 'mission-generic',
      title: 'Pick one visible win',
      body:
          'Choose the smallest action that clearly reduces friction in one AI-allowed area and review it once it is done.',
      evidence: const [
        'At least one domain allows AI.',
      ],
      uncertainty: 'Mock mission with limited cross-domain context.',
      requiresConfirmation: true,
      trace: {
        'mock': true,
        'allowedDomains': allowedDomains.toList()..sort(),
        'eventCount': lifeEvents.length,
      },
    );
  }

  @override
  Future<void> submitMissionFeedback({
    required MissionFeedback feedback,
  }) async {}
}

class HttpAiGatewayClient implements AiGatewayClient {
  HttpAiGatewayClient({
    required this.baseUri,
    http.Client? httpClient,
    AiGatewayClient? fallbackClient,
    this.userId = 'local-user',
    this.timeout = const Duration(seconds: 4),
  })  : _httpClient = httpClient ?? http.Client(),
        _fallbackClient = fallbackClient ?? const MockAiGatewayClient();

  final Uri baseUri;
  final http.Client _httpClient;
  final AiGatewayClient _fallbackClient;
  final String userId;
  final Duration timeout;

  @override
  Future<MissionSuggestionDto> fetchDailyMission({
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    final allowedDomains = privacySettings.aiAllowedWireDomains;
    final requestPayload = {
      'user_id': userId,
      'scope': 'daily',
      'allowed_domains': allowedDomains,
      'life_events': lifeEvents
          .map(
            (event) => event.toGatewayJson(
              userIdOverride: userId,
              privacyLevelOverride:
                  privacySettings.permissionForWireDomain(event.domain).storageKey,
            ),
          )
          .toList(growable: false),
      'privacy_settings': {
        'ai_enabled': privacySettings.aiEnabled,
        'allowed_domains': allowedDomains,
        'allow_cross_domain_patterns': allowedDomains.length > 1,
      },
      'domain_summaries': _buildDomainSummaries(
        lifeEvents: lifeEvents,
        privacySettings: privacySettings,
      ),
      'constraints': {
        'client': 'golife_flutter',
        'trace_visible': true,
        'fallback_enabled': true,
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
        return _fallbackMission(
          privacySettings: privacySettings,
          lifeEvents: lifeEvents,
          reason: 'http_${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return _fallbackMission(
          privacySettings: privacySettings,
          lifeEvents: lifeEvents,
          reason: 'invalid_json_shape',
        );
      }

      final mission = MissionSuggestionDto.fromGatewayJson(decoded);
      return mission.copyWith(
        trace: {
          ...mission.trace,
          'remote': true,
          'baseUrl': baseUri.toString(),
          'endpoint': '/v1/missions/daily',
          'statusCode': response.statusCode,
        },
      );
    } on TimeoutException {
      return _fallbackMission(
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: 'timeout',
      );
    } on FormatException {
      return _fallbackMission(
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: 'invalid_json',
      );
    } catch (error) {
      return _fallbackMission(
        privacySettings: privacySettings,
        lifeEvents: lifeEvents,
        reason: error.runtimeType.toString(),
      );
    }
  }

  @override
  Future<void> submitMissionFeedback({
    required MissionFeedback feedback,
  }) async {
    final payload = {
      'user_id': userId,
      'suggestion_id': feedback.missionId,
      'status': feedback.status.storageKey,
      'notes': feedback.notes,
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

  Future<MissionSuggestionDto> _fallbackMission({
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
    required String reason,
    int? statusCode,
  }) async {
    final fallback = await _fallbackClient.fetchDailyMission(
      privacySettings: privacySettings,
      lifeEvents: lifeEvents,
    );
    return fallback.copyWith(
      trace: {
        ...fallback.trace,
        'clientFallback': true,
        'fallbackReason': reason,
        'statusCode': statusCode,
        'baseUrl': baseUri.toString(),
        'endpoint': '/v1/missions/daily',
      },
    );
  }

  Uri _endpoint(String path) {
    final normalizedBase = baseUri.toString().endsWith('/')
        ? baseUri.toString().substring(0, baseUri.toString().length - 1)
        : baseUri.toString();
    return Uri.parse('$normalizedBase$path');
  }
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
