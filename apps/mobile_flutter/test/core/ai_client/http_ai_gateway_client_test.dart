import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/lifegraph/life_event.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/domains/missions/mission_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('HttpAiGatewayClient', () {
    test('sends only ai_allowed events without overriding event privacy', () async {
      late Map<String, dynamic> requestBody;

      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient((request) async {
          requestBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'suggestions': [
                {
                  'suggestion_id': 'mission-1',
                  'title': 'Focus first',
                  'body': 'Do the short task first.',
                  'evidence': [
                    {'claim': 'Recent task signal'}
                  ],
                  'uncertainty': 'Limited sample size.',
                  'requires_confirmation': true,
                }
              ],
              'trace': {'provider': 'mock'}
            }),
            200,
          );
        }),
      );

      final privacySettings = PrivacySettings(
        permissions: {
          DomainKey.tasks: DataPermission.aiAllowed,
          DomainKey.habits: DataPermission.localOnly,
          DomainKey.week: DataPermission.localOnly,
          DomainKey.finance: DataPermission.localOnly,
          DomainKey.pantry: DataPermission.localOnly,
          DomainKey.wardrobe: DataPermission.localOnly,
          DomainKey.copilot: DataPermission.aiAllowed,
        },
      );

      final result = await client.fetchDailyMission(
        privacySettings: privacySettings,
        lifeEvents: const [
          LifeEvent(
            eventId: 'evt-1',
            userId: 'user-1',
            domain: 'task',
            eventType: 'task_captured',
            timestampIso: '2026-04-24T10:00:00Z',
            payload: {'summary': 'Submit invoice'},
            source: 'manual',
            privacyLevel: 'ai_allowed',
          ),
          LifeEvent(
            eventId: 'evt-2',
            userId: 'user-1',
            domain: 'task',
            eventType: 'task_captured',
            timestampIso: '2026-04-24T10:05:00Z',
            payload: {'summary': 'Private note'},
            source: 'manual',
            privacyLevel: 'local_only',
          ),
        ],
      );

      final sentEvents = requestBody['life_events'] as List<dynamic>;
      expect(sentEvents, hasLength(1));
      expect((sentEvents.first as Map<String, dynamic>)['privacy_level'], 'ai_allowed');
      expect(result.trace['remote'], true);
    });

    test('falls back when gateway returns 500', () async {
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient((request) async => http.Response('boom', 500)),
      );

      final result = await client.fetchDailyMission(
        privacySettings: PrivacySettings.defaults(),
        lifeEvents: const [],
      );

      expect(result.trace['clientFallback'], true);
      expect(result.trace['fallbackReason'], 'http_500');
    });

    test('falls back on timeout', () async {
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        timeout: const Duration(milliseconds: 10),
        httpClient: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{}', 200);
        }),
      );

      final result = await client.fetchDailyMission(
        privacySettings: PrivacySettings.defaults(),
        lifeEvents: const [],
      );

      expect(result.trace['clientFallback'], true);
      expect(result.trace['fallbackReason'], 'timeout');
    });

    test('falls back on invalid JSON', () async {
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient((request) async => http.Response('{', 200)),
      );

      final result = await client.fetchDailyMission(
        privacySettings: PrivacySettings.defaults(),
        lifeEvents: const [],
      );

      expect(result.trace['clientFallback'], true);
      expect(result.trace['fallbackReason'], 'invalid_json');
    });

    test('falls back when response contains no suggestions', () async {
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({'suggestions': [], 'trace': {}}),
            200,
          ),
        ),
      );

      final result = await client.fetchDailyMission(
        privacySettings: PrivacySettings.defaults(),
        lifeEvents: const [],
      );

      expect(result.trace['clientFallback'], true);
    });

    test('throws when feedback endpoint fails', () async {
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient((request) async => http.Response('fail', 500)),
      );

      await expectLater(
        client.submitMissionFeedback(
          feedback: const MissionFeedback(
            id: 'feedback-1',
            missionId: 'mission-1',
            status: MissionFeedbackStatus.useful,
            createdAtIso: '2026-04-24T10:00:00Z',
          ),
        ),
        throwsException,
      );
    });
  });
}
