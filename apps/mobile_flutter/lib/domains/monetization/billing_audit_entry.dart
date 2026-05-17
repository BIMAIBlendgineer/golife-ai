class BillingAuditEntry {
  const BillingAuditEntry({
    required this.auditId,
    required this.createdAtIso,
    required this.eventType,
    required this.provider,
    required this.mode,
    required this.statusCode,
    required this.productId,
    required this.purchaseTokenHash,
    required this.renewalState,
    required this.sandbox,
    required this.verified,
    required this.restored,
    required this.trace,
  });

  final String auditId;
  final String createdAtIso;
  final String eventType;
  final String provider;
  final String mode;
  final String statusCode;
  final String? productId;
  final String? purchaseTokenHash;
  final String renewalState;
  final bool sandbox;
  final bool verified;
  final bool restored;
  final Map<String, Object?> trace;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'audit_id': auditId,
      'created_at_iso': createdAtIso,
      'event_type': eventType,
      'provider': provider,
      'mode': mode,
      'status_code': statusCode,
      'product_id': productId,
      'purchase_token_hash': purchaseTokenHash,
      'renewal_state': renewalState,
      'sandbox': sandbox,
      'verified': verified,
      'restored': restored,
      'trace': trace,
    };
  }

  factory BillingAuditEntry.fromJson(Map<String, dynamic> json) {
    return BillingAuditEntry(
      auditId: (json['audit_id'] ?? json['auditId'] ?? '').toString(),
      createdAtIso:
          (json['created_at_iso'] ?? json['createdAtIso'] ?? '').toString(),
      eventType:
          (json['event_type'] ?? json['eventType'] ?? 'unknown').toString(),
      provider: (json['provider'] ?? 'disabled').toString(),
      mode: (json['mode'] ?? 'disabled').toString(),
      statusCode:
          (json['status_code'] ?? json['statusCode'] ?? 'unknown').toString(),
      productId: (json['product_id'] ?? json['productId'])?.toString(),
      purchaseTokenHash:
          (json['purchase_token_hash'] ?? json['purchaseTokenHash'])
              ?.toString(),
      renewalState:
          (json['renewal_state'] ?? json['renewalState'] ?? 'disabled')
              .toString(),
      sandbox: json['sandbox'] == true,
      verified: json['verified'] == true,
      restored: json['restored'] == true,
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
    );
  }
}
