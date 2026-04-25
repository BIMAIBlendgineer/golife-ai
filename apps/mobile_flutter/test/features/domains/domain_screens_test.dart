import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/i18n/app_locale.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/domains/domain_screens.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

GoLifeController _buildController() {
  final localStore = MemoryLocalStore();
  return GoLifeController(
    localStore: localStore,
    aiGatewayClient: MockAiGatewayClient(),
    lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
  );
}

Future<void> _pumpDomainScreen(
  WidgetTester tester, {
  required Locale locale,
  required Widget screen,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: screen),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('everyday screen renders in Japanese without overflow',
      (tester) async {
    final controller = _buildController();

    await _pumpDomainScreen(
      tester,
      locale: const Locale('ja'),
      screen: EverydayScreen(controller: controller),
    );

    expect(find.byType(EverydayScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('journal screen renders in Simplified Chinese without overflow',
      (tester) async {
    final controller = _buildController();

    await _pumpDomainScreen(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      screen: JournalScreen(controller: controller),
    );

    expect(find.byType(JournalScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
