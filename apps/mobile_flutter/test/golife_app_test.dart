import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golife_flutter/app/golife_app.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/ai_client/dto/ai_gateway_dto.dart';
import 'package:golife_flutter/core/i18n/app_locale.dart';
import 'package:golife_flutter/core/lifegraph/life_event.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/settings/app_profile_preferences.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/domains/missions/mission_feedback.dart';
import 'package:golife_flutter/domains/missions/mission_set.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/dashboard/dashboard_screen.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

class _BlockingBootstrapStore extends MemoryLocalStore {
  final Completer<void> gate = Completer<void>();

  void release() {
    if (!gate.isCompleted) {
      gate.complete();
    }
  }

  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    await gate.future;
    return super.loadPrivacySettings();
  }
}

class _FallbackAiGatewayClient extends AiGatewayClient {
  @override
  Future<MissionPlanDto> fetchDailyPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    return MissionPlanDto(
      missionSetId: 'mission-set-offline-test',
      date: '2026-05-16',
      sourceState: MissionSourceState.fallback,
      fallbackUsed: true,
      policyVersion: 'policy_v1',
      rankingVersion: 'mission_ranker_v1',
      suggestions: [
        MissionSuggestionDto(
          id: 'mission-offline-1',
          title: 'Keep one local win visible',
          body: 'Finish one short task locally while the gateway is offline.',
          evidence: const ['Gateway request fell back to local guidance.'],
          uncertainty: 'Remote AI is unavailable, so this plan is local only.',
          requiresConfirmation: true,
          domainTargets: const ['task'],
          recommendationType: 'mission',
          confidence: 0.72,
          ranking: null,
          trace: const {
            'clientFallback': true,
            'fallbackReason': 'no_connection',
          },
        ),
      ],
      trace: const {
        'clientFallback': true,
        'fallbackReason': 'no_connection',
        'sourceState': 'fallback',
        'fallbackUsed': true,
      },
    );
  }

  @override
  Future<CaptureClassificationDto> classifyCapture({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String text,
  }) async {
    return const CaptureClassificationDto(
      domain: 'task',
      eventType: 'task_captured',
      confidence: 0.8,
      rationale: 'Fallback test client',
      trace: {'clientFallback': true, 'fallbackReason': 'no_connection'},
    );
  }

  @override
  Future<DecisionPlanDto> fetchDecisionPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> mentalLoadItems,
  }) async {
    return const DecisionPlanDto(
      decisions: <DecisionCardDto>[],
      trace: <String, Object?>{
        'clientFallback': true,
        'fallbackReason': 'no_connection',
      },
    );
  }

  @override
  Future<ShoppingPlanDto> optimizeShoppingList({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<Map<String, Object?>> shoppingNeeds,
    List<Map<String, Object?>> pantryContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> financeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> wardrobeContext = const <Map<String, Object?>>[],
    List<Map<String, Object?>> homememoryContext =
        const <Map<String, Object?>>[],
  }) async {
    return const ShoppingPlanDto(
      needs: <ShoppingNeedDto>[],
      productEvidence: <ProductEvidenceCardDto>[],
      decisions: <DecisionCardDto>[],
      trace: <String, Object?>{
        'clientFallback': true,
        'fallbackReason': 'no_connection',
      },
    );
  }

  @override
  Future<ProductEvidenceCardDto?> fetchProductEvidence({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required String productName,
    String? merchantName,
  }) async {
    return const ProductEvidenceCardDto(
      id: 'evidence-fallback',
      userId: 'local-user',
      productName: 'fallback',
      brand: null,
      merchantName: null,
      price: null,
      currency: null,
      source: 'local_fallback',
      checkedAtIso: null,
      reviewSummary: null,
      sustainabilityStatus: 'insufficient_verified_data',
      confidence: 0,
      disclaimer: 'Fallback evidence only.',
      trace: <String, Object?>{
        'clientFallback': true,
        'fallbackReason': 'no_connection',
      },
    );
  }

  @override
  Future<void> submitMissionFeedback({
    String locale = 'en',
    required MissionFeedback feedback,
  }) async {}
}

