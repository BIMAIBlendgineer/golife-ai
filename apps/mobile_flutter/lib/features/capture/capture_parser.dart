import '../../core/ai_client/dto/ai_gateway_dto.dart';
import '../../core/privacy/privacy_models.dart';

class CaptureDraftItem {
  const CaptureDraftItem({
    required this.id,
    required this.text,
    required this.domain,
    required this.eventType,
    required this.privacyLevel,
    required this.rationale,
    this.confidence = 0.5,
    this.hints = const <String, Object?>{},
  });

  final String id;
  final String text;
  final DomainKey domain;
  final String eventType;
  final String privacyLevel;
  final String rationale;
  final double confidence;
  final Map<String, Object?> hints;

  CaptureDraftItem copyWith({
    String? id,
    String? text,
    DomainKey? domain,
    String? eventType,
    String? privacyLevel,
    String? rationale,
    double? confidence,
    Map<String, Object?>? hints,
  }) {
    return CaptureDraftItem(
      id: id ?? this.id,
      text: text ?? this.text,
      domain: domain ?? this.domain,
      eventType: eventType ?? this.eventType,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      rationale: rationale ?? this.rationale,
      confidence: confidence ?? this.confidence,
      hints: hints ?? this.hints,
    );
  }
}

class CaptureParser {
  const CaptureParser();

  List<CaptureDraftItem> parse({
    required String text,
    required PrivacySettings privacySettings,
    DomainKey? forcedDomain,
    CaptureClassificationDto? gatewayClassification,
    List<CaptureParseItemDto>? gatewayItems,
  }) {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return const <CaptureDraftItem>[];
    }

    if (gatewayItems != null && gatewayItems.isNotEmpty) {
      return List<CaptureDraftItem>.generate(gatewayItems.length, (index) {
        final item = gatewayItems[index];
        final domain = domainKeyFromWireName(item.domain) ?? DomainKey.tasks;
        return CaptureDraftItem(
          id: 'draft-$index-${DateTime.now().microsecondsSinceEpoch}',
          text: item.text,
          domain: domain,
          eventType: item.eventType,
          privacyLevel: privacySettings.permissionFor(domain).storageKey,
          rationale: item.rationale,
          confidence: item.confidence,
          hints: item.hints,
        );
      });
    }

    final clauses = _splitIntoClauses(normalizedText);
    if (clauses.isEmpty) {
      return const <CaptureDraftItem>[];
    }

