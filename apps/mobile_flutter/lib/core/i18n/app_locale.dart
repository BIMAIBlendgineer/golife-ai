import 'package:flutter/material.dart';

enum AppLocalePreference {
  system,
  en,
  es,
  ptBr,
  ja,
  zhHans,
}

const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('pt', 'BR'),
  Locale('ja'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
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
      case AppLocalePreference.ja:
        return 'ja';
      case AppLocalePreference.zhHans:
        return 'zh-Hans';
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
      case AppLocalePreference.ja:
        return const Locale('ja');
      case AppLocalePreference.zhHans:
        return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
    }
  }
}

AppLocalePreference appLocalePreferenceFromStorage(String? rawValue) {
  for (final value in AppLocalePreference.values) {
    if (value.storageKey == rawValue) {
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
  if (normalized == 'es' || normalized.startsWith('es-')) {
    return 'es';
  }
  if (normalized == 'pt' || normalized == 'pt-br') {
    return 'pt-BR';
  }
  if (normalized == 'ja' || normalized.startsWith('ja-')) {
    return 'ja';
  }
  if (normalized == 'zh' ||
      normalized == 'zh-cn' ||
      normalized == 'zh-hans' ||
      normalized.startsWith('zh-')) {
    return 'zh-Hans';
  }
  return 'en';
}
