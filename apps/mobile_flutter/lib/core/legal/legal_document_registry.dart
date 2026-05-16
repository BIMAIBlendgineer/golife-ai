enum LegalDocumentId {
  privacyPolicy,
  termsOfService,
  support,
}

extension LegalDocumentIdKey on LegalDocumentId {
  String get storageKey {
    switch (this) {
      case LegalDocumentId.privacyPolicy:
        return 'privacy_policy';
      case LegalDocumentId.termsOfService:
        return 'terms_of_service';
      case LegalDocumentId.support:
        return 'support';
    }
  }
}

class LegalDocumentLink {
  const LegalDocumentLink({
    required this.id,
    required this.url,
  });

  final LegalDocumentId id;
  final String url;
}

abstract final class GoLifeLegalDocuments {
  static const String repositoryUrl =
      'https://github.com/BIMAIBlendgineer/golife-ai';
  static const String issueTrackerUrl =
      'https://github.com/BIMAIBlendgineer/golife-ai/issues';
  static const String _repoBlobBase =
      'https://github.com/BIMAIBlendgineer/golife-ai/blob/main';

  static const String privacyPolicyUrl =
      '$_repoBlobBase/docs/legal/PRIVACY_POLICY.md';
  static const String termsOfServiceUrl =
      '$_repoBlobBase/docs/legal/TERMS_OF_SERVICE.md';
  static const String supportUrl = '$_repoBlobBase/docs/legal/SUPPORT.md';
  static const String billingDisabledDecisionUrl =
      '$_repoBlobBase/docs/operations/BILLING_DISABLED_DECISION.md';
  static const String billingSandboxDecisionUrl =
      '$_repoBlobBase/docs/operations/BILLING_SANDBOX_DECISION.md';

  static const List<LegalDocumentLink> publicLinks = <LegalDocumentLink>[
    LegalDocumentLink(
      id: LegalDocumentId.privacyPolicy,
      url: privacyPolicyUrl,
    ),
    LegalDocumentLink(
      id: LegalDocumentId.termsOfService,
      url: termsOfServiceUrl,
    ),
    LegalDocumentLink(
      id: LegalDocumentId.support,
      url: supportUrl,
    ),
  ];
}
