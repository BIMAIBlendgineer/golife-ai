class BillingSubscriptionState {
  const BillingSubscriptionState({
    required this.provider,
    required this.mode,
    required this.packageName,
    required this.productId,
    required this.purchaseToken,
    required this.purchaseTokenHash,
    required this.purchaseId,
    required this.renewalState,
    required this.statusCode,
    required this.sandbox,
    required this.verified,
    required this.restored,
    required this.lastTransactionDateIso,
    required this.lastValidatedAtIso,
    required this.trace,
  });

  final String provider;
  final String mode;
  final String packageName;
  final String productId;
  final String purchaseToken;
  final String purchaseTokenHash;
  final String? purchaseId;
  final String renewalState;
  final String statusCode;
  final bool sandbox;
  final bool verified;
  final bool restored;
  final String? lastTransactionDateIso;
  final String? lastValidatedAtIso;
  final Map<String, Object?> trace;

  BillingSubscriptionState copyWith({
    String? provider,
    String? mode,
    String? packageName,
    String? productId,
    String? purchaseToken,
    String? purchaseTokenHash,
    String? purchaseId,
    String? renewalState,
    String? statusCode,
    bool? sandbox,
    bool? verified,
    bool? restored,
    String? lastTransactionDateIso,
    String? lastValidatedAtIso,
    Map<String, Object?>? trace,
  }) {
    return BillingSubscriptionState(
      provider: provider ?? this.provider,
      mode: mode ?? this.mode,
      packageName: packageName ?? this.packageName,
      productId: productId ?? this.productId,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      purchaseTokenHash: purchaseTokenHash ?? this.purchaseTokenHash,
      purchaseId: purchaseId ?? this.purchaseId,
      renewalState: renewalState ?? this.renewalState,
      statusCode: statusCode ?? this.statusCode,
      sandbox: sandbox ?? this.sandbox,
      verified: verified ?? this.verified,
      restored: restored ?? this.restored,
      lastTransactionDateIso:
          lastTransactionDateIso ?? this.lastTransactionDateIso,
      lastValidatedAtIso: lastValidatedAtIso ?? this.lastValidatedAtIso,
      trace: trace ?? this.trace,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'provider': provider,
      'mode': mode,
      'package_name': packageName,
      'product_id': productId,
      'purchase_token': purchaseToken,
      'purchase_token_hash': purchaseTokenHash,
      'purchase_id': purchaseId,
      'renewal_state': renewalState,
      'status_code': statusCode,
      'sandbox': sandbox,
      'verified': verified,
      'restored': restored,
      'last_transaction_date_iso': lastTransactionDateIso,
      'last_validated_at_iso': lastValidatedAtIso,
      'trace': trace,
    };
  }

  Map<String, Object?> toExportJson() {
    return <String, Object?>{
      'provider': provider,
      'mode': mode,
      'package_name': packageName,
      'product_id': productId,
      'purchase_token_hash': purchaseTokenHash,
      'purchase_token_redacted': true,
      'purchase_id': purchaseId,
      'renewal_state': renewalState,
      'status_code': statusCode,
      'sandbox': sandbox,
      'verified': verified,
      'restored': restored,
      'last_transaction_date_iso': lastTransactionDateIso,
      'last_validated_at_iso': lastValidatedAtIso,
      'trace': trace,
    };
  }

  factory BillingSubscriptionState.fromJson(Map<String, dynamic> json) {
    return BillingSubscriptionState(
      provider: (json['provider'] ?? 'disabled').toString(),
      mode: (json['mode'] ?? 'disabled').toString(),
      packageName:
          (json['package_name'] ?? json['packageName'] ?? '').toString(),
      productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
      purchaseToken:
          (json['purchase_token'] ?? json['purchaseToken'] ?? '').toString(),
      purchaseTokenHash:
          (json['purchase_token_hash'] ?? json['purchaseTokenHash'] ?? '')
              .toString(),
      purchaseId: (json['purchase_id'] ?? json['purchaseId'])?.toString(),
      renewalState:
          (json['renewal_state'] ?? json['renewalState'] ?? 'disabled')
              .toString(),
      statusCode:
          (json['status_code'] ?? json['statusCode'] ?? 'unknown').toString(),
      sandbox: json['sandbox'] == true,
      verified: json['verified'] == true,
      restored: json['restored'] == true,
      lastTransactionDateIso:
          (json['last_transaction_date_iso'] ?? json['lastTransactionDateIso'])
              ?.toString(),
      lastValidatedAtIso:
          (json['last_validated_at_iso'] ?? json['lastValidatedAtIso'])
              ?.toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
    );
  }
}
