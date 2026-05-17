import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

import '../../domains/monetization/billing_audit_entry.dart';
import '../../domains/monetization/billing_subscription_state.dart';
import 'billing_runtime_models.dart';

class SubscriptionStateService {
  const SubscriptionStateService();

  String hashPurchaseToken(String purchaseToken) {
    final digest = crypto.sha256.convert(utf8.encode(purchaseToken));
    return digest.toString();
  }

  BillingSubscriptionState buildState({
    required BillingPurchaseUpdate purchase,
    required BillingValidationDecision decision,
    required MobileBillingConfig config,
  }) {
    return BillingSubscriptionState(
      provider: config.provider,
      mode: config.mode.storageKey,
      packageName: config.packageName ?? '',
      productId: purchase.productId,
      purchaseToken: purchase.purchaseToken,
      purchaseTokenHash: hashPurchaseToken(purchase.purchaseToken),
      purchaseId: purchase.purchaseId,
      renewalState: decision.renewalState,
      statusCode: decision.statusCode,
      sandbox: decision.sandbox,
      verified: decision.verified,
      restored: purchase.restored,
      lastTransactionDateIso: purchase.transactionDateIso,
      lastValidatedAtIso: decision.validatedAtIso,
      trace: <String, Object?>{
        'purchase_status': purchase.statusCode,
        'pending_complete_purchase': purchase.pendingCompletePurchase,
        ...purchase.trace,
        ...decision.trace,
      },
    );
  }

  BillingAuditEntry buildAuditEntry({
    required String auditId,
    required String createdAtIso,
    required String eventType,
    required String provider,
    required String mode,
    required String statusCode,
    required String renewalState,
    required bool sandbox,
    required bool verified,
    required bool restored,
    String? productId,
    String? purchaseToken,
    Map<String, Object?> trace = const <String, Object?>{},
  }) {
    return BillingAuditEntry(
      auditId: auditId,
      createdAtIso: createdAtIso,
      eventType: eventType,
      provider: provider,
      mode: mode,
      statusCode: statusCode,
      productId: productId,
      purchaseTokenHash: purchaseToken == null || purchaseToken.isEmpty
          ? null
          : hashPurchaseToken(purchaseToken),
      renewalState: renewalState,
      sandbox: sandbox,
      verified: verified,
      restored: restored,
      trace: trace,
    );
  }
}
