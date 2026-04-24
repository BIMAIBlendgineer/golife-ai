import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import '../runtime/app_runtime_config.dart';
import 'local_store.dart';

class SharedPrefsLocalStore implements LocalStore {
  const SharedPrefsLocalStore();

  static const _privacyKey = 'golife.privacy_settings';
  static const _lifeEventsKey = 'golife.life_events';
  static const _missionFeedbackKey = 'golife.mission_feedback';
  static const _missionsKey = 'golife.missions';
  static const _risksKey = 'golife.daily_risks';
  static const _tasksKey = 'golife.tasks';
  static const _habitsKey = 'golife.habits';
  static const _expensesKey = 'golife.expenses';
  static const _pantryItemsKey = 'golife.pantry_items';
  static const _purchaseIntentionsKey = 'golife.purchase_intentions';
  static const _weekPlansKey = 'golife.week_plans';
  static const _runtimeConfigKey = 'golife.runtime_config';

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
    return _loadList(
      _lifeEventsKey,
      (item) => LifeEvent.fromJson(item),
    );
  }

  @override
  Future<void> saveLifeEvents(List<LifeEvent> events) async {
    await _saveList(
      _lifeEventsKey,
      events.map((event) => event.toJson()).toList(growable: false),
    );
  }

  @override
  Future<AppRuntimeConfig?> loadRuntimeConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_runtimeConfigKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }
    return AppRuntimeConfig.fromJson(
      Map<String, dynamic>.from(jsonDecode(rawJson) as Map),
    );
  }

  @override
  Future<void> saveRuntimeConfig(AppRuntimeConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_runtimeConfigKey, jsonEncode(config.toJson()));
  }

  @override
  Future<List<MissionFeedback>> loadMissionFeedback() async {
    return _loadList(
      _missionFeedbackKey,
      (item) => MissionFeedback.fromJson(item),
    );
  }

  @override
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems) async {
    await _saveList(
      _missionFeedbackKey,
      feedbackItems
          .map((feedback) => feedback.toJson())
          .toList(growable: false),
    );
  }

  @override
  Future<List<DailyMission>> loadDailyMissions() async {
    return _loadList(
      _missionsKey,
      (item) => DailyMission.fromJson(item),
    );
  }

  @override
  Future<void> saveDailyMissions(List<DailyMission> missions) async {
    await _saveList(
      _missionsKey,
      missions.map((item) => item.toJson()).toList(growable: false),
    );
  }

  @override
  Future<List<DailyRisk>> loadDailyRisks() async {
    return _loadList(
      _risksKey,
      (item) => DailyRisk.fromJson(item),
    );
  }

  @override
  Future<void> saveDailyRisks(List<DailyRisk> risks) async {
    await _saveList(
      _risksKey,
      risks.map((item) => item.toJson()).toList(growable: false),
    );
  }

  @override
  Future<List<GoTask>> loadTasks() async {
    return _loadList(
      _tasksKey,
      (item) => GoTask.fromJson(item),
    );
  }

  @override
  Future<List<Habit>> loadHabits() async {
    return _loadList(
      _habitsKey,
      (item) => Habit.fromJson(item),
    );
  }

  @override
  Future<List<ExpenseRecord>> loadExpenses() async {
    return _loadList(
      _expensesKey,
      (item) => ExpenseRecord.fromJson(item),
    );
  }

  @override
  Future<List<PantryItem>> loadPantryItems() async {
    return _loadList(
      _pantryItemsKey,
      (item) => PantryItem.fromJson(item),
    );
  }

  @override
  Future<List<PurchaseIntention>> loadPurchaseIntentions() async {
    return _loadList(
      _purchaseIntentionsKey,
      (item) => PurchaseIntention.fromJson(item),
    );
  }

  @override
  Future<List<WeekPlan>> loadWeekPlans() async {
    return _loadList(
      _weekPlansKey,
      (item) => WeekPlan.fromJson(item),
    );
  }

  @override
  Future<void> upsertTask(GoTask task) async {
    await _upsertEntity(_tasksKey, task.id, task.toJson());
  }

  @override
  Future<void> upsertHabit(Habit habit) async {
    await _upsertEntity(_habitsKey, habit.id, habit.toJson());
  }

  @override
  Future<void> upsertExpense(ExpenseRecord expense) async {
    await _upsertEntity(_expensesKey, expense.id, expense.toJson());
  }

  @override
  Future<void> upsertPantryItem(PantryItem pantryItem) async {
    await _upsertEntity(_pantryItemsKey, pantryItem.id, pantryItem.toJson());
  }

  @override
  Future<void> upsertPurchaseIntention(
    PurchaseIntention purchaseIntention,
  ) async {
    await _upsertEntity(
      _purchaseIntentionsKey,
      purchaseIntention.id,
      purchaseIntention.toJson(),
    );
  }

  @override
  Future<void> upsertWeekPlan(WeekPlan weekPlan) async {
    await _upsertEntity(_weekPlansKey, weekPlan.id, weekPlan.toJson());
  }

  Future<List<T>> _loadList<T>(
    String key,
    T Function(Map<String, dynamic> item) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(key);
    if (rawJson == null || rawJson.isEmpty) {
      return <T>[];
    }

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> _saveList(
    String key,
    List<Map<String, Object?>> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }

  Future<void> _upsertEntity(
    String key,
    String id,
    Map<String, Object?> entity,
  ) async {
    final existing = await _loadList<Map<String, dynamic>>(
      key,
      (item) => item,
    );
    final mutable = existing.map(Map<String, dynamic>.from).toList(growable: true);
    final index = mutable.indexWhere((item) => item['id']?.toString() == id);
    if (index >= 0) {
      mutable[index] = Map<String, dynamic>.from(entity);
    } else {
      mutable.add(Map<String, dynamic>.from(entity));
    }
    await _saveList(
      key,
      mutable
          .map((item) => Map<String, Object?>.from(item))
          .toList(growable: false),
    );
  }
}
