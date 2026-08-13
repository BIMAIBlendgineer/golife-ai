import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/homememory/homememory_screen.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

Future<GoLifeController> _buildController() async {
  final localStore = MemoryLocalStore();
  final controller = GoLifeController(
    localStore: localStore,
    aiGatewayClient: MockAiGatewayClient(),
    lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
  );
  await controller.bootstrap();
  await controller.saveManualPurchaseProof(
    productName: 'Dyson V8',
    brand: 'Dyson',
    model: 'V8',
    store: 'Amazon',
    purchaseDate: '2026-04-10',
    price: 249.99,
    currency: 'USD',
    warrantyMonths: 24,
    notes: 'Keep receipt local.',
    createWarrantyReminder: true,
  );
  return controller;
}

void main() {
  testWidgets('HomeMemory screen renders stored item without overflow', (
    tester,
  ) async {
    final controller = await _buildController();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: HomeMemoryScreen(controller: controller)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomeMemoryScreen), findsOneWidget);
    expect(find.text('Dyson V8'), findsOneWidget);
    expect(find.text('HomeMemory'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
