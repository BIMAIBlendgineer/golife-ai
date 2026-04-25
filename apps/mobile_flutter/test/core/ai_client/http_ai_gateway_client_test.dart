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
    test('sends only ai_allowed events without overriding event privacy',
        () async {
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
      expect((sentEvents.first as Map<String, dynamic>)['privacy_level'],
          'ai_allowed');
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
      expect(result.trace['fallbackReason'], 'no_connection');
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

    test('keeps ai_temporarily_unavailable machine code from gateway',
        () async {
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'detail': {
                'code': 'ai_temporarily_unavailable',
                'message': 'busy',
              },
            }),
            503,
          ),
        ),
      );

      final result = await client.fetchDailyMission(
        privacySettings: PrivacySettings.defaults(),
        lifeEvents: const [],
      );

      expect(result.trace['clientFallback'], true);
      expect(result.trace['fallbackReason'], 'ai_temporarily_unavailable');
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

    test('parses capture items from gateway when available', () async {
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'items': [
                {
                  'text': 'Compre cafe 4.50',
                  'domain': 'finance',
                  'event_type': 'expense_logged',
                  'confidence': 0.91,
                  'rationale': 'Detected finance language.',
                  'hints': {'amount': 4.5}
                },
                {
                  'text': 'la lechuga vence manana',
                  'domain': 'pantry',
                  'event_type': 'ingredient_flagged',
                  'confidence': 0.84,
                  'rationale': 'Detected expiry wording.',
                  'hints': {'expiry_hint': 'manana'}
                },
              ],
              'trace': {'parser': 'semantic_openrouter'}
            }),
            200,
          ),
        ),
      );

      final response = await client.parseCapture(
        privacySettings: PrivacySettings.defaults(),
        text: 'Compre cafe 4.50, la lechuga vence manana',
      );

      expect(response, isNotNull);
      expect(response!.items, hasLength(2));
      expect(response.items.first.domain, 'finance');
      expect(response.trace['parser'], 'semantic_openrouter');
    });

    test('sends locale to parse and classify endpoints', () async {
      final seenBodies = <Map<String, dynamic>>[];
      final client = HttpAiGatewayClient(
        baseUri: Uri.parse('http://localhost:8000'),
        httpClient: MockClient((request) async {
          seenBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          if (request.url.path.endsWith('/classify')) {
            return http.Response(
              jsonEncode({
                'domain': 'task',
                'event_type': 'task_captured',
                'confidence': 0.9,
                'rationale': 'Locale-aware response.',
                'trace': {'classifier': 'semantic_openrouter'}
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'text': 'Comprei cafe 8.50',
                  'domain': 'finance',
                  'event_type': 'expense_logged',
                  'confidence': 0.91,
                  'rationale': 'Resposta em portugues.',
                  'hints': {'amount': 8.5}
                }
              ],
              'trace': {'parser': 'semantic_openrouter'}
            }),
            200,
          );
        }),
      );

      await client.classifyCapture(
        locale: 'pt-BR',
        privacySettings: PrivacySettings.defaults(),
        text: 'Preciso enviar o recibo.',
      );
      await client.parseCapture(
        locale: 'ja',
        privacySettings: PrivacySettings.defaults(),
        text: '冷蔵庫のほうれん草は明日まで',
      );

      expect(seenBodies[0]['locale'], 'pt-BR');
      expect(seenBodies[1]['locale'], 'ja');
    });
  });
}
