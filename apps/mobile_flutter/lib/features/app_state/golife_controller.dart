import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/ai_client/ai_gateway_client.dart';
import '../../core/ai_client/dto/ai_gateway_dto.dart';
import '../../core/ai_client/mappers/mission_mapper.dart';
import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';
import '../../core/lifegraph/lifegraph_repository.dart';
import '../../core/privacy/privacy_models.dart';
import '../../core/runtime/app_runtime_config.dart';
import '../../core/runtime/runtime_config_client.dart';
import '../../core/storage/local_store.dart';
import '../../domains/calendar/calendar_item.dart';
import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
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
import '../capture/capture_parser.dart';

class GoLifeController extends ChangeNotifier {
  GoLifeController({
    required LocalStore localStore,
    required AiGatewayClient aiGatewayClient,
    required LifeGraphRepository lifeGraphRepository,
    RuntimeConfigClient? runtimeConfigClient,
  })  : _localStore = localStore,
        _aiGatewayClient = aiGatewayClient,
        _lifeGraphRepository = lifeGraphRepository,
        _runtimeConfigClient = runtimeConfigClient;

  final LocalStore _localStore;
  final AiGatewayClient _aiGatewayClient;
  final LifeGraphRepository _lifeGraphRepository;
  final RuntimeConfigClient? _runtimeConfigClient;
  final CaptureParser _captureParser = const CaptureParser();

  bool _isReady = false;
  PrivacySettings _privacySettings = PrivacySettings.defaults();
  List<DailyMission> _dailyMissions = <DailyMission>[];
  List<DailyRisk> _cachedDailyRisks = <DailyRisk>[];
  List<MissionFeedback> _missionFeedback = <MissionFeedback>[];
  AppRuntimeConfig? _runtimeConfig;
  List<GoTask> _tasks = <GoTask>[];
  List<Habit> _habits = <Habit>[];
  List<ExpenseRecord> _expenses = <ExpenseRecord>[];
  List<PantryItem> _pantryItems = <PantryItem>[];
  List<PurchaseIntention> _purchaseIntentions = <PurchaseIntention>[];
  List<WeekPlan> _weekPlans = <WeekPlan>[];
  List<JournalEntry> _journalEntries = <JournalEntry>[];
  List<QuickNote> _quickNotes = <QuickNote>[];
  List<CalendarItem> _calendarItems = <CalendarItem>[];
  List<RecipeRescue> _recipeRescues = <RecipeRescue>[];

  final GoTask criticalTask = const GoTask(
    id: 'task-rent-receipt',
    title: 'Submit rent receipt',
    estimatedMinutes: 12,
    priority: TaskPriority.critical,
    status: TaskStatus.active,
    subtasks: <GoSubtask>[
      GoSubtask(id: 'receipt-1', title: 'Find invoice PDF'),
      GoSubtask(id: 'receipt-2', title: 'Forward it to accounting'),
    ],
  );

  final Habit recoveryHabit = const Habit(
    id: 'habit-night-reset',
    title: 'Night reset',
    cue: 'After dinner',
    streak: 4,
    cadence: HabitCadence.daily,
  );

  final WeekPlan weekSummary = const WeekPlan(
    id: 'week-shell',
    theme: 'Ship the shell before polishing',
    colorToken: 'terra',
    days: <DayPlan>[
      DayPlan(
        label: 'Friday',
        focus: 'Friday is scoped for low-friction admin work.',
        recurringAnchors: <String>['Inbox cleanup', 'Calendar reset'],
      ),
    ],
  );

  final ExpenseRecord financeSummary = const ExpenseRecord(
    id: 'expense-coffee-lunch',
    label: 'Food spend drifted upward this week',
    amount: 12.40,
    category: 'food',
  );

  final PantryItem pantrySummary = const PantryItem(
    id: 'pantry-spinach',
    name: 'Spinach and chickpeas can still become dinner',
    quantityLabel: '1 meal base',
    rescueHint: 'Use oldest ingredients first to reduce waste.',
  );

  final PurchaseIntention closetSummary = const PurchaseIntention(
    id: 'purchase-black-jacket',
    label: 'One black jacket already covers most use cases',
    reason: 'A new purchase should be compared against existing outfits first.',
  );

  bool get isReady => _isReady;
  PrivacySettings get privacySettings => _privacySettings;
  DailyMission? get dailyMission =>
      _dailyMissions.isEmpty ? null : _dailyMissions.first;
  List<DailyMission> get dailyMissions =>
      List<DailyMission>.unmodifiable(_dailyMissions);
  List<LifeEvent> get lifeEvents => _lifeGraphRepository.allEvents();
  List<MissionFeedback> get missionFeedbackHistory =>
      List<MissionFeedback>.unmodifiable(_missionFeedback);
  List<DailyRisk> get dailyRisks =>
      List<DailyRisk>.unmodifiable(_cachedDailyRisks);
  AppRuntimeConfig? get runtimeConfig => _runtimeConfig;
  List<GoTask> get tasks => List<GoTask>.unmodifiable(_tasks);
  List<Habit> get habits => List<Habit>.unmodifiable(_habits);
  List<ExpenseRecord> get expenses =>
      List<ExpenseRecord>.unmodifiable(_expenses);
  List<PantryItem> get pantryItems =>
      List<PantryItem>.unmodifiable(_pantryItems);
  List<PurchaseIntention> get purchaseIntentions =>
      List<PurchaseIntention>.unmodifiable(_purchaseIntentions);
  List<WeekPlan> get weekPlans => List<WeekPlan>.unmodifiable(_weekPlans);
  List<JournalEntry> get journalEntries =>
      List<JournalEntry>.unmodifiable(_journalEntries);
  List<QuickNote> get quickNotes => List<QuickNote>.unmodifiable(_quickNotes);
  List<CalendarItem> get calendarItems =>
      List<CalendarItem>.unmodifiable(_calendarItems);
  List<RecipeRescue> get recipeRescues =>
      List<RecipeRescue>.unmodifiable(_recipeRescues);
  int get totalEventCount => lifeEvents.length;
  int get aiEligibleEventCount => lifeEvents.where(_eventEligibleForAi).length;
  List<LifeEvent> get aiEligibleEvents => List<LifeEvent>.unmodifiable(
        lifeEvents.where(_eventEligibleForAi).toList(growable: false),
      );
  List<LifeEvent> get blockedFromAiEvents => List<LifeEvent>.unmodifiable(
        lifeEvents.where((event) => !_eventEligibleForAi(event)).toList(
              growable: false,
            ),
      );
  bool get hasOverloadedCalendarDay => _calendarItems.length >= 4;

