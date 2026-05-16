class LifeGraphRelation {
  const LifeGraphRelation({
    required this.relationId,
    required this.fromEventId,
    required this.toEventId,
    required this.relationType,
    required this.confidence,
    required this.createdAt,
  });

  final String relationId;
  final String fromEventId;
  final String toEventId;
  final String relationType;
  final double confidence;
  final String createdAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'relation_id': relationId,
      'from_event_id': fromEventId,
      'to_event_id': toEventId,
      'relation_type': relationType,
      'confidence': confidence,
      'created_at': createdAt,
    };
  }

  factory LifeGraphRelation.fromJson(Map<String, dynamic> json) {
    return LifeGraphRelation(
      relationId: (json['relation_id'] ?? json['relationId'] ?? '').toString(),
      fromEventId:
          (json['from_event_id'] ?? json['fromEventId'] ?? '').toString(),
      toEventId: (json['to_event_id'] ?? json['toEventId'] ?? '').toString(),
      relationType:
          (json['relation_type'] ?? json['relationType'] ?? '').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
    );
  }
}
