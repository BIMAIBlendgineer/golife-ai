import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/i18n/app_locale.dart';

void main() {
  test('normalizes productive locale tags to the EN/ES release scope', () {
    expect(normalizeLocaleTag('en-US'), 'en');
    expect(normalizeLocaleTag('es-ES'), 'es');
    expect(normalizeLocaleTag('pt-BR'), 'en');
    expect(normalizeLocaleTag('fr-FR'), 'en');
    expect(normalizeLocaleTag('zh-CN'), 'en');
  });

  test('maps stored release-scope preferences to exact Flutter locales', () {
    expect(appLocalePreferenceFromStorage('en').locale, const Locale('en'));
    expect(appLocalePreferenceFromStorage('es').locale, const Locale('es'));
  });

  test('unsupported stored locale preferences fall back to system', () {
    expect(appLocalePreferenceFromStorage('pt-BR'), AppLocalePreference.system);
    expect(
        appLocalePreferenceFromStorage('zh-Hans'), AppLocalePreference.system);
  });

  test('falls back to English for unsupported locale tags', () {
    expect(normalizeLocaleTag('xx-YY'), 'en');
    expect(normalizeLocaleTag(null), 'en');
  });
}