  MissionFeedback? get latestMissionFeedback {
    final mission = dailyMission;
    if (mission == null) {
      return null;
    }
    for (final feedback in _missionFeedback.reversed) {
      if (feedback.missionId == mission.id) {
        return feedback;
      }
    }
    return null;
  }

  String get latestFeedbackLabel =>
      latestMissionFeedback?.status.label ?? 'No feedback yet';

  String get gatewayStatusLabel {
    final trace = dailyMission?.trace ?? const <String, Object?>{};
    if (trace['remote'] == true) {
      return 'Gateway live';
    }
    final reason = (trace['fallbackReason'] ?? '').toString();
    if (reason == 'no_connection') {
      return 'No connection';
    }
    if (reason == 'ai_temporarily_unavailable') {
      return 'AI temporarily unavailable';
    }
    if (trace['clientFallback'] == true) {
      return 'Using local fallback';
    }
    if (trace['mock'] == true) {
      return 'Using local fallback';
    }
    return 'Gateway live';
  }

  String? get gatewayStatusMessage {
    final trace = dailyMission?.trace ?? const <String, Object?>{};
    final reason = (trace['fallbackReason'] ?? '').toString();
    final config = _runtimeConfig ??
        AppRuntimeConfig.defaults(
          gatewayBaseUrl: _defaultGatewayBaseUrl,
        );

    if (reason == 'no_connection') {
      return config.messageFor('offline');
    }
    if (reason == 'ai_temporarily_unavailable') {
      return config.messageFor('ai_temporarily_unavailable');
    }
    if (trace['clientFallback'] == true || trace['mock'] == true) {
      return config.messageFor('gateway_degraded');
    }
    return null;
  }

  int eventCountFor(String domain) {
    return _lifeGraphRepository.eventsForDomain(domain).length;
  }

  int aiEligibleEventCountFor(DomainKey domain) {
    return lifeEvents.where((event) {
      return event.domain == domain.wireName && _eventEligibleForAi(event);
    }).length;
  }

  Future<void> bootstrap() async {
    _privacySettings = await _localStore.loadPrivacySettings();
    _runtimeConfig = await _localStore.loadRuntimeConfig();
    _applyRuntimeConfig();
    await _lifeGraphRepository.bootstrap();
    _dailyMissions = await _localStore.loadDailyMissions();
    _cachedDailyRisks = await _localStore.loadDailyRisks();
    _missionFeedback = await _localStore.loadMissionFeedback();
    _tasks = await _localStore.loadTasks();
    _habits = await _localStore.loadHabits();
    _expenses = await _localStore.loadExpenses();
    _pantryItems = await _localStore.loadPantryItems();
    _purchaseIntentions = await _localStore.loadPurchaseIntentions();
    _weekPlans = await _localStore.loadWeekPlans();
    _journalEntries = await _localStore.loadJournalEntries();
    _quickNotes = await _localStore.loadQuickNotes();
    _calendarItems = await _localStore.loadCalendarItems();
    _recipeRescues = await _localStore.loadRecipeRescues();
    await _seedDomainEntitiesIfNeeded();
    await _refreshMissionPlan();
    await refreshRuntimeConfig(refreshMissionPlan: true, notify: false);
    _isReady = true;
    notifyListeners();
  }

