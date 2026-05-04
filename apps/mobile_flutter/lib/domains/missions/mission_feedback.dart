enum MissionFeedbackStatus {
  useful,
  rejected,
  accepted,
  completed,
  edited,
}

enum MissionRejectionReasonCategory {
  tooHard,
  notRelevant,
  notNow,
  privacy,
  tooGeneric,
  alreadyDone,
  unknown,
}

extension MissionRejectionReasonCategoryX on MissionRejectionReasonCategory {
  String get storageKey {
    switch (this) {
      case MissionRejectionReasonCategory.tooHard:
        return 'too_hard';
      case MissionRejectionReasonCategory.notRelevant:
        return 'not_relevant';
      case MissionRejectionReasonCategory.notNow:
        return 'not_now';
      case MissionRejectionReasonCategory.privacy:
        return 'privacy';
      case MissionRejectionReasonCategory.tooGeneric:
        return 'too_generic';
      case MissionRejectionReasonCategory.alreadyDone:
        return 'already_done';
      case MissionRejectionReasonCategory.unknown:
        return 'unknown';
    }
  }
}

enum MissionEffortFeedback {
  low,
  balanced,
  high,
  unknown,
}

extension MissionEffortFeedbackX on MissionEffortFeedback {
  String get storageKey {
    switch (this) {
      case MissionEffortFeedback.low:
        return 'low';
      case MissionEffortFeedback.balanced:
        return 'balanced';
      case MissionEffortFeedback.high:
        return 'high';
      case MissionEffortFeedback.unknown:
        return 'unknown';
    }
  }
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
    this.rejectionReasonCategory,
    this.effortFeedback,
    this.repeatedFlag = false,
    this.trace = const <String, Object?>{},
  });

  final String id;
  final String missionId;
  final MissionFeedbackStatus status;
  final String createdAtIso;
  final List<String> domainTargets;
  final String? recommendationType;
  final String? notes;
  final MissionRejectionReasonCategory? rejectionReasonCategory;
  final MissionEffortFeedback? effortFeedback;
  final bool repeatedFlag;
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
      'rejection_reason_category': rejectionReasonCategory?.storageKey,
      'effort_feedback': effortFeedback?.storageKey,
      'repeated_flag': repeatedFlag,
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
      domainTargets:
          ((json['domain_targets'] ?? json['domainTargets']) as List?)
                  ?.map((item) => item.toString())
                  .toList(growable: false) ??
              const <String>[],
      recommendationType:
          (json['recommendation_type'] ?? json['recommendationType'])
              ?.toString(),
      notes: json['notes']?.toString(),
      rejectionReasonCategory: _rejectionReasonFromKey(
        json['rejection_reason_category']?.toString(),
      ),
      effortFeedback:
          _effortFeedbackFromKey(json['effort_feedback']?.toString()),
      repeatedFlag: json['repeated_flag'] == true,
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

MissionRejectionReasonCategory? _rejectionReasonFromKey(String? rawValue) {
  for (final reason in MissionRejectionReasonCategory.values) {
    if (reason.storageKey == rawValue) {
      return reason;
    }
  }
  return null;
}

MissionEffortFeedback? _effortFeedbackFromKey(String? rawValue) {
  for (final effort in MissionEffortFeedback.values) {
    if (effort.storageKey == rawValue) {
      return effort;
    }
  }
  return null;
}
