import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/legal/legal_document_registry.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/export/local_export_service.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/settings/privacy_screen.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

class _FakeLocalExportService implements LocalExportService {
  @override
  Future<LocalExportResult> saveExportBundle({
    required String baseFileName,
    required String jsonPayload,
    List<LocalExportAsset> assets = const <LocalExportAsset>[],
  }) async {
    return const LocalExportResult(
      fileName: 'golife_local_export_20260504T103015Z',
      filePath: '/protected/exports/golife_local_export_20260504T103015Z',
      dataFilePath:
          '/protected/exports/golife_local_export_20260504T103015Z/data.json',
      byteCount: 128,
      assetCount: 0,
    );
  }
}

void main() {
  testWidgets('privacy screen reports protected file export', (tester) async {
    final localStore = MemoryLocalStore();
    final controller = GoLifeController(
      localStore: localStore,
      aiGatewayClient: MockAiGatewayClient(),
      lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      localExportService: _FakeLocalExportService(),
    );
    await controller.bootstrap();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PrivacyScreen(controller: controller),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Export JSON'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Export JSON'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Protected local export bundle saved as golife_local_export_20260504T103015Z.',
      ),
      findsOneWidget,
    );
    expect(find.text('Clear AI history'), findsOneWidget);
  });

  testWidgets('privacy screen exposes event controls and visible local audit',
      (tester) async {
    final localStore = MemoryLocalStore();
    final controller = GoLifeController(
      localStore: localStore,
      aiGatewayClient: MockAiGatewayClient(),
      lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      localExportService: _FakeLocalExportService(),
    );
    await controller.bootstrap();
    await controller.updatePermission(
      DomainKey.finance,
      DataPermission.aiAllowed,
    );
    final financeEvent = controller.lifeEvents.firstWhere(
      (event) => event.domain == 'finance',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => PrivacyScreen(controller: controller),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Recent LifeGraph events'), findsOneWidget);
    expect(find.text('Privacy audit'), findsOneWidget);
    expect(find.text('No local privacy audit entries yet.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(ValueKey<String>('life-event-${financeEvent.eventId}')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(
        ValueKey<String>(
          'event-privacy-${financeEvent.eventId}-${DataPermission.aiAllowed.storageKey}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No local privacy audit entries yet.'), findsNothing);
    expect(find.textContaining('Event ID: ${financeEvent.eventId}'),
        findsOneWidget);
    expect(find.textContaining('Changed at:'), findsOneWidget);
  });

  testWidgets('privacy screen exposes public legal links', (tester) async {
    final localStore = MemoryLocalStore();
    final controller = GoLifeController(
      localStore: localStore,
      aiGatewayClient: MockAiGatewayClient(),
      lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      localExportService: _FakeLocalExportService(),
    );
    await controller.bootstrap();

    final openedUrls = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PrivacyScreen(
            controller: controller,
            onOpenExternalUrl: (url) async => openedUrls.add(url),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Store and legal'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Store and legal'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('legal-url-privacy_policy')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('legal-open-privacy_policy')),
    );
    await tester.pumpAndSettle();

    expect(openedUrls, <String>[GoLifeLegalDocuments.privacyPolicyUrl]);
  });
}
