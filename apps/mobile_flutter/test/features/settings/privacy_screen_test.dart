import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/export/local_export_service.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/settings/privacy_screen.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

class _FakeLocalExportService implements LocalExportService {
  @override
  Future<LocalExportResult> saveJsonExport({
    required String baseFileName,
    required String jsonPayload,
  }) async {
    return const LocalExportResult(
      fileName: 'golife_local_export_20260504T103015Z.json',
      filePath: '/protected/exports/golife_local_export_20260504T103015Z.json',
      byteCount: 128,
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
        'Protected local JSON export saved as golife_local_export_20260504T103015Z.json.',
      ),
      findsOneWidget,
    );
  });
}
