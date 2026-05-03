import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/ai_client/ai_gateway_client.dart';
import '../../core/ai_client/dto/ai_gateway_dto.dart';
import '../../core/ai_client/mappers/mission_mapper.dart';
import '../../core/i18n/app_locale.dart';
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
  bool _sensitiveLocalEncryptionEnabled = false;
  AppLocalePreference _localePreference = AppLocalePreference.system;
  String _deviceLocaleTag = 'en';

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
  bool get sensitiveLocalEncryptionEnabled => _sensitiveLocalEncryptionEnabled;
  AppLocalePreference get localePreference => _localePreference;
  Locale? get preferredLocale => _localePreference.locale;
  String get currentLocaleTag => _localePreference == AppLocalePreference.system
      ? normalizeLocaleTag(_deviceLocaleTag)
      : _localePreference.storageKey;
  List<String> get encryptedCollectionLabels => const <String>[
        'Finance records',
        'Journal entries',
        'Quick notes',
      ];
  List<String> get alwaysLocalCollectionLabels => const <String>[
        'Privacy settings',
        'Journal entries',
        'Quick notes',
        'Runtime config cache',
        'Device encryption key',
      ];
  List<String> get aiSendableCollectionLabels {
    final labels = _privacySettings.aiAllowedDomains
        .where((domain) => domain != DomainKey.copilot)
        .map((domain) => domain.label)
        .toList(growable: false);
    if (labels.isEmpty) {
      return const <String>['Nothing is AI-enabled right now'];
    }
    return labels;
  }

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
    _localePreference = appLocalePreferenceFromStorage(
      await _localStore.loadLocalePreference(),
    );
    _sensitiveLocalEncryptionEnabled =
        await _localStore.supportsSensitiveLocalEncryption();
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

  Future<void> updateLocalePreference(AppLocalePreference preference) async {
    _localePreference = preference;
    await _localStore.saveLocalePreference(
      preference == AppLocalePreference.system ? null : preference.storageKey,
    );
    notifyListeners();
  }

  void updateDeviceLocaleTag(String? rawLocaleTag) {
    final normalized = normalizeLocaleTag(rawLocaleTag);
    if (_deviceLocaleTag == normalized) {
      return;
    }
    _deviceLocaleTag = normalized;
    if (_localePreference == AppLocalePreference.system) {
      notifyListeners();
    }
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
      locale: currentLocaleTag,
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
        locale: currentLocaleTag,
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
      return _controllerText('mission_completed');
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
    return _controllerText('task_completed', {'title': updated.title});
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
    return _controllerText('habit_checked_in', {'title': updated.title});
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
    return _controllerText('expense_revisited', {'label': target.label});
  }

  Future<String?> markPantryItemUsedById(String id) async {
    final target = _pantryItems.firstWhere(
      (item) => item.id == id,
      orElse: () => pantrySummary,
    );
    final updated = PantryItem(
      id: target.id,
      name: target.name,
      quantityLabel: _controllerText('pantry_used_quantity'),
      rescueHint: _controllerText('pantry_used_board_hint'),
    );
    await _upsertPantryItem(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        'ingredient_used',
        privacyLevel: _privacyLevelForDomain('pantry'),
      ),
    );
    return _controllerText('pantry_item_used', {'name': updated.name});
  }

  Future<String?> pausePurchaseIntentionById(String id) async {
    final target = _purchaseIntentions.firstWhere(
      (item) => item.id == id,
      orElse: () => closetSummary,
    );
    final updated = PurchaseIntention(
      id: target.id,
      label: target.label,
      reason: _controllerText('purchase_paused_board_reason', {
        'reason': target.reason,
      }),
    );
    await _upsertPurchaseIntention(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('wardrobe'),
      ),
    );
    return _controllerText('purchase_paused', {'label': updated.label});
  }

  Future<String?> refreshWeekPlanById(String id) async {
    final target = _weekPlans.firstWhere(
      (plan) => plan.id == id,
      orElse: () => weekSummary,
    );
    final updated = WeekPlan(
      id: target.id,
      theme: '${target.theme}${_controllerText('week_adjusted_suffix')}',
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
    return _controllerText('week_plan_updated');
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
    return _controllerText(id == null ? 'task_created' : 'task_updated');
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
    return _controllerText(id == null ? 'habit_created' : 'habit_updated');
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
    return _controllerText(id == null ? 'expense_saved' : 'expense_updated');
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
    return _controllerText(
      id == null ? 'pantry_item_saved' : 'pantry_item_updated',
    );
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
        ? _controllerText('purchase_saved')
        : _controllerText('purchase_updated');
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
          label: _controllerText('today_label'),
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
    return _controllerText(
        id == null ? 'week_plan_saved' : 'week_plan_updated');
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
    return _controllerText(
      id == null ? 'journal_entry_saved' : 'journal_entry_updated',
    );
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
    return _controllerText(
      id == null ? 'quick_note_saved' : 'quick_note_updated',
    );
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
    return _controllerText(
      id == null ? 'calendar_item_saved' : 'calendar_item_updated',
    );
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
    return _controllerText(
      id == null ? 'recipe_rescue_saved' : 'recipe_rescue_updated',
    );
  }

  Future<void> deleteTaskById(String id) => _deleteEntity<GoTask>(
        id: id,
        current: _tasks,
        idOf: (item) => item.id,
        assign: (next) => _tasks = next,
        deleteFromStore: _localStore.deleteTask,
      );

  Future<void> deleteHabitById(String id) => _deleteEntity<Habit>(
        id: id,
        current: _habits,
        idOf: (item) => item.id,
        assign: (next) => _habits = next,
        deleteFromStore: _localStore.deleteHabit,
      );

  Future<void> deleteExpenseById(String id) => _deleteEntity<ExpenseRecord>(
        id: id,
        current: _expenses,
        idOf: (item) => item.id,
        assign: (next) => _expenses = next,
        deleteFromStore: _localStore.deleteExpense,
      );

  Future<void> deletePantryItemById(String id) => _deleteEntity<PantryItem>(
        id: id,
        current: _pantryItems,
        idOf: (item) => item.id,
        assign: (next) => _pantryItems = next,
        deleteFromStore: _localStore.deletePantryItem,
      );

  Future<void> deletePurchaseIntentionById(String id) =>
      _deleteEntity<PurchaseIntention>(
        id: id,
        current: _purchaseIntentions,
        idOf: (item) => item.id,
        assign: (next) => _purchaseIntentions = next,
        deleteFromStore: _localStore.deletePurchaseIntention,
      );

  Future<void> deleteWeekPlanById(String id) => _deleteEntity<WeekPlan>(
        id: id,
        current: _weekPlans,
        idOf: (item) => item.id,
        assign: (next) => _weekPlans = next,
        deleteFromStore: _localStore.deleteWeekPlan,
      );

  Future<void> deleteJournalEntryById(String id) =>
      _deleteEntity<JournalEntry>(
        id: id,
        current: _journalEntries,
        idOf: (item) => item.id,
        assign: (next) => _journalEntries = next,
        deleteFromStore: _localStore.deleteJournalEntry,
      );

  Future<void> deleteQuickNoteById(String id) => _deleteEntity<QuickNote>(
        id: id,
        current: _quickNotes,
        idOf: (item) => item.id,
        assign: (next) => _quickNotes = next,
        deleteFromStore: _localStore.deleteQuickNote,
      );

  Future<void> deleteCalendarItemById(String id) =>
      _deleteEntity<CalendarItem>(
        id: id,
        current: _calendarItems,
        idOf: (item) => item.id,
        assign: (next) => _calendarItems = next,
        deleteFromStore: _localStore.deleteCalendarItem,
      );

  Future<void> deleteRecipeRescueById(String id) =>
      _deleteEntity<RecipeRescue>(
        id: id,
        current: _recipeRescues,
        idOf: (item) => item.id,
        assign: (next) => _recipeRescues = next,
        deleteFromStore: _localStore.deleteRecipeRescue,
      );

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
    return _controllerText('recipe_rescue_cooked', {'title': updated.title});
  }

  Future<String> exportLocalDataJson() async {
    final snapshot = <String, Object?>{
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'locale_preference': _localePreference.storageKey,
      'privacy_settings': _privacySettings.toJson(),
      'runtime_config': _runtimeConfig?.toJson(),
      'storage_security': {
        'sensitive_local_encryption': _sensitiveLocalEncryptionEnabled,
        'encrypted_collections': const <String>[
          'expenses',
          'journal_entries',
          'quick_notes',
        ],
      },
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
    _localePreference = AppLocalePreference.system;
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
      lines.add(risk.title);
    }
    return lines.take(6).toList(growable: false);
  }

  String missionDeliveryLabel(DailyMission mission) {
    final trace = mission.trace;
    if (trace['remote'] == true) {
      return 'AI-assisted';
    }
    if (_missionUsedLocalFallback(mission)) {
      return 'Fallback local';
    }
    return 'Local';
  }

  String missionDeliverySummary(DailyMission mission) {
    final trace = mission.trace;
    if (trace['remote'] == true) {
      return 'GoLife used AI for this mission after local privacy filtering.';
    }
    if (_missionUsedLocalFallback(mission)) {
      return 'GoLife stayed local because the gateway was unavailable or degraded.';
    }
    return 'GoLife kept this mission local on the device.';
  }

  List<String> dataSentToAiPreview({int limit = 6}) {
    return aiEligibleEvents
        .take(limit)
        .map((event) => '${event.domain}: ${event.summary}')
        .toList(growable: false);
  }

  List<String> dataSentToAiForMission(
    DailyMission mission, {
    int limit = 6,
  }) {
    if (mission.trace['remote'] != true) {
      return const <String>[];
    }
    final domains = mission.domainTargets.toSet();
    final matching = aiEligibleEvents.where((event) {
      return domains.isEmpty || domains.contains(event.domain);
    });
    final selected = (matching.isNotEmpty ? matching : aiEligibleEvents)
        .take(limit)
        .map((event) => '${event.domain}: ${event.summary}')
        .toList(growable: false);
    return selected;
  }

  List<String> dataBlockedFromAiPreview({int limit = 6}) {
    return blockedFromAiEvents
        .take(limit)
        .map((event) => '${event.domain}: ${event.summary}')
        .toList(growable: false);
  }

  List<String> dataBlockedForMission(
    DailyMission mission, {
    int limit = 6,
  }) {
    final domains = mission.domainTargets.toSet();
    final matching = blockedFromAiEvents.where((event) {
      return domains.isEmpty || domains.contains(event.domain);
    });
    return matching
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
      locale: currentLocaleTag,
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
      await _aiGatewayClient.submitMissionFeedback(
        locale: currentLocaleTag,
        feedback: feedback,
      );
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

  bool _missionUsedLocalFallback(DailyMission mission) {
    final trace = mission.trace;
    final reason = (trace['fallbackReason'] ?? '').toString();
    return trace['clientFallback'] == true ||
        trace['mock'] == true ||
        reason.isNotEmpty;
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
      cue: _controllerText('captured_manually'),
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
        ? _controllerText('pantry_capture_review')
        : _controllerText('pantry_capture_expiry', {'expiry': '$expiryHint'});
    return PantryItem(
      id: _entityId('pantry'),
      name: draft.text,
      quantityLabel: _controllerText('captured_item_quantity'),
      rescueHint: rescueHint,
    );
  }

  PurchaseIntention _purchaseIntentionFromCapture(CaptureDraftItem draft) {
    return PurchaseIntention(
      id: _entityId('purchase'),
      label: draft.text,
      reason: _controllerText('purchase_capture_reason'),
    );
  }

  WeekPlan _weekPlanFromCapture(CaptureDraftItem draft) {
    return WeekPlan(
      id: _entityId('week'),
      theme: draft.text,
      colorToken: 'terra',
      days: [
        DayPlan(
          label: _controllerText('today_label'),
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
    return _controllerText('task_marked_done', {'title': updated.title});
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
    return _controllerText('habit_checked_in', {'title': updated.title});
  }

  Future<String?> _markPantryUsedFromMission(DailyMission mission) async {
    final target = _pantryItems.isNotEmpty ? _pantryItems.first : pantrySummary;
    final updated = PantryItem(
      id: target.id,
      name: target.name,
      quantityLabel: _controllerText('pantry_used_quantity'),
      rescueHint: _controllerText('pantry_used_mission_hint'),
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
    return _controllerText('pantry_item_marked_used', {'name': updated.name});
  }

  Future<String?> _pausePurchaseFromMission(DailyMission mission) async {
    final target = _purchaseIntentions.isNotEmpty
        ? _purchaseIntentions.first
        : closetSummary;
    final updated = PurchaseIntention(
      id: target.id,
      label: target.label,
      reason: _controllerText('purchase_paused_mission_reason', {
        'reason': target.reason,
      }),
    );
    await _upsertPurchaseIntention(updated);
    await _recordEvent(
      event: updated.toLifeEvent(
        privacyLevel: _privacyLevelForDomain('wardrobe'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    return _controllerText('purchase_paused', {'label': updated.label});
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
    return _controllerText(
        'finance_reflection_logged', {'label': target.label});
  }

  Future<String?> _refreshWeekPlanFromMission(DailyMission mission) async {
    final target = _weekPlans.isNotEmpty ? _weekPlans.first : weekSummary;
    final updated = WeekPlan(
      id: target.id,
      theme: '${target.theme}${_controllerText('week_replanned_suffix')}',
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
    return _controllerText('week_plan_refreshed');
  }

  Future<void> _deleteEntity<T>({
    required String id,
    required List<T> current,
    required String Function(T value) idOf,
    required void Function(List<T> next) assign,
    required Future<void> Function(String id) deleteFromStore,
  }) async {
    assign(_removeById(current, id, idOf));
    await deleteFromStore(id);
    await _refreshMissionPlan();
    notifyListeners();
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
      return _controllerText('captured_from_quick_capture');
    }
    return _controllerText('captured_due_hint', {'due': dueHint});
  }

  String _controllerText(
    String key, [
    Map<String, String> variables = const <String, String>{},
  ]) {
    final template = switch (key) {
      'today_label' => _localizedControllerString(
          en: 'Today',
          es: 'Hoy',
          ptBr: 'Hoje',
          ja: '今日',
          zhHans: '今天',
        ),
      'mission_completed' => _localizedControllerString(
          en: 'Mission marked as completed.',
          es: 'Mision marcada como completada.',
          ptBr: 'Missao marcada como concluida.',
          ja: 'ミッションを完了として記録しました。',
          zhHans: '任务已标记为完成。',
        ),
      'task_completed' => _localizedControllerString(
          en: 'Task completed: {title}.',
          es: 'Tarea completada: {title}.',
          ptBr: 'Tarefa concluida: {title}.',
          ja: 'タスクを完了しました: {title}。',
          zhHans: '任务已完成：{title}。',
        ),
      'task_marked_done' => _localizedControllerString(
          en: 'Task marked done: {title}.',
          es: 'Tarea marcada como hecha: {title}.',
          ptBr: 'Tarefa marcada como feita: {title}.',
          ja: 'タスクを完了済みにしました: {title}。',
          zhHans: '任务已标记为完成：{title}。',
        ),
      'habit_checked_in' => _localizedControllerString(
          en: 'Habit checked in: {title}.',
          es: 'Habito registrado: {title}.',
          ptBr: 'Habito registrado: {title}.',
          ja: '習慣を記録しました: {title}。',
          zhHans: '已记录习惯：{title}。',
        ),
      'expense_revisited' => _localizedControllerString(
          en: 'Expense revisited: {label}.',
          es: 'Gasto revisado: {label}.',
          ptBr: 'Gasto revisado: {label}.',
          ja: '支出を見直しました: {label}。',
          zhHans: '已重新检查支出：{label}。',
        ),
      'pantry_item_used' => _localizedControllerString(
          en: 'Pantry item used: {name}.',
          es: 'Ingrediente usado: {name}.',
          ptBr: 'Ingrediente usado: {name}.',
          ja: '食材を使用済みにしました: {name}。',
          zhHans: '食材已使用：{name}。',
        ),
      'pantry_item_marked_used' => _localizedControllerString(
          en: 'Pantry item marked used: {name}.',
          es: 'Ingrediente marcado como usado: {name}.',
          ptBr: 'Ingrediente marcado como usado: {name}.',
          ja: '食材を使用済みにしました: {name}。',
          zhHans: '食材已标记为使用：{name}。',
        ),
      'purchase_paused' => _localizedControllerString(
          en: 'Purchase intention paused: {label}.',
          es: 'Intencion de compra pausada: {label}.',
          ptBr: 'Intencao de compra pausada: {label}.',
          ja: '購入意図を一時停止しました: {label}。',
          zhHans: '购买意图已暂停：{label}。',
        ),
      'week_plan_updated' => _localizedControllerString(
          en: 'Week plan updated.',
          es: 'Plan semanal actualizado.',
          ptBr: 'Plano semanal atualizado.',
          ja: '週間プランを更新しました。',
          zhHans: '周计划已更新。',
        ),
      'week_plan_saved' => _localizedControllerString(
          en: 'Week plan saved.',
          es: 'Plan semanal guardado.',
          ptBr: 'Plano semanal salvo.',
          ja: '週間プランを保存しました。',
          zhHans: '周计划已保存。',
        ),
      'week_plan_refreshed' => _localizedControllerString(
          en: 'Week plan refreshed from mission.',
          es: 'Plan semanal refrescado desde la mision.',
          ptBr: 'Plano semanal atualizado a partir da missao.',
          ja: 'ミッションから週間プランを更新しました。',
          zhHans: '已根据任务刷新周计划。',
        ),
      'task_created' => _localizedControllerString(
          en: 'Task created.',
          es: 'Tarea creada.',
          ptBr: 'Tarefa criada.',
          ja: 'タスクを作成しました。',
          zhHans: '任务已创建。',
        ),
      'task_updated' => _localizedControllerString(
          en: 'Task updated.',
          es: 'Tarea actualizada.',
          ptBr: 'Tarefa atualizada.',
          ja: 'タスクを更新しました。',
          zhHans: '任务已更新。',
        ),
      'habit_created' => _localizedControllerString(
          en: 'Habit created.',
          es: 'Habito creado.',
          ptBr: 'Habito criado.',
          ja: '習慣を作成しました。',
          zhHans: '习惯已创建。',
        ),
      'habit_updated' => _localizedControllerString(
          en: 'Habit updated.',
          es: 'Habito actualizado.',
          ptBr: 'Habito atualizado.',
          ja: '習慣を更新しました。',
          zhHans: '习惯已更新。',
        ),
      'expense_saved' => _localizedControllerString(
          en: 'Expense saved.',
          es: 'Gasto guardado.',
          ptBr: 'Gasto salvo.',
          ja: '支出を保存しました。',
          zhHans: '支出已保存。',
        ),
      'expense_updated' => _localizedControllerString(
          en: 'Expense updated.',
          es: 'Gasto actualizado.',
          ptBr: 'Gasto atualizado.',
          ja: '支出を更新しました。',
          zhHans: '支出已更新。',
        ),
      'pantry_item_saved' => _localizedControllerString(
          en: 'Pantry item saved.',
          es: 'Ingrediente guardado.',
          ptBr: 'Ingrediente salvo.',
          ja: '食材を保存しました。',
          zhHans: '食材已保存。',
        ),
      'pantry_item_updated' => _localizedControllerString(
          en: 'Pantry item updated.',
          es: 'Ingrediente actualizado.',
          ptBr: 'Ingrediente atualizado.',
          ja: '食材を更新しました。',
          zhHans: '食材已更新。',
        ),
      'purchase_saved' => _localizedControllerString(
          en: 'Purchase intention saved.',
          es: 'Intencion de compra guardada.',
          ptBr: 'Intencao de compra salva.',
          ja: '購入意図を保存しました。',
          zhHans: '购买意图已保存。',
        ),
      'purchase_updated' => _localizedControllerString(
          en: 'Purchase intention updated.',
          es: 'Intencion de compra actualizada.',
          ptBr: 'Intencao de compra atualizada.',
          ja: '購入意図を更新しました。',
          zhHans: '购买意图已更新。',
        ),
      'journal_entry_saved' => _localizedControllerString(
          en: 'Journal entry saved.',
          es: 'Entrada del journal guardada.',
          ptBr: 'Entrada do journal salva.',
          ja: 'ジャーナルを保存しました。',
          zhHans: '日记条目已保存。',
        ),
      'journal_entry_updated' => _localizedControllerString(
          en: 'Journal entry updated.',
          es: 'Entrada del journal actualizada.',
          ptBr: 'Entrada do journal atualizada.',
          ja: 'ジャーナルを更新しました。',
          zhHans: '日记条目已更新。',
        ),
      'quick_note_saved' => _localizedControllerString(
          en: 'Quick note saved.',
          es: 'Nota rapida guardada.',
          ptBr: 'Nota rapida salva.',
          ja: 'クイックメモを保存しました。',
          zhHans: '快速笔记已保存。',
        ),
      'quick_note_updated' => _localizedControllerString(
          en: 'Quick note updated.',
          es: 'Nota rapida actualizada.',
          ptBr: 'Nota rapida atualizada.',
          ja: 'クイックメモを更新しました。',
          zhHans: '快速笔记已更新。',
        ),
      'calendar_item_saved' => _localizedControllerString(
          en: 'Calendar item saved.',
          es: 'Item del calendario guardado.',
          ptBr: 'Item do calendario salvo.',
          ja: 'カレンダー項目を保存しました。',
          zhHans: '日历项目已保存。',
        ),
      'calendar_item_updated' => _localizedControllerString(
          en: 'Calendar item updated.',
          es: 'Item del calendario actualizado.',
          ptBr: 'Item do calendario atualizado.',
          ja: 'カレンダー項目を更新しました。',
          zhHans: '日历项目已更新。',
        ),
      'recipe_rescue_saved' => _localizedControllerString(
          en: 'Recipe rescue saved.',
          es: 'Rescate de receta guardado.',
          ptBr: 'Resgate de receita salvo.',
          ja: 'レシピ救済を保存しました。',
          zhHans: '食谱救援已保存。',
        ),
      'recipe_rescue_updated' => _localizedControllerString(
          en: 'Recipe rescue updated.',
          es: 'Rescate de receta actualizado.',
          ptBr: 'Resgate de receita atualizado.',
          ja: 'レシピ救済を更新しました。',
          zhHans: '食谱救援已更新。',
        ),
      'recipe_rescue_cooked' => _localizedControllerString(
          en: 'Recipe rescue marked cooked: {title}.',
          es: 'Rescate de receta marcado como cocinado: {title}.',
          ptBr: 'Resgate de receita marcado como cozinhado: {title}.',
          ja: 'レシピ救済を調理済みにしました: {title}。',
          zhHans: '食谱救援已标记为已烹饪：{title}。',
        ),
      'finance_reflection_logged' => _localizedControllerString(
          en: 'Finance reflection logged for {label}.',
          es: 'Reflexion financiera registrada para {label}.',
          ptBr: 'Reflexao financeira registrada para {label}.',
          ja: '{label} の家計リフレクションを記録しました。',
          zhHans: '已为 {label} 记录财务反思。',
        ),
      'captured_manually' => _localizedControllerString(
          en: 'Captured manually',
          es: 'Capturado manualmente',
          ptBr: 'Capturado manualmente',
          ja: '手動で記録',
          zhHans: '手动记录',
        ),
      'pantry_capture_review' => _localizedControllerString(
          en: 'Review expiry and use this before buying more.',
          es: 'Revisa el vencimiento y usa esto antes de comprar mas.',
          ptBr: 'Revise a validade e use isto antes de comprar mais.',
          ja: '期限を確認し、買い足す前にこれを使ってください。',
          zhHans: '先检查保质期，并在继续购买前先把它用掉。',
        ),
      'pantry_capture_expiry' => _localizedControllerString(
          en: 'Use soon. Detected expiry hint: {expiry}.',
          es: 'Usa pronto esto. Pista de vencimiento detectada: {expiry}.',
          ptBr: 'Use em breve. Indicio de validade detectado: {expiry}.',
          ja: '早めに使ってください。検出された期限ヒント: {expiry}。',
          zhHans: '请尽快使用。检测到的到期提示：{expiry}。',
        ),
      'captured_item_quantity' => _localizedControllerString(
          en: '1 captured item',
          es: '1 item capturado',
          ptBr: '1 item capturado',
          ja: '取り込み済み1件',
          zhHans: '已捕获 1 项',
        ),
      'purchase_capture_reason' => _localizedControllerString(
          en: 'Captured from quick capture. Compare against existing items first.',
          es: 'Capturado desde captura rapida. Compara primero con lo que ya tienes.',
          ptBr:
              'Capturado da captura rapida. Compare primeiro com o que voce ja tem.',
          ja: 'クイックキャプチャから記録しました。まず手持ちの物と比較してください。',
          zhHans: '来自快速捕获。先与已有物品进行比较。',
        ),
      'captured_from_quick_capture' => _localizedControllerString(
          en: 'Captured from quick capture.',
          es: 'Capturado desde captura rapida.',
          ptBr: 'Capturado da captura rapida.',
          ja: 'クイックキャプチャから記録しました。',
          zhHans: '来自快速捕获。',
        ),
      'captured_due_hint' => _localizedControllerString(
          en: 'Captured from quick capture. Due hint: {due}.',
          es: 'Capturado desde captura rapida. Pista de fecha: {due}.',
          ptBr: 'Capturado da captura rapida. Indicio de prazo: {due}.',
          ja: 'クイックキャプチャから記録しました。期限ヒント: {due}。',
          zhHans: '来自快速捕获。截止提示：{due}。',
        ),
      'pantry_used_quantity' => _localizedControllerString(
          en: 'used',
          es: 'usado',
          ptBr: 'usado',
          ja: '使用済み',
          zhHans: '已使用',
        ),
      'pantry_used_board_hint' => _localizedControllerString(
          en: 'Used locally from the pantry board.',
          es: 'Usado localmente desde el tablero de pantry.',
          ptBr: 'Usado localmente a partir do painel da despensa.',
          ja: 'パントリーボードからローカルで使用しました。',
          zhHans: '已在 pantry 面板中本地标记为使用。',
        ),
      'pantry_used_mission_hint' => _localizedControllerString(
          en: 'Used by a mission action. Refill only if still needed.',
          es: 'Usado por una accion de mision. Reponer solo si todavia hace falta.',
          ptBr:
              'Usado por uma acao de missao. Reponha apenas se ainda fizer falta.',
          ja: 'ミッション操作で使用しました。本当に必要な場合のみ補充してください。',
          zhHans: '已由任务动作使用。只有在仍然需要时才补充。',
        ),
      'purchase_paused_board_reason' => _localizedControllerString(
          en: 'Paused for 24h from the closet board. {reason}',
          es: 'Pausado 24 h desde el tablero de closet. {reason}',
          ptBr: 'Pausado por 24 h a partir do painel do guarda-roupa. {reason}',
          ja: 'クローゼットボードから24時間保留しました。{reason}',
          zhHans: '已在衣橱面板中暂停 24 小时。{reason}',
        ),
      'purchase_paused_mission_reason' => _localizedControllerString(
          en: 'Paused for 24h after mission action. {reason}',
          es: 'Pausado 24 h despues de la accion de mision. {reason}',
          ptBr: 'Pausado por 24 h apos a acao da missao. {reason}',
          ja: 'ミッション操作後に24時間保留しました。{reason}',
          zhHans: '任务动作后已暂停 24 小时。{reason}',
        ),
      'week_adjusted_suffix' => _localizedControllerString(
          en: ' · Adjusted',
          es: ' · Ajustado',
          ptBr: ' · Ajustado',
          ja: ' ・調整済み',
          zhHans: ' · 已调整',
        ),
      'week_replanned_suffix' => _localizedControllerString(
          en: ' · Replanned from mission',
          es: ' · Replanificado desde la mision',
          ptBr: ' · Replanejado a partir da missao',
          ja: ' ・ミッションから再計画',
          zhHans: ' · 已根据任务重排',
        ),
      _ => key,
    };

    return variables.entries.fold(
      template,
      (value, entry) => value.replaceAll('{${entry.key}}', entry.value),
    );
  }

  String _localizedControllerString({
    required String en,
    required String es,
    required String ptBr,
    required String ja,
    required String zhHans,
  }) {
    switch (normalizeLocaleTag(currentLocaleTag)) {
      case 'es':
        return es;
      case 'pt-BR':
        return ptBr;
      case 'ja':
        return ja;
      case 'zh-Hans':
        return zhHans;
      default:
        return en;
    }
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

List<T> _removeById<T>(
  List<T> values,
  String id,
  String Function(T value) idOf,
) {
  return List<T>.unmodifiable(
    values.where((item) => idOf(item) != id).toList(growable: false),
  );
}
