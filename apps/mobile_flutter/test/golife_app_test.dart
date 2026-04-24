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
    expect(find.text('3 Missions for today'), findsOneWidget);
    expect(find.text('Risks today'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
  });
}
