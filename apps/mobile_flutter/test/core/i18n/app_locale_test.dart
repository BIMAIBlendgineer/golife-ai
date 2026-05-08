import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/i18n/app_locale.dart';

void main() {
  test('normalizes supported locale tags to the requested 10-locale set', () {
    expect(normalizeLocaleTag('en-US'), 'en');
    expect(normalizeLocaleTag('es-ES'), 'es');
    expect(normalizeLocaleTag('pt-BR'), 'pt-BR');
    expect(normalizeLocaleTag('pt-PT'), 'pt-PT');
    expect(normalizeLocaleTag('fr-FR'), 'fr');
    expect(normalizeLocaleTag('it-IT'), 'it');
    expect(normalizeLocaleTag('de-DE'), 'de');
    expect(normalizeLocaleTag('ja-JP'), 'ja');
    expect(normalizeLocaleTag('zh-CN'), 'zh-Hans');
    expect(normalizeLocaleTag('zh-TW'), 'zh-Hant');
  });

  test('maps stored locale preferences to exact Flutter locales', () {
    expect(appLocalePreferenceFromStorage('pt-BR').locale, const Locale('pt', 'BR'));
    expect(appLocalePreferenceFromStorage('pt-PT').locale, const Locale('pt', 'PT'));
    expect(
      appLocalePreferenceFromStorage('zh-Hans').locale,
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
    expect(
      appLocalePreferenceFromStorage('zh-Hant').locale,
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
  });
}