    return List<CaptureDraftItem>.generate(clauses.length, (index) {
      final clause = clauses[index];
      final parsed = _classifyClause(
        clause,
        forcedDomain: forcedDomain,
        gatewayClassification:
            clauses.length == 1 ? gatewayClassification : null,
      );
      return CaptureDraftItem(
        id: 'draft-$index-${DateTime.now().microsecondsSinceEpoch}',
        text: clause,
        domain: parsed.domain,
        eventType: parsed.eventType,
        privacyLevel: privacySettings.permissionFor(parsed.domain).storageKey,
        rationale: parsed.rationale,
        confidence: parsed.confidence,
        hints: parsed.hints,
      );
    });
  }

  List<String> _splitIntoClauses(String text) {
    final compact = text
        .replaceAll('\n', ', ')
        .replaceAll(';', ', ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final roughParts = compact
        .split(RegExp(r'\s*,\s*'))
        .expand(_splitOnConnector)
        .map(_cleanClause)
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (roughParts.isEmpty) {
      return <String>[compact];
    }
    return roughParts;
  }

  List<String> _splitOnConnector(String text) {
    final lowered = text.toLowerCase();
    final signalCount = _countSignals(
          lowered,
          <String>['compr', 'gaste', 'pague', 'paid', 'pay ', 'coffee'],
        ) +
        _countSignals(
            lowered, <String>['vence', 'caduc', 'fridge', 'expires']) +
        _countSignals(
          lowered,
          <String>['debo', 'tengo que', 'submit', 'need to'],
        ) +
        _countSignals(lowered, <String>['comprar', 'jacket', 'ropa']);

    if (signalCount < 2 ||
        (!lowered.contains(' y ') && !lowered.contains(' and '))) {
      return <String>[text];
    }
    return text.split(RegExp(r'\s+(y|and)\s+', caseSensitive: false));
  }

  int _countSignals(String lowered, List<String> signals) {
    return signals.where(lowered.contains).length;
  }

  String _cleanClause(String input) {
    return input
        .trim()
        .replaceFirst(RegExp(r'^(y|and)\s+', caseSensitive: false), '')
        .trim();
  }

  _ParsedClause _classifyClause(
    String clause, {
    DomainKey? forcedDomain,
    CaptureClassificationDto? gatewayClassification,
  }) {
    if (forcedDomain != null) {
      return _buildParsedClause(
        clause,
        forcedDomain,
        confidence: 0.95,
        rationale: 'Manual route selected before saving.',
      );
    }

    if (gatewayClassification != null) {
      final gatewayDomain = domainKeyFromWireName(gatewayClassification.domain);
      if (gatewayDomain != null) {
        return _buildParsedClause(
          clause,
          gatewayDomain,
          eventTypeOverride: gatewayClassification.eventType,
          confidence: gatewayClassification.confidence,
          rationale: gatewayClassification.rationale,
        );
      }
    }

    final lowered = clause.toLowerCase();
    if (_looksLikeFinance(lowered)) {
      return _buildParsedClause(
        clause,
        DomainKey.finance,
        confidence: 0.88,
        rationale: 'Detected spend, amount, or finance wording.',
      );
    }
    if (_looksLikePantry(lowered)) {
      return _buildParsedClause(
        clause,
        DomainKey.pantry,
        confidence: 0.86,
        rationale: 'Detected food, expiry, or pantry rescue wording.',
      );
    }
    if (_looksLikeWardrobe(lowered)) {
      return _buildParsedClause(
        clause,
        DomainKey.wardrobe,
        confidence: 0.82,
        rationale: 'Detected purchase intention or clothing wording.',
      );
    }
    if (_looksLikeHabit(lowered)) {
      return _buildParsedClause(
        clause,
        DomainKey.habits,
        confidence: 0.8,
        rationale: 'Detected repeated behavior or self-care wording.',
      );
    }
    if (_looksLikeWeek(lowered)) {
      return _buildParsedClause(
        clause,
        DomainKey.week,
        confidence: 0.76,
        rationale: 'Detected weekly planning or schedule wording.',
      );
    }

    return _buildParsedClause(
      clause,
      DomainKey.tasks,
      confidence: 0.72,
      rationale: 'Defaulted to task because the clause looks actionable.',
    );
  }

  _ParsedClause _buildParsedClause(
    String clause,
    DomainKey domain, {
    String? eventTypeOverride,
    required double confidence,
    required String rationale,
  }) {
    return _ParsedClause(
      domain: domain,
      eventType: eventTypeOverride ?? _defaultEventType(domain),
      confidence: confidence,
      rationale: rationale,
      hints: _extractHints(clause, domain),
    );
  }

  Map<String, Object?> _extractHints(String clause, DomainKey domain) {
    final hints = <String, Object?>{};
    final lowered = clause.toLowerCase();
    final amountMatch = RegExp(r'(\d+[.,]?\d{0,2})').firstMatch(clause);
    if (amountMatch != null) {
      hints['amount'] = double.tryParse(
        amountMatch.group(1)!.replaceAll(',', '.'),
      );
    }

    if (RegExp(r'eur|euro').hasMatch(lowered)) {
      hints['currency'] = 'EUR';
    } else if (RegExp(r'\$|usd|dollar').hasMatch(lowered)) {
      hints['currency'] = 'USD';
    }

    final timeHintMatch =
        RegExp(r'\b(today|tomorrow|tonight|manana|hoy)\b').firstMatch(lowered);
    if (timeHintMatch != null) {
      hints['time_hint'] = timeHintMatch.group(1);
    }

    if (domain == DomainKey.tasks &&
        (lowered.contains('debo') ||
            lowered.contains('tengo que') ||
            lowered.contains('need to'))) {
      hints['task_intent'] = 'required';
    }
    if (domain == DomainKey.habits) {
      hints['habit_intent'] = 'check_in';
    }
    if (domain == DomainKey.week) {
      hints['planning_intent'] = 'weekly_focus';
    }
    if (domain == DomainKey.finance) {
      hints['finance_intent'] = 'expense';
    }
    if (domain == DomainKey.pantry &&
        (lowered.contains('vence') ||
            lowered.contains('caduca') ||
            lowered.contains('expires'))) {
      hints['expiry_hint'] = hints['time_hint'] ?? 'soon';
    }
    if (domain == DomainKey.wardrobe) {
      hints['purchase_pause_hours'] = 24;
    }

    return hints;
  }

  bool _looksLikeFinance(String lowered) {
    return lowered.contains('compr') ||
        lowered.contains('gaste') ||
        lowered.contains('pague') ||
        lowered.contains('coffee') ||
        lowered.contains('cafe') ||
        lowered.contains('sandwich') ||
        RegExp(r'(\d+[.,]?\d{0,2})').hasMatch(lowered);
  }

  bool _looksLikePantry(String lowered) {
    return lowered.contains('vence') ||
        lowered.contains('caduca') ||
        lowered.contains('expires') ||
        lowered.contains('fridge') ||
        lowered.contains('lechuga') ||
        lowered.contains('spinach') ||
        lowered.contains('pantry') ||
        lowered.contains('food');
  }

  bool _looksLikeWardrobe(String lowered) {
    return lowered.contains('jacket') ||
        lowered.contains('shoes') ||
        lowered.contains('ropa') ||
        lowered.contains('closet') ||
        lowered.contains('buy another') ||
        lowered.contains('comprar') ||
        lowered.contains('chaqueta');
  }

  bool _looksLikeHabit(String lowered) {
    return lowered.contains('walk') ||
        lowered.contains('sleep') ||
        lowered.contains('meditat') ||
        lowered.contains('reset') ||
        lowered.contains('habit') ||
        lowered.contains('agua') ||
        lowered.contains('exercise');
  }

  bool _looksLikeWeek(String lowered) {
    return lowered.contains('week') ||
        lowered.contains('monday') ||
        lowered.contains('friday') ||
        lowered.contains('calendar') ||
        lowered.contains('schedule') ||
        lowered.contains('plan');
  }

  String _defaultEventType(DomainKey domain) {
    switch (domain) {
      case DomainKey.tasks:
        return 'task_captured';
      case DomainKey.habits:
        return 'habit_logged';
      case DomainKey.week:
        return 'week_note_captured';
      case DomainKey.finance:
        return 'expense_logged';
      case DomainKey.pantry:
        return 'ingredient_flagged';
      case DomainKey.wardrobe:
        return 'purchase_intention';
      case DomainKey.copilot:
        return 'note_captured';
    }
  }
}

class _ParsedClause {
  const _ParsedClause({
    required this.domain,
    required this.eventType,
    required this.confidence,
    required this.rationale,
    required this.hints,
  });

  final DomainKey domain;
  final String eventType;
  final double confidence;
  final String rationale;
  final Map<String, Object?> hints;
}
