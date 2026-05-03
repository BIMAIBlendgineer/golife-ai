import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/homememory/claim_draft.dart';
import '../../domains/homememory/evidence_attachment.dart';
import '../../domains/homememory/maintenance_reminder.dart';
import '../../domains/homememory/owned_item.dart';
import '../../domains/homememory/purchase_proof.dart';
import '../../domains/homememory/warranty_record.dart';
import '../../domains/journal/journal_entry.dart';
import '../../domains/journal/quick_note.dart';
import '../../domains/calendar/calendar_item.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/recipes/recipe_rescue.dart';
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
  static const _localePreferenceKey = 'golife.locale_preference';
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
  static const _journalEntriesKey = 'golife.journal_entries';
  static const _quickNotesKey = 'golife.quick_notes';
  static const _calendarItemsKey = 'golife.calendar_items';
  static const _recipeRescuesKey = 'golife.recipe_rescues';
  static const _ownedItemsKey = 'golife.owned_items';
  static const _purchaseProofsKey = 'golife.purchase_proofs';
  static const _warrantyRecordsKey = 'golife.warranty_records';
  static const _maintenanceRemindersKey = 'golife.maintenance_reminders';
  static const _claimDraftsKey = 'golife.claim_drafts';
  static const _evidenceAttachmentsKey = 'golife.evidence_attachments';
  static const _runtimeConfigKey = 'golife.runtime_config';
  static const _demoSeedEnabledKey = 'golife.demo_seed_enabled';

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
  Future<String?> loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localePreferenceKey);
  }

  @override
  Future<void> saveLocalePreference(String? localeTag) async {
    final prefs = await SharedPreferences.getInstance();
    if (localeTag == null) {
      await prefs.remove(_localePreferenceKey);
      return;
    }
    await prefs.setString(_localePreferenceKey, localeTag);
  }

  @override
  Future<bool> loadDemoSeedEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_demoSeedEnabledKey) ?? true;
  }

  @override
  Future<void> saveDemoSeedEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoSeedEnabledKey, enabled);
  }

  @override
  Future<bool> supportsSensitiveLocalEncryption() async {
    return false;
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
  Future<List<JournalEntry>> loadJournalEntries() async {
    return _loadList(
      _journalEntriesKey,
      (item) => JournalEntry.fromJson(item),
    );
  }

  @override
  Future<List<QuickNote>> loadQuickNotes() async {
    return _loadList(
      _quickNotesKey,
      (item) => QuickNote.fromJson(item),
    );
  }

  @override
  Future<List<CalendarItem>> loadCalendarItems() async {
    return _loadList(
      _calendarItemsKey,
      (item) => CalendarItem.fromJson(item),
    );
  }

  @override
  Future<List<RecipeRescue>> loadRecipeRescues() async {
    return _loadList(
      _recipeRescuesKey,
      (item) => RecipeRescue.fromJson(item),
    );
  }

  @override
  Future<List<OwnedItem>> loadOwnedItems() async {
    return _loadList(
      _ownedItemsKey,
      (item) => OwnedItem.fromJson(item),
    );
  }

  @override
  Future<List<PurchaseProof>> loadPurchaseProofs() async {
    return _loadList(
      _purchaseProofsKey,
      (item) => PurchaseProof.fromJson(item),
    );
  }

  @override
  Future<List<WarrantyRecord>> loadWarrantyRecords() async {
    return _loadList(
      _warrantyRecordsKey,
      (item) => WarrantyRecord.fromJson(item),
    );
  }

  @override
  Future<List<MaintenanceReminder>> loadMaintenanceReminders() async {
    return _loadList(
      _maintenanceRemindersKey,
      (item) => MaintenanceReminder.fromJson(item),
    );
  }

  @override
  Future<List<ClaimDraft>> loadClaimDrafts() async {
    return _loadList(
      _claimDraftsKey,
      (item) => ClaimDraft.fromJson(item),
    );
  }

  @override
  Future<List<EvidenceAttachment>> loadEvidenceAttachments() async {
    return _loadList(
      _evidenceAttachmentsKey,
      (item) => EvidenceAttachment.fromJson(item),
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

  @override
  Future<void> upsertJournalEntry(JournalEntry journalEntry) async {
    await _upsertEntity(
      _journalEntriesKey,
      journalEntry.id,
      journalEntry.toJson(),
    );
  }

  @override
  Future<void> upsertQuickNote(QuickNote quickNote) async {
    await _upsertEntity(_quickNotesKey, quickNote.id, quickNote.toJson());
  }

  @override
  Future<void> upsertCalendarItem(CalendarItem calendarItem) async {
    await _upsertEntity(
      _calendarItemsKey,
      calendarItem.id,
      calendarItem.toJson(),
    );
  }

  @override
  Future<void> upsertRecipeRescue(RecipeRescue recipeRescue) async {
    await _upsertEntity(
      _recipeRescuesKey,
      recipeRescue.id,
      recipeRescue.toJson(),
    );
  }

  @override
  Future<void> upsertOwnedItem(OwnedItem ownedItem) async {
    await _upsertEntity(_ownedItemsKey, ownedItem.id, ownedItem.toJson());
  }

  @override
  Future<void> upsertPurchaseProof(PurchaseProof purchaseProof) async {
    await _upsertEntity(
      _purchaseProofsKey,
      purchaseProof.id,
      purchaseProof.toJson(),
    );
  }

  @override
  Future<void> upsertWarrantyRecord(WarrantyRecord warrantyRecord) async {
    await _upsertEntity(
      _warrantyRecordsKey,
      warrantyRecord.id,
      warrantyRecord.toJson(),
    );
  }

  @override
  Future<void> upsertMaintenanceReminder(
    MaintenanceReminder maintenanceReminder,
  ) async {
    await _upsertEntity(
      _maintenanceRemindersKey,
      maintenanceReminder.id,
      maintenanceReminder.toJson(),
    );
  }

  @override
  Future<void> upsertClaimDraft(ClaimDraft claimDraft) async {
    await _upsertEntity(_claimDraftsKey, claimDraft.id, claimDraft.toJson());
  }

  @override
  Future<void> upsertEvidenceAttachment(
    EvidenceAttachment evidenceAttachment,
  ) async {
    await _upsertEntity(
      _evidenceAttachmentsKey,
      evidenceAttachment.id,
      evidenceAttachment.toJson(),
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    await _deleteEntity(_tasksKey, id);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _deleteEntity(_habitsKey, id);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _deleteEntity(_expensesKey, id);
  }

  @override
  Future<void> deletePantryItem(String id) async {
    await _deleteEntity(_pantryItemsKey, id);
  }

  @override
  Future<void> deletePurchaseIntention(String id) async {
    await _deleteEntity(_purchaseIntentionsKey, id);
  }

  @override
  Future<void> deleteWeekPlan(String id) async {
    await _deleteEntity(_weekPlansKey, id);
  }

  @override
  Future<void> deleteJournalEntry(String id) async {
    await _deleteEntity(_journalEntriesKey, id);
  }

  @override
  Future<void> deleteQuickNote(String id) async {
    await _deleteEntity(_quickNotesKey, id);
  }

  @override
  Future<void> deleteCalendarItem(String id) async {
    await _deleteEntity(_calendarItemsKey, id);
  }

  @override
  Future<void> deleteRecipeRescue(String id) async {
    await _deleteEntity(_recipeRescuesKey, id);
  }

  @override
  Future<void> deleteAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privacyKey);
    await prefs.remove(_localePreferenceKey);
    await prefs.remove(_lifeEventsKey);
    await prefs.remove(_missionFeedbackKey);
    await prefs.remove(_missionsKey);
    await prefs.remove(_risksKey);
    await prefs.remove(_tasksKey);
    await prefs.remove(_habitsKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_pantryItemsKey);
    await prefs.remove(_purchaseIntentionsKey);
    await prefs.remove(_weekPlansKey);
    await prefs.remove(_journalEntriesKey);
    await prefs.remove(_quickNotesKey);
    await prefs.remove(_calendarItemsKey);
    await prefs.remove(_recipeRescuesKey);
    await prefs.remove(_ownedItemsKey);
    await prefs.remove(_purchaseProofsKey);
    await prefs.remove(_warrantyRecordsKey);
    await prefs.remove(_maintenanceRemindersKey);
    await prefs.remove(_claimDraftsKey);
    await prefs.remove(_evidenceAttachmentsKey);
    await prefs.remove(_runtimeConfigKey);
    await prefs.setBool(_demoSeedEnabledKey, false);
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
    final mutable =
        existing.map(Map<String, dynamic>.from).toList(growable: true);
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

  Future<void> _deleteEntity(String key, String id) async {
    final existing = await _loadList<Map<String, dynamic>>(
      key,
      (item) => item,
    );
    final filtered = existing
        .where((item) => item['id']?.toString() != id)
        .map((item) => Map<String, Object?>.from(item))
        .toList(growable: false);
    await _saveList(key, filtered);
  }
}
