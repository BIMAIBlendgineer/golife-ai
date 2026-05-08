import '../../domains/missions/mission_feedback.dart';
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
import '../../domains/missions/daily_risk.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/recipes/recipe_rescue.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import '../runtime/app_runtime_config.dart';
import '../settings/app_profile_preferences.dart';
import 'local_store.dart';

class MemoryLocalStore implements LocalStore {
  PrivacySettings _settings = PrivacySettings.defaults();
  String? _localePreference;
  AppProfilePreferences _profilePreferences = AppProfilePreferences.defaults();
  bool _demoSeedEnabled = true;
  final List<LifeEvent> _events = <LifeEvent>[];
  final List<MissionFeedback> _feedbackItems = <MissionFeedback>[];
  final List<DailyMission> _missions = <DailyMission>[];
  final List<DailyRisk> _risks = <DailyRisk>[];
  final List<GoTask> _tasks = <GoTask>[];
  final List<Habit> _habits = <Habit>[];
  final List<ExpenseRecord> _expenses = <ExpenseRecord>[];
  final List<PantryItem> _pantryItems = <PantryItem>[];
  final List<PurchaseIntention> _purchaseIntentions = <PurchaseIntention>[];
  final List<WeekPlan> _weekPlans = <WeekPlan>[];
  final List<JournalEntry> _journalEntries = <JournalEntry>[];
  final List<QuickNote> _quickNotes = <QuickNote>[];
  final List<CalendarItem> _calendarItems = <CalendarItem>[];
  final List<RecipeRescue> _recipeRescues = <RecipeRescue>[];
  final List<OwnedItem> _ownedItems = <OwnedItem>[];
  final List<PurchaseProof> _purchaseProofs = <PurchaseProof>[];
  final List<WarrantyRecord> _warrantyRecords = <WarrantyRecord>[];
  final List<MaintenanceReminder> _maintenanceReminders =
      <MaintenanceReminder>[];
  final List<ClaimDraft> _claimDrafts = <ClaimDraft>[];
  final List<EvidenceAttachment> _evidenceAttachments = <EvidenceAttachment>[];
  AppRuntimeConfig? _runtimeConfig;

  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    return _settings;
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    _settings = settings;
  }

  @override
  Future<String?> loadLocalePreference() async {
    return _localePreference;
  }

  @override
  Future<void> saveLocalePreference(String? localeTag) async {
    _localePreference = localeTag;
  }

  @override
  Future<AppProfilePreferences> loadProfilePreferences() async {
    return _profilePreferences;
  }

  @override
  Future<void> saveProfilePreferences(AppProfilePreferences preferences) async {
    _profilePreferences = preferences;
  }

  @override
  Future<bool> loadDemoSeedEnabled() async {
    return _demoSeedEnabled;
  }

  @override
  Future<void> saveDemoSeedEnabled(bool enabled) async {
    _demoSeedEnabled = enabled;
  }

  @override
  Future<bool> supportsSensitiveLocalEncryption() async {
    return false;
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
  Future<AppRuntimeConfig?> loadRuntimeConfig() async {
    return _runtimeConfig;
  }

  @override
  Future<void> saveRuntimeConfig(AppRuntimeConfig config) async {
    _runtimeConfig = config;
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

  @override
  Future<List<DailyMission>> loadDailyMissions() async {
    return List<DailyMission>.unmodifiable(_missions);
  }

  @override
  Future<void> saveDailyMissions(List<DailyMission> missions) async {
    _missions
      ..clear()
      ..addAll(missions);
  }

  @override
  Future<List<DailyRisk>> loadDailyRisks() async {
    return List<DailyRisk>.unmodifiable(_risks);
  }

  @override
  Future<void> saveDailyRisks(List<DailyRisk> risks) async {
    _risks
      ..clear()
      ..addAll(risks);
  }

  @override
  Future<List<GoTask>> loadTasks() async {
    return List<GoTask>.unmodifiable(_tasks);
  }

  @override
  Future<List<Habit>> loadHabits() async {
    return List<Habit>.unmodifiable(_habits);
  }

  @override
  Future<List<ExpenseRecord>> loadExpenses() async {
    return List<ExpenseRecord>.unmodifiable(_expenses);
  }

  @override
  Future<List<PantryItem>> loadPantryItems() async {
    return List<PantryItem>.unmodifiable(_pantryItems);
  }

  @override
  Future<List<PurchaseIntention>> loadPurchaseIntentions() async {
    return List<PurchaseIntention>.unmodifiable(_purchaseIntentions);
  }

  @override
  Future<List<WeekPlan>> loadWeekPlans() async {
    return List<WeekPlan>.unmodifiable(_weekPlans);
  }

  @override
  Future<List<JournalEntry>> loadJournalEntries() async {
    return List<JournalEntry>.unmodifiable(_journalEntries);
  }

  @override
  Future<List<QuickNote>> loadQuickNotes() async {
    return List<QuickNote>.unmodifiable(_quickNotes);
  }

  @override
  Future<List<CalendarItem>> loadCalendarItems() async {
    return List<CalendarItem>.unmodifiable(_calendarItems);
  }

  @override
  Future<List<RecipeRescue>> loadRecipeRescues() async {
    return List<RecipeRescue>.unmodifiable(_recipeRescues);
  }

  @override
  Future<List<OwnedItem>> loadOwnedItems() async {
    return List<OwnedItem>.unmodifiable(_ownedItems);
  }

  @override
  Future<List<PurchaseProof>> loadPurchaseProofs() async {
    return List<PurchaseProof>.unmodifiable(_purchaseProofs);
  }

  @override
  Future<List<WarrantyRecord>> loadWarrantyRecords() async {
    return List<WarrantyRecord>.unmodifiable(_warrantyRecords);
  }

  @override
  Future<List<MaintenanceReminder>> loadMaintenanceReminders() async {
    return List<MaintenanceReminder>.unmodifiable(_maintenanceReminders);
  }

  @override
  Future<List<ClaimDraft>> loadClaimDrafts() async {
    return List<ClaimDraft>.unmodifiable(_claimDrafts);
  }

  @override
  Future<List<EvidenceAttachment>> loadEvidenceAttachments() async {
    return List<EvidenceAttachment>.unmodifiable(_evidenceAttachments);
  }

  @override
  Future<void> upsertTask(GoTask task) async {
    _replaceById(_tasks, task, (item) => item.id);
  }

  @override
  Future<void> upsertHabit(Habit habit) async {
    _replaceById(_habits, habit, (item) => item.id);
  }

  @override
  Future<void> upsertExpense(ExpenseRecord expense) async {
    _replaceById(_expenses, expense, (item) => item.id);
  }

  @override
  Future<void> upsertPantryItem(PantryItem pantryItem) async {
    _replaceById(_pantryItems, pantryItem, (item) => item.id);
  }

  @override
  Future<void> upsertPurchaseIntention(
    PurchaseIntention purchaseIntention,
  ) async {
    _replaceById(
      _purchaseIntentions,
      purchaseIntention,
      (item) => item.id,
    );
  }

  @override
  Future<void> upsertWeekPlan(WeekPlan weekPlan) async {
    _replaceById(_weekPlans, weekPlan, (item) => item.id);
  }

  @override
  Future<void> upsertJournalEntry(JournalEntry journalEntry) async {
    _replaceById(_journalEntries, journalEntry, (item) => item.id);
  }

  @override
  Future<void> upsertQuickNote(QuickNote quickNote) async {
    _replaceById(_quickNotes, quickNote, (item) => item.id);
  }

  @override
  Future<void> upsertCalendarItem(CalendarItem calendarItem) async {
    _replaceById(_calendarItems, calendarItem, (item) => item.id);
  }

  @override
  Future<void> upsertRecipeRescue(RecipeRescue recipeRescue) async {
    _replaceById(_recipeRescues, recipeRescue, (item) => item.id);
  }

  @override
  Future<void> upsertOwnedItem(OwnedItem ownedItem) async {
    _replaceById(_ownedItems, ownedItem, (item) => item.id);
  }

  @override
  Future<void> upsertPurchaseProof(PurchaseProof purchaseProof) async {
    _replaceById(_purchaseProofs, purchaseProof, (item) => item.id);
  }

  @override
  Future<void> upsertWarrantyRecord(WarrantyRecord warrantyRecord) async {
    _replaceById(_warrantyRecords, warrantyRecord, (item) => item.id);
  }

  @override
  Future<void> upsertMaintenanceReminder(
    MaintenanceReminder maintenanceReminder,
  ) async {
    _replaceById(
      _maintenanceReminders,
      maintenanceReminder,
      (item) => item.id,
    );
  }

  @override
  Future<void> upsertClaimDraft(ClaimDraft claimDraft) async {
    _replaceById(_claimDrafts, claimDraft, (item) => item.id);
  }

  @override
  Future<void> upsertEvidenceAttachment(
    EvidenceAttachment evidenceAttachment,
  ) async {
    _replaceById(_evidenceAttachments, evidenceAttachment, (item) => item.id);
  }

  @override
  Future<void> deleteTask(String id) async {
    _removeById(_tasks, id, (item) => item.id);
  }

  @override
  Future<void> deleteHabit(String id) async {
    _removeById(_habits, id, (item) => item.id);
  }

  @override
  Future<void> deleteExpense(String id) async {
    _removeById(_expenses, id, (item) => item.id);
  }

  @override
  Future<void> deletePantryItem(String id) async {
    _removeById(_pantryItems, id, (item) => item.id);
  }

  @override
  Future<void> deletePurchaseIntention(String id) async {
    _removeById(_purchaseIntentions, id, (item) => item.id);
  }

  @override
  Future<void> deleteWeekPlan(String id) async {
    _removeById(_weekPlans, id, (item) => item.id);
  }

  @override
  Future<void> deleteJournalEntry(String id) async {
    _removeById(_journalEntries, id, (item) => item.id);
  }

  @override
  Future<void> deleteQuickNote(String id) async {
    _removeById(_quickNotes, id, (item) => item.id);
  }

  @override
  Future<void> deleteCalendarItem(String id) async {
    _removeById(_calendarItems, id, (item) => item.id);
  }

  @override
  Future<void> deleteRecipeRescue(String id) async {
    _removeById(_recipeRescues, id, (item) => item.id);
  }

  @override
  Future<void> deleteAllData() async {
    _settings = PrivacySettings.defaults();
    _localePreference = null;
    _profilePreferences = AppProfilePreferences.defaults();
    _demoSeedEnabled = false;
    _events.clear();
    _feedbackItems.clear();
    _missions.clear();
    _risks.clear();
    _tasks.clear();
    _habits.clear();
    _expenses.clear();
    _pantryItems.clear();
    _purchaseIntentions.clear();
    _weekPlans.clear();
    _journalEntries.clear();
    _quickNotes.clear();
    _calendarItems.clear();
    _recipeRescues.clear();
    _ownedItems.clear();
    _purchaseProofs.clear();
    _warrantyRecords.clear();
    _maintenanceReminders.clear();
    _claimDrafts.clear();
    _evidenceAttachments.clear();
    _runtimeConfig = null;
  }
}

void _replaceById<T>(
  List<T> items,
  T next,
  String Function(T value) idOf,
) {
  final index = items.indexWhere((item) => idOf(item) == idOf(next));
  if (index >= 0) {
    items[index] = next;
    return;
  }
  items.add(next);
}

void _removeById<T>(
  List<T> items,
  String id,
  String Function(T value) idOf,
) {
  items.removeWhere((item) => idOf(item) == id);
}
