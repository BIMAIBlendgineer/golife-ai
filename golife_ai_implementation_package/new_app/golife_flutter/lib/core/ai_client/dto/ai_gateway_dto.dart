class MissionSuggestionDto {
  const MissionSuggestionDto({
    required this.id,
    required this.title,
    required this.body,
    required this.evidence,
    required this.uncertainty,
    required this.requiresConfirmation,
    required this.trace,
  });

  final String id;
  final String title;
  final String body;
  final List<String> evidence;
  final String uncertainty;
  final bool requiresConfirmation;
  final Map<String, Object?> trace;

  MissionSuggestionDto copyWith({
    String? id,
    String? title,
    String? body,
    List<String>? evidence,
    String? uncertainty,
    bool? requiresConfirmation,
    Map<String, Object?>? trace,
  }) {
    return MissionSuggestionDto(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      evidence: evidence ?? this.evidence,
      uncertainty: uncertainty ?? this.uncertainty,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      trace: trace ?? this.trace,
    );
  }

  factory MissionSuggestionDto.fromGatewayJson(
    Map<String, dynamic> responseJson,
  ) {
    final rawSuggestions = responseJson['suggestions'] as List<dynamic>? ?? const [];
    if (rawSuggestions.isEmpty || rawSuggestions.first is! Map) {
      throw const FormatException('Gateway returned no suggestions.');
    }

    final suggestion = Map<String, dynamic>.from(rawSuggestions.first as Map);
    final rawEvidence = suggestion['evidence'] as List<dynamic>? ?? const [];
    final evidence = rawEvidence.map((item) {
      if (item is Map && item['claim'] != null) {
        return item['claim'].toString();
      }
      return item.toString();
    }).toList(growable: false);

    return MissionSuggestionDto(
      id: (suggestion['suggestion_id'] ?? 'mission-unknown').toString(),
      title: (suggestion['title'] ?? 'Mission unavailable').toString(),
      body: (suggestion['body'] ?? 'The gateway did not return a mission body.')
          .toString(),
      evidence: evidence,
      uncertainty: (suggestion['uncertainty'] ?? 'No uncertainty provided.')
          .toString(),
      requiresConfirmation:
          (suggestion['requires_confirmation'] as bool?) ?? true,
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
