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
    domainTargets: dto.domainTargets,
    recommendationType: dto.recommendationType,
    confidence: dto.confidence,
    ranking: dto.ranking == null
        ? null
        : MissionRanking(
            impactScore: dto.ranking!.impactScore,
            urgencyScore: dto.ranking!.urgencyScore,
            effortScore: dto.ranking!.effortScore,
            confidenceScore: dto.ranking!.confidenceScore,
            privacyScore: dto.ranking!.privacyScore,
            feedbackScore: dto.ranking!.feedbackScore,
            noveltyScore: dto.ranking!.noveltyScore,
            finalScore: dto.ranking!.finalScore,
            rankingReason: dto.ranking!.rankingReason,
            evidenceRefs: dto.ranking!.evidenceRefs,
          ),
    trace: dto.trace,
  );
}

List<DailyMission> mapMissionPlan(MissionPlanDto dto) {
  return dto.suggestions.map(mapMissionSuggestion).toList(growable: false);
}
