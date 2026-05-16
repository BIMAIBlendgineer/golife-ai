class PrivacyAuditEntry {
  const PrivacyAuditEntry({
    required this.auditId,
    required this.eventId,
    required this.oldPrivacyLevel,
    required this.newPrivacyLevel,
    required this.changedAt,
  });

  final String auditId;
  final String eventId;
  final String oldPrivacyLevel;
  final String newPrivacyLevel;
  final String changedAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'audit_id': auditId,
      'event_id': eventId,
      'old_privacy_level': oldPrivacyLevel,
      'new_privacy_level': newPrivacyLevel,
      'changed_at': changedAt,
    };
  }

  factory PrivacyAuditEntry.fromJson(Map<String, dynamic> json) {
    return PrivacyAuditEntry(
      auditId: (json['audit_id'] ?? json['auditId'] ?? '').toString(),
      eventId: (json['event_id'] ?? json['eventId'] ?? '').toString(),
      oldPrivacyLevel:
          (json['old_privacy_level'] ?? json['oldPrivacyLevel'] ?? 'local_only')
              .toString(),
      newPrivacyLevel:
          (json['new_privacy_level'] ?? json['newPrivacyLevel'] ?? 'local_only')
              .toString(),
      changedAt: (json['changed_at'] ?? json['changedAt'] ?? '').toString(),
    );
  }
}
