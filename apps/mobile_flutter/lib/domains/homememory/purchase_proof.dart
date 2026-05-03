class PurchaseProofSourceType {
  static const manualEntry = 'manual_entry';
  static const receiptPhoto = 'receipt_photo';
  static const invoicePdf = 'invoice_pdf';
  static const email = 'email';
  static const screenshot = 'screenshot';

  static const values = <String>[
    manualEntry,
    receiptPhoto,
    invoicePdf,
    email,
    screenshot,
  ];

  static String normalize(String? rawValue) {
    if (values.contains(rawValue)) {
      return rawValue!;
    }
    return manualEntry;
  }
}

class PurchaseProof {
  const PurchaseProof({
    required this.id,
    required this.userId,
    required this.ownedItemId,
    this.sourceType = PurchaseProofSourceType.manualEntry,
    this.merchantName = '',
    this.purchaseDate,
    this.totalAmount,
    this.currency = 'EUR',
    this.rawText = '',
    this.fileRef,
    this.extractedFields = const <String, Object?>{},
    this.privacyLevel = 'local_only',
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String ownedItemId;
  final String sourceType;
  final String merchantName;
  final String? purchaseDate;
  final double? totalAmount;
  final String currency;
  final String rawText;
  final String? fileRef;
  final Map<String, Object?> extractedFields;
  final String privacyLevel;
  final String createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'owned_item_id': ownedItemId,
      'source_type': sourceType,
      'merchant_name': merchantName,
      'purchase_date': purchaseDate,
      'total_amount': totalAmount,
      'currency': currency,
      'raw_text': rawText,
      'file_ref': fileRef,
      'extracted_fields': extractedFields,
      'privacy_level': privacyLevel,
      'created_at': createdAt,
    };
  }

  factory PurchaseProof.fromJson(Map<String, dynamic> json) {
    return PurchaseProof(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 'local-user').toString(),
      ownedItemId:
          (json['owned_item_id'] ?? json['ownedItemId'] ?? '').toString(),
      sourceType: PurchaseProofSourceType.normalize(
        (json['source_type'] ?? json['sourceType'])?.toString(),
      ),
      merchantName:
          (json['merchant_name'] ?? json['merchantName'] ?? '').toString(),
      purchaseDate: (json['purchase_date'] ?? json['purchaseDate'])?.toString(),
      totalAmount:
          ((json['total_amount'] ?? json['totalAmount']) as num?)?.toDouble(),
      currency: (json['currency'] ?? 'EUR').toString(),
      rawText: (json['raw_text'] ?? json['rawText'] ?? '').toString(),
      fileRef: (json['file_ref'] ?? json['fileRef'])?.toString(),
      extractedFields: Map<String, Object?>.from(
        ((json['extracted_fields'] ?? json['extractedFields']) as Map?)
                ?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
      privacyLevel:
          (json['privacy_level'] ?? json['privacyLevel'] ?? 'local_only')
              .toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
    );
  }
}
