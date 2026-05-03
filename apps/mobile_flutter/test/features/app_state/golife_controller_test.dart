import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/domains/missions/daily_mission.dart';
import 'package:golife_flutter/domains/tasks/go_task.dart';
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
        text: 'Compre cafe 4.50, la lechuga vence manana y debo pagar internet',
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

    test('mission action updates a task and records completion feedback',
        () async {
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

    test('stores journal, calendar, and recipe rescue entities locally',
        () async {
      await controller.saveJournalEntry(
        title: 'Evening reset',
        body: 'Need to protect a shorter evening shutdown.',
        mood: 'reflective',
      );
      await controller.saveQuickNote(text: 'Call landlord tomorrow morning.');
      await controller.saveCalendarItem(
        title: 'Deep work',
        startIso: '2026-04-25T09:00:00Z',
        endIso: '2026-04-25T10:30:00Z',
      );
      await controller.saveRecipeRescue(
        title: 'Spinach rescue bowl',
        summary: 'Use spinach before it expires.',
        ingredientNames: const <String>['spinach', 'rice'],
        estimatedMinutes: 15,
      );

      expect(controller.journalEntries, hasLength(1));
      expect(controller.quickNotes, hasLength(1));
      expect(controller.calendarItems, hasLength(1));
      expect(
        controller.recipeRescues.any(
          (recipe) => recipe.title == 'Spinach rescue bowl',
        ),
        isTrue,
      );
      expect(
        controller.blockedFromAiEvents.any((event) => event.domain == 'system'),
        isTrue,
      );
    });

    test(
        'manual proof flow creates item, warranty, reminder, claim, evidence, and export security',
        () async {
      final message = await controller.saveManualPurchaseProof(
        productName: 'Dyson V8',
        brand: 'Dyson',
        model: 'V8',
        category: 'appliance',
        store: 'Amazon',
        purchaseDate: '2026-04-10',
        price: 249.99,
        currency: 'USD',
        warrantyMonths: 24,
        notes: 'Keep receipt local.',
        createWarrantyReminder: true,
      );

      final ownedItem = controller.ownedItems.single;
      expect(message, isNotNull);
      expect(message, isNotEmpty);
      expect(ownedItem.name, 'Dyson V8');
      expect(controller.purchaseProofs.single.ownedItemId, ownedItem.id);
      expect(controller.warrantyRecords.single.ownedItemId, ownedItem.id);
      expect(controller.maintenanceReminders.single.ownedItemId, ownedItem.id);

      await controller.saveClaimDraft(
        ownedItemId: ownedItem.id,
        issueDescription: 'Battery stopped charging.',
        recipientHint: 'Amazon support',
      );
      await controller.saveEvidenceAttachment(
        ownedItemId: ownedItem.id,
        proofId: controller.purchaseProofs.single.id,
        type: 'receipt',
        fileRef: 'files/receipt-1.jpg',
        description: 'Receipt photo',
        privacyLevel: 'local_only',
      );

      expect(controller.claimDrafts, hasLength(1));
      expect(controller.evidenceAttachments, hasLength(1));
      expect(
        controller.lifeEvents
            .any((event) => event.type == 'purchase_proof_added'),
        isTrue,
      );
      expect(
        controller.lifeEvents
            .any((event) => event.type == 'owned_item_created'),
        isTrue,
      );
      expect(
        controller.lifeEvents.any((event) => event.type == 'warranty_detected'),
        isTrue,
      );
      expect(
        controller.lifeEvents
            .any((event) => event.type == 'maintenance_scheduled'),
        isTrue,
      );
      expect(
        controller.lifeEvents
            .any((event) => event.type == 'claim_draft_created'),
        isTrue,
      );
      expect(
        controller.lifeEvents.any(
          (event) => event.type == 'evidence_attachment_added',
        ),
        isTrue,
      );

      final exportedJson = await controller.exportLocalDataJson();
      final decoded = jsonDecode(exportedJson) as Map<String, dynamic>;
      final storageSecurity =
          decoded['storage_security'] as Map<String, dynamic>;
      final encryptedCollections =
          (storageSecurity['encrypted_collections'] as List<dynamic>)
              .cast<String>();

      expect(encryptedCollections, contains('owned_items'));
      expect(encryptedCollections, contains('purchase_proofs'));
      expect(encryptedCollections, contains('claim_drafts'));
      expect(encryptedCollections, contains('evidence_attachments'));
    });

    test('deletes individual entities without wiping the full local state',
        () async {
      await controller.saveTask(
        title: 'Archive travel receipts',
        priority: TaskPriority.standard,
        estimatedMinutes: 20,
      );
      await controller.saveExpense(
        label: 'Train ticket',
        amount: 14.2,
        category: 'transport',
      );
      await controller.savePantryItem(
        name: 'Spinach',
        quantityLabel: '1 bag',
        rescueHint: 'Use tonight.',
      );
      await controller.saveJournalEntry(
        title: 'Evening note',
        body: 'Keep the reset small.',
        mood: 'steady',
      );
      await controller.saveCalendarItem(
        title: 'Admin block',
        startIso: '2026-04-25T13:00:00Z',
        endIso: '2026-04-25T14:00:00Z',
      );
      await controller.saveRecipeRescue(
        title: 'Spinach rice bowl',
        summary: 'Use the oldest greens first.',
        ingredientNames: const <String>['spinach', 'rice'],
        estimatedMinutes: 15,
      );

      final taskId = controller.tasks.first.id;
      final expenseId = controller.expenses.first.id;
      final pantryId = controller.pantryItems.first.id;
      final journalId = controller.journalEntries.first.id;
      final calendarId = controller.calendarItems.first.id;
      final recipeId = controller.recipeRescues.first.id;

      await controller.deleteTaskById(taskId);
      await controller.deleteExpenseById(expenseId);
      await controller.deletePantryItemById(pantryId);
      await controller.deleteJournalEntryById(journalId);
      await controller.deleteCalendarItemById(calendarId);
      await controller.deleteRecipeRescueById(recipeId);

      expect(controller.tasks.any((task) => task.id == taskId), isFalse);
      expect(
        controller.expenses.any((expense) => expense.id == expenseId),
        isFalse,
      );
      expect(
        controller.pantryItems.any((item) => item.id == pantryId),
        isFalse,
      );
      expect(
        controller.journalEntries.any((entry) => entry.id == journalId),
        isFalse,
      );
      expect(
        controller.calendarItems.any((item) => item.id == calendarId),
        isFalse,
      );
      expect(
        controller.recipeRescues.any((recipe) => recipe.id == recipeId),
        isFalse,
      );
      expect(controller.totalEventCount, greaterThan(0));
    });
  });
}