  Future<void> refreshRuntimeConfig({
    bool refreshMissionPlan = false,
    bool notify = true,
  }) async {
    final client = _runtimeConfigClient;
    if (client == null) {
      return;
    }

    final config = await client.fetchRuntimeConfig();
    if (config == null) {
      return;
    }

    _runtimeConfig = config;
    await _localStore.saveRuntimeConfig(config);
    _applyRuntimeConfig();
    if (refreshMissionPlan) {
      await _refreshMissionPlan();
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> updatePermission(
    DomainKey domain,
    DataPermission permission,
  ) async {
    _privacySettings = _privacySettings.copyWithPermission(domain, permission);
    await _localStore.savePrivacySettings(_privacySettings);
    await _refreshMissionPlan();
    notifyListeners();
  }

  Future<void> emitMissionEvent() => _recordEvent(
        domain: 'mission',
        type: 'mission_ping',
        summary: 'Manual mission checkpoint emitted from shell.',
      );

  Future<void> emitWeekEvent() => _recordEvent(
        event: weekSummary.toLifeEvent(
          'week_plan_checked',
          privacyLevel: _privacyLevelForDomain('week'),
        ),
      );

  Future<void> emitTaskEvent() => _recordEvent(
        event: criticalTask.toLifeEvent(
          'task_progress_ping',
          privacyLevel: _privacyLevelForDomain('task'),
        ),
      );

  Future<void> emitFinanceEvent() => _recordEvent(
        event: financeSummary.toLifeEvent(
          privacyLevel: _privacyLevelForDomain('finance'),
        ),
      );

  Future<void> emitPantryEvent() => _recordEvent(
        event: pantrySummary.toLifeEvent(
          'ingredient_flagged',
          privacyLevel: _privacyLevelForDomain('pantry'),
        ),
      );

  Future<void> emitWardrobeEvent() => _recordEvent(
        event: closetSummary.toLifeEvent(
          privacyLevel: _privacyLevelForDomain('wardrobe'),
        ),
      );

  Future<CaptureClassificationDto?> classifyCaptureText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return _aiGatewayClient.classifyCapture(
      privacySettings: _privacySettings,
      text: trimmed,
    );
  }

  Future<List<CaptureDraftItem>> prepareCaptureDrafts({
    required String text,
    DomainKey? forcedDomain,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const <CaptureDraftItem>[];
    }

    final localDrafts = _captureParser.parse(
      text: trimmed,
      privacySettings: _privacySettings,
      forcedDomain: forcedDomain,
    );

    if (forcedDomain != null || localDrafts.length != 1) {
      return localDrafts;
    }

    try {
      final parsed = await _aiGatewayClient.parseCapture(
        privacySettings: _privacySettings,
        text: trimmed,
      );
      if (parsed != null && parsed.items.isNotEmpty) {
        return _captureParser.parse(
          text: trimmed,
          privacySettings: _privacySettings,
          gatewayItems: parsed.items,
        );
      }
      final classification = await classifyCaptureText(trimmed);
      return _captureParser.parse(
        text: trimmed,
        privacySettings: _privacySettings,
        gatewayClassification: classification,
      );
    } catch (_) {
      return localDrafts;
    }
  }

  Future<void> captureEvent({
    required DomainKey domain,
    required String text,
    String? eventType,
  }) async {
    final drafts = await prepareCaptureDrafts(
      text: text,
      forcedDomain: domain,
    );
    if (drafts.isEmpty) {
      return;
    }
    final normalizedDrafts = drafts
        .map(
          (draft) => draft.copyWith(
            eventType: eventType ?? draft.eventType,
          ),
        )
        .toList(growable: false);
    await captureDrafts(normalizedDrafts);
  }

  Future<void> captureDrafts(List<CaptureDraftItem> drafts) async {
    if (drafts.isEmpty) {
      return;
    }

    for (final draft in drafts) {
      await _persistDomainEntityFromDraft(draft);
      await _recordEvent(
        event: LifeEventFactory.create(
          domain: draft.domain.wireName,
          type: draft.eventType,
          summary: draft.text,
          privacyLevel: draft.privacyLevel,
          payload: {
            'summary': draft.text,
            'capturedFrom': 'capture_screen',
            'rationale': draft.rationale,
            'hints': draft.hints,
            'multiCapture': drafts.length > 1,
          },
        ),
        refreshPlan: false,
        notifyAfter: false,
      );
    }

    await _refreshMissionPlan();
    notifyListeners();
  }

  Future<void> markMissionUseful([DailyMission? mission]) =>
      _submitMissionFeedback(
        MissionFeedbackStatus.useful,
        mission: mission,
      );

  Future<void> acceptMission([DailyMission? mission]) => _submitMissionFeedback(
        MissionFeedbackStatus.accepted,
        mission: mission,
      );

  Future<void> completeMission([DailyMission? mission]) =>
      _submitMissionFeedback(
        MissionFeedbackStatus.completed,
        mission: mission,
      );

  Future<void> rejectMission([DailyMission? mission]) => _submitMissionFeedback(
        MissionFeedbackStatus.rejected,
        mission: mission,
      );

  Future<String?> completeMissionAction([DailyMission? mission]) async {
    final targetMission = mission ?? dailyMission;
    if (targetMission == null) {
      return null;
    }

    String? summary;
    final domains = targetMission.domainTargets.toSet();
    if (domains.contains('task')) {
      summary = await _completeTaskFromMission(targetMission);
    } else if (domains.contains('habit')) {
      summary = await _checkInHabitFromMission(targetMission);
    } else if (domains.contains('pantry')) {
      summary = await _markPantryUsedFromMission(targetMission);
    } else if (domains.contains('wardrobe')) {
      summary = await _pausePurchaseFromMission(targetMission);
    } else if (domains.contains('finance')) {
      summary = await _logFinanceReflectionFromMission(targetMission);
    } else if (domains.contains('week')) {
      summary = await _refreshWeekPlanFromMission(targetMission);
    }

    if (summary == null) {
      await _submitMissionFeedback(
        MissionFeedbackStatus.completed,
        mission: targetMission,
      );
      return 'Mission marked as completed.';
    }

    await _submitMissionFeedback(
      MissionFeedbackStatus.completed,
      mission: targetMission,
      refreshPlan: false,
      notifyAfter: false,
    );
    await _refreshMissionPlan();
    notifyListeners();
    return summary;
  }

  Future<String?> completeTaskById(String id) async {
    final target = _tasks.firstWhere(
      (task) => task.id == id,
      orElse: () => criticalTask,
    );
    final updated = GoTask(
      id: target.id,
      title: target.title,
      priority: target.priority,
      status: TaskStatus.done,
      estimatedMinutes: target.estimatedMinutes,
      notes: target.notes,
      subtasks: target.subtasks,
    );
    await _upsertTask(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'task_completed',
        privacyLevel: _privacyLevelForDomain('task'),
      ),
    );
    return 'Task completed: ${updated.title}.';
  }

