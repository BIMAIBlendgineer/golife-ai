import '../../domains/monetization/entitlement.dart';

enum BillingRuntimeMode {
  disabled,
  googlePlaySandbox,
  googlePlayLive,
}

extension BillingRuntimeModeX on BillingRuntimeMode {
  String get storageKey {
    switch (this) {
      case BillingRuntimeMode.disabled:
        return 'disabled';
      case BillingRuntimeMode.googlePlaySandbox:
        return 'google_play_sandbox';
      case BillingRuntimeMode.googlePlayLive:
        return 'google_play_live';
    }
  }
}

BillingRuntimeMode billingRuntimeModeFromStorage(String? rawValue) {
  for (final value in BillingRuntimeMode.values) {
    if (value.storageKey == rawValue) {
      return value;
    }
  }
  return BillingRuntimeMode.disabled;
}

class BillingCatalogConfig {
  const BillingCatalogConfig({
    required this.productId,
    required this.plan,
    required this.title,
    required this.description,
  });

  final String productId;
  final EntitlementPlan plan;
  final String title;
  final String description;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'product_id': productId,
      'plan': plan.storageKey,
      'title': title,
      'description': description,
    };
  }

  factory BillingCatalogConfig.fromJson(Map<String, dynamic> json) {
    return BillingCatalogConfig(
      productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
      plan: entitlementPlanFromStorage(json['plan']?.toString()),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

class MobileBillingConfig {
  const MobileBillingConfig({
    required this.enabled,
    required this.provider,
    required this.mode,
    required this.sandboxOnly,
    required this.productionPurchasesEnabled,
    required this.restorePurchases,
    required this.packageName,
    required this.validationPath,
    required this.decisionDocumentUrl,
    required this.publicMessage,
    required this.catalog,
  });

  final bool enabled;
  final String provider;
  final BillingRuntimeMode mode;
  final bool sandboxOnly;
  final bool productionPurchasesEnabled;
  final bool restorePurchases;
  final String? packageName;
  final String validationPath;
  final String decisionDocumentUrl;
  final String publicMessage;
  final List<BillingCatalogConfig> catalog;

  factory MobileBillingConfig.disabledDefault() {
    return const MobileBillingConfig(
      enabled: false,
      provider: entitlementBillingProviderDisabled,
      mode: BillingRuntimeMode.disabled,
      sandboxOnly: false,
      productionPurchasesEnabled: false,
      restorePurchases: false,
      packageName: null,
      validationPath: '/public/mobile/billing/google-play/validate',
      decisionDocumentUrl:
          'https://github.com/BIMAIBlendgineer/golife-ai/blob/main/docs/operations/BILLING_DISABLED_DECISION.md',
      publicMessage:
          'Billing remains disabled in this release. Export and delete stay available.',
      catalog: <BillingCatalogConfig>[],
    );
  }

  Set<String> get productIds => catalog.map((item) => item.productId).toSet();

  Map<String, EntitlementPlan> get planByProductId {
    final mapping = <String, EntitlementPlan>{};
    for (final item in catalog) {
      mapping[item.productId] = item.plan;
    }
    return mapping;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'enabled': enabled,
      'provider': provider,
      'mode': mode.storageKey,
      'sandbox_only': sandboxOnly,
      'production_purchases_enabled': productionPurchasesEnabled,
      'restore_purchases': restorePurchases,
      'package_name': packageName,
      'validation_path': validationPath,
      'decision_document_url': decisionDocumentUrl,
      'public_message': publicMessage,
      'catalog': catalog.map((item) => item.toJson()).toList(growable: false),
    };
  }

  factory MobileBillingConfig.fromJson(Map<String, dynamic> json) {
    final rawCatalog = json['catalog'];
    return MobileBillingConfig(
      enabled: json['enabled'] == true,
      provider:
          (json['provider'] ?? entitlementBillingProviderDisabled).toString(),
      mode: billingRuntimeModeFromStorage(
        (json['mode'] ?? json['billing_mode'])?.toString(),
      ),
      sandboxOnly: json['sandbox_only'] == true || json['sandboxOnly'] == true,
      productionPurchasesEnabled:
          json['production_purchases_enabled'] == true ||
              json['productionPurchasesEnabled'] == true,
      restorePurchases:
          json['restore_purchases'] == true || json['restorePurchases'] == true,
      packageName: (json['package_name'] ?? json['packageName'])?.toString(),
      validationPath: (json['validation_path'] ??
              json['validationPath'] ??
              '/public/mobile/billing/google-play/validate')
          .toString(),
      decisionDocumentUrl: (json['decision_document_url'] ??
              json['decisionDocumentUrl'] ??
              MobileBillingConfig.disabledDefault().decisionDocumentUrl)
          .toString(),
      publicMessage: (json['public_message'] ??
              json['publicMessage'] ??
              MobileBillingConfig.disabledDefault().publicMessage)
          .toString(),
      catalog: rawCatalog is List
          ? rawCatalog
              .whereType<Map>()
              .map((item) => BillingCatalogConfig.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((item) => item.productId.isNotEmpty)
              .toList(growable: false)
          : const <BillingCatalogConfig>[],
    );
  }
}

class BillingCatalogItem {
  const BillingCatalogItem({
    required this.productId,
    required this.plan,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.trace,
  });

  final String productId;
  final EntitlementPlan plan;
  final String title;
  final String description;
  final String priceLabel;
  final Map<String, Object?> trace;
}

class BillingRuntimeState {
  const BillingRuntimeState({
    required this.config,
    required this.catalog,
    required this.available,
    required this.statusCode,
    required this.statusMessage,
    required this.lastValidatedAtIso,
    required this.lastValidatedProductId,
    required this.trace,
  });

  final MobileBillingConfig config;
  final List<BillingCatalogItem> catalog;
  final bool available;
  final String statusCode;
  final String statusMessage;
  final String? lastValidatedAtIso;
  final String? lastValidatedProductId;
  final Map<String, Object?> trace;

  factory BillingRuntimeState.disabledDefault({
    MobileBillingConfig? config,
    String statusCode = 'billing_disabled',
    String? statusMessage,
    Map<String, Object?> trace = const <String, Object?>{},
  }) {
    final resolvedConfig = config ?? MobileBillingConfig.disabledDefault();
    return BillingRuntimeState(
      config: resolvedConfig,
      catalog: const <BillingCatalogItem>[],
      available: false,
      statusCode: statusCode,
      statusMessage: statusMessage ?? resolvedConfig.publicMessage,
      lastValidatedAtIso: null,
      lastValidatedProductId: null,
      trace: trace,
    );
  }

  BillingRuntimeState copyWith({
    MobileBillingConfig? config,
    List<BillingCatalogItem>? catalog,
    bool? available,
    String? statusCode,
    String? statusMessage,
    String? lastValidatedAtIso,
    String? lastValidatedProductId,
    Map<String, Object?>? trace,
  }) {
    return BillingRuntimeState(
      config: config ?? this.config,
      catalog: catalog ?? this.catalog,
      available: available ?? this.available,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      lastValidatedAtIso: lastValidatedAtIso ?? this.lastValidatedAtIso,
      lastValidatedProductId:
          lastValidatedProductId ?? this.lastValidatedProductId,
      trace: trace ?? this.trace,
    );
  }
}

class BillingActionResult {
  const BillingActionResult({
    required this.statusCode,
    required this.message,
    this.productId,
  });

  final String statusCode;
  final String message;
  final String? productId;

  bool get succeeded =>
      statusCode == 'purchase_started' || statusCode == 'restore_started';
}

class BillingPurchaseUpdate {
  const BillingPurchaseUpdate({
    required this.productId,
    required this.purchaseToken,
    required this.purchaseId,
    required this.transactionDateIso,
    required this.statusCode,
    required this.restored,
    required this.pendingCompletePurchase,
    required this.trace,
    required this.rawHandle,
    this.errorCode,
    this.errorMessage,
  });

  final String productId;
  final String purchaseToken;
  final String? purchaseId;
  final String? transactionDateIso;
  final String statusCode;
  final bool restored;
  final bool pendingCompletePurchase;
  final Map<String, Object?> trace;
  final Object rawHandle;
  final String? errorCode;
  final String? errorMessage;
}

class BillingValidationDecision {
  const BillingValidationDecision({
    required this.verified,
    required this.plan,
    required this.quota,
    required this.billingProvider,
    required this.renewalState,
    required this.sandbox,
    required this.statusCode,
    required this.message,
    required this.validatedAtIso,
    required this.trace,
  });

  final bool verified;
  final EntitlementPlan plan;
  final EntitlementQuota quota;
  final String billingProvider;
  final String renewalState;
  final bool sandbox;
  final String statusCode;
  final String message;
  final String validatedAtIso;
  final Map<String, Object?> trace;

  factory BillingValidationDecision.fromJson(Map<String, dynamic> json) {
    return BillingValidationDecision(
      verified: json['verified'] == true,
      plan: entitlementPlanFromStorage(json['plan']?.toString()),
      quota: EntitlementQuota.fromJson(
        Map<String, dynamic>.from(
          (json['quota'] as Map?)?.cast<String, Object?>() ?? const {},
        ),
      ),
      billingProvider:
          (json['billing_provider'] ?? entitlementBillingProviderDisabled)
              .toString(),
      renewalState:
          (json['renewal_state'] ?? entitlementRenewalStateDisabled).toString(),
      sandbox: json['sandbox'] == true,
      statusCode: (json['status_code'] ?? 'validation_unknown').toString(),
      message: (json['message'] ?? '').toString(),
      validatedAtIso: (json['validated_at_iso'] ?? '').toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
    );
  }
}
