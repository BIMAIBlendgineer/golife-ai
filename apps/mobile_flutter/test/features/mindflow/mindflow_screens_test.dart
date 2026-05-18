import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/i18n/app_locale.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/mindflow/mindflow_screens.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

Future<void> _pumpScreen(WidgetTester tester, {required Widget screen}) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
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

Future<GoLifeController> _buildController() async {
  final localStore = MemoryLocalStore();
  final controller = GoLifeController(
    localStore: localStore,
    aiGatewayClient: MockAiGatewayClient(),
    lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
  );
  await controller.bootstrap();
  await controller.captureEvent(
    domain: DomainKey.pantry,
    text: 'Dishwasher tablets are nearly gone',
  );
  return controller;
}

void main() {
  testWidgets('decisions screen renders without overflow', (tester) async {
    final controller = await _buildController();

    await _pumpScreen(tester, screen: DecisionsScreen(controller: controller));

    expect(find.byType(DecisionsScreen), findsOneWidget);
    expect(find.text('Decisions'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shopping screen renders without overflow', (tester) async {
    final controller = await _buildController();

    await _pumpScreen(tester, screen: ShoppingScreen(controller: controller));

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(find.text('Shopping'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