  Future<String?> checkInHabitById(String id) async {
    final target = _habits.firstWhere(
      (habit) => habit.id == id,
      orElse: () => recoveryHabit,
    );
    final updated = Habit(
      id: target.id,
      title: target.title,
      cue: target.cue,
      streak: target.streak + 1,
      cadence: target.cadence,
    );
    await _upsertHabit(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'habit_checked_in',
        privacyLevel: _privacyLevelForDomain('habit'),
      ),
    );
    return 'Habit checked in: ${updated.title}.';
  }

  Future<String?> logExpenseTouchById(String id) async {
    final target = _expenses.firstWhere(
      (expense) => expense.id == id,
      orElse: () => financeSummary,
    );
    await _recordEvent(
      event: target.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('finance'),
      ),
    );
    return 'Expense revisited: ${target.label}.';
  }

  Future<String?> markPantryItemUsedById(String id) async {
    final target = _pantryItems.firstWhere(
      (item) => item.id == id,
      orElse: () => pantrySummary,
    );
    final updated = PantryItem(
      id: target.id,
      name: target.name,
      quantityLabel: 'used',
      rescueHint: 'Used locally from the pantry board.',
    );
    await _upsertPantryItem(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'ingredient_used',
        privacyLevel: _privacyLevelForDomain('pantry'),
      ),
    );
    return 'Pantry item used: ${updated.name}.';
  }

  Future<String?> pausePurchaseIntentionById(String id) async {
    final target = _purchaseIntentions.firstWhere(
      (item) => item.id == id,
      orElse: () => closetSummary,
    );
    final updated = PurchaseIntention(
      id: target.id,
      label: target.label,
      reason: 'Paused for 24h from the closet board. ${target.reason}',
    );
    await _upsertPurchaseIntention(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('wardrobe'),
      ),
    );
    return 'Purchase intention paused: ${updated.label}.';
  }

  Future<String?> refreshWeekPlanById(String id) async {
    final target = _weekPlans.firstWhere(
      (plan) => plan.id == id,
      orElse: () => weekSummary,
    );
    final updated = WeekPlan(
      id: target.id,
      theme: '${target.theme} · Adjusted',
      colorToken: target.colorToken,
      days: target.days,
    );
    await _upsertWeekPlan(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'week_replanned',
        privacyLevel: _privacyLevelForDomain('week'),
      ),
    );
    return 'Week plan updated.';
  }

  Future<String?> saveTask({
    String? id,
    required String title,
    required TaskPriority priority,
    required int estimatedMinutes,
    String notes = '',
    TaskStatus status = TaskStatus.inbox,
  }) async {
    final task = GoTask(
      id: id ?? _entityId('task'),
      title: title,
      priority: priority,
      status: status,
      estimatedMinutes: estimatedMinutes,
      notes: notes,
    );
    await _upsertTask(task);
    await _recordEvent(
      event: task.toLifeEvent(
        id == null ? 'task_created' : 'task_updated',
        privacyLevel: _privacyLevelForDomain('task'),
      ),
    );
    return id == null ? 'Task created.' : 'Task updated.';
  }

  Future<String?> saveHabit({
    String? id,
    required String title,
    required String cue,
    required HabitCadence cadence,
    int streak = 0,
  }) async {
    final habit = Habit(
      id: id ?? _entityId('habit'),
      title: title,
      cue: cue,
      streak: streak,
      cadence: cadence,
    );
    await _upsertHabit(habit);
    await _recordEvent(
      event: habit.toLifeEvent(
        id == null ? 'habit_created' : 'habit_updated',
        privacyLevel: _privacyLevelForDomain('habit'),
      ),
    );
    return id == null ? 'Habit created.' : 'Habit updated.';
  }

  Future<String?> saveExpense({
    String? id,
    required String label,
    required double amount,
    required String category,
  }) async {
    final expense = ExpenseRecord(
      id: id ?? _entityId('expense'),
      label: label,
      amount: amount,
      category: category,
    );
    await _upsertExpense(expense);
    await _recordEvent(
      event: expense.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('finance'),
      ),
    );
    return id == null ? 'Expense saved.' : 'Expense updated.';
  }

  Future<String?> savePantryItem({
    String? id,
    required String name,
    required String quantityLabel,
    required String rescueHint,
  }) async {
    final pantryItem = PantryItem(
      id: id ?? _entityId('pantry'),
      name: name,
      quantityLabel: quantityLabel,
      rescueHint: rescueHint,
    );
    await _upsertPantryItem(pantryItem);
    await _recordEvent(
      event: pantryItem.toLifeEvent(
        id == null ? 'ingredient_created' : 'ingredient_updated',
        privacyLevel: _privacyLevelForDomain('pantry'),
      ),
    );
    return id == null ? 'Pantry item saved.' : 'Pantry item updated.';
  }

  Future<String?> savePurchaseIntention({
    String? id,
    required String label,
    required String reason,
  }) async {
    final purchaseIntention = PurchaseIntention(
      id: id ?? _entityId('purchase'),
      label: label,
      reason: reason,
    );
    await _upsertPurchaseIntention(purchaseIntention);
    await _recordEvent(
      event: purchaseIntention.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('wardrobe'),
      ),
    );
    return id == null
        ? 'Purchase intention saved.'
        : 'Purchase intention updated.';
  }

  Future<String?> saveWeekPlan({
    String? id,
    required String theme,
    required String focus,
    String colorToken = 'terra',
  }) async {
    final plan = WeekPlan(
      id: id ?? _entityId('week'),
      theme: theme,
      colorToken: colorToken,
      days: [
        DayPlan(
          label: 'Today',
          focus: focus,
        ),
      ],
    );
    await _upsertWeekPlan(plan);
    await _recordEvent(
      event: plan.toLifeEvent(
        id == null ? 'week_plan_created' : 'week_plan_updated',
        privacyLevel: _privacyLevelForDomain('week'),
      ),
    );
    return id == null ? 'Week plan saved.' : 'Week plan updated.';
  }

  Future<String?> saveJournalEntry({
    String? id,
    required String title,
    required String body,
    required String mood,
  }) async {
    final entry = JournalEntry(
      id: id ?? _entityId('journal'),
      title: title,
      body: body,
      mood: mood,
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    await _upsertJournalEntry(entry);
    await _recordEvent(
      event: entry.toLifeEvent(
        id == null ? 'journal_entry_created' : 'journal_entry_updated',
      ),
    );
    return id == null ? 'Journal entry saved.' : 'Journal entry updated.';
  }

  Future<String?> saveQuickNote({
    String? id,
    required String text,
  }) async {
    final note = QuickNote(
      id: id ?? _entityId('note'),
      text: text,
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    await _upsertQuickNote(note);
    await _recordEvent(
      event: note.toLifeEvent(
        id == null ? 'quick_note_created' : 'quick_note_updated',
      ),
    );
    return id == null ? 'Quick note saved.' : 'Quick note updated.';
  }

  Future<String?> saveCalendarItem({
    String? id,
    required String title,
    required String startIso,
    required String endIso,
    String location = '',
    String energy = 'steady',
  }) async {
    final item = CalendarItem(
      id: id ?? _entityId('calendar'),
      title: title,
      startIso: startIso,
      endIso: endIso,
      location: location,
      energy: energy,
    );
    await _upsertCalendarItem(item);
    await _recordEvent(
      event: item.toLifeEvent(
        id == null ? 'calendar_item_created' : 'calendar_item_updated',
        privacyLevel: _privacyLevelForDomain('week'),
      ),
    );
    return id == null ? 'Calendar item saved.' : 'Calendar item updated.';
  }

  Future<String?> saveRecipeRescue({
    String? id,
    required String title,
    required String summary,
    required List<String> ingredientNames,
    required int estimatedMinutes,
    String status = 'draft',
  }) async {
    final recipe = RecipeRescue(
      id: id ?? _entityId('recipe'),
      title: title,
      summary: summary,
      ingredientNames: ingredientNames,
      estimatedMinutes: estimatedMinutes,
      status: status,
    );
    await _upsertRecipeRescue(recipe);
    await _recordEvent(
      event: recipe.toLifeEvent(
        id == null ? 'recipe_rescue_created' : 'recipe_rescue_updated',
        privacyLevel: _privacyLevelForDomain('pantry'),
      ),
    );
    return id == null ? 'Recipe rescue saved.' : 'Recipe rescue updated.';
  }

  Future<String?> markRecipeRescueCookedById(String id) async {
    final target = _recipeRescues.firstWhere(
      (recipe) => recipe.id == id,
      orElse: () => RecipeRescue(
        id: id,
        title: 'Recipe rescue',
        summary: 'Local recipe rescue action.',
        ingredientNames: const <String>[],
        estimatedMinutes: 15,
      ),
    );
    final updated = RecipeRescue(
      id: target.id,
      title: target.title,
      summary: target.summary,
      ingredientNames: target.ingredientNames,
      estimatedMinutes: target.estimatedMinutes,
      status: 'cooked',
    );
    await _upsertRecipeRescue(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'recipe_rescue_cooked',
        privacyLevel: _privacyLevelForDomain('pantry'),
      ),
    );
    return 'Recipe rescue marked cooked: ${updated.title}.';
  }

  Future<String> exportLocalDataJson() async {
    final snapshot = <String, Object?>{
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'privacy_settings': _privacySettings.toJson(),
      'runtime_config': _runtimeConfig?.toJson(),
      'life_events':
          lifeEvents.map((item) => item.toJson()).toList(growable: false),
      'missions':
          _dailyMissions.map((item) => item.toJson()).toList(growable: false),
      'daily_risks': _cachedDailyRisks
          .map((item) => item.toJson())
          .toList(growable: false),
      'mission_feedback':
          _missionFeedback.map((item) => item.toJson()).toList(growable: false),
      'tasks': _tasks.map((item) => item.toJson()).toList(growable: false),
      'habits': _habits.map((item) => item.toJson()).toList(growable: false),
      'expenses':
          _expenses.map((item) => item.toJson()).toList(growable: false),
      'pantry_items':
          _pantryItems.map((item) => item.toJson()).toList(growable: false),
      'purchase_intentions': _purchaseIntentions
          .map((item) => item.toJson())
          .toList(growable: false),
      'week_plans':
          _weekPlans.map((item) => item.toJson()).toList(growable: false),
      'journal_entries':
          _journalEntries.map((item) => item.toJson()).toList(growable: false),
      'quick_notes':
          _quickNotes.map((item) => item.toJson()).toList(growable: false),
      'calendar_items':
          _calendarItems.map((item) => item.toJson()).toList(growable: false),
      'recipe_rescues':
          _recipeRescues.map((item) => item.toJson()).toList(growable: false),
    };
    return const JsonEncoder.withIndent('  ').convert(snapshot);
  }

  Future<void> deleteAllLocalData() async {
    await _localStore.saveDemoSeedEnabled(false);
    await _localStore.deleteAllData();
    await _lifeGraphRepository.clear();
    _privacySettings = PrivacySettings.defaults();
    _runtimeConfig = null;
    _dailyMissions = <DailyMission>[];
    _cachedDailyRisks = <DailyRisk>[];
    _missionFeedback = <MissionFeedback>[];
    _tasks = <GoTask>[];
    _habits = <Habit>[];
    _expenses = <ExpenseRecord>[];
    _pantryItems = <PantryItem>[];
    _purchaseIntentions = <PurchaseIntention>[];
    _weekPlans = <WeekPlan>[];
    _journalEntries = <JournalEntry>[];
    _quickNotes = <QuickNote>[];
    _calendarItems = <CalendarItem>[];
    _recipeRescues = <RecipeRescue>[];
    notifyListeners();
  }

  List<String> missionDataUsed(DailyMission mission) {
    final lines = <String>[
      ...mission.evidence,
    ];
    final relatedRisks = _cachedDailyRisks.where((risk) {
      return risk.domainTargets.any(mission.domainTargets.contains);
    });
    for (final risk in relatedRisks) {
      lines.add('Risk: ${risk.title}');
    }
    return lines.take(6).toList(growable: false);
  }

  List<String> dataSentToAiPreview({int limit = 6}) {
    return aiEligibleEvents
        .take(limit)
        .map((event) => '${event.domain}: ${event.summary}')
        .toList(growable: false);
  }

  List<String> dataBlockedFromAiPreview({int limit = 6}) {
    return blockedFromAiEvents
        .take(limit)
        .map((event) => '${event.domain}: ${event.summary}')
        .toList(growable: false);
  }

  Future<void> _recordEvent({
    LifeEvent? event,
    String? domain,
    String? type,
    String? summary,
    bool refreshPlan = true,
    bool notifyAfter = true,
  }) async {
    final nextEvent = event ??
        LifeEvent(
          eventId: 'evt-${DateTime.now().microsecondsSinceEpoch}',
          userId: 'local-user',
          domain: domain ?? 'system',
          eventType: type ?? 'ping',
          timestampIso: DateTime.now().toUtc().toIso8601String(),
          payload: {
            'summary': summary ?? 'Sample shell event.',
          },
          source: 'manual',
          privacyLevel: _privacyLevelForDomain(domain ?? 'system'),
        );
    await _lifeGraphRepository.addEvent(nextEvent);
    if (refreshPlan) {
      await _refreshMissionPlan();
    }
    if (notifyAfter) {
      notifyListeners();
    }
  }

  Future<void> _refreshMissionPlan() async {
    final dto = await _aiGatewayClient.fetchDailyPlan(
      privacySettings: _privacySettings,
      lifeEvents: lifeEvents,
    );
    _dailyMissions = mapMissionPlan(dto);
    _cachedDailyRisks = _extractDailyRisksFromMission(
      _dailyMissions.isEmpty ? null : _dailyMissions.first,
    );
    await _localStore.saveDailyMissions(_dailyMissions);
    await _localStore.saveDailyRisks(_cachedDailyRisks);
  }

  void _applyRuntimeConfig() {
    final config = _runtimeConfig;
    if (config == null) {
      return;
    }
    if (_aiGatewayClient is HttpAiGatewayClient) {
      (_aiGatewayClient).updateBaseUri(
        Uri.parse(config.gatewayBaseUrl),
      );
    }
  }

  String get _defaultGatewayBaseUrl {
    if (_aiGatewayClient is HttpAiGatewayClient) {
      return (_aiGatewayClient).baseUri.toString();
    }
    return 'http://127.0.0.1:8000';
  }

  Future<void> _submitMissionFeedback(
    MissionFeedbackStatus status, {
    DailyMission? mission,
    bool refreshPlan = true,
    bool notifyAfter = true,
  }) async {
    final targetMission = mission ?? dailyMission;
    if (targetMission == null) {
      return;
    }

    final feedback = MissionFeedback(
      id: 'feedback-${DateTime.now().microsecondsSinceEpoch}',
      missionId: targetMission.id,
      status: status,
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      domainTargets: targetMission.domainTargets,
      recommendationType: targetMission.recommendationType,
      trace: targetMission.trace,
    );

    _missionFeedback = <MissionFeedback>[
      ..._missionFeedback,
      feedback,
    ];
    await _localStore.saveMissionFeedback(_missionFeedback);

    try {
      await _aiGatewayClient.submitMissionFeedback(feedback: feedback);
    } catch (_) {
      // Local persistence remains the source of truth until the gateway is available.
    }

    if (refreshPlan) {
      await _refreshMissionPlan();
    }
    if (notifyAfter) {
      notifyListeners();
    }
  }

  String _privacyLevelForDomain(String domain) {
    return _privacySettings.permissionForWireDomain(domain).storageKey;
  }

  bool _eventEligibleForAi(LifeEvent event) {
    final permission = _privacySettings.permissionForWireDomain(event.domain);
    return permission == DataPermission.aiAllowed &&
        event.privacyLevel == DataPermission.aiAllowed.storageKey;
  }

  List<DailyRisk> _extractDailyRisksFromMission(DailyMission? mission) {
    if (mission == null) {
      return const <DailyRisk>[];
    }

    final assessRisks = mission.trace['assess_risks'];
    if (assessRisks is! Map) {
      return const <DailyRisk>[];
    }

    final rawRisks = assessRisks['risks'];
    if (rawRisks is! List) {
      return const <DailyRisk>[];
    }

    return rawRisks.whereType<Map>().map((risk) {
      final domainTargets = (risk['domains'] as List?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const <String>[];
      return DailyRisk(
        id: (risk['risk_id'] ?? 'risk-unknown').toString(),
        title: (risk['title'] ?? 'Risk').toString(),
        summary: (risk['summary'] ?? '').toString(),
        severity: (risk['severity'] ?? 'low').toString(),
        domainTargets: domainTargets,
      );
    }).toList(growable: false);
  }

  Future<void> _seedDomainEntitiesIfNeeded() async {
    final demoSeedEnabled = await _localStore.loadDemoSeedEnabled();
    if (!demoSeedEnabled) {
      return;
    }

    if (_tasks.isEmpty) {
      await _upsertTask(criticalTask);
    }
    if (_habits.isEmpty) {
      await _upsertHabit(recoveryHabit);
    }
    if (_expenses.isEmpty) {
      await _upsertExpense(financeSummary);
    }
    if (_pantryItems.isEmpty) {
      await _upsertPantryItem(pantrySummary);
    }
    if (_purchaseIntentions.isEmpty) {
      await _upsertPurchaseIntention(closetSummary);
    }
    if (_weekPlans.isEmpty) {
      await _upsertWeekPlan(weekSummary);
    }
    if (_recipeRescues.isEmpty && _pantryItems.isNotEmpty) {
      await _upsertRecipeRescue(
        RecipeRescue(
          id: 'recipe-spinach-rescue',
          title: 'Spinach rescue bowl',
          summary: 'Use spinach first with chickpeas or rice to reduce waste.',
          ingredientNames: const <String>['spinach', 'chickpeas'],
          estimatedMinutes: 15,
        ),
      );
    }
  }

  Future<void> _persistDomainEntityFromDraft(CaptureDraftItem draft) async {
    switch (draft.domain.wireName) {
      case 'task':
        await _upsertTask(_taskFromCapture(draft));
        return;
      case 'habit':
        await _upsertHabit(_habitFromCapture(draft));
        return;
      case 'finance':
        await _upsertExpense(_expenseFromCapture(draft));
        return;
      case 'pantry':
        await _upsertPantryItem(_pantryItemFromCapture(draft));
        return;
      case 'wardrobe':
        await _upsertPurchaseIntention(_purchaseIntentionFromCapture(draft));
        return;
      case 'week':
        await _upsertWeekPlan(_weekPlanFromCapture(draft));
        return;
    }
  }

  GoTask _taskFromCapture(CaptureDraftItem draft) {
    final lowered = draft.text.toLowerCase();
    final priority = lowered.contains('urgent') ||
            lowered.contains('today') ||
            (draft.hints['time_hint']?.toString() == 'today')
        ? TaskPriority.critical
        : TaskPriority.standard;
    return GoTask(
      id: _entityId('task'),
      title: draft.text,
      priority: priority,
      status: TaskStatus.inbox,
      estimatedMinutes: 15,
      notes: _taskNotesFromHints(draft.hints),
    );
  }

  Habit _habitFromCapture(CaptureDraftItem draft) {
    return Habit(
      id: _entityId('habit'),
      title: draft.text,
      cue: 'Captured manually',
      streak: 1,
      cadence: HabitCadence.daily,
    );
  }

  ExpenseRecord _expenseFromCapture(CaptureDraftItem draft) {
    final lowered = draft.text.toLowerCase();
    final amount = (draft.hints['amount'] as double?) ??
        _extractFirstAmount(draft.text) ??
        0;
    final category = lowered.contains('coffee') ||
            lowered.contains('food') ||
            lowered.contains('lunch') ||
            lowered.contains('cafe') ||
            lowered.contains('sandwich')
        ? 'food'
        : 'general';
    return ExpenseRecord(
      id: _entityId('expense'),
      label: draft.text,
      amount: amount,
      category: category,
    );
  }

  PantryItem _pantryItemFromCapture(CaptureDraftItem draft) {
    final expiryHint = draft.hints['expiry_hint'];
    final rescueHint = expiryHint == null
        ? 'Review expiry and use this before buying more.'
        : 'Use soon. Detected expiry hint: $expiryHint.';
    return PantryItem(
      id: _entityId('pantry'),
      name: draft.text,
      quantityLabel: '1 captured item',
      rescueHint: rescueHint,
    );
  }

  PurchaseIntention _purchaseIntentionFromCapture(CaptureDraftItem draft) {
    return PurchaseIntention(
      id: _entityId('purchase'),
      label: draft.text,
      reason:
          'Captured from quick capture. Compare against existing items first.',
    );
  }

  WeekPlan _weekPlanFromCapture(CaptureDraftItem draft) {
    return WeekPlan(
      id: _entityId('week'),
      theme: draft.text,
      colorToken: 'terra',
      days: [
        DayPlan(
          label: 'Today',
          focus: draft.text,
        ),
      ],
    );
  }

  Future<String?> _completeTaskFromMission(DailyMission mission) async {
    final target = _tasks.firstWhere(
      (task) => task.status != TaskStatus.done,
      orElse: () => criticalTask,
    );
    final updated = GoTask(
      id: target.id,
      title: target.title,
      priority: target.priority,
      status: TaskStatus.done,
      estimatedMinutes: target.estimatedMinutes,
      notes: target.notes,
      subtasks: target.subtasks,
    );
    await _upsertTask(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'task_completed_from_mission',
        privacyLevel: _privacyLevelForDomain('task'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    return 'Task marked done: ${updated.title}.';
  }

  Future<String?> _checkInHabitFromMission(DailyMission mission) async {
    final target = _habits.isNotEmpty ? _habits.first : recoveryHabit;
    final updated = Habit(
      id: target.id,
      title: target.title,
      cue: target.cue,
      streak: target.streak + 1,
      cadence: target.cadence,
    );
    await _upsertHabit(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'habit_checked_in_from_mission',
        privacyLevel: _privacyLevelForDomain('habit'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    return 'Habit checked in: ${updated.title}.';
  }

  Future<String?> _markPantryUsedFromMission(DailyMission mission) async {
    final target = _pantryItems.isNotEmpty ? _pantryItems.first : pantrySummary;
    final updated = PantryItem(
      id: target.id,
      name: target.name,
      quantityLabel: 'used',
      rescueHint: 'Used by a mission action. Refill only if still needed.',
    );
    await _upsertPantryItem(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'ingredient_used_from_mission',
        privacyLevel: _privacyLevelForDomain('pantry'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    return 'Pantry item marked used: ${updated.name}.';
  }

  Future<String?> _pausePurchaseFromMission(DailyMission mission) async {
    final target = _purchaseIntentions.isNotEmpty
        ? _purchaseIntentions.first
        : closetSummary;
    final updated = PurchaseIntention(
      id: target.id,
      label: target.label,
      reason: 'Paused for 24h after mission action. ${target.reason}',
    );
    await _upsertPurchaseIntention(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('wardrobe'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    return 'Purchase intention paused: ${updated.label}.';
  }

  Future<String?> _logFinanceReflectionFromMission(DailyMission mission) async {
    final target = _expenses.isNotEmpty ? _expenses.first : financeSummary;
    await _recordEvent(
      event: target.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('finance'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    return 'Finance reflection logged for ${target.label}.';
  }

  Future<String?> _refreshWeekPlanFromMission(DailyMission mission) async {
    final target = _weekPlans.isNotEmpty ? _weekPlans.first : weekSummary;
    final updated = WeekPlan(
      id: target.id,
      theme: '${target.theme} · Replanned from mission',
      colorToken: target.colorToken,
      days: target.days,
    );
    await _upsertWeekPlan(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'week_replanned_from_mission',
        privacyLevel: _privacyLevelForDomain('week'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    return 'Week plan refreshed from mission.';
  }

  Future<void> _upsertTask(GoTask task) async {
    _tasks = _upsertById(_tasks, task, (item) => item.id);
    await _localStore.upsertTask(task);
  }

  Future<void> _upsertHabit(Habit habit) async {
    _habits = _upsertById(_habits, habit, (item) => item.id);
    await _localStore.upsertHabit(habit);
  }

  Future<void> _upsertExpense(ExpenseRecord expense) async {
    _expenses = _upsertById(_expenses, expense, (item) => item.id);
    await _localStore.upsertExpense(expense);
  }

  Future<void> _upsertPantryItem(PantryItem pantryItem) async {
    _pantryItems = _upsertById(_pantryItems, pantryItem, (item) => item.id);
    await _localStore.upsertPantryItem(pantryItem);
  }

  Future<void> _upsertPurchaseIntention(
    PurchaseIntention purchaseIntention,
  ) async {
    _purchaseIntentions = _upsertById(
      _purchaseIntentions,
      purchaseIntention,
      (item) => item.id,
    );
    await _localStore.upsertPurchaseIntention(purchaseIntention);
  }

  Future<void> _upsertWeekPlan(WeekPlan weekPlan) async {
    _weekPlans = _upsertById(_weekPlans, weekPlan, (item) => item.id);
    await _localStore.upsertWeekPlan(weekPlan);
  }

  Future<void> _upsertJournalEntry(JournalEntry journalEntry) async {
    _journalEntries =
        _upsertById(_journalEntries, journalEntry, (item) => item.id);
    await _localStore.upsertJournalEntry(journalEntry);
  }

  Future<void> _upsertQuickNote(QuickNote quickNote) async {
    _quickNotes = _upsertById(_quickNotes, quickNote, (item) => item.id);
    await _localStore.upsertQuickNote(quickNote);
  }

  Future<void> _upsertCalendarItem(CalendarItem calendarItem) async {
    _calendarItems =
        _upsertById(_calendarItems, calendarItem, (item) => item.id);
    await _localStore.upsertCalendarItem(calendarItem);
  }

  Future<void> _upsertRecipeRescue(RecipeRescue recipeRescue) async {
    _recipeRescues =
        _upsertById(_recipeRescues, recipeRescue, (item) => item.id);
    await _localStore.upsertRecipeRescue(recipeRescue);
  }

  String _taskNotesFromHints(Map<String, Object?> hints) {
    final dueHint = hints['time_hint']?.toString();
    if (dueHint == null || dueHint.isEmpty) {
      return 'Captured from quick capture.';
    }
    return 'Captured from quick capture. Due hint: $dueHint.';
  }

  double? _extractFirstAmount(String text) {
    final match = RegExp(r'(\d+[.,]?\d{0,2})').firstMatch(text);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  String _entityId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}

List<T> _upsertById<T>(
  List<T> values,
  T next,
  String Function(T value) idOf,
) {
  final mutable = List<T>.from(values);
  final index = mutable.indexWhere((item) => idOf(item) == idOf(next));
  if (index >= 0) {
    mutable[index] = next;
    return List<T>.unmodifiable(mutable);
  }
  return List<T>.unmodifiable(<T>[next, ...mutable]);
}
