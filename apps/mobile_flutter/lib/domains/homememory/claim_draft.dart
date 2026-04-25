class ClaimDraftStatus {
  static const draft = 'draft';
  static const sentOutsideApp = 'sent_outside_app';
  static const archived = 'archived';

  static const values = <String>[draft, sentOutsideApp, archived];

  static String normalize(String? rawValue) {
    if (values.contains(rawValue)) {
      return rawValue!;
    }
    return draft;
  }
}

class ClaimDraft {
  const ClaimDraft({
    required this.id,
    required this.userId,
    required this.ownedItemId,
    required this.title,
    required this.issueDescription,
    required this.generatedMessage,
    this.recipientHint = '',
    this.status = ClaimDraftStatus.draft,
    this.disclaimer = '',
    this.privacyLevel = 'local_only',
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String ownedItemId;
  final String title;
  final String issueDescription;
  final String generatedMessage;
  final String recipientHint;
  final String status;
  final String disclaimer;
  final String privacyLevel;
  final String createdAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'owned_item_id': ownedItemId,
      'title': title,
      'issue_description': issueDescription,
      'generated_message': generatedMessage,
      'recipient_hint': recipientHint,
      'status': status,
      'disclaimer': disclaimer,
      'privacy_level': privacyLevel,
      'created_at': createdAt,
    };
  }

  factory ClaimDraft.fromJson(Map<String, dynamic> json) {
    return ClaimDraft(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 'local-user').toString(),
      ownedItemId:
          (json['owned_item_id'] ?? json['ownedItemId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      issueDescription:
          (json['issue_description'] ?? json['issueDescription'] ?? '')
              .toString(),
      generatedMessage:
          (json['generated_message'] ?? json['generatedMessage'] ?? '')
              .toString(),
      recipientHint:
          (json['recipient_hint'] ?? json['recipientHint'] ?? '').toString(),
      status: ClaimDraftStatus.normalize((json['status'] ?? '').toString()),
      disclaimer: (json['disclaimer'] ?? '').toString(),
      privacyLevel:
          (json['privacy_level'] ?? json['privacyLevel'] ?? 'local_only')
              .toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
    );
  }
}
