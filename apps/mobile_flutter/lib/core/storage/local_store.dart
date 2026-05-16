import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/homememory/claim_draft.dart';
import '../../domains/homememory/evidence_attachment.dart';
import '../../domains/homememory/maintenance_reminder.dart';
import '../../domains/homememory/owned_item.dart';
import '../../domains/homememory/purchase_proof.dart';
import '../../domains/homememory/warranty_record.dart';
import '../../domains/analytics/analytics_event.dart';
import '../../domains/journal/journal_entry.dart';
import '../../domains/journal/quick_note.dart';
import '../../domains/mindflow/decision_card.dart';
import '../../domains/mindflow/mental_load_item.dart';
import '../../domains/calendar/calendar_item.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/missions/mission_set.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/privacy/evidence_item.dart';
import '../../domains/privacy/privacy_audit_entry.dart';
import '../../domains/recipes/recipe_rescue.dart';
import '../../domains/shopping/product_evidence_card.dart';
import '../../domains/shopping/shopping_need.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';
import '../lifegraph/life_event.dart';
import '../lifegraph/lifegraph_relation.dart';
import '../privacy/privacy_models.dart';
import '../runtime/app_runtime_config.dart';
import '../settings/app_profile_preferences.dart';

abstract class LocalStore {
  Future<PrivacySettings> loadPrivacySettings();
  Future<void> savePrivacySettings(PrivacySettings settings);
  Future<String?> loadLocalePreference() async => null;
  Future<void> saveLocalePreference(String? localeTag) async {}
  Future<AppProfilePreferences> loadProfilePreferences() async =>
      AppProfilePreferences.defaults();
  Future<void> saveProfilePreferences(
    AppProfilePreferences preferences,
  ) async {}
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

  Future<List<MissionSet>> loadMissionSets() async => const <MissionSet>[];
  Future<void> saveMissionSets(List<MissionSet> missionSets) async {}

  Future<List<EvidenceItem>> loadEvidenceItems() async =>
      const <EvidenceItem>[];
  Future<void> saveEvidenceItems(List<EvidenceItem> evidenceItems) async {}

  Future<List<LifeGraphRelation>> loadLifeGraphRelations() async =>
      const <LifeGraphRelation>[];
  Future<void> saveLifeGraphRelations(
    List<LifeGraphRelation> relations,
  ) async {}

  Future<List<PrivacyAuditEntry>> loadPrivacyAuditEntries() async =>
      const <PrivacyAuditEntry>[];
  Future<void> savePrivacyAuditEntries(
    List<PrivacyAuditEntry> entries,
  ) async {}

  Future<List<AnalyticsEvent>> loadAnalyticsEvents() async =>
      const <AnalyticsEvent>[];
  Future<void> saveAnalyticsEvents(List<AnalyticsEvent> events) async {}

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
  Future<List<MentalLoadItem>> loadMentalLoadItems() async =>
      const <MentalLoadItem>[];
  Future<void> saveMentalLoadItems(List<MentalLoadItem> items) async {}
  Future<void> upsertMentalLoadItem(MentalLoadItem item) async {}
  Future<List<DecisionCard>> loadDecisionCards() async =>
      const <DecisionCard>[];
  Future<void> saveDecisionCards(List<DecisionCard> cards) async {}
  Future<void> upsertDecisionCard(DecisionCard card) async {}
  Future<List<ShoppingNeed>> loadShoppingNeeds() async =>
      const <ShoppingNeed>[];
  Future<void> saveShoppingNeeds(List<ShoppingNeed> needs) async {}
  Future<void> upsertShoppingNeed(ShoppingNeed need) async {}
  Future<List<ProductEvidenceCard>> loadProductEvidenceCards() async =>
      const <ProductEvidenceCard>[];
  Future<void> saveProductEvidenceCards(
      List<ProductEvidenceCard> cards) async {}
  Future<void> upsertProductEvidenceCard(ProductEvidenceCard card) async {}

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
  Future<void> deleteTask(String id) async {}
  Future<void> deleteHabit(String id) async {}
  Future<void> deleteExpense(String id) async {}
  Future<void> deletePantryItem(String id) async {}
  Future<void> deletePurchaseIntention(String id) async {}
  Future<void> deleteWeekPlan(String id) async {}
  Future<void> deleteJournalEntry(String id) async {}
  Future<void> deleteQuickNote(String id) async {}
  Future<void> deleteCalendarItem(String id) async {}
  Future<void> deleteRecipeRescue(String id) async {}
  Future<void> deleteMentalLoadItem(String id) async {}
  Future<void> deleteDecisionCard(String id) async {}
  Future<void> deleteShoppingNeed(String id) async {}
  Future<void> deleteProductEvidenceCard(String id) async {}

  Future<void> deleteAllData() async {}
}
