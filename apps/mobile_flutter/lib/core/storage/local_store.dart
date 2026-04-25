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

abstract class LocalStore {
  Future<PrivacySettings> loadPrivacySettings();
  Future<void> savePrivacySettings(PrivacySettings settings);
  Future<String?> loadLocalePreference() async => null;
  Future<void> saveLocalePreference(String? localeTag) async {}
  Future<bool> loadDemoSeedEnabled() async => true;
  Future<void> saveDemoSeedEnabled(bool enabled) async {}
  Future<bool> supportsSensitiveLocalEncryption() async => false;

  Future<List<LifeEvent>> loadLifeEvents();
  Future<void> saveLifeEvents(List<LifeEvent> events);

  Future<AppRuntimeConfig?> loadRuntimeConfig() async => null;
  Future<void> saveRuntimeConfig(AppRuntimeConfig config) async {}

  Future<List<MissionFeedback>> loadMissionFeedback();
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems);

  Future<List<DailyMission>> loadDailyMissions() async =>
      const <DailyMission>[];
  Future<void> saveDailyMissions(List<DailyMission> missions) async {}

  Future<List<DailyRisk>> loadDailyRisks() async => const <DailyRisk>[];
  Future<void> saveDailyRisks(List<DailyRisk> risks) async {}

  Future<List<GoTask>> loadTasks() async => const <GoTask>[];
  Future<List<Habit>> loadHabits() async => const <Habit>[];
  Future<List<ExpenseRecord>> loadExpenses() async => const <ExpenseRecord>[];
  Future<List<PantryItem>> loadPantryItems() async => const <PantryItem>[];
  Future<List<PurchaseIntention>> loadPurchaseIntentions() async =>
      const <PurchaseIntention>[];
  Future<List<WeekPlan>> loadWeekPlans() async => const <WeekPlan>[];
  Future<List<JournalEntry>> loadJournalEntries() async =>
      const <JournalEntry>[];
  Future<List<QuickNote>> loadQuickNotes() async => const <QuickNote>[];
  Future<List<CalendarItem>> loadCalendarItems() async =>
      const <CalendarItem>[];
  Future<List<RecipeRescue>> loadRecipeRescues() async =>
      const <RecipeRescue>[];
  Future<List<OwnedItem>> loadOwnedItems() async => const <OwnedItem>[];
  Future<List<PurchaseProof>> loadPurchaseProofs() async =>
      const <PurchaseProof>[];
  Future<List<WarrantyRecord>> loadWarrantyRecords() async =>
      const <WarrantyRecord>[];
  Future<List<MaintenanceReminder>> loadMaintenanceReminders() async =>
      const <MaintenanceReminder>[];
  Future<List<ClaimDraft>> loadClaimDrafts() async => const <ClaimDraft>[];
  Future<List<EvidenceAttachment>> loadEvidenceAttachments() async =>
      const <EvidenceAttachment>[];

  Future<void> upsertTask(GoTask task) async {}
  Future<void> upsertHabit(Habit habit) async {}
  Future<void> upsertExpense(ExpenseRecord expense) async {}
  Future<void> upsertPantryItem(PantryItem pantryItem) async {}
  Future<void> upsertPurchaseIntention(
      PurchaseIntention purchaseIntention) async {}
  Future<void> upsertWeekPlan(WeekPlan weekPlan) async {}
  Future<void> upsertJournalEntry(JournalEntry journalEntry) async {}
  Future<void> upsertQuickNote(QuickNote quickNote) async {}
  Future<void> upsertCalendarItem(CalendarItem calendarItem) async {}
  Future<void> upsertRecipeRescue(RecipeRescue recipeRescue) async {}
  Future<void> upsertOwnedItem(OwnedItem ownedItem) async {}
  Future<void> upsertPurchaseProof(PurchaseProof purchaseProof) async {}
  Future<void> upsertWarrantyRecord(WarrantyRecord warrantyRecord) async {}
  Future<void> upsertMaintenanceReminder(
    MaintenanceReminder maintenanceReminder,
  ) async {}
  Future<void> upsertClaimDraft(ClaimDraft claimDraft) async {}
  Future<void> upsertEvidenceAttachment(
    EvidenceAttachment evidenceAttachment,
  ) async {}

  Future<void> deleteAllData() async {}
}
