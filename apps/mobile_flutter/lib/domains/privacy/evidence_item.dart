enum EvidencePrivacyClass {
  localOnly,
  private,
  aiAllowed,
  blocked,
}

extension EvidencePrivacyClassX on EvidencePrivacyClass {
  String get storageKey {
    switch (this) {
      case EvidencePrivacyClass.localOnly:
        return 'local_only';
      case EvidencePrivacyClass.private:
        return 'private';
      case EvidencePrivacyClass.aiAllowed:
        return 'ai_allowed';
      case EvidencePrivacyClass.blocked:
        return 'blocked';
    }
  }
}

EvidencePrivacyClass evidencePrivacyClassFromStorage(String? rawValue) {
  for (final value in EvidencePrivacyClass.values) {
    if (value.storageKey == rawValue) {
      return value;
    }
  }
  return EvidencePrivacyClass.localOnly;
}

class EvidenceItem {
  const EvidenceItem({
    required this.evidenceId,
    required this.sourceType,
    required this.localPayloadRef,
    required this.privacyClass,
    required this.allowedForAi,
    required this.createdAt,
    required this.hash,
  });

  final String evidenceId;
  final String sourceType;
  final String? localPayloadRef;
  final EvidencePrivacyClass privacyClass;
  final bool allowedForAi;
  final String createdAt;
  final String hash;

  Map<String, Object?> toJson() {
    return {
      'evidence_id': evidenceId,
      'source_type': sourceType,
      'local_payload_ref': localPayloadRef,
      'privacy_class': privacyClass.storageKey,
      'allowed_for_ai': allowedForAi,
      'created_at': createdAt,
      'hash': hash,
    };
  }

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      evidenceId: (json['evidence_id'] ?? json['evidenceId'] ?? '').toString(),
      sourceType:
          (json['source_type'] ?? json['sourceType'] ?? 'manual').toString(),
      localPayloadRef:
          (json['local_payload_ref'] ?? json['localPayloadRef'])?.toString(),
      privacyClass: evidencePrivacyClassFromStorage(
        (json['privacy_class'] ?? json['privacyClass'])?.toString(),
      ),
      allowedForAi:
          (json['allowed_for_ai'] ?? json['allowedForAi'] ?? false) == true,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      hash: (json['hash'] ?? '').toString(),
    );
  }
}
