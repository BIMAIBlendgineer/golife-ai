class ActionContract {
  const ActionContract({
    required this.actionType,
    required this.requiresConfirmation,
    required this.destructive,
    required this.external,
    required this.payloadPreview,
    required this.forbiddenActions,
  });

  final String actionType;
  final bool requiresConfirmation;
  final bool destructive;
  final bool external;
  final Map<String, Object?> payloadPreview;
  final List<String> forbiddenActions;

  Map<String, Object?> toJson() {
    return {
      'action_type': actionType,
      'requires_confirmation': requiresConfirmation,
      'destructive': destructive,
      'external': external,
      'payload_preview': payloadPreview,
      'forbidden_actions': forbiddenActions,
    };
  }

  factory ActionContract.fromJson(Map<String, dynamic> json) {
    return ActionContract(
      actionType: (json['action_type'] ?? 'review').toString(),
      requiresConfirmation: json['requires_confirmation'] != false,
      destructive: json['destructive'] == true,
      external: json['external'] == true,
      payloadPreview: Map<String, Object?>.from(
        (json['payload_preview'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
      forbiddenActions:
          ((json['forbidden_actions'] ?? const <Object?>[]) as List)
              .map((item) => item.toString())
              .toList(growable: false),
    );
  }
}
