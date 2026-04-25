class EvidenceAttachmentType {
  static const receipt = 'receipt';
  static const invoice = 'invoice';
  static const manual = 'manual';
  static const photo = 'photo';
  static const warranty = 'warranty';
  static const other = 'other';

  static const values = <String>[
    receipt,
    invoice,
    manual,
    photo,
    warranty,
    other,
  ];

  static String normalize(String? rawValue) {
    if (values.contains(rawValue)) {
      return rawValue!;
    }
    return other;
  }
}

class EvidenceAttachment {
  const EvidenceAttachment({
    required this.id,
    required this.userId,
    required this.ownedItemId,
    this.proofId,
    this.type = EvidenceAttachmentType.other,
    this.fileRef,
    this.description = '',
    this.privacyLevel = 'local_only',
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String ownedItemId;
  final String? proofId;
  final String type;
  final String? fileRef;
  final String description;
  final String privacyLevel;
  final String createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'owned_item_id': ownedItemId,
      'proof_id': proofId,
      'type': type,
      'file_ref': fileRef,
      'description': description,
      'privacy_level': privacyLevel,
      'created_at': createdAt,
    };
  }

  factory EvidenceAttachment.fromJson(Map<String, dynamic> json) {
    return EvidenceAttachment(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 'local-user').toString(),
      ownedItemId:
          (json['owned_item_id'] ?? json['ownedItemId'] ?? '').toString(),
      proofId: (json['proof_id'] ?? json['proofId'])?.toString(),
      type: EvidenceAttachmentType.normalize(
        (json['type'] ?? EvidenceAttachmentType.other).toString(),
      ),
      fileRef: (json['file_ref'] ?? json['fileRef'])?.toString(),
      description: (json['description'] ?? '').toString(),
      privacyLevel:
          (json['privacy_level'] ?? json['privacyLevel'] ?? 'local_only')
              .toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
    );
  }
}
