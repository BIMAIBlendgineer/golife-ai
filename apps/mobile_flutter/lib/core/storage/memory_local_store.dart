import '../../domains/missions/mission_feedback.dart';
import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
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
import 'local_store.dart';

class MemoryLocalStore implements LocalStore {
  PrivacySettings _settings = PrivacySettings.defaults();
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
  Future<void> deleteAllData() async {
    _settings = PrivacySettings.defaults();
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