void main() {
  testWidgets('renders the shell dashboard', (tester) async {
    await tester.pumpWidget(
      GoLifeApp(
        localStore: MemoryLocalStore(),
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Your daily decision OS.'), findsNothing);
    expect(find.text('Today'), findsWidgets);
    expect(find.textContaining('Your focus for today.'), findsOneWidget);
    expect(find.text('Risks today'), findsOneWidget);
    expect(find.text('Other missions'), findsOneWidget);
  });

  testWidgets(
    'mobile shell exposes exactly five primary destinations without global product banner',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GoLifeApp(
          localStore: MemoryLocalStore(),
          aiGatewayClient: MockAiGatewayClient(),
          lifeGraphRepository: LifeGraphRepository.seeded(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));

      final navigationBar =
          tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.destinations, hasLength(5));

      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Capture'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Memory'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Coach'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );
      expect(find.text('Your daily decision OS.'), findsNothing);
    },
  );

  testWidgets(
    'shows premium bootstrap screen until controller is ready',
    (tester) async {
      final localStore = _BlockingBootstrapStore();

      await tester.pumpWidget(
        GoLifeApp(
          localStore: localStore,
          aiGatewayClient: MockAiGatewayClient(),
          lifeGraphRepository: LifeGraphRepository.seeded(
            localStore: localStore,
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byKey(const Key('golife-bootstrap-screen')),
        findsOneWidget,
      );
      expect(find.text('GoLife AI'), findsOneWidget);
      expect(find.text('Preparing your day...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      localStore.release();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('golife-bootstrap-screen')),
        findsNothing,
      );
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('renders the dashboard in Spanish when locale preference is es', (
    tester,
  ) async {
    final localStore = MemoryLocalStore();
    await localStore.saveLocalePreference('es');

    await tester.pumpWidget(
      GoLifeApp(
        localStore: localStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hoy'), findsWidgets);
    expect(find.textContaining('Tu foco de hoy.'), findsOneWidget);
    expect(find.text('Riesgos de hoy'), findsOneWidget);
  });

  testWidgets(
    'PT-BR keeps primary mobile surfaces coherently localized',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final localStore = MemoryLocalStore();
      await localStore.saveLocalePreference('pt-BR');

      await tester.pumpWidget(
        GoLifeApp(
          localStore: localStore,
          aiGatewayClient: MockAiGatewayClient(),
          lifeGraphRepository: LifeGraphRepository.seeded(
            localStore: localStore,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      for (final label in const [
        'Hoje',
        'Capturar',
        'Memória',
        'Coach',
        'Ajustes',
      ]) {
        expect(
          find.descendant(of: navigationBar, matching: find.text(label)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: navigationBar, matching: find.text('Memory')),
        findsNothing,
      );
      expect(find.text('Seu foco de hoje.'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: navigationBar,
          matching: find.text('Capturar'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Solte o que está na sua cabeça.'), findsOneWidget);
      expect(find.text('Capture primeiro. Organize depois.'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Memória'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Memória'), findsWidgets);
      expect(find.text('Sua vida recente.'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Coach'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pergunte sobre o seu dia.'), findsOneWidget);
    },
  );

  testWidgets(
    'Spanish keeps primary navigation and P0 headings localized',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final localStore = MemoryLocalStore();
      await localStore.saveLocalePreference('es');

      await tester.pumpWidget(
        GoLifeApp(
          localStore: localStore,
          aiGatewayClient: MockAiGatewayClient(),
          lifeGraphRepository: LifeGraphRepository.seeded(
            localStore: localStore,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      for (final label in const [
        'Hoy',
        'Capturar',
        'Memoria',
        'Coach',
        'Ajustes',
      ]) {
        expect(
          find.descendant(of: navigationBar, matching: find.text(label)),
          findsOneWidget,
        );
      }

      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('Capturar')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Suelta lo que tienes en la cabeza.'), findsOneWidget);
      expect(find.text('Captura primero. Ordena después.'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Memoria'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Memoria'), findsWidgets);
      expect(find.text('Tu vida reciente.'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Coach'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pregunta sobre tu día.'), findsOneWidget);
    },
  );

  testWidgets('limits productive supported locales to EN ES and PT-BR', (
    tester,
  ) async {
    final localStore = MemoryLocalStore();

    await tester.pumpWidget(
      GoLifeApp(
        localStore: localStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      ),
    );

    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      app.supportedLocales,
      const <Locale>[
        Locale('en'),
        Locale('es'),
        Locale('pt', 'BR'),
      ],
    );
  });

  testWidgets(
    'uses Brazilian Portuguese automatically when device locale is pt-BR',
    (tester) async {
      final platformDispatcher = tester.binding.platformDispatcher;
      platformDispatcher.localeTestValue = const Locale('pt', 'BR');
      platformDispatcher.localesTestValue = const [Locale('pt', 'BR')];
      addTearDown(() {
        platformDispatcher.clearLocaleTestValue();
        platformDispatcher.clearLocalesTestValue();
      });

      final localStore = _BlockingBootstrapStore();

      await tester.pumpWidget(
        GoLifeApp(
          localStore: localStore,
          aiGatewayClient: MockAiGatewayClient(),
          lifeGraphRepository: LifeGraphRepository.seeded(
            localStore: localStore,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Preparando o seu dia...'), findsOneWidget);

      localStore.release();
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Capturar'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ajustes'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'stored PT-BR preference overrides a non-Portuguese device locale',
    (tester) async {
      final platformDispatcher = tester.binding.platformDispatcher;
      platformDispatcher.localeTestValue = const Locale('en', 'US');
      platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(() {
        platformDispatcher.clearLocaleTestValue();
        platformDispatcher.clearLocalesTestValue();
      });

      final localStore = MemoryLocalStore();
      await localStore.saveLocalePreference('pt-BR');

      await tester.pumpWidget(
        GoLifeApp(
          localStore: localStore,
          aiGatewayClient: MockAiGatewayClient(),
          lifeGraphRepository: LifeGraphRepository.seeded(
            localStore: localStore,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Capturar'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ajustes'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('uses stored dark theme preference', (tester) async {
    final localStore = MemoryLocalStore();
    await localStore.saveProfilePreferences(
      AppProfilePreferences.defaults().copyWith(
        themePreference: AppThemePreference.dark,
      ),
    );

    await tester.pumpWidget(
      GoLifeApp(
        localStore: localStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      ),
    );

    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('shows degraded gateway status when the HTTP client falls back', (
    tester,
  ) async {
    final localStore = MemoryLocalStore();
    final controller = GoLifeController(
      localStore: localStore,
      aiGatewayClient: _FallbackAiGatewayClient(),
      lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
    );
    await controller.bootstrap();

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: supportedAppLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: DashboardScreen(controller: controller)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No connection'), findsOneWidget);
    expect(
      find.text(
        'You can keep using GoLife locally. Reconnect when you want fresh AI help.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows mission snapshot metadata on home and in explanation sheet',
    (tester) async {
      final localStore = MemoryLocalStore();
      final controller = GoLifeController(
        localStore: localStore,
        aiGatewayClient: _FallbackAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      );
      await controller.bootstrap();

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: supportedAppLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: DashboardScreen(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AI data disclosure'), findsOneWidget);
      expect(find.text('Technical trace'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Explain').first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Explain').first);
      await tester.pumpAndSettle();

      expect(find.text('Technical trace'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Technical trace'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Technical trace'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'MissionSet: mission-set-offline-test',
          findRichText: true,
        ),
        findsWidgets,
      );
      expect(
        controller.analyticsEvents.any(
          (event) => event.eventName == 'mission_viewed',
        ),
        isTrue,
      );
    },
  );
}
