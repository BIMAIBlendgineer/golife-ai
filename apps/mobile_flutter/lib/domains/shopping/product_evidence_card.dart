class ProductEvidenceCard {
  const ProductEvidenceCard({
    required this.id,
    required this.userId,
    required this.productName,
    required this.brand,
    required this.merchantName,
    required this.price,
    required this.currency,
    required this.source,
    required this.checkedAtIso,
    required this.reviewSummary,
    required this.sustainabilityStatus,
    required this.confidence,
    required this.disclaimer,
    required this.trace,
  });

  final String id;
  final String userId;
  final String productName;
  final String? brand;
  final String? merchantName;
  final double? price;
  final String? currency;
  final String? source;
  final String? checkedAtIso;
  final String? reviewSummary;
  final String sustainabilityStatus;
  final double confidence;
  final String disclaimer;
  final Map<String, Object?> trace;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_name': productName,
      'brand': brand,
      'merchant_name': merchantName,
      'price': price,
      'currency': currency,
      'source': source,
      'checked_at_iso': checkedAtIso,
      'review_summary': reviewSummary,
      'sustainability_status': sustainabilityStatus,
      'confidence': confidence,
      'disclaimer': disclaimer,
      'trace': trace,
    };
  }

  factory ProductEvidenceCard.fromJson(Map<String, dynamic> json) {
    return ProductEvidenceCard(
      id: (json['id'] ?? '${json['product_name'] ?? 'evidence'}').toString(),
      userId: (json['user_id'] ?? 'local-user').toString(),
      productName: (json['product_name'] ?? '').toString(),
      brand: json['brand']?.toString(),
      merchantName: json['merchant_name']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      source: json['source']?.toString(),
      checkedAtIso:
          (json['checked_at_iso'] ?? json['checked_at'])?.toString(),
      reviewSummary: json['review_summary']?.toString(),
      sustainabilityStatus:
          (json['sustainability_status'] ?? 'not_checked').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      disclaimer: (json['disclaimer'] ?? '').toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}
