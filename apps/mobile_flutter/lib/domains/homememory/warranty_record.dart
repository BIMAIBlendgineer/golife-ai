class WarrantySource {
  static const explicit = 'explicit';
  static const estimated = 'estimated';
  static const unknown = 'unknown';

  static const values = <String>[explicit, estimated, unknown];

  static String normalize(String? rawValue) {
    if (values.contains(rawValue)) {
      return rawValue!;
    }
    return unknown;
  }
}

class WarrantyRecord {
  const WarrantyRecord({
    required this.id,
    required this.userId,
    required this.ownedItemId,
    this.warrantyUntil,
    this.warrantySource = WarrantySource.unknown,
    this.warrantyMonths,
    this.disclaimer = '',
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String ownedItemId;
  final String? warrantyUntil;
  final String warrantySource;
  final int? warrantyMonths;
  final String disclaimer;
  final String createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'owned_item_id': ownedItemId,
      'warranty_until': warrantyUntil,
      'warranty_source': warrantySource,
      'warranty_months': warrantyMonths,
      'disclaimer': disclaimer,
      'created_at': createdAt,
    };
  }

  factory WarrantyRecord.fromJson(Map<String, dynamic> json) {
    return WarrantyRecord(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 'local-user').toString(),
      ownedItemId:
          (json['owned_item_id'] ?? json['ownedItemId'] ?? '').toString(),
      warrantyUntil:
          (json['warranty_until'] ?? json['warrantyUntil'])?.toString(),
      warrantySource: WarrantySource.normalize(
        (json['warranty_source'] ?? json['warrantySource'])?.toString(),
      ),
      warrantyMonths:
          ((json['warranty_months'] ?? json['warrantyMonths']) as num?)
              ?.toInt(),
      disclaimer: (json['disclaimer'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
    );
  }
}
