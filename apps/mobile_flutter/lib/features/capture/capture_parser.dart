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
    if (_looksUnsafeForCapture(normalizedText)) {
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

  bool _looksUnsafeForCapture(String text) {
    const crisisTerms = <String>[
      'suicide',
      'suicidal',
      'kill myself',
      'end my life',
      'self harm',
      'harm myself',
      'quiero morir',
      'quitarme la vida',
      'hacerme dano',
      'lastimarme',
      'matarme',
      'nao quero viver',
      'quero morrer',
      'me machucar',
      '死にたい',
      '自殺',
      '消えたい',
      '自残',
      '不想活了',
      '想死',
    ];
    const clinicalTerms = <String>[
      'depressed',
      'depression',
      'anxiety disorder',
      'panic disorder',
      'diagnostico',
      'diagnosis',
      'diagnosticar',
      'terapia',
      'therapy',
      'tratamiento',
      'treatment',
      'medicacion',
      'saude mental',
      'depressao',
      'ansiedade',
      'うつ',
      '不安障害',
      '診断',
      '治療',
      '抑郁',
      '焦虑症',
    ];

    final normalized = _normalizeSafetyText(text);
    final tokens =
        normalized.split(' ').where((token) => token.isNotEmpty).toList();
    final joinedTokens = _joinedTokenWindows(tokens);
    return _matchesSafetyTerms(normalized, joinedTokens, crisisTerms) ||
        _matchesSafetyTerms(normalized, joinedTokens, clinicalTerms);
  }

  bool _matchesSafetyTerms(
    String normalizedText,
    Set<String> joinedTokens,
    List<String> terms,
  ) {
    for (final term in terms) {
      final normalizedTerm = _normalizeSafetyText(term);
      final compactTerm = normalizedTerm.replaceAll(' ', '');
      if (normalizedText.contains(normalizedTerm) ||
          joinedTokens.contains(compactTerm)) {
        return true;
      }
    }
    return false;
  }

  String _normalizeSafetyText(String value) {
    const replacements = <String, String>{
      '0': 'o',
      '1': 'i',
      '3': 'e',
      '4': 'a',
      '5': 's',
      '7': 't',
      '@': 'a',
      r'$': 's',
      '!': 'i',
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    final translated = value
        .split('')
        .map((character) => replacements[character] ?? character.toLowerCase())
        .join();
    final sanitized = StringBuffer();
    for (final rune in translated.runes) {
      final character = String.fromCharCode(rune);
      final isAsciiAlphaNum = RegExp(r'[a-z0-9]').hasMatch(character);
      final isCjkOrKana =
          rune >= 0x3040 && rune <= 0x30ff || rune >= 0x3400 && rune <= 0x9fff;
      sanitized.write(isAsciiAlphaNum || isCjkOrKana ? character : ' ');
    }

    final collapsed = <String>[];
    final tokens = sanitized.toString().split(RegExp(r'\s+'));
    var letterRun = '';
    for (final token in tokens) {
      if (token.isEmpty) {
        continue;
      }
      if (token.length == 1 && RegExp(r'[a-z]').hasMatch(token)) {
        letterRun += token;
        continue;
      }
      if (letterRun.isNotEmpty) {
        collapsed.add(letterRun);
        letterRun = '';
      }
      collapsed.add(token);
    }
    if (letterRun.isNotEmpty) {
      collapsed.add(letterRun);
    }
    return collapsed.join(' ');
  }

  Set<String> _joinedTokenWindows(List<String> tokens) {
    final windows = <String>{...tokens};
    final maxWindow = tokens.length < 4 ? tokens.length : 4;
    for (var size = 2; size <= maxWindow; size++) {
      for (var index = 0; index <= tokens.length - size; index++) {
        windows.add(tokens.sublist(index, index + size).join());
      }
    }
    return windows;
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
          <String>[
            'compr',
            'gaste',
            'pague',
            'paid',
            'pay ',
            'coffee',
            'comprei',
            'gastei',
            '買',
            '支払',
            '买',
            '支付',
          ],
        ) +
        _countSignals(lowered, <String>[
          'vence',
          'caduc',
          'fridge',
          'expires',
          'geladeira',
          'consum',
          '賞味',
          '消費',
          '冰箱',
          '过期',
        ]) +
        _countSignals(
          lowered,
          <String>[
            'debo',
            'tengo que',
            'submit',
            'need to',
            'preciso',
            'tenho que',
            'する必要',
            '需要',
          ],
        ) +
        _countSignals(
          lowered,
          <String>['comprar', 'jacket', 'ropa', 'jaqueta', '服', '衣服'],
        );

    if (signalCount < 2 ||
        (!lowered.contains(' y ') &&
            !lowered.contains(' and ') &&
            !lowered.contains(' e '))) {
      return <String>[text];
    }
    return text.split(RegExp(r'\s+(y|and|e)\s+', caseSensitive: false));
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
        RegExp(r'\b(today|tomorrow|tonight|manana|hoy|hoje|amanha)\b')
            .firstMatch(lowered);
    if (timeHintMatch != null) {
      hints['time_hint'] = timeHintMatch.group(1);
    }
    if (lowered.contains('明日') || lowered.contains('明天')) {
      hints['time_hint'] = 'tomorrow';
    } else if (lowered.contains('今日') || lowered.contains('今天')) {
      hints['time_hint'] = 'today';
    }

    if (domain == DomainKey.tasks &&
        (lowered.contains('debo') ||
            lowered.contains('tengo que') ||
            lowered.contains('need to') ||
            lowered.contains('preciso') ||
            lowered.contains('tenho que') ||
            lowered.contains('する必要') ||
            lowered.contains('需要'))) {
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
            lowered.contains('expires') ||
            lowered.contains('consome') ||
            lowered.contains('賞味') ||
            lowered.contains('消費') ||
            lowered.contains('过期'))) {
      hints['expiry_hint'] = hints['time_hint'] ?? 'soon';
    }
    if (domain == DomainKey.wardrobe) {
      hints['purchase_pause_hours'] = 24;
    }

    return hints;
  }

  bool _looksLikeFinance(String lowered) {
    return lowered.contains('compr') ||
        lowered.contains('comprei') ||
        lowered.contains('gaste') ||
        lowered.contains('gastei') ||
        lowered.contains('pague') ||
        lowered.contains('paguei') ||
        lowered.contains('coffee') ||
        lowered.contains('cafe') ||
        lowered.contains('sandwich') ||
        lowered.contains('almoco') ||
        lowered.contains('mercado') ||
        lowered.contains('買') ||
        lowered.contains('支払') ||
        lowered.contains('円') ||
        lowered.contains('买') ||
        lowered.contains('支付') ||
        lowered.contains('元') ||
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
        lowered.contains('food') ||
        lowered.contains('geladeira') ||
        lowered.contains('comida') ||
        lowered.contains('alface') ||
        lowered.contains('consome') ||
        lowered.contains('賞味') ||
        lowered.contains('消費') ||
        lowered.contains('冷蔵庫') ||
        lowered.contains('冰箱') ||
        lowered.contains('过期');
  }

  bool _looksLikeWardrobe(String lowered) {
    return lowered.contains('jacket') ||
        lowered.contains('shoes') ||
        lowered.contains('ropa') ||
        lowered.contains('closet') ||
        lowered.contains('buy another') ||
        lowered.contains('comprar') ||
        lowered.contains('chaqueta') ||
        lowered.contains('jaqueta') ||
        lowered.contains('sapato') ||
        lowered.contains('服') ||
        lowered.contains('靴') ||
        lowered.contains('衣服') ||
        lowered.contains('鞋');
  }

  bool _looksLikeHabit(String lowered) {
    return lowered.contains('walk') ||
        lowered.contains('sleep') ||
        lowered.contains('meditat') ||
        lowered.contains('reset') ||
        lowered.contains('habit') ||
        lowered.contains('agua') ||
        lowered.contains('exercise') ||
        lowered.contains('caminh') ||
        lowered.contains('dormi') ||
        lowered.contains('exercicio') ||
        lowered.contains('散歩') ||
        lowered.contains('睡眠') ||
        lowered.contains('瞑想') ||
        lowered.contains('散步') ||
        lowered.contains('冥想');
  }

  bool _looksLikeWeek(String lowered) {
    return lowered.contains('week') ||
        lowered.contains('monday') ||
        lowered.contains('friday') ||
        lowered.contains('calendar') ||
        lowered.contains('schedule') ||
        lowered.contains('plan') ||
        lowered.contains('semana') ||
        lowered.contains('segunda') ||
        lowered.contains('sexta') ||
        lowered.contains('agenda') ||
        lowered.contains('今週') ||
        lowered.contains('月曜') ||
        lowered.contains('金曜') ||
        lowered.contains('予定') ||
        lowered.contains('本周') ||
        lowered.contains('周一') ||
        lowered.contains('周五') ||
        lowered.contains('日程') ||
        lowered.contains('计划');
  }

  String _defaultEventType(DomainKey domain) {
    switch (domain) {
      case DomainKey.calendar:
        return 'calendar_block_captured';
      case DomainKey.journal:
        return 'journal_note_captured';
      case DomainKey.recipes:
        return 'recipe_note_captured';
      case DomainKey.homememory:
        return 'homememory_note_captured';
      case DomainKey.shopping:
        return 'shopping_need_captured';
      case DomainKey.decisions:
        return 'decision_note_captured';
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
