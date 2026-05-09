class PrivacySummary {
  const PrivacySummary({
    required this.aiEnabled,
    required this.sentEventCount,
    required this.blockedEventCount,
    required this.allowedDomains,
    required this.blockedDomains,
    required this.localOnlyCollections,
    required this.trace,
  });

  final bool aiEnabled;
  final int sentEventCount;
  final int blockedEventCount;
  final List<String> allowedDomains;
  final List<String> blockedDomains;
  final List<String> localOnlyCollections;
  final Map<String, Object?> trace;

  Map<String, Object?> toJson() {
    return {
      'ai_enabled': aiEnabled,
      'sent_event_count': sentEventCount,
      'blocked_event_count': blockedEventCount,
      'allowed_domains': allowedDomains,
      'blocked_domains': blockedDomains,
      'local_only_collections': localOnlyCollections,
      'trace': trace,
    };
  }

  factory PrivacySummary.fromJson(Map<String, dynamic> json) {
    return PrivacySummary(
      aiEnabled: json['ai_enabled'] == true,
      sentEventCount: (json['sent_event_count'] as num?)?.toInt() ?? 0,
      blockedEventCount: (json['blocked_event_count'] as num?)?.toInt() ?? 0,
      allowedDomains: ((json['allowed_domains'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      blockedDomains: ((json['blocked_domains'] ?? const <Object?>[]) as List)
          .map((item) => item.toString())
          .toList(growable: false),
      localOnlyCollections:
          ((json['local_only_collections'] ?? const <Object?>[]) as List)
              .map((item) => item.toString())
              .toList(growable: false),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}
