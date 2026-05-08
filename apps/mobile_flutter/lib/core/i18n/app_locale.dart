import 'package:flutter/material.dart';

enum AppLocalePreference {
  system,
  en,
  es,
  ptBr,
  ptPt,
  fr,
  it,
  de,
  ja,
  zhHans,
  zhHant,
}

const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('pt', 'BR'),
  Locale('pt', 'PT'),
  Locale('fr'),
  Locale('it'),
  Locale('de'),
  Locale('ja'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
];

extension AppLocalePreferenceX on AppLocalePreference {
  String get storageKey {
    switch (this) {
      case AppLocalePreference.system:
        return 'system';
      case AppLocalePreference.en:
        return 'en';
      case AppLocalePreference.es:
        return 'es';
      case AppLocalePreference.ptBr:
        return 'pt-BR';
      case AppLocalePreference.ptPt:
        return 'pt-PT';
      case AppLocalePreference.fr:
        return 'fr';
      case AppLocalePreference.it:
        return 'it';
      case AppLocalePreference.de:
        return 'de';
      case AppLocalePreference.ja:
        return 'ja';
      case AppLocalePreference.zhHans:
        return 'zh-Hans';
      case AppLocalePreference.zhHant:
        return 'zh-Hant';
    }
  }

  Locale? get locale {
    switch (this) {
      case AppLocalePreference.system:
        return null;
      case AppLocalePreference.en:
        return const Locale('en');
      case AppLocalePreference.es:
        return const Locale('es');
      case AppLocalePreference.ptBr:
        return const Locale('pt', 'BR');
      case AppLocalePreference.ptPt:
        return const Locale('pt', 'PT');
      case AppLocalePreference.fr:
        return const Locale('fr');
      case AppLocalePreference.it:
        return const Locale('it');
      case AppLocalePreference.de:
        return const Locale('de');
      case AppLocalePreference.ja:
        return const Locale('ja');
      case AppLocalePreference.zhHans:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      case AppLocalePreference.zhHant:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
  }
}

AppLocalePreference appLocalePreferenceFromStorage(String? rawValue) {
  final normalized = normalizeLocaleTag(rawValue);
  if ((rawValue ?? '').trim().toLowerCase() == 'system') {
    return AppLocalePreference.system;
  }
  for (final value in AppLocalePreference.values) {
    if (value.storageKey == rawValue || value.storageKey == normalized) {
      return value;
    }
  }
  return AppLocalePreference.system;
}

String normalizeLocaleTag(String? rawValue) {
  final normalized = (rawValue ?? '').trim().replaceAll('_', '-').toLowerCase();
  if (normalized.isEmpty) {
    return 'en';
  }
  if (normalized == 'pt-br' || normalized.startsWith('pt-br-')) {
    return 'pt-BR';
  }
  if (
      normalized == 'pt' ||
      normalized == 'pt-pt' ||
      normalized.startsWith('pt-pt-') ||
      (normalized.startsWith('pt-') && !normalized.startsWith('pt-br'))) {
    return 'pt-PT';
  }
  if (normalized == 'fr' || normalized.startsWith('fr-')) {
    return 'fr';
  }
  if (normalized == 'it' || normalized.startsWith('it-')) {
    return 'it';
  }
  if (normalized == 'de' || normalized.startsWith('de-')) {
    return 'de';
  }
  if (normalized == 'ja' || normalized.startsWith('ja-')) {
    return 'ja';
  }
  if (
      normalized == 'zh-hant' ||
      normalized.contains('-hant') ||
      normalized.endsWith('-tw') ||
      normalized.endsWith('-hk') ||
      normalized.endsWith('-mo')) {
    return 'zh-Hant';
  }
  if (
      normalized == 'zh' ||
      normalized == 'zh-hans' ||
      normalized.contains('-hans') ||
      normalized.endsWith('-cn') ||
      normalized.endsWith('-sg') ||
      normalized.startsWith('zh-')) {
    return 'zh-Hans';
  }
  if (normalized == 'es' || normalized.startsWith('es-')) {
    return 'es';
  }
  if (normalized == 'en' || normalized.startsWith('en-')) {
    return 'en';
  }
  return 'en';
}
