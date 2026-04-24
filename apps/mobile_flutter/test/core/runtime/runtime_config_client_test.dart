import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/runtime/runtime_config_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('RuntimeConfigClient', () {
    test('fetches runtime config from backend', () async {
      final client = RuntimeConfigClient(
        baseUri: Uri.parse('http://localhost:8010'),
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'schema_version': 1,
              'ttl_seconds': 21600,
              'gateway_base_url': 'http://localhost:8000',
              'feature_flags': {'multi_event_capture': true},
              'friendly_copy': {
                'offline': 'Offline copy',
              },
              'ai_status': {'active_key_count': 2},
              'generated_at': '2026-04-24T12:00:00Z',
            }),
            200,
          ),
        ),
      );

      final config = await client.fetchRuntimeConfig();

      expect(config, isNotNull);
      expect(config!.gatewayBaseUrl, 'http://localhost:8000');
      expect(config.featureFlags['multi_event_capture'], true);
      expect(config.messageFor('offline'), 'Offline copy');
    });

    test('returns null when backend is unavailable', () async {
      final client = RuntimeConfigClient(
        baseUri: Uri.parse('http://localhost:8010'),
        httpClient: MockClient((request) async => http.Response('down', 503)),
      );

      final config = await client.fetchRuntimeConfig();

      expect(config, isNull);
    });
  });
}
