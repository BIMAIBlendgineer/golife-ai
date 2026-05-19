import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/legal/legal_document_registry.dart';
import 'package:golife_flutter/core/ai_client/ai_gateway_client.dart';
import 'package:golife_flutter/core/export/local_export_service.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_repository.dart';
import 'package:golife_flutter/core/monetization/billing_provider_adapter.dart';
import 'package:golife_flutter/core/monetization/billing_runtime_models.dart';
import 'package:golife_flutter/core/monetization/billing_validation_client.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/runtime/app_runtime_config.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/domains/monetization/billing_audit_entry.dart';
import 'package:golife_flutter/domains/monetization/billing_subscription_state.dart';
import 'package:golife_flutter/domains/monetization/entitlement.dart';
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
  _FakeBillingValidationClient();

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
      message: 'validated',
      validatedAtIso: '2026-05-17T10:01:00Z',
      trace: const <String, Object?>{'mode': 'google_play_sandbox'},
    );
  }
}

Future<void> _expandSettingsSection(
  WidgetTester tester,
  String sectionKey,
) async {
  final finder = find.byKey(ValueKey<String>(sectionKey));
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _scrollToFinder(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
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
    addTearDown(controller.dispose);
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
        home: Scaffold(body: PrivacyScreen(controller: controller)),
      ),
    );

    await _expandSettingsSection(tester, 'settings-section-data-controls');
    final exportFinder =
        find.byKey(const ValueKey<String>('privacy-export-json'));
    await _scrollToFinder(tester, exportFinder);
    await tester.tap(exportFinder);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Protected local export bundle saved as golife_local_export_20260504T103015Z.',
      ),
      findsOneWidget,
    );
    expect(find.text('Clear AI history'), findsOneWidget);
  });

  testWidgets('privacy screen exposes event controls and visible local audit', (
    tester,
  ) async {
    final localStore = MemoryLocalStore();
    final controller = GoLifeController(
      localStore: localStore,
      aiGatewayClient: MockAiGatewayClient(),
      lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      localExportService: _FakeLocalExportService(),
    );
    addTearDown(controller.dispose);
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

    await _expandSettingsSection(tester, 'settings-section-recent-events');
    await _expandSettingsSection(tester, 'settings-section-privacy-audit');

    expect(find.text('Recent LifeGraph events'), findsWidgets);
    expect(find.text('Privacy audit'), findsWidgets);
    expect(find.text('No local privacy audit entries yet.'), findsOneWidget);

    await _scrollToFinder(
      tester,
      find.byKey(ValueKey<String>('life-event-${financeEvent.eventId}')),
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
    expect(
      find.textContaining('Event ID: ${financeEvent.eventId}'),
      findsOneWidget,
    );
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
    addTearDown(controller.dispose);
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
    await _expandSettingsSection(tester, 'settings-section-billing');

    expect(find.text('Plan and billing'), findsWidgets);
    expect(find.text('Feature gates'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('billing-open-decision')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('billing-copy-decision')),
      findsOneWidget,
    );

    final billingDecisionFinder = find.byKey(
      const ValueKey<String>('billing-open-decision'),
    );
    await _scrollToFinder(tester, billingDecisionFinder);
    await tester.tap(billingDecisionFinder);
    await tester.pumpAndSettle();

    expect(openedUrls, <String>[
      GoLifeLegalDocuments.billingDisabledDecisionUrl,
    ]);

    await _expandSettingsSection(tester, 'settings-section-legal');

    expect(find.text('Store and legal'), findsWidgets);
    expect(
      find.byKey(const ValueKey<String>('legal-url-privacy_policy')),
      findsOneWidget,
    );

    final legalPrivacyFinder = find.byKey(
      const ValueKey<String>('legal-open-privacy_policy'),
    );
    await _scrollToFinder(tester, legalPrivacyFinder);
    await tester.tap(legalPrivacyFinder);
    await tester.pumpAndSettle();

    expect(openedUrls, <String>[
      GoLifeLegalDocuments.billingDisabledDecisionUrl,
      GoLifeLegalDocuments.privacyPolicyUrl,
    ]);
  });

  testWidgets('privacy screen shows Google Play sandbox billing controls', (
    tester,
  ) async {
    final localStore = MemoryLocalStore();
    await localStore.saveRuntimeConfig(
      AppRuntimeConfig(
        schemaVersion: 2,
        ttlSeconds: 21600,
        gatewayBaseUrl: 'http://127.0.0.1:8000',
        featureFlags: const <String, bool>{},
        friendlyCopy: const <String, String>{},
        aiStatus: const <String, Object?>{},
        billing: const MobileBillingConfig(
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
          catalog: <BillingCatalogConfig>[
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
    final controller = GoLifeController(
      localStore: localStore,
      aiGatewayClient: MockAiGatewayClient(),
      lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      localExportService: _FakeLocalExportService(),
      billingProviderAdapter: _FakeBillingProviderAdapter(),
      billingValidationClient: _FakeBillingValidationClient(),
    );
    addTearDown(controller.dispose);
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
        home: Scaffold(body: PrivacyScreen(controller: controller)),
      ),
    );

    await tester.pumpAndSettle();
    await _expandSettingsSection(tester, 'settings-section-billing');

    expect(find.text('Sandbox catalog'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('billing-restore-purchases')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('billing-buy-golife_premium_monthly_sandbox'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('privacy screen shows billing refresh and audit after purchase', (
    tester,
  ) async {
    final localStore = MemoryLocalStore();
    await localStore.saveRuntimeConfig(
      AppRuntimeConfig(
        schemaVersion: 2,
        ttlSeconds: 21600,
        gatewayBaseUrl: 'http://127.0.0.1:8000',
        featureFlags: const <String, bool>{},
        friendlyCopy: const <String, String>{},
        aiStatus: const <String, Object?>{},
        billing: const MobileBillingConfig(
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
          catalog: <BillingCatalogConfig>[
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
    await localStore.saveEntitlement(
      Entitlement(
        plan: EntitlementPlan.premium,
        quota: EntitlementQuota.premiumSandboxDefault,
        trialStatus: entitlementTrialStatusNotStarted,
        billingProvider: entitlementBillingProviderGooglePlay,
        renewalState: entitlementRenewalStateActive,
        trace: const <String, Object?>{
          'source_state': 'google_play_validation',
          'verified': true,
          'store_validated': true,
          'sandbox': true,
          'status_code': 'validated',
        },
      ),
    );
    await localStore.saveBillingSubscriptionState(
      BillingSubscriptionState(
        provider: entitlementBillingProviderGooglePlay,
        mode: BillingRuntimeMode.googlePlaySandbox.storageKey,
        packageName: 'ai.golife.mobile',
        productId: 'golife_premium_monthly_sandbox',
        purchaseToken: 'sandbox-token-golife_premium_monthly_sandbox',
        purchaseTokenHash: 'hashed-sandbox-token',
        purchaseId: 'purchase-golife_premium_monthly_sandbox',
        renewalState: entitlementRenewalStateActive,
        statusCode: 'validated',
        sandbox: true,
        verified: true,
        restored: false,
        lastTransactionDateIso: '2026-05-17T10:00:00Z',
        lastValidatedAtIso: '2026-05-17T10:01:00Z',
        trace: const <String, Object?>{
          'mode': 'google_play_sandbox',
          'source_action': 'purchase',
        },
      ),
    );
    await localStore.saveBillingAuditEntries(const <BillingAuditEntry>[
      BillingAuditEntry(
        auditId: 'billing-audit-1',
        createdAtIso: '2026-05-17T10:01:00Z',
        eventType: 'validation_applied',
        provider: entitlementBillingProviderGooglePlay,
        mode: 'google_play_sandbox',
        statusCode: 'validated',
        productId: 'golife_premium_monthly_sandbox',
        purchaseTokenHash: 'hashed-sandbox-token',
        renewalState: entitlementRenewalStateActive,
        sandbox: true,
        verified: true,
        restored: false,
        trace: <String, Object?>{'source_action': 'purchase'},
      ),
    ]);
    final controller = GoLifeController(
      localStore: localStore,
      aiGatewayClient: MockAiGatewayClient(),
      lifeGraphRepository: LifeGraphRepository.seeded(localStore: localStore),
      localExportService: _FakeLocalExportService(),
      billingValidationClient: _FakeBillingValidationClient(),
    );
    addTearDown(controller.dispose);
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
          body: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => PrivacyScreen(controller: controller),
          ),
        ),
      ),
    );

    await tester.pump();
    await _expandSettingsSection(tester, 'settings-section-billing');

    expect(find.text('Billing audit'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('billing-refresh-status')),
      findsOneWidget,
    );
    expect(find.textContaining('validation_applied'), findsWidgets);
    expect(find.text('golife_premium_monthly_sandbox'), findsWidgets);
  });
}
