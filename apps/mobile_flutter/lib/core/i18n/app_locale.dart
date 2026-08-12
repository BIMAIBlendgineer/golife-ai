import 'package:flutter/material.dart';

enum AppLocalePreference {
  system,
  en,
  es,
  ptBr,
}

const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('pt', 'BR'),
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
    }
  }
}

AppLocalePreference appLocalePreferenceFromStorage(String? rawValue) {
  final raw = (rawValue ?? '').trim();
  if (raw.isEmpty || raw.toLowerCase() == 'system') {
    return AppLocalePreference.system;
  }

  switch (_normalizeSupportedLocaleTag(raw)) {
    case 'en':
      return AppLocalePreference.en;
    case 'es':
      return AppLocalePreference.es;
    case 'pt-BR':
      return AppLocalePreference.ptBr;
    default:
      return AppLocalePreference.system;
  }
}

String normalizeLocaleTag(String? rawValue) {
  return _normalizeSupportedLocaleTag(rawValue) ?? 'en';
}

String? _normalizeSupportedLocaleTag(String? rawValue) {
  final normalized = (rawValue ?? '').trim().replaceAll('_', '-').toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }

  if (normalized == 'en' || normalized.startsWith('en-')) {
    return 'en';
  }
  if (normalized == 'es' || normalized.startsWith('es-')) {
    return 'es';
  }
  if (normalized == 'pt' || normalized.startsWith('pt-')) {
    return 'pt-BR';
  }

  return null;
}
