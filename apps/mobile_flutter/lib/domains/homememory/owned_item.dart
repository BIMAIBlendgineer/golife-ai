import 'warranty_record.dart';

class OwnedItem {
  const OwnedItem({
    required this.id,
    required this.userId,
    required this.name,
    this.brand = '',
    this.model = '',
    this.serialNumber = '',
    this.category = 'general',
    this.purchaseDate,
    this.purchasePrice,
    this.currency = 'EUR',
    this.store = '',
    this.warrantyUntil,
    this.warrantySource = WarrantySource.unknown,
    this.proofIds = const <String>[],
    this.maintenanceReminderIds = const <String>[],
    this.claimDraftIds = const <String>[],
    this.notes = '',
    this.privacyLevel = 'local_only',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String brand;
  final String model;
  final String serialNumber;
  final String category;
  final String? purchaseDate;
  final double? purchasePrice;
  final String currency;
  final String store;
  final String? warrantyUntil;
  final String warrantySource;
  final List<String> proofIds;
  final List<String> maintenanceReminderIds;
  final List<String> claimDraftIds;
  final String notes;
  final String privacyLevel;
  final String createdAt;
  final String updatedAt;

  String get displayName {
    final base = name.trim();
    if (base.isNotEmpty) {
      return base;
    }
    final composed = [brand.trim(), model.trim()]
        .where((value) => value.isNotEmpty)
        .join(' ');
    return composed.isNotEmpty ? composed : 'Owned item';
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'category': category,
      'purchase_date': purchaseDate,
      'purchase_price': purchasePrice,
      'currency': currency,
      'store': store,
      'warranty_until': warrantyUntil,
      'warranty_source': warrantySource,
      'proof_ids': proofIds,
      'maintenance_reminder_ids': maintenanceReminderIds,
      'claim_draft_ids': claimDraftIds,
      'notes': notes,
      'privacy_level': privacyLevel,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory OwnedItem.fromJson(Map<String, dynamic> json) {
    return OwnedItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 'local-user').toString(),
      name: (json['name'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      serialNumber:
          (json['serial_number'] ?? json['serialNumber'] ?? '').toString(),
      category: (json['category'] ?? 'general').toString(),
      purchaseDate: (json['purchase_date'] ?? json['purchaseDate'])?.toString(),
      purchasePrice: ((json['purchase_price'] ?? json['purchasePrice']) as num?)
          ?.toDouble(),
      currency: (json['currency'] ?? 'EUR').toString(),
      store: (json['store'] ?? '').toString(),
      warrantyUntil:
          (json['warranty_until'] ?? json['warrantyUntil'])?.toString(),
      warrantySource: WarrantySource.normalize(
        (json['warranty_source'] ?? json['warrantySource'])?.toString(),
      ),
      proofIds: ((json['proof_ids'] ?? json['proofIds']) as List?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[],
      maintenanceReminderIds: ((json['maintenance_reminder_ids'] ??
                  json['maintenanceReminderIds']) as List?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[],
      claimDraftIds:
          ((json['claim_draft_ids'] ?? json['claimDraftIds']) as List?)
                  ?.map((item) => item.toString())
                  .toList(growable: false) ??
              const <String>[],
      notes: (json['notes'] ?? '').toString(),
      privacyLevel:
          (json['privacy_level'] ?? json['privacyLevel'] ?? 'local_only')
              .toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
    );
  }
}
