import '../../domains/missions/mission_feedback.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import 'local_store.dart';

class MemoryLocalStore implements LocalStore {
  PrivacySettings _settings = PrivacySettings.defaults();
  final List<LifeEvent> _events = <LifeEvent>[];
  final List<MissionFeedback> _feedbackItems = <MissionFeedback>[];

  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    return _settings;
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    _settings = settings;
  }

  @override
  Future<List<LifeEvent>> loadLifeEvents() async {
    return List<LifeEvent>.unmodifiable(_events);
  }

  @override
  Future<void> saveLifeEvents(List<LifeEvent> events) async {
    _events
      ..clear()
      ..addAll(events);
  }

  @override
  Future<List<MissionFeedback>> loadMissionFeedback() async {
    return List<MissionFeedback>.unmodifiable(_feedbackItems);
  }

  @override
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems) async {
    _feedbackItems
      ..clear()
      ..addAll(feedbackItems);
  }
}
