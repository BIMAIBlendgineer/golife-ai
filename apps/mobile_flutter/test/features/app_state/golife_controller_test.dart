import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/monetization/billing_provider_adapter.dart';
import 'package:golife_flutter/core/monetization/billing_runtime_models.dart';
import 'package:golife_flutter/core/monetization/billing_validation_client.dart';
import 'package:golife_flutter/core/export/local_export_service.dart';
import 'package:golife_flutter/core/export/submission_asset_vault.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/runtime/app_runtime_config.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/domains/monetization/entitlement.dart';
import 'package:golife_flutter/domains/missions/daily_mission.dart';
import 'package:golife_flutter/domains/tasks/go_task.dart';
import 'package:golife_flutter/features/app_state/golife_controller.dart';
import 'package:path/path.dart' as path;

class _RecordingLocalExportService implements LocalExportService {
  String? lastPayload;
  String? lastBaseFileName;
  List<LocalExportAsset> lastAssets = <LocalExportAsset>[];

  @override
  Future<LocalExportResult> saveExportBundle({
    required String baseFileName,
    required String jsonPayload,
    List<LocalExportAsset> assets = const <LocalExportAsset>[],
  }) async {
    lastBaseFileName = baseFileName;
    lastPayload = jsonPayload;
    lastAssets = List<LocalExportAsset>.from(assets);
    return const LocalExportResult(
      fileName: 'golife_local_export_20260504T100000Z',
      filePath: '/protected/exports/golife_local_export_20260504T100000Z',
      dataFilePath:
          '/protected/exports/golife_local_export_20260504T100000Z/data.json',
      byteCount: 256,
      assetCount: 0,
    );
  }
}

class _StaticSubmissionAssetDirectoryResolver
    implements SubmissionAssetDirectoryResolver {
  const _StaticSubmissionAssetDirectoryResolver(this.path);

  final String path;

  @override
  Future<String> resolveProtectedSubmissionAssetDirectory() async => path;
}

class _StaticExportDirectoryResolver implements ExportDirectoryResolver {
  const _StaticExportDirectoryResolver(this.path);

  final String path;

  @override
  Future<String> resolveProtectedExportDirectory() async => path;
}

class _NoopSubmissionAssetVault implements SubmissionAssetVault {
  @override
  Future<void> clearVault() async {}

