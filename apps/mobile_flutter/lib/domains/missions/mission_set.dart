import 'daily_mission.dart';

enum MissionSourceState {
  live,
  fallback,
  offline,
  local,
  degraded,
}

extension MissionSourceStateX on MissionSourceState {
  String get storageKey {
    switch (this) {
      case MissionSourceState.live:
        return 'live';
      case MissionSourceState.fallback:
        return 'fallback';
      case MissionSourceState.offline:
        return 'offline';
      case MissionSourceState.local:
        return 'local';
      case MissionSourceState.degraded:
        return 'degraded';
    }
  }
}

MissionSourceState missionSourceStateFromStorage(String? rawValue) {
  for (final value in MissionSourceState.values) {
    if (value.storageKey == rawValue) {
      return value;
    }
  }
  return MissionSourceState.local;
}

class MissionSet {
  const MissionSet({
    required this.missionSetId,
    required this.date,
    required this.sourceState,
    required this.missions,
    required this.rankingTrace,
    required this.createdAt,
  });

  final String missionSetId;
  final String date;
  final MissionSourceState sourceState;
  final List<DailyMission> missions;
  final Map<String, Object?> rankingTrace;
  final String createdAt;

  Map<String, Object?> toJson() {
    return {
      'mission_set_id': missionSetId,
      'date': date,
      'source_state': sourceState.storageKey,
      'missions': missions.map((item) => item.toJson()).toList(growable: false),
      'ranking_trace': rankingTrace,
      'created_at': createdAt,
    };
  }

  factory MissionSet.fromJson(Map<String, dynamic> json) {
    final rawRankingTrace = json['ranking_trace'] ?? json['rankingTrace'];
    return MissionSet(
      missionSetId:
          (json['mission_set_id'] ?? json['missionSetId'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      sourceState: missionSourceStateFromStorage(
        (json['source_state'] ?? json['sourceState'])?.toString(),
      ),
      missions: ((json['missions'] ?? const <Object?>[]) as List)
          .whereType<Map>()
          .map(
            (item) => DailyMission.fromJson(
              Map<String, dynamic>.from(item.cast<String, Object?>()),
            ),
          )
          .toList(growable: false),
      rankingTrace: Map<String, Object?>.from(
        (rawRankingTrace as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{},
      ),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? json['date'] ?? '')
          .toString(),
    );
  }
}
