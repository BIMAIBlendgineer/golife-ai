import 'package:flutter/foundation.dart';

import '../../domains/calendar/calendar_item.dart';
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
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/recipes/recipe_rescue.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import '../runtime/app_runtime_config.dart';
import 'local_store.dart';
import 'memory_local_store.dart';

class ResilientLocalStore implements LocalStore {
  ResilientLocalStore({
    required LocalStore primary,
    LocalStore? fallback,
  })  : _primary = primary,
        _fallback = fallback ?? MemoryLocalStore();

  final LocalStore _primary;
  final LocalStore _fallback;

  bool _usingFallback = false;

  LocalStore get _activeStore => _usingFallback ? _fallback : _primary;

  Future<T> _run<T>(Future<T> Function(LocalStore store) action) async {
    try {
      return await action(_activeStore);
    } catch (error) {
      if (_usingFallback) {
        rethrow;
      }
      _usingFallback = true;
      debugPrint(
        'ResilientLocalStore switched to safe fallback: $error',
      );
      return action(_fallback);
    }
  }

  @override
  Future<PrivacySettings> loadPrivacySettings() =>
      _run((store) => store.loadPrivacySettings());

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) =>
      _run((store) => store.savePrivacySettings(settings));

  @override
  Future<String?> loadLocalePreference() =>
      _run((store) => store.loadLocalePreference());

  @override
  Future<void> saveLocalePreference(String? localeTag) =>
      _run((store) => store.saveLocalePreference(localeTag));

  @override
  Future<bool> loadDemoSeedEnabled() =>
      _run((store) => store.loadDemoSeedEnabled());

  @override
  Future<void> saveDemoSeedEnabled(bool enabled) =>
      _run((store) => store.saveDemoSeedEnabled(enabled));

  @override
  Future<bool> supportsSensitiveLocalEncryption() =>
      _run((store) => store.supportsSensitiveLocalEncryption());

  @override
  Future<List<LifeEvent>> loadLifeEvents() =>
      _run((store) => store.loadLifeEvents());

  @override
  Future<void> saveLifeEvents(List<LifeEvent> events) =>
      _run((store) => store.saveLifeEvents(events));

  @override
  Future<AppRuntimeConfig?> loadRuntimeConfig() =>
      _run((store) => store.loadRuntimeConfig());

  @override
  Future<void> saveRuntimeConfig(AppRuntimeConfig config) =>
      _run((store) => store.saveRuntimeConfig(config));

  @override
  Future<List<MissionFeedback>> loadMissionFeedback() =>
      _run((store) => store.loadMissionFeedback());

  @override
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems) =>
      _run((store) => store.saveMissionFeedback(feedbackItems));

  @override
  Future<List<DailyMission>> loadDailyMissions() =>
      _run((store) => store.loadDailyMissions());

  @override
  Future<void> saveDailyMissions(List<DailyMission> missions) =>
      _run((store) => store.saveDailyMissions(missions));

  @override
  Future<List<DailyRisk>> loadDailyRisks() =>
      _run((store) => store.loadDailyRisks());

  @override
  Future<void> saveDailyRisks(List<DailyRisk> risks) =>
      _run((store) => store.saveDailyRisks(risks));

  @override
  Future<List<GoTask>> loadTasks() => _run((store) => store.loadTasks());

  @override
  Future<List<Habit>> loadHabits() => _run((store) => store.loadHabits());

  @override
  Future<List<ExpenseRecord>> loadExpenses() =>
      _run((store) => store.loadExpenses());

  @override
  Future<List<PantryItem>> loadPantryItems() =>
      _run((store) => store.loadPantryItems());

  @override
  Future<List<PurchaseIntention>> loadPurchaseIntentions() =>
      _run((store) => store.loadPurchaseIntentions());

  @override
  Future<List<WeekPlan>> loadWeekPlans() =>
      _run((store) => store.loadWeekPlans());

  @override
  Future<List<JournalEntry>> loadJournalEntries() =>
      _run((store) => store.loadJournalEntries());

  @override
  Future<List<QuickNote>> loadQuickNotes() =>
      _run((store) => store.loadQuickNotes());

  @override
  Future<List<CalendarItem>> loadCalendarItems() =>
      _run((store) => store.loadCalendarItems());

  @override
  Future<List<RecipeRescue>> loadRecipeRescues() =>
      _run((store) => store.loadRecipeRescues());

  @override
  Future<List<OwnedItem>> loadOwnedItems() =>
      _run((store) => store.loadOwnedItems());

  @override
  Future<List<PurchaseProof>> loadPurchaseProofs() =>
      _run((store) => store.loadPurchaseProofs());

  @override
  Future<List<WarrantyRecord>> loadWarrantyRecords() =>
      _run((store) => store.loadWarrantyRecords());

  @override
  Future<List<MaintenanceReminder>> loadMaintenanceReminders() =>
      _run((store) => store.loadMaintenanceReminders());

  @override
  Future<List<ClaimDraft>> loadClaimDrafts() =>
      _run((store) => store.loadClaimDrafts());

  @override
  Future<List<EvidenceAttachment>> loadEvidenceAttachments() =>
      _run((store) => store.loadEvidenceAttachments());

  @override
  Future<void> upsertTask(GoTask task) =>
      _run((store) => store.upsertTask(task));

  @override
  Future<void> upsertHabit(Habit habit) =>
      _run((store) => store.upsertHabit(habit));

  @override
  Future<void> upsertExpense(ExpenseRecord expense) =>
      _run((store) => store.upsertExpense(expense));

  @override
  Future<void> upsertPantryItem(PantryItem pantryItem) =>
      _run((store) => store.upsertPantryItem(pantryItem));

  @override
  Future<void> upsertPurchaseIntention(
    PurchaseIntention purchaseIntention,
  ) =>
      _run((store) => store.upsertPurchaseIntention(purchaseIntention));

  @override
  Future<void> upsertWeekPlan(WeekPlan weekPlan) =>
      _run((store) => store.upsertWeekPlan(weekPlan));

  @override
  Future<void> upsertJournalEntry(JournalEntry journalEntry) =>
      _run((store) => store.upsertJournalEntry(journalEntry));

  @override
  Future<void> upsertQuickNote(QuickNote quickNote) =>
      _run((store) => store.upsertQuickNote(quickNote));

  @override
  Future<void> upsertCalendarItem(CalendarItem calendarItem) =>
      _run((store) => store.upsertCalendarItem(calendarItem));

  @override
  Future<void> upsertRecipeRescue(RecipeRescue recipeRescue) =>
      _run((store) => store.upsertRecipeRescue(recipeRescue));

  @override
  Future<void> upsertOwnedItem(OwnedItem ownedItem) =>
      _run((store) => store.upsertOwnedItem(ownedItem));

  @override
  Future<void> upsertPurchaseProof(PurchaseProof purchaseProof) =>
      _run((store) => store.upsertPurchaseProof(purchaseProof));

  @override
  Future<void> upsertWarrantyRecord(WarrantyRecord warrantyRecord) =>
      _run((store) => store.upsertWarrantyRecord(warrantyRecord));

  @override
  Future<void> upsertMaintenanceReminder(
    MaintenanceReminder maintenanceReminder,
  ) =>
      _run((store) => store.upsertMaintenanceReminder(maintenanceReminder));

  @override
  Future<void> upsertClaimDraft(ClaimDraft claimDraft) =>
      _run((store) => store.upsertClaimDraft(claimDraft));

  @override
  Future<void> upsertEvidenceAttachment(
    EvidenceAttachment evidenceAttachment,
  ) =>
      _run((store) => store.upsertEvidenceAttachment(evidenceAttachment));

  @override
  Future<void> deleteTask(String id) => _run((store) => store.deleteTask(id));

  @override
  Future<void> deleteHabit(String id) => _run((store) => store.deleteHabit(id));

  @override
  Future<void> deleteExpense(String id) =>
      _run((store) => store.deleteExpense(id));

  @override
  Future<void> deletePantryItem(String id) =>
      _run((store) => store.deletePantryItem(id));

  @override
  Future<void> deletePurchaseIntention(String id) =>
      _run((store) => store.deletePurchaseIntention(id));

  @override
  Future<void> deleteWeekPlan(String id) =>
      _run((store) => store.deleteWeekPlan(id));

  @override
  Future<void> deleteJournalEntry(String id) =>
      _run((store) => store.deleteJournalEntry(id));

  @override
  Future<void> deleteQuickNote(String id) =>
      _run((store) => store.deleteQuickNote(id));

  @override
  Future<void> deleteCalendarItem(String id) =>
      _run((store) => store.deleteCalendarItem(id));

  @override
  Future<void> deleteRecipeRescue(String id) =>
      _run((store) => store.deleteRecipeRescue(id));

  @override
  Future<void> deleteAllData() => _run((store) => store.deleteAllData());
}
