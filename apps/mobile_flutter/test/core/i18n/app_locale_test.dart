import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/i18n/app_locale.dart';

void main() {
  test('normalizes productive locale tags to the EN/ES/PT-BR release scope',
      () {
    expect(normalizeLocaleTag('en-US'), 'en');
    expect(normalizeLocaleTag('en_GB'), 'en');
    expect(normalizeLocaleTag('es-ES'), 'es');
    expect(normalizeLocaleTag('es_AR'), 'es');
    expect(normalizeLocaleTag('pt-BR'), 'pt-BR');
    expect(normalizeLocaleTag('pt_BR'), 'pt-BR');
    expect(normalizeLocaleTag('pt'), 'pt-BR');
    expect(normalizeLocaleTag('pt-PT'), 'pt-BR');
    expect(normalizeLocaleTag('fr-FR'), 'en');
    expect(normalizeLocaleTag('zh-CN'), 'en');
  });

  test('maps stored release-scope preferences to exact Flutter locales', () {
    expect(appLocalePreferenceFromStorage('en').locale, const Locale('en'));
    expect(appLocalePreferenceFromStorage('es').locale, const Locale('es'));
    expect(
      appLocalePreferenceFromStorage('pt-BR').locale,
      const Locale('pt', 'BR'),
    );
    expect(
      appLocalePreferenceFromStorage('pt_BR'),
      AppLocalePreference.ptBr,
    );
    expect(
      appLocalePreferenceFromStorage('pt-PT'),
      AppLocalePreference.ptBr,
    );
  });

  test('unsupported stored locale preferences fall back to system', () {
    expect(appLocalePreferenceFromStorage('fr-FR'), AppLocalePreference.system);
    expect(
        appLocalePreferenceFromStorage('zh-Hans'), AppLocalePreference.system);
    expect(appLocalePreferenceFromStorage('xx-YY'), AppLocalePreference.system);
    expect(appLocalePreferenceFromStorage(null), AppLocalePreference.system);
  });

  test('falls back to English for unsupported locale tags', () {
    expect(normalizeLocaleTag('xx-YY'), 'en');
    expect(normalizeLocaleTag(null), 'en');
  });

  test('productive Flutter locale list is exactly EN ES and PT-BR', () {
    expect(
      supportedAppLocales,
      const <Locale>[
        Locale('en'),
        Locale('es'),
        Locale('pt', 'BR'),
      ],
    );
  });
}