  @override
  Future<List<SubmissionAssetManifestEntry>> collectManifestEntries(
    Iterable<String?> storedRefs,
  ) async {
    return storedRefs
        .whereType<String>()
        .map(
          (storedRef) => SubmissionAssetManifestEntry(
            storedRef: storedRef,
            sourcePath: storedRef,
            bundleRelativePath: 'assets/legacy/${path.basename(storedRef)}',
            byteCount: 0,
            available: false,
            sourceKind: 'legacy_metadata_ref',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> deleteStoredAsset(String? storedRef) async {}

  @override
  Future<String?> persistSubmissionAsset({
    required String collection,
    required String entityId,
    String? sourcePath,
  }) async {
    return sourcePath;
  }
}

class _FakeBillingProviderAdapter implements BillingProviderAdapter {
  final StreamController<BillingPurchaseUpdate> _controller =
      StreamController<BillingPurchaseUpdate>.broadcast();

  @override
  Stream<BillingPurchaseUpdate> get purchaseUpdates => _controller.stream;

  @override
  Future<BillingActionResult> initialize() async {
    return const BillingActionResult(
      statusCode: 'store_available',
      message: 'Google Play sandbox available.',
    );
  }

  @override
  Future<List<BillingCatalogItem>> queryCatalog(
    Iterable<BillingCatalogConfig> catalog,
  ) async {
    return catalog
        .map(
          (item) => BillingCatalogItem(
            productId: item.productId,
            plan: item.plan,
            title: item.title,
            description: item.description,
            priceLabel: 'EUR 4.99',
            trace: const <String, Object?>{'provider': 'google_play'},
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<BillingActionResult> buyProduct(String productId) async {
    return BillingActionResult(
      statusCode: 'purchase_started',
      message: 'Sandbox purchase started.',
      productId: productId,
    );
  }

  @override
  Future<BillingActionResult> restorePurchases() async {
    return const BillingActionResult(
      statusCode: 'restore_started',
      message: 'Sandbox restore started.',
    );
  }

  @override
  Future<void> completePurchase(BillingPurchaseUpdate purchase) async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  void emitPurchased(String productId, {bool restored = false}) {
    _controller.add(
      BillingPurchaseUpdate(
        productId: productId,
        purchaseToken: 'sandbox-token-$productId',
        purchaseId: 'purchase-$productId',
        transactionDateIso: '2026-05-17T10:00:00Z',
        statusCode: restored ? 'purchase_restored' : 'purchase_purchased',
        restored: restored,
        pendingCompletePurchase: false,
        trace: const <String, Object?>{'provider': 'google_play'},
        rawHandle: Object(),
      ),
    );
  }
}

class _FakeBillingValidationClient implements BillingValidationClient {
  const _FakeBillingValidationClient();

  @override
  Future<BillingValidationDecision?> validateGooglePlayPurchase({
    required MobileBillingConfig config,
    required BillingPurchaseUpdate purchase,
  }) async {
    return BillingValidationDecision(
      verified: true,
      plan: EntitlementPlan.premium,
      quota: EntitlementQuota.premiumSandboxDefault,
      billingProvider: entitlementBillingProviderGooglePlay,
      renewalState: entitlementRenewalStateActive,
      sandbox: true,
      statusCode: 'validated',
      message: 'Google Play sandbox purchase validated.',
      validatedAtIso: '2026-05-17T10:01:00Z',
      trace: <String, Object?>{
        'mode': config.mode.storageKey,
        'product_id': purchase.productId,
      },
    );
  }
}

void main() {
  group('GoLifeController', () {
    late MemoryLocalStore localStore;
    late GoLifeController controller;
    late _RecordingLocalExportService exportService;

    setUp(() async {
      exportService = _RecordingLocalExportService();
      localStore = MemoryLocalStore();
      controller = GoLifeController(
        localStore: localStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
        localExportService: exportService,
        submissionAssetVault: _NoopSubmissionAssetVault(),
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
        ranking: null,
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
      final fileExport = await controller.exportLocalDataFile();

      expect(decoded['life_events'], isA<List<dynamic>>());
      expect(decoded['tasks'], isA<List<dynamic>>());
      expect(decoded['mission_sets'], isA<List<dynamic>>());
      expect(decoded['analytics_events'], isA<List<dynamic>>());
      expect(decoded['analytics_summary'], isA<Map<String, dynamic>>());
      expect(decoded['entitlement'], isA<Map<String, dynamic>>());
      expect((decoded['mission_sets'] as List<dynamic>), isNotEmpty);
      expect(
        (decoded['analytics_events'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((item) => item['event_name'])
            .contains('export_requested'),
        isTrue,
      );
      expect(fileExport.fileName, 'golife_local_export_20260504T100000Z');
      expect(exportService.lastBaseFileName, 'golife_local_export');
      final exportedFileJson =
          jsonDecode(exportService.lastPayload!) as Map<String, dynamic>;
      expect(exportedFileJson['tasks'], decoded['tasks']);
      expect(exportedFileJson['life_events'], decoded['life_events']);
      expect(exportedFileJson['mission_sets'], decoded['mission_sets']);
      final exportedFileAnalytics =
          (exportedFileJson['analytics_events'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
      final analyticsSummary =
          exportedFileJson['analytics_summary'] as Map<String, dynamic>;
      expect(
        exportedFileAnalytics.length,
        greaterThanOrEqualTo(
          (decoded['analytics_events'] as List<dynamic>).length,
        ),
      );
      expect(
        exportedFileAnalytics
            .map((item) => item['event_name'])
            .contains('export_requested'),
        isTrue,
      );
      expect(analyticsSummary['total_events'], greaterThan(0));

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
      expect(controller.evidenceItems, isNotEmpty);
      expect(
        controller.evidenceItems
            .any((item) => item.sourceType == 'purchase_proof'),
        isTrue,
      );
      expect(controller.lifeGraphRelations, isNotEmpty);
      expect(
        controller.lifeGraphRelations.any(
          (relation) => relation.relationType == 'homememory.proof_attachment',
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

      expect(encryptedCollections, contains('life_events'));
      expect(encryptedCollections, contains('missions'));
      expect(encryptedCollections, contains('daily_risks'));
      expect(encryptedCollections, contains('mission_sets'));
      expect(encryptedCollections, contains('lifegraph_relations'));
      expect(encryptedCollections, contains('calendar_items'));
      expect(encryptedCollections, contains('evidence_items'));
      expect(encryptedCollections, contains('owned_items'));
      expect(encryptedCollections, contains('purchase_proofs'));
      expect(encryptedCollections, contains('claim_drafts'));
      expect(encryptedCollections, contains('evidence_attachments'));
      expect(encryptedCollections, contains('privacy_audit_entries'));
      expect(encryptedCollections, contains('analytics_events'));
      expect(decoded['mission_sets'], isA<List<dynamic>>());
      expect(decoded['evidence_items'], isA<List<dynamic>>());
      expect(decoded['lifegraph_relations'], isA<List<dynamic>>());
    });

    test(
        'stores submission assets in a private vault and exports a recoverable bundle',
        () async {
      final vaultDirectory =
          await Directory.systemTemp.createTemp('golife_controller_vault_');
      final exportDirectory =
          await Directory.systemTemp.createTemp('golife_controller_export_');
      final sourceDirectory =
          await Directory.systemTemp.createTemp('golife_controller_source_');
      addTearDown(() async {
        if (await vaultDirectory.exists()) {
          await vaultDirectory.delete(recursive: true);
        }
        if (await exportDirectory.exists()) {
          await exportDirectory.delete(recursive: true);
        }
        if (await sourceDirectory.exists()) {
          await sourceDirectory.delete(recursive: true);
        }
      });

      final proofSource =
          File(path.join(sourceDirectory.path, 'manual-proof.txt'));
      await proofSource.writeAsString('proof text bytes', flush: true);
      final evidenceSource =
          File(path.join(sourceDirectory.path, 'receipt.jpg'));
      await evidenceSource.writeAsString('receipt image bytes', flush: true);

      final endToEndLocalStore = MemoryLocalStore();
      final endToEndController = GoLifeController(
        localStore: endToEndLocalStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository:
            LifeGraphRepository.seeded(localStore: endToEndLocalStore),
        localExportService: ProtectedLocalExportService(
          directoryResolver: _StaticExportDirectoryResolver(
            exportDirectory.path,
          ),
          now: () => DateTime.utc(2026, 5, 4, 10, 45, 0),
        ),
        submissionAssetVault: ProtectedSubmissionAssetVault(
          directoryResolver: _StaticSubmissionAssetDirectoryResolver(
            vaultDirectory.path,
          ),
        ),
      );
      await endToEndController.bootstrap();

      await endToEndController.saveManualPurchaseProof(
        productName: 'Dyson V8',
        store: 'Amazon',
        purchaseDate: '2026-04-10',
        price: 249.99,
        currency: 'USD',
        notes: 'Keep proof local.',
        fileRef: proofSource.path,
        createWarrantyReminder: false,
      );
      final ownedItem = endToEndController.ownedItems.single;
      final purchaseProof = endToEndController.purchaseProofs.single;

      await endToEndController.saveEvidenceAttachment(
        ownedItemId: ownedItem.id,
        proofId: purchaseProof.id,
        type: 'receipt',
        fileRef: evidenceSource.path,
        description: 'Receipt photo',
        privacyLevel: 'local_only',
      );

      expect(
        purchaseProof.fileRef,
        startsWith(ProtectedSubmissionAssetVault.managedRefPrefix),
      );
      expect(
        endToEndController.evidenceAttachments.single.fileRef,
        startsWith(ProtectedSubmissionAssetVault.managedRefPrefix),
      );

      final exportResult = await endToEndController.exportLocalDataFile();
      final exportPayload = jsonDecode(
        await File(exportResult.dataFilePath).readAsString(),
      ) as Map<String, dynamic>;
      final submissionAssets =
          exportPayload['submission_assets'] as Map<String, dynamic>;
      final entries = (submissionAssets['entries'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(exportResult.fileName, 'golife_local_export_20260504T104500Z');
      expect(exportResult.assetCount, 2);
      expect(submissionAssets['storage_mode'], 'separate_private_files');
      expect(submissionAssets['asset_count'], 2);
      expect(submissionAssets['included_asset_count'], 2);
      expect(entries.every((entry) => entry['available'] == true), isTrue);

      for (final entry in entries) {
        final copiedFile = File(
          path.joinAll(
            <String>[
              exportResult.filePath,
              ...(entry['bundle_path'] as String).split('/'),
            ],
          ),
        );
        expect(await copiedFile.exists(), isTrue);
      }

      await endToEndController.deleteAllLocalData();
      expect(await Directory(vaultDirectory.path).exists(), isFalse);
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

    test('updates event privacy and records a local audit entry', () async {
      final targetEvent = controller.lifeEvents.firstWhere(
        (event) => event.domain == 'finance',
      );

      await controller.updatePermission(
        DomainKey.finance,
        DataPermission.aiAllowed,
      );
      await controller.updateEventPrivacy(
        targetEvent.eventId,
        DataPermission.aiAllowed,
      );

      final updatedEvent = controller.lifeEvents.firstWhere(
        (event) => event.eventId == targetEvent.eventId,
      );

      expect(updatedEvent.privacyLevel, DataPermission.aiAllowed.storageKey);
      expect(controller.privacyAuditEntries, hasLength(1));
      expect(
          controller.privacyAuditEntries.single.eventId, targetEvent.eventId);
      expect(
        controller.analyticsEvents.any(
          (event) => event.eventName == 'privacy_setting_changed',
        ),
        isTrue,
      );
      expect(
        controller.analyticsEvents.any(
          (event) => event.eventName == 'event_privacy_changed',
        ),
        isTrue,
      );
    });

    test('stores metadata-only analytics events without raw capture text',
        () async {
      final rawCapture =
          'Call landlord tomorrow morning and buy coffee for 4.50 before lunch';

      final drafts = await controller.prepareCaptureDrafts(text: rawCapture);
      await controller.captureDrafts(drafts);

      final missionSetEvent = controller.analyticsEvents.firstWhere(
        (event) => event.eventName == 'mission_set_generated',
      );
      final captureEvent = controller.analyticsEvents.firstWhere(
        (event) => event.eventName == 'capture_created',
      );
      final entitlementEvent = controller.analyticsEvents.firstWhere(
        (event) => event.eventName == 'entitlement_loaded',
      );

      final exported = jsonDecode(await controller.exportLocalDataJson())
          as Map<String, dynamic>;
      final analyticsJson = jsonEncode(exported['analytics_events']);

      expect(
        controller.analyticsEvents.any(
          (event) => event.eventName == 'capture_parsed',
        ),
        isTrue,
      );
      expect(
        controller.analyticsEvents.any(
          (event) => event.eventName == 'capture_created',
        ),
        isTrue,
      );
      expect(missionSetEvent.metadata.containsKey('title'), isFalse);
      expect(missionSetEvent.metadata.containsKey('body'), isFalse);
      expect(captureEvent.metadata.containsKey('text'), isFalse);
      expect(captureEvent.metadata.containsKey('payload'), isFalse);
      expect(entitlementEvent.metadata.containsKey('price'), isFalse);
      expect(entitlementEvent.metadata.containsKey('receipt'), isFalse);
      expect(entitlementEvent.metadata.containsKey('purchaseToken'), isFalse);
      expect(analyticsJson, isNot(contains('Call landlord tomorrow morning')));
      expect(analyticsJson, isNot(contains('buy coffee for 4.50')));
    });

    test('validates Google Play sandbox purchases before activating premium',
        () async {
      final sandboxStore = MemoryLocalStore();
      await sandboxStore.saveRuntimeConfig(
        AppRuntimeConfig(
          schemaVersion: 2,
          ttlSeconds: 21600,
          gatewayBaseUrl: 'http://127.0.0.1:8000',
          featureFlags: const <String, bool>{},
          friendlyCopy: const <String, String>{},
          aiStatus: const <String, Object?>{},
          billing: MobileBillingConfig(
            enabled: true,
            provider: entitlementBillingProviderGooglePlay,
            mode: BillingRuntimeMode.googlePlaySandbox,
            sandboxOnly: true,
            productionPurchasesEnabled: false,
            restorePurchases: true,
            packageName: 'ai.golife.mobile',
            validationPath: '/public/mobile/billing/google-play/validate',
            decisionDocumentUrl: 'https://example.test/billing-sandbox',
            publicMessage: 'Sandbox only.',
            catalog: const <BillingCatalogConfig>[
              BillingCatalogConfig(
                productId: 'golife_premium_monthly_sandbox',
                plan: EntitlementPlan.premium,
                title: 'GoLife Premium Sandbox',
                description: 'Sandbox premium plan',
              ),
            ],
          ),
          generatedAtIso: '2026-05-17T10:00:00Z',
        ),
      );
      final fakeAdapter = _FakeBillingProviderAdapter();
      final sandboxController = GoLifeController(
        localStore: sandboxStore,
        aiGatewayClient: MockAiGatewayClient(),
        lifeGraphRepository:
            LifeGraphRepository.seeded(localStore: sandboxStore),
        localExportService: exportService,
        submissionAssetVault: _NoopSubmissionAssetVault(),
        billingProviderAdapter: fakeAdapter,
        billingValidationClient: const _FakeBillingValidationClient(),
      );
      await sandboxController.bootstrap();

      expect(sandboxController.billingRuntimeState.config.enabled, isTrue);
      expect(sandboxController.billingRuntimeState.catalog, hasLength(1));

      final purchaseResult = await sandboxController.buyBillingCatalogProduct(
        'golife_premium_monthly_sandbox',
      );
      expect(purchaseResult.statusCode, 'purchase_started');

      fakeAdapter.emitPurchased('golife_premium_monthly_sandbox');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(sandboxController.entitlement.plan, EntitlementPlan.premium);
      expect(
        sandboxController.entitlement.billingProvider,
        entitlementBillingProviderGooglePlay,
      );
      expect(
        sandboxController.analyticsEvents.any(
          (event) => event.eventName == 'billing_purchase_validation',
        ),
        isTrue,
      );

      final exportedJson = await sandboxController.exportLocalDataJson();
      expect(exportedJson, isNot(contains('sandbox-token')));
    });
  });
}
