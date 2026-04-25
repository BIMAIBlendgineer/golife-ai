import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/features/capture/capture_parser.dart';

void main() {
  group('CaptureParser', () {
    const parser = CaptureParser();

    test('splits a multi-event sentence into domain drafts', () {
      final drafts = parser.parse(
        text: 'Compre cafe 4.50, la lechuga vence manana y debo pagar internet',
        privacySettings: PrivacySettings.defaults(),
      );

      expect(drafts, hasLength(3));
      expect(drafts[0].domain, DomainKey.finance);
      expect(drafts[1].domain, DomainKey.pantry);
      expect(drafts[2].domain, DomainKey.tasks);
      expect(drafts[0].eventType, 'expense_logged');
      expect(drafts[1].eventType, 'ingredient_flagged');
      expect(drafts[2].eventType, 'task_captured');
    });

    test('honors a forced domain for all generated drafts', () {
      final drafts = parser.parse(
        text: 'submit rent receipt and archive the invoice',
        privacySettings: PrivacySettings.defaults(),
        forcedDomain: DomainKey.tasks,
      );

      expect(drafts, isNotEmpty);
      expect(
        drafts.every((draft) => draft.domain == DomainKey.tasks),
        isTrue,
      );
    });

    test('supports portuguese connectors and multilingual fallback terms', () {
      final drafts = parser.parse(
        text: 'Comprei cafe 8.50 e a alface vence amanha e preciso pagar internet',
        privacySettings: PrivacySettings.defaults(),
      );

      expect(drafts, hasLength(3));
      expect(drafts[0].domain, DomainKey.finance);
      expect(drafts[1].domain, DomainKey.pantry);
      expect(drafts[2].domain, DomainKey.tasks);
    });

    test('classifies japanese and chinese pantry wording locally', () {
      final japanese = parser.parse(
        text: '冷蔵庫のほうれん草は明日まで',
        privacySettings: PrivacySettings.defaults(),
      );
      final chinese = parser.parse(
        text: '冰箱里的菠菜明天过期',
        privacySettings: PrivacySettings.defaults(),
      );

      expect(japanese.single.domain, DomainKey.pantry);
      expect(chinese.single.domain, DomainKey.pantry);
    });
  });
}
