import '../../domains/missions/mission_feedback.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';

abstract class LocalStore {
  Future<PrivacySettings> loadPrivacySettings();
  Future<void> savePrivacySettings(PrivacySettings settings);

  Future<List<LifeEvent>> loadLifeEvents();
  Future<void> saveLifeEvents(List<LifeEvent> events);

  Future<List<MissionFeedback>> loadMissionFeedback();
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems);
}
