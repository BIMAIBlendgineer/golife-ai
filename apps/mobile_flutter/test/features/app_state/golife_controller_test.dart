import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/domains/missions/daily_mission.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';

void main() {
  group('GoLifeController', () {
    late MemoryLocalStore localStore;
    late GoLifeController controller;

    setUp(() async {
      localStore = MemoryLocalStore();
      controller = GoLifeController(
        localStore: localStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      );
      await controller.bootstrap();
    });

    test('captures multiple drafts into entities and life events', () async {
      final drafts = await controller.prepareCaptureDrafts(
        text:
            'Compre cafe 4.50, la lechuga vence manana y debo pagar internet',
      );

      expect(drafts, hasLength(3));

      final initialTaskCount = controller.tasks.length;
      final initialExpenseCount = controller.expenses.length;
      final initialPantryCount = controller.pantryItems.length;
      final initialEventCount = controller.totalEventCount;

      await controller.captureDrafts(drafts);

      expect(controller.tasks.length, initialTaskCount + 1);
      expect(controller.expenses.length, initialExpenseCount + 1);
      expect(controller.pantryItems.length, initialPantryCount + 1);
      expect(controller.totalEventCount, initialEventCount + 3);
    });

    test('mission action updates a task and records completion feedback', () async {
      final mission = DailyMission(
        id: 'mission-task',
        title: 'Close one critical task',
        body: 'Mark the critical task as done.',
        evidence: const <String>['Task is still active'],
        uncertainty: 'No uncertainty',
        requiresConfirmation: true,
        domainTargets: const <String>['task'],
        recommendationType: 'task_execution',
        confidence: 0.9,
        trace: const <String, Object?>{},
      );

      final result = await controller.completeMissionAction(mission);

      expect(result, contains('Task'));
      expect(
        controller.tasks.any((task) => task.status.name == 'done'),
        isTrue,
      );
      expect(
        controller.missionFeedbackHistory.any(
          (item) => item.missionId == mission.id,
        ),
        isTrue,
      );
    });

    test('exports and deletes local data', () async {
      final exportedJson = await controller.exportLocalDataJson();
      final decoded = jsonDecode(exportedJson) as Map<String, dynamic>;

      expect(decoded['life_events'], isA<List<dynamic>>());
      expect(decoded['tasks'], isA<List<dynamic>>());

      await controller.deleteAllLocalData();

      expect(controller.totalEventCount, 0);
      expect(controller.tasks, isEmpty);
      expect(controller.habits, isEmpty);
      expect(await localStore.loadDemoSeedEnabled(), isFalse);
    });
  });
}
