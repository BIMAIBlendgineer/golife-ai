import 'package:flutter/foundation.dart';

import '../../core/ai_client/ai_gateway_client.dart';
import '../../core/ai_client/dto/ai_gateway_dto.dart';
import '../../core/ai_client/mappers/mission_mapper.dart';
import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';
import '../../core/lifegraph/lifegraph_repository.dart';
import '../../core/privacy/privacy_models.dart';
import '../../core/storage/local_store.dart';
import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';

class GoLifeController extends ChangeNotifier {
  GoLifeController({
    required LocalStore localStore,
    required AiGatewayClient aiGatewayClient,
    required LifeGraphRepository lifeGraphRepository,
  })  : _localStore = localStore,
        _aiGatewayClient = aiGatewayClient,
        _lifeGraphRepository = lifeGraphRepository;

  final LocalStore _localStore;
  final AiGatewayClient _aiGatewayClient;
  final LifeGraphRepository _lifeGraphRepository;

  bool _isReady = false;
  PrivacySettings _privacySettings = PrivacySettings.defaults();
  List<DailyMission> _dailyMissions = <DailyMission>[];
  List<MissionFeedback> _missionFeedback = <MissionFeedback>[];

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
    await _lifeGraphRepository.bootstrap();
    _missionFeedback = await _localStore.loadMissionFeedback();
    await _refreshMissionPlan();
    _isReady = true;
    notifyListeners();
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
}
