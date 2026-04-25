import 'package:flutter_test/flutter_test.dart';

import 'package:golife_flutter/app/golife_app.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';

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

  testWidgets('renders the dashboard in Portuguese when locale preference is pt-BR',
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

    expect(find.textContaining('missoes para hoje'), findsOneWidget);
    expect(find.text('Riscos de hoje'), findsOneWidget);
  });
}
