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

abstract class LocalStore {
  Future<PrivacySettings> loadPrivacySettings();
  Future<void> savePrivacySettings(PrivacySettings settings);

  Future<List<LifeEvent>> loadLifeEvents();
  Future<void> saveLifeEvents(List<LifeEvent> events);

  Future<List<MissionFeedback>> loadMissionFeedback();
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems);

  Future<List<DailyMission>> loadDailyMissions() async => const <DailyMission>[];
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

  Future<void> upsertTask(GoTask task) async {}
  Future<void> upsertHabit(Habit habit) async {}
  Future<void> upsertExpense(ExpenseRecord expense) async {}
  Future<void> upsertPantryItem(PantryItem pantryItem) async {}
  Future<void> upsertPurchaseIntention(PurchaseIntention purchaseIntention) async {}
  Future<void> upsertWeekPlan(WeekPlan weekPlan) async {}
}
