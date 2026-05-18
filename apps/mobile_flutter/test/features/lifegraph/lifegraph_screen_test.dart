import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/i18n/app_locale.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/lifegraph/lifegraph_screen.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

GoLifeController _buildController() {
  final localStore = MemoryLocalStore();
  return GoLifeController(
    localStore: localStore,
    aiGatewayClient: MockAiGatewayClient(),
    lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
  );
}

Future<void> _pumpLifeGraphScreen(
  WidgetTester tester, {
  required Locale locale,
  required GoLifeController controller,
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
      home: Scaffold(body: LifeGraphScreen(controller: controller)),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'lifegraph screen renders timeline and filters without overflow',
    (tester) async {
      final controller = _buildController();
      await controller.bootstrap();

      await _pumpLifeGraphScreen(
        tester,
        locale: const Locale('en'),
        controller: controller,
      );

      expect(find.byType(LifeGraphScreen), findsOneWidget);
      expect(find.text('Memory'), findsWidgets);
      expect(find.text('Search and filters'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);
      expect(
        controller.analyticsEvents.any(
          (event) => event.eventName == 'lifegraph_viewed',
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'lifegraph screen filters by search and shows local audit state',
    (tester) async {
      final controller = _buildController();
      await controller.bootstrap();
      await controller.updatePermission(
        DomainKey.finance,
        DataPermission.aiAllowed,
      );
      final financeEvent = controller.lifeEvents.firstWhere(
        (event) => event.domain == 'finance',
      );
      await controller.updateEventPrivacy(
        financeEvent.eventId,
        DataPermission.aiAllowed,
      );

      await _pumpLifeGraphScreen(
        tester,
        locale: const Locale('en'),
        controller: controller,
      );

      await tester.enterText(
        find.byKey(const ValueKey<String>('lifegraph-search-field')),
        'coffee',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(
        find.text('Coffee and sandwich purchase recorded'),
        findsOneWidget,
      );
      expect(find.text('Submit rent receipt'), findsNothing);
      expect(
        find.byKey(ValueKey<String>('lifegraph-audit-${financeEvent.eventId}')),
        findsOneWidget,
      );
      expect(find.textContaining('Changed at'), findsOneWidget);
      expect(
        controller.analyticsEvents.any(
          (event) => event.eventName == 'lifegraph_search_used',
        ),
        isTrue,
      );

      await tester.tap(find.text('Search and filters'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'Money'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Money'));
      await tester.pumpAndSettle();

      final filteredEvents = controller.analyticsEvents
          .where((event) => event.eventName == 'lifegraph_filtered')
          .toList(growable: false);
      expect(filteredEvents, isNotEmpty);
      expect(filteredEvents.first.metadata['domain_filter'], 'finance');
    },
  );
}
