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
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/domains/missions/mission_feedback.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:golife_flutter/features/dashboard/dashboard_screen.dart';
import 'package:golife_flutter/l10n/app_localizations.dart';

class _FallbackAiGatewayClient extends AiGatewayClient {
  @override
  Future<MissionPlanDto> fetchDailyPlan({
    String locale = 'en',
    required PrivacySettings privacySettings,
    required List<LifeEvent> lifeEvents,
  }) async {
    return MissionPlanDto(
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
      trace: {
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

    expect(find.text('GoLife AI'), findsOneWidget);
    expect(find.textContaining('missions for today'), findsOneWidget);
    expect(find.text('Risks today'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
  });

  testWidgets('renders the dashboard in Spanish when locale preference is es',
      (tester) async {
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

    expect(find.textContaining('misiones para hoy'), findsOneWidget);
    expect(find.text('Riesgos de hoy'), findsOneWidget);
  });

  testWidgets('falls back to English when a non-release locale preference is stored',
      (tester) async {
    final localStore = MemoryLocalStore();
    await localStore.saveLocalePreference('pt-BR');

    await tester.pumpWidget(
      GoLifeApp(
        localStore: localStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('missions for today'), findsOneWidget);
    expect(find.text('Risks today'), findsOneWidget);
  });

  testWidgets('shows degraded gateway status when the HTTP client falls back',
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
        home: Scaffold(
          body: DashboardScreen(
            controller: controller,
          ),
        ),
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
}
