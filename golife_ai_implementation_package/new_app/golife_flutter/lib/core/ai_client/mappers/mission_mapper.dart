import '../../../domains/missions/daily_mission.dart';
import '../dto/ai_gateway_dto.dart';

DailyMission mapMissionSuggestion(MissionSuggestionDto dto) {
  return DailyMission(
    id: dto.id,
    title: dto.title,
    body: dto.body,
    evidence: dto.evidence,
    uncertainty: dto.uncertainty,
    requiresConfirmation: dto.requiresConfirmation,
    trace: dto.trace,
  );
}
