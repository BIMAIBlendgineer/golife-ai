enum MissionFeedbackStatus {
  useful,
  rejected,
  accepted,
  completed,
  edited,
}

extension MissionFeedbackStatusX on MissionFeedbackStatus {
  String get storageKey {
    switch (this) {
      case MissionFeedbackStatus.useful:
        return 'useful';
      case MissionFeedbackStatus.rejected:
        return 'rejected';
      case MissionFeedbackStatus.accepted:
        return 'accepted';
      case MissionFeedbackStatus.completed:
        return 'completed';
      case MissionFeedbackStatus.edited:
        return 'edited';
    }
  }

  String get label {
    switch (this) {
      case MissionFeedbackStatus.useful:
        return 'Useful';
      case MissionFeedbackStatus.rejected:
        return 'Rejected';
      case MissionFeedbackStatus.accepted:
        return 'Accepted';
      case MissionFeedbackStatus.completed:
        return 'Completed';
      case MissionFeedbackStatus.edited:
        return 'Edited';
    }
  }
}

class MissionFeedback {
  const MissionFeedback({
    required this.id,
    required this.missionId,
    required this.status,
    required this.createdAtIso,
    this.domainTargets = const <String>[],
    this.recommendationType,
    this.notes,
    this.trace = const <String, Object?>{},
  });

  final String id;
  final String missionId;
  final MissionFeedbackStatus status;
  final String createdAtIso;
  final List<String> domainTargets;
  final String? recommendationType;
  final String? notes;
  final Map<String, Object?> trace;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'mission_id': missionId,
      'status': status.storageKey,
      'created_at': createdAtIso,
      'domain_targets': domainTargets,
      'recommendation_type': recommendationType,
      'notes': notes,
      'trace': trace,
    };
  }

  factory MissionFeedback.fromJson(Map<String, dynamic> json) {
    return MissionFeedback(
      id: (json['id'] ?? '').toString(),
      missionId: (json['mission_id'] ?? json['missionId'] ?? '').toString(),
      status: _statusFromKey((json['status'] ?? 'useful').toString()),
      createdAtIso:
          (json['created_at'] ?? json['createdAtIso'] ?? '').toString(),
      domainTargets: ((json['domain_targets'] ?? json['domainTargets']) as List?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[],
      recommendationType:
          (json['recommendation_type'] ?? json['recommendationType'])
              ?.toString(),
      notes: json['notes']?.toString(),
      trace: Map<String, Object?>.from(
        (json['trace'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }
}

MissionFeedbackStatus _statusFromKey(String rawValue) {
  for (final status in MissionFeedbackStatus.values) {
    if (status.storageKey == rawValue) {
      return status;
    }
  }
  return MissionFeedbackStatus.useful;
}
