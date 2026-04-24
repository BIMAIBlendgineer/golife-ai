class AppRuntimeConfig {
  const AppRuntimeConfig({
    required this.schemaVersion,
    required this.ttlSeconds,
    required this.gatewayBaseUrl,
    required this.featureFlags,
    required this.friendlyCopy,
    required this.aiStatus,
    required this.generatedAtIso,
  });

  final int schemaVersion;
  final int ttlSeconds;
  final String gatewayBaseUrl;
  final Map<String, bool> featureFlags;
  final Map<String, String> friendlyCopy;
  final Map<String, Object?> aiStatus;
  final String generatedAtIso;

  factory AppRuntimeConfig.defaults({
    String gatewayBaseUrl = 'http://127.0.0.1:8000',
  }) {
    return AppRuntimeConfig(
      schemaVersion: 1,
      ttlSeconds: 21600,
      gatewayBaseUrl: gatewayBaseUrl,
      featureFlags: const <String, bool>{},
      friendlyCopy: const <String, String>{
        'offline':
            'You can keep using GoLife locally. Reconnect when you want fresh AI help.',
        'gateway_degraded':
            'GoLife AI is under heavy load. Local guidance is still available.',
        'ai_temporarily_unavailable':
            'GoLife AI is temporarily unavailable. Your local plan and data are still safe.',
        'runtime_config_stale':
            'Using the last trusted server configuration until a fresh one is available.',
      },
      aiStatus: const <String, Object?>{},
      generatedAtIso: '',
    );
  }

  factory AppRuntimeConfig.fromJson(Map<String, dynamic> json) {
    final featureFlags = <String, bool>{};
    final rawFeatureFlags = json['feature_flags'];
    if (rawFeatureFlags is Map) {
      for (final entry in rawFeatureFlags.entries) {
        featureFlags[entry.key.toString()] = entry.value == true;
      }
    }

    final friendlyCopy = <String, String>{};
    final rawFriendlyCopy = json['friendly_copy'];
    if (rawFriendlyCopy is Map) {
      for (final entry in rawFriendlyCopy.entries) {
        friendlyCopy[entry.key.toString()] = entry.value.toString();
      }
    }

    final rawAiStatus = json['ai_status'];
    final aiStatus = rawAiStatus is Map
        ? rawAiStatus.map<String, Object?>(
            (key, value) => MapEntry(key.toString(), _normalizeJsonValue(value)),
          )
        : const <String, Object?>{};

    return AppRuntimeConfig(
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
      ttlSeconds: (json['ttl_seconds'] as num?)?.toInt() ?? 21600,
      gatewayBaseUrl:
          (json['gateway_base_url'] ?? 'http://127.0.0.1:8000').toString(),
      featureFlags: featureFlags,
      friendlyCopy: friendlyCopy,
      aiStatus: aiStatus,
      generatedAtIso: (json['generated_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schema_version': schemaVersion,
      'ttl_seconds': ttlSeconds,
      'gateway_base_url': gatewayBaseUrl,
      'feature_flags': featureFlags,
      'friendly_copy': friendlyCopy,
      'ai_status': aiStatus,
      'generated_at': generatedAtIso,
    };
  }

  String messageFor(String key) {
    return friendlyCopy[key] ?? AppRuntimeConfig.defaults().friendlyCopy[key]!;
  }
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
