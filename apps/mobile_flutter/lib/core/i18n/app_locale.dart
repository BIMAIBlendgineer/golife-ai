import 'package:flutter/material.dart';

enum AppLocalePreference {
  system,
  en,
  es,
}

const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
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
    }
  }
}

AppLocalePreference appLocalePreferenceFromStorage(String? rawValue) {
  final rawNormalized =
      (rawValue ?? '').trim().replaceAll('_', '-').toLowerCase();
  final normalized = normalizeLocaleTag(rawValue);
  if ((rawValue ?? '').trim().toLowerCase() == 'system') {
    return AppLocalePreference.system;
  }
  for (final value in AppLocalePreference.values) {
    if (value.storageKey == rawValue) {
      return value;
    }
    if (value.storageKey == normalized &&
        (rawNormalized == normalized ||
            rawNormalized.startsWith('$normalized-'))) {
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
  if (normalized == 'en' || normalized.startsWith('en-')) {
    return 'en';
  }
  return 'en';
}
