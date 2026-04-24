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
import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';

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

  bool _isReady = false;
  PrivacySettings _privacySettings = PrivacySettings.defaults();
  List<DailyMission> _dailyMissions = <DailyMission>[];
  List<DailyRisk> _cachedDailyRisks = <DailyRisk>[];
  List<MissionFeedback> _missionFeedback = <MissionFeedback>[];
  AppRuntimeConfig? _runtimeConfig;

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
  int get totalEventCount => lifeEvents.length;
  int get aiEligibleEventCount =>
      lifeEvents.where(_eventEligibleForAi).length;

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

  Future<void> captureEvent({
    required DomainKey domain,
    required String text,
    String? eventType,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final wireDomain = domain.wireName;
    final resolvedEventType = eventType ?? _defaultEventTypeForDomain(wireDomain);

    await _persistDomainEntity(
      domain: wireDomain,
      text: trimmed,
    );

    await _recordEvent(
      event: LifeEventFactory.create(
        domain: wireDomain,
        type: resolvedEventType,
        summary: trimmed,
        privacyLevel: _privacyLevelForDomain(wireDomain),
        payload: {
          'summary': trimmed,
          'capturedFrom': 'capture_screen',
        },
      ),
    );
  }

  Future<void> markMissionUseful([DailyMission? mission]) =>
      _submitMissionFeedback(
        MissionFeedbackStatus.useful,
        mission: mission,
      );

  Future<void> acceptMission([DailyMission? mission]) =>
      _submitMissionFeedback(
        MissionFeedbackStatus.accepted,
        mission: mission,
      );

  Future<void> completeMission([DailyMission? mission]) =>
      _submitMissionFeedback(
        MissionFeedbackStatus.completed,
        mission: mission,
      );

  Future<void> rejectMission([DailyMission? mission]) =>
      _submitMissionFeedback(
        MissionFeedbackStatus.rejected,
        mission: mission,
      );

  Future<void> _recordEvent({
    LifeEvent? event,
    String? domain,
    String? type,
    String? summary,
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
    await _refreshMissionPlan();
    notifyListeners();
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

    notifyListeners();
  }

  String _privacyLevelForDomain(String domain) {
    return _privacySettings.permissionForWireDomain(domain).storageKey;
  }

  bool _eventEligibleForAi(LifeEvent event) {
    final permission = _privacySettings.permissionForWireDomain(event.domain);
    return permission == DataPermission.aiAllowed &&
        event.privacyLevel == DataPermission.aiAllowed.storageKey;
  }

  String _defaultEventTypeForDomain(String domain) {
    switch (domain) {
      case 'task':
        return 'task_captured';
      case 'habit':
        return 'habit_logged';
      case 'week':
        return 'week_note_captured';
      case 'finance':
        return 'expense_logged';
      case 'pantry':
        return 'ingredient_flagged';
      case 'wardrobe':
        return 'purchase_intention';
      case 'mission':
        return 'mission_note';
      default:
        return 'note_captured';
    }
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

  Future<void> _persistDomainEntity({
    required String domain,
    required String text,
  }) async {
    switch (domain) {
      case 'task':
        await _localStore.upsertTask(_taskFromCapture(text));
        return;
      case 'habit':
        await _localStore.upsertHabit(_habitFromCapture(text));
        return;
      case 'finance':
        await _localStore.upsertExpense(_expenseFromCapture(text));
        return;
      case 'pantry':
        await _localStore.upsertPantryItem(_pantryItemFromCapture(text));
        return;
      case 'wardrobe':
        await _localStore.upsertPurchaseIntention(
          _purchaseIntentionFromCapture(text),
        );
        return;
      case 'week':
        await _localStore.upsertWeekPlan(_weekPlanFromCapture(text));
        return;
    }
  }

  GoTask _taskFromCapture(String text) {
    final lowered = text.toLowerCase();
    final priority = lowered.contains('urgent') || lowered.contains('today')
        ? TaskPriority.critical
        : TaskPriority.standard;
    return GoTask(
      id: _entityId('task'),
      title: text,
      priority: priority,
      status: TaskStatus.inbox,
      estimatedMinutes: 15,
      notes: 'Captured from quick capture.',
    );
  }

  Habit _habitFromCapture(String text) {
    return Habit(
      id: _entityId('habit'),
      title: text,
      cue: 'Captured manually',
      streak: 1,
      cadence: HabitCadence.daily,
    );
  }

  ExpenseRecord _expenseFromCapture(String text) {
    final lowered = text.toLowerCase();
    final amount = _extractFirstAmount(text) ?? 0;
    final category = lowered.contains('coffee') ||
            lowered.contains('food') ||
            lowered.contains('lunch') ||
            lowered.contains('cafe')
        ? 'food'
        : 'general';
    return ExpenseRecord(
      id: _entityId('expense'),
      label: text,
      amount: amount,
      category: category,
    );
  }

  PantryItem _pantryItemFromCapture(String text) {
    return PantryItem(
      id: _entityId('pantry'),
      name: text,
      quantityLabel: '1 captured item',
      rescueHint: 'Review expiry and use this before buying more.',
    );
  }

  PurchaseIntention _purchaseIntentionFromCapture(String text) {
    return PurchaseIntention(
      id: _entityId('purchase'),
      label: text,
      reason: 'Captured from quick capture.',
    );
  }

  WeekPlan _weekPlanFromCapture(String text) {
    return WeekPlan(
      id: _entityId('week'),
      theme: text,
      colorToken: 'terra',
      days: [
        DayPlan(
          label: 'Today',
          focus: text,
        ),
      ],
    );
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
