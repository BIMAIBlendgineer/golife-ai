class MissionRankingDto {
  const MissionRankingDto({
    required this.impactScore,
    required this.urgencyScore,
    required this.effortScore,
    required this.confidenceScore,
    required this.privacyScore,
    required this.feedbackScore,
    required this.noveltyScore,
    required this.finalScore,
    required this.rankingReason,
    required this.evidenceRefs,
  });

  final double impactScore;
  final double urgencyScore;
  final double effortScore;
  final double confidenceScore;
  final double privacyScore;
  final double feedbackScore;
  final double noveltyScore;
  final double finalScore;
  final String rankingReason;
  final List<String> evidenceRefs;

  factory MissionRankingDto.fromJson(Map<String, dynamic> json) {
    return MissionRankingDto(
      impactScore: _asDouble(json['impact_score']) ?? 0,
      urgencyScore: _asDouble(json['urgency_score']) ?? 0,
      effortScore: _asDouble(json['effort_score']) ?? 0,
      confidenceScore: _asDouble(json['confidence_score']) ?? 0,
      privacyScore: _asDouble(json['privacy_score']) ?? 0,
      feedbackScore: _asDouble(json['feedback_score']) ?? 0,
      noveltyScore: _asDouble(json['novelty_score']) ?? 0,
      finalScore: _asDouble(json['final_score']) ?? 0,
      rankingReason: (json['ranking_reason'] ?? '').toString(),
      evidenceRefs: ((json['evidence_refs'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}

class MissionSuggestionDto {
  const MissionSuggestionDto({
    required this.id,
    required this.title,
    required this.body,
    required this.evidence,
    required this.uncertainty,
    required this.requiresConfirmation,
    required this.domainTargets,
    required this.recommendationType,
    required this.confidence,
    required this.ranking,
    required this.trace,
  });

  final String id;
  final String title;
  final String body;
  final List<String> evidence;
  final String uncertainty;
  final bool requiresConfirmation;
  final List<String> domainTargets;
  final String recommendationType;
  final double confidence;
  final MissionRankingDto? ranking;
  final Map<String, Object?> trace;

  MissionSuggestionDto copyWith({
    String? id,
    String? title,
    String? body,
    List<String>? evidence,
    String? uncertainty,
    bool? requiresConfirmation,
    List<String>? domainTargets,
    String? recommendationType,
    double? confidence,
    MissionRankingDto? ranking,
    Map<String, Object?>? trace,
  }) {
    return MissionSuggestionDto(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      evidence: evidence ?? this.evidence,
      uncertainty: uncertainty ?? this.uncertainty,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      domainTargets: domainTargets ?? this.domainTargets,
      recommendationType: recommendationType ?? this.recommendationType,
      confidence: confidence ?? this.confidence,
      ranking: ranking ?? this.ranking,
      trace: trace ?? this.trace,
    );
  }

  factory MissionSuggestionDto.fromJson(
    Map<String, dynamic> suggestionJson, {
    Map<String, Object?> trace = const <String, Object?>{},
  }) {
    final rawEvidence =
        suggestionJson['evidence'] as List<dynamic>? ?? const [];
    final evidence = rawEvidence.map((item) {
      if (item is Map && item['claim'] != null) {
        return item['claim'].toString();
      }
      return item.toString();
    }).toList(growable: false);

    final rawDomainTargets =
        suggestionJson['domain_targets'] as List<dynamic>? ?? const [];
    final rankingJson = suggestionJson['ranking'];

    return MissionSuggestionDto(
      id: (suggestionJson['suggestion_id'] ?? 'mission-unknown').toString(),
      title: (suggestionJson['title'] ?? 'Mission unavailable').toString(),
      body: (suggestionJson['body'] ??
              'The gateway did not return a mission body.')
          .toString(),
      evidence: evidence,
      uncertainty: (suggestionJson['uncertainty'] ?? 'No uncertainty provided.')
          .toString(),
      requiresConfirmation:
          (suggestionJson['requires_confirmation'] as bool?) ?? true,
      domainTargets: rawDomainTargets
          .map((item) => item.toString())
          .toList(growable: false),
      recommendationType:
          (suggestionJson['recommendation_type'] ?? 'mission').toString(),
      confidence: _asDouble(suggestionJson['confidence']) ?? 0.5,
      ranking: rankingJson is Map<String, dynamic>
          ? MissionRankingDto.fromJson(rankingJson)
          : rankingJson is Map
              ? MissionRankingDto.fromJson(
                  Map<String, dynamic>.from(rankingJson),
                )
              : null,
      trace: trace,
    );
  }
}

class MissionPlanDto {
  const MissionPlanDto({
    required this.suggestions,
    required this.trace,
  });

  final List<MissionSuggestionDto> suggestions;
  final Map<String, Object?> trace;

  MissionSuggestionDto get primarySuggestion {
    if (suggestions.isEmpty) {
      throw const FormatException('Gateway returned no suggestions.');
    }
    return suggestions.first;
  }

  MissionPlanDto mergeTrace(Map<String, Object?> extraTrace) {
    final mergedTrace = <String, Object?>{
      ...trace,
      ...extraTrace,
    };

    return MissionPlanDto(
      suggestions: suggestions
          .map(
            (suggestion) => suggestion.copyWith(
              trace: <String, Object?>{
                ...suggestion.trace,
                ...extraTrace,
              },
            ),
          )
          .toList(growable: false),
      trace: mergedTrace,
    );
  }

  factory MissionPlanDto.fromGatewayJson(Map<String, dynamic> responseJson) {
    final rawSuggestions =
        responseJson['suggestions'] as List<dynamic>? ?? const [];
    final trace = _normalizeTrace(
      Map<String, dynamic>.from(
        (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );

    final suggestions = <MissionSuggestionDto>[];
    for (final item in rawSuggestions) {
      if (item is! Map) {
        continue;
      }
      suggestions.add(
        MissionSuggestionDto.fromJson(
          Map<String, dynamic>.from(item),
          trace: trace,
        ),
      );
    }

    if (suggestions.isEmpty) {
      throw const FormatException('Gateway returned no suggestions.');
    }

    return MissionPlanDto(
      suggestions: suggestions,
      trace: trace,
    );
  }
}

class CaptureClassificationDto {
  const CaptureClassificationDto({
    required this.domain,
    required this.eventType,
    required this.confidence,
    required this.rationale,
    required this.trace,
  });

  final String domain;
  final String eventType;
  final double confidence;
  final String rationale;
  final Map<String, Object?> trace;

  CaptureClassificationDto copyWith({
    String? domain,
    String? eventType,
    double? confidence,
    String? rationale,
    Map<String, Object?>? trace,
  }) {
    return CaptureClassificationDto(
      domain: domain ?? this.domain,
      eventType: eventType ?? this.eventType,
      confidence: confidence ?? this.confidence,
      rationale: rationale ?? this.rationale,
      trace: trace ?? this.trace,
    );
  }

  factory CaptureClassificationDto.fromGatewayJson(
    Map<String, dynamic> responseJson,
  ) {
    return CaptureClassificationDto(
      domain: (responseJson['domain'] ?? 'task').toString(),
      eventType: (responseJson['event_type'] ?? 'task_captured').toString(),
      confidence: _asDouble(responseJson['confidence']) ?? 0.5,
      rationale: (responseJson['rationale'] ?? 'No rationale was returned.')
          .toString(),
      trace: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['trace'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class CaptureParseItemDto {
  const CaptureParseItemDto({
    required this.text,
    required this.domain,
    required this.eventType,
    required this.confidence,
    required this.rationale,
    required this.hints,
  });

  final String text;
  final String domain;
  final String eventType;
  final double confidence;
  final String rationale;
  final Map<String, Object?> hints;

  factory CaptureParseItemDto.fromGatewayJson(
      Map<String, dynamic> responseJson) {
    return CaptureParseItemDto(
      text: (responseJson['text'] ?? '').toString(),
      domain: (responseJson['domain'] ?? 'task').toString(),
      eventType: (responseJson['event_type'] ?? 'task_captured').toString(),
      confidence: _asDouble(responseJson['confidence']) ?? 0.5,
      rationale: (responseJson['rationale'] ?? 'No rationale was returned.')
          .toString(),
      hints: _normalizeTrace(
        Map<String, dynamic>.from(
          (responseJson['hints'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      ),
    );
  }
}

class CaptureParseResponseDto {
  const CaptureParseResponseDto({
    required this.items,
    required this.trace,
  });

  final List<CaptureParseItemDto> items;
  final Map<String, Object?> trace;

  factory CaptureParseResponseDto.fromGatewayJson(
    Map<String, dynamic> responseJson,
  ) {
    final rawItems = responseJson['items'] as List<dynamic>? ?? const [];
    return CaptureParseResponseDto(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => CaptureParseItemDto.fromGatewayJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.text.isNotEmpty)
          .toList(growable: false),
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

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}
