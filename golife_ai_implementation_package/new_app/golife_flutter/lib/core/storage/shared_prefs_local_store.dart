import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domains/missions/mission_feedback.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import 'local_store.dart';

class SharedPrefsLocalStore implements LocalStore {
  const SharedPrefsLocalStore();

  static const _privacyKey = 'golife.privacy_settings';
  static const _lifeEventsKey = 'golife.life_events';
  static const _missionFeedbackKey = 'golife.mission_feedback';

  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_privacyKey);
    if (rawJson == null || rawJson.isEmpty) {
      return PrivacySettings.defaults();
    }

    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return PrivacySettings.fromJson(decoded);
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_privacyKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<List<LifeEvent>> loadLifeEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_lifeEventsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return const <LifeEvent>[];
    }

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => LifeEvent.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> saveLifeEvents(List<LifeEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lifeEventsKey,
      jsonEncode(events.map((event) => event.toJson()).toList(growable: false)),
    );
  }

  @override
  Future<List<MissionFeedback>> loadMissionFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_missionFeedbackKey);
    if (rawJson == null || rawJson.isEmpty) {
      return const <MissionFeedback>[];
    }

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map(
          (item) => MissionFeedback.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _missionFeedbackKey,
      jsonEncode(
        feedbackItems
            .map((feedback) => feedback.toJson())
            .toList(growable: false),
      ),
    );
  }
}
