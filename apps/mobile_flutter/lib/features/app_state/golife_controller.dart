import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/ai_client/ai_gateway_client.dart';
import '../../core/ai_client/dto/ai_gateway_dto.dart';
import '../../core/ai_client/mappers/mission_mapper.dart';
import '../../core/analytics/local_analytics_repository.dart';
import '../../core/export/local_export_service.dart';
import '../../core/export/submission_asset_vault.dart';
import '../../core/i18n/app_locale.dart';
import '../../core/i18n/app_localized_values.dart';
import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';
import '../../core/lifegraph/lifegraph_repository.dart';
import '../../core/lifegraph/lifegraph_relation.dart';
import '../../core/monetization/entitlement_service.dart';
import '../../core/mindflow/mindflow_mappers.dart';
import '../../core/privacy/privacy_models.dart';
import '../../core/runtime/app_runtime_config.dart';
import '../../core/runtime/runtime_config_client.dart';
import '../../core/settings/app_profile_preferences.dart';
import '../../core/storage/local_store.dart';
import '../../domains/calendar/calendar_item.dart';
import '../../domains/analytics/analytics_event.dart';
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
import '../../domains/mindflow/action_contract.dart';
import '../../domains/mindflow/decision_card.dart';
import '../../domains/mindflow/mental_load_item.dart';
import '../../domains/mindflow/privacy_summary.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/mission_set.dart';
import '../../domains/monetization/entitlement.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/privacy/evidence_item.dart';
import '../../domains/privacy/privacy_audit_entry.dart';
import '../../domains/recipes/recipe_rescue.dart';
import '../../domains/shopping/product_evidence_card.dart';
import '../../domains/shopping/shopping_need.dart';
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
    LocalExportService? localExportService,
    SubmissionAssetVault? submissionAssetVault,
    LocalAnalyticsRepository? localAnalyticsRepository,
    EntitlementService? entitlementService,
  })  : _localStore = localStore,
        _aiGatewayClient = aiGatewayClient,
        _lifeGraphRepository = lifeGraphRepository,
        _runtimeConfigClient = runtimeConfigClient,
        _localExportService =
            localExportService ?? ProtectedLocalExportService(),
        _submissionAssetVault =
            submissionAssetVault ?? ProtectedSubmissionAssetVault(),
        _localAnalyticsRepository =
            localAnalyticsRepository ??
                LocalAnalyticsRepository(localStore: localStore),
        _entitlementService =
            entitlementService ?? EntitlementService(localStore: localStore);

  final LocalStore _localStore;
  final AiGatewayClient _aiGatewayClient;
  final LifeGraphRepository _lifeGraphRepository;
  final RuntimeConfigClient? _runtimeConfigClient;
  final LocalExportService _localExportService;
  final SubmissionAssetVault _submissionAssetVault;
  final LocalAnalyticsRepository _localAnalyticsRepository;
  final EntitlementService _entitlementService;
  final CaptureParser _captureParser = const CaptureParser();

  bool _isReady = false;
  PrivacySettings _privacySettings = PrivacySettings.defaults();
  List<DailyMission> _dailyMissions = <DailyMission>[];
  List<DailyRisk> _cachedDailyRisks = <DailyRisk>[];
  List<MissionSet> _missionSets = <MissionSet>[];
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
  List<OwnedItem> _ownedItems = <OwnedItem>[];
  List<PurchaseProof> _purchaseProofs = <PurchaseProof>[];
  List<WarrantyRecord> _warrantyRecords = <WarrantyRecord>[];
  List<MaintenanceReminder> _maintenanceReminders = <MaintenanceReminder>[];
  List<ClaimDraft> _claimDrafts = <ClaimDraft>[];
  List<EvidenceAttachment> _evidenceAttachments = <EvidenceAttachment>[];
  List<EvidenceItem> _evidenceItems = <EvidenceItem>[];
  List<LifeGraphRelation> _lifeGraphRelations = <LifeGraphRelation>[];
  List<PrivacyAuditEntry> _privacyAuditEntries = <PrivacyAuditEntry>[];
  List<AnalyticsEvent> _analyticsEvents = <AnalyticsEvent>[];
  Entitlement _entitlement = Entitlement.disabledSafeDefault();
  List<MentalLoadItem> _mentalLoadItems = <MentalLoadItem>[];
  List<DecisionCard> _decisionCards = <DecisionCard>[];
  List<ShoppingNeed> _shoppingNeeds = <ShoppingNeed>[];
  List<ProductEvidenceCard> _productEvidenceCards = <ProductEvidenceCard>[];
  bool _sensitiveLocalEncryptionEnabled = false;
  AppLocalePreference _localePreference = AppLocalePreference.system;
  AppProfilePreferences _profilePreferences = AppProfilePreferences.defaults();
  String _deviceLocaleTag = 'en';
  final Set<String> _sessionAnalyticsMarkers = <String>{};

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
  MissionSet? get currentMissionSet =>
      _missionSets.isEmpty ? null : _missionSets.first;
  List<MissionSet> get missionSets =>
      List<MissionSet>.unmodifiable(_missionSets);
  List<LifeEvent> get lifeEvents => _lifeGraphRepository.allEvents();
  List<EvidenceItem> get evidenceItems =>
      List<EvidenceItem>.unmodifiable(_evidenceItems);
  List<LifeGraphRelation> get lifeGraphRelations =>
      List<LifeGraphRelation>.unmodifiable(_lifeGraphRelations);
  List<PrivacyAuditEntry> get privacyAuditEntries =>
      List<PrivacyAuditEntry>.unmodifiable(_privacyAuditEntries);
  List<AnalyticsEvent> get analyticsEvents =>
      List<AnalyticsEvent>.unmodifiable(_analyticsEvents);
  Entitlement get entitlement => _entitlement;
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
  List<OwnedItem> get ownedItems => List<OwnedItem>.unmodifiable(_ownedItems);
  List<PurchaseProof> get purchaseProofs =>
      List<PurchaseProof>.unmodifiable(_purchaseProofs);
  List<WarrantyRecord> get warrantyRecords =>
      List<WarrantyRecord>.unmodifiable(_warrantyRecords);
  List<MaintenanceReminder> get maintenanceReminders =>
      List<MaintenanceReminder>.unmodifiable(_maintenanceReminders);
  List<ClaimDraft> get claimDrafts =>
      List<ClaimDraft>.unmodifiable(_claimDrafts);
  List<EvidenceAttachment> get evidenceAttachments =>
      List<EvidenceAttachment>.unmodifiable(_evidenceAttachments);
  List<MentalLoadItem> get mentalLoadItems =>
      List<MentalLoadItem>.unmodifiable(_mentalLoadItems);
  List<DecisionCard> get decisionCards =>
      List<DecisionCard>.unmodifiable(_decisionCards);
  List<ShoppingNeed> get shoppingNeeds =>
      List<ShoppingNeed>.unmodifiable(_shoppingNeeds);
  List<ProductEvidenceCard> get productEvidenceCards =>
      List<ProductEvidenceCard>.unmodifiable(_productEvidenceCards);
  ProductEvidenceCard? productEvidenceForTitle(String title) {
    final lowered = title.toLowerCase();
    for (final item in _productEvidenceCards) {
      if (item.productName.toLowerCase() == lowered ||
          lowered.contains(item.productName.toLowerCase()) ||
          item.productName.toLowerCase().contains(lowered)) {
        return item;
      }
    }
    return null;
  }

  bool get sensitiveLocalEncryptionEnabled => _sensitiveLocalEncryptionEnabled;
  AppLocalePreference get localePreference => _localePreference;
  AppProfilePreferences get profilePreferences => _profilePreferences;
  Locale? get preferredLocale => _localePreference.locale;
  ThemeMode get themeMode => _profilePreferences.themePreference.themeMode;
  String get currentLocaleTag => _localePreference == AppLocalePreference.system
      ? normalizeLocaleTag(_deviceLocaleTag)
      : _localePreference.storageKey;
  List<String> get encryptedCollectionLabels => const <String>[
        'Life events',
        'Daily missions',
        'Daily risks',
        'Mission sets',
        'Entitlement state',
        'LifeGraph relations',
        'Finance records',
        'Calendar items',
        'Journal entries',
        'Quick notes',
        'Evidence items',
        'Owned items',
        'Purchase proofs',
        'Claim drafts',
        'Evidence attachments',
        'Privacy audit entries',
        'Mental load items',
        'Decision cards',
        'Shopping needs',
        'Product evidence cards',
      ];
  List<String> get alwaysLocalCollectionLabels => const <String>[
        'Privacy settings',
        'Entitlement state',
        'Journal entries',
        'Quick notes',
        'Owned items',
        'Purchase proofs',
        'Claim drafts',
        'Evidence attachments',
        'Mental load items',
        'Decision cards',
        'Shopping needs',
        'Product evidence cards',
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
  EntitlementGateResult entitlementGateForFeature(EntitlementFeature feature) {
    return _entitlementService.gateForFeature(
      feature,
      entitlement: _entitlement,
      analyticsEvents: _analyticsEvents,
    );
  }
  List<LifeEvent> get aiEligibleEvents => List<LifeEvent>.unmodifiable(
        lifeEvents.where(_eventEligibleForAi).toList(growable: false),
      );
  List<LifeEvent> get blockedFromAiEvents => List<LifeEvent>.unmodifiable(
        lifeEvents.where((event) => !_eventEligibleForAi(event)).toList(
              growable: false,
            ),
      );
  bool get hasOverloadedCalendarDay => _calendarItems.length >= 4;
  List<OwnedItem> get warrantyEndingSoonItems {
    final now = DateTime.now().toUtc();
    final soon = now.add(const Duration(days: 45));
    final items = _ownedItems.where((item) {
      final warrantyDate = _tryParseDate(item.warrantyUntil);
      if (warrantyDate == null) {
        return false;
      }
      return !warrantyDate.isBefore(now) && !warrantyDate.isAfter(soon);
    }).toList(growable: false);
    items.sort((left, right) {
      final leftDate = _tryParseDate(left.warrantyUntil) ?? DateTime(2100);
      final rightDate = _tryParseDate(right.warrantyUntil) ?? DateTime(2100);
      return leftDate.compareTo(rightDate);
    });
    return List<OwnedItem>.unmodifiable(items);
  }

  List<PurchaseProof> get recentPurchaseProofs {
    final items = List<PurchaseProof>.from(_purchaseProofs);
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return List<PurchaseProof>.unmodifiable(items.take(5).toList());
  }

  List<MaintenanceReminder> get upcomingMaintenanceReminders {
    final items = List<MaintenanceReminder>.from(_maintenanceReminders);
    items.sort((left, right) => left.dueDate.compareTo(right.dueDate));
    return List<MaintenanceReminder>.unmodifiable(items.take(5).toList());
  }

  List<MentalLoadItem> get pendingMentalLoadItems {
    final items = _mentalLoadItems
        .where((item) => item.state != 'completed' && item.state != 'rejected')
        .toList(growable: false);
    return List<MentalLoadItem>.unmodifiable(items);
  }

  MentalLoadItem? get primaryMentalLoadItem =>
      pendingMentalLoadItems.isEmpty ? null : pendingMentalLoadItems.first;

  List<DecisionCard> get activeDecisionCards {
    final cards = _decisionCards
        .where(
            (card) => card.status != 'completed' && card.status != 'rejected')
        .toList(growable: false);
    return List<DecisionCard>.unmodifiable(cards);
  }

  DecisionCard? get primaryDecisionCard =>
      activeDecisionCards.isEmpty ? null : activeDecisionCards.first;

  List<DecisionCard> get homeMemoryDecisionCards =>
      List<DecisionCard>.unmodifiable(
        activeDecisionCards
            .where((card) => card.domainTargets.contains('homememory'))
            .toList(growable: false),
      );

  List<DecisionCard> get secondaryDecisionCards {
    final cards = activeDecisionCards;
    if (cards.length <= 1) {
      return const <DecisionCard>[];
    }
    return List<DecisionCard>.unmodifiable(
        cards.skip(1).toList(growable: false));
  }

  List<ShoppingNeed> get activeShoppingNeeds {
    final needs = _shoppingNeeds
        .where((need) => need.state != 'fulfilled' && need.state != 'rejected')
        .toList(growable: false);
    return List<ShoppingNeed>.unmodifiable(needs);
  }

  bool get hasShoppingAlert => activeShoppingNeeds.isNotEmpty;

  List<MentalLoadItem> get homeMemoryMentalLoadItems =>
      List<MentalLoadItem>.unmodifiable(
        pendingMentalLoadItems
            .where((item) => item.domain == 'homememory')
            .toList(growable: false),
      );

  bool featureFlagEnabled(String key, {bool fallback = true}) {
    final runtimeValue = _runtimeConfig?.featureFlags[key];
    return runtimeValue ?? fallback;
  }

  List<ClaimDraft> get activeClaimDrafts {
    return List<ClaimDraft>.unmodifiable(
      _claimDrafts.where((item) => item.status == ClaimDraftStatus.draft),
    );
  }

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
    _profilePreferences = await _localStore.loadProfilePreferences();
    _sensitiveLocalEncryptionEnabled =
        await _localStore.supportsSensitiveLocalEncryption();
    _runtimeConfig = await _localStore.loadRuntimeConfig();
    _applyRuntimeConfig();
    await _lifeGraphRepository.bootstrap();
    _dailyMissions = await _localStore.loadDailyMissions();
    _cachedDailyRisks = await _localStore.loadDailyRisks();
    _missionSets = await _localStore.loadMissionSets();
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
    _ownedItems = await _localStore.loadOwnedItems();
    _purchaseProofs = await _localStore.loadPurchaseProofs();
    _warrantyRecords = await _localStore.loadWarrantyRecords();
    _maintenanceReminders = await _localStore.loadMaintenanceReminders();
    _claimDrafts = await _localStore.loadClaimDrafts();
    _evidenceAttachments = await _localStore.loadEvidenceAttachments();
    _evidenceItems = await _localStore.loadEvidenceItems();
    _lifeGraphRelations = await _localStore.loadLifeGraphRelations();
    _privacyAuditEntries = await _localStore.loadPrivacyAuditEntries();
    _analyticsEvents = await _localAnalyticsRepository.loadEvents();
    _entitlement = await _entitlementService.loadEntitlement();
    _mentalLoadItems = await _localStore.loadMentalLoadItems();
    _decisionCards = await _localStore.loadDecisionCards();
    _shoppingNeeds = await _localStore.loadShoppingNeeds();
    _productEvidenceCards = await _localStore.loadProductEvidenceCards();
    await _recordAnalyticsEvent(
      'entitlement_loaded',
      source: 'entitlement_runtime',
      metadata: <String, Object?>{
        'plan': _entitlement.plan.storageKey,
        'billing_provider': _entitlement.billingProvider,
        'renewal_state': _entitlement.renewalState,
        'trial_status': _entitlement.trialStatus,
        'daily_mission_refreshes':
            _entitlement.quota.dailyMissionRefreshes,
        'ai_assisted_captures': _entitlement.quota.aiAssistedCaptures,
        'export_bundles': _entitlement.quota.exportBundles,
      },
    );
    if (_dailyMissions.isEmpty && _missionSets.isNotEmpty) {
      _dailyMissions = _missionSets.first.missions;
    }
    await _syncDerivedEvidenceItems(notifyStore: false);
    await _rebuildDerivedLifeGraphRelations(notifyStore: false);
    await _seedDomainEntitiesIfNeeded();
    await _refreshMissionPlan();
    await refreshDecisionPlan(notify: false);
    await refreshShoppingPlan(notify: false);
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
      await refreshDecisionPlan(notify: false);
      await refreshShoppingPlan(notify: false);
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> updatePermission(
    DomainKey domain,
    DataPermission permission,
  ) async {
    final previousPermission = _privacySettings.permissionFor(domain);
    if (previousPermission == permission) {
      return;
    }
    _privacySettings = _privacySettings.copyWithPermission(domain, permission);
    await _localStore.savePrivacySettings(_privacySettings);
    await _recordAnalyticsEvent(
      'privacy_setting_changed',
      source: 'privacy_settings',
      metadata: <String, Object?>{
        'scope': 'domain',
        'domain': domain.storageKey,
        'old_permission': previousPermission.storageKey,
        'new_permission': permission.storageKey,
        'ai_enabled_domain_count': _privacySettings.aiAllowedDomains.length,
      },
    );
    await _refreshMissionPlan();
    notifyListeners();
  }

  Future<void> updateEventPrivacy(
    String eventId,
    DataPermission permission,
  ) async {
    final currentEvents = lifeEvents.reversed.toList(growable: false);
    final targetIndex =
        currentEvents.indexWhere((event) => event.eventId == eventId);
    if (targetIndex < 0) {
      return;
    }

    final currentEvent = currentEvents[targetIndex];
    final nextPrivacyLevel = permission.storageKey;
    if (currentEvent.privacyLevel == nextPrivacyLevel) {
      return;
    }

    final updatedEvent = LifeEvent(
      eventId: currentEvent.eventId,
      userId: currentEvent.userId,
      domain: currentEvent.domain,
      eventType: currentEvent.eventType,
      timestampIso: currentEvent.timestampIso,
      payload: currentEvent.payload,
      source: currentEvent.source,
      privacyLevel: nextPrivacyLevel,
      evidenceHash: currentEvent.evidenceHash,
    );

    final mutable = List<LifeEvent>.from(currentEvents);
    mutable[targetIndex] = updatedEvent;
    await _lifeGraphRepository.replaceAll(mutable);
    _privacyAuditEntries = _upsertById(
      _privacyAuditEntries,
      PrivacyAuditEntry(
        auditId: _entityId('privacy-audit'),
        eventId: eventId,
        oldPrivacyLevel: currentEvent.privacyLevel,
        newPrivacyLevel: nextPrivacyLevel,
        changedAt: DateTime.now().toUtc().toIso8601String(),
      ),
      (item) => item.auditId,
    );
    await _localStore.savePrivacyAuditEntries(_privacyAuditEntries);
    await _recordAnalyticsEvent(
      'event_privacy_changed',
      source: 'privacy_event',
      metadata: <String, Object?>{
        'scope': 'event',
        'event_id': eventId,
        'domain': currentEvent.domain,
        'old_permission': currentEvent.privacyLevel,
        'new_permission': nextPrivacyLevel,
        'was_ai_eligible': _eventEligibleForAi(currentEvent),
        'is_ai_eligible': permission == DataPermission.aiAllowed &&
            _privacySettings.permissionForWireDomain(currentEvent.domain) ==
                DataPermission.aiAllowed,
      },
    );
    await _syncDerivedEvidenceItems(notifyStore: true);
    await _rebuildDerivedLifeGraphRelations(notifyStore: true);
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

  Future<void> updateThemePreference(AppThemePreference preference) async {
    _profilePreferences = _profilePreferences.copyWith(
      themePreference: preference,
    );
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateNotificationsPreference(
    NotificationPreference preference,
  ) async {
    _profilePreferences = _profilePreferences.copyWith(
      notifications: preference,
    );
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateQuietHoursPreference(
    QuietHoursPreference preference,
  ) async {
    _profilePreferences = _profilePreferences.copyWith(
      quietHours: preference,
    );
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateMeasurementUnitsPreference(
    MeasurementUnitPreference preference,
  ) async {
    _profilePreferences = _profilePreferences.copyWith(
      measurementUnits: preference,
    );
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateRegionPreference(RegionPreference preference) async {
    _profilePreferences = _profilePreferences.copyWith(region: preference);
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateReminderFrequencyPreference(
    ReminderFrequencyPreference preference,
  ) async {
    _profilePreferences = _profilePreferences.copyWith(
      reminderFrequency: preference,
    );
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateAiDetailPreference(AiDetailPreference preference) async {
    _profilePreferences = _profilePreferences.copyWith(aiDetail: preference);
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateBackupSyncPreference(
    BackupSyncPreference preference,
  ) async {
    _profilePreferences = _profilePreferences.copyWith(
      backupSync: preference,
    );
    await _localStore.saveProfilePreferences(_profilePreferences);
    notifyListeners();
  }

  Future<void> updateCurrentPlanPreference(
    CurrentPlanPreference preference,
  ) async {
    _profilePreferences = _profilePreferences.copyWith(currentPlan: preference);
    await _localStore.saveProfilePreferences(_profilePreferences);
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

    if (localDrafts.isEmpty) {
      await _recordAnalyticsEvent(
        'capture_parsed',
        source: 'capture_parser',
        metadata: <String, Object?>{
          'parser': 'safety_blocked',
          'draft_count': 0,
          'forced_domain': forcedDomain?.storageKey,
          'remote': false,
          'fallback_used': false,
        },
      );
      return const <CaptureDraftItem>[];
    }

    if (forcedDomain != null || localDrafts.length != 1) {
      await _recordAnalyticsEvent(
        'capture_parsed',
        source: 'capture_parser',
        metadata: <String, Object?>{
          'parser': forcedDomain != null ? 'forced_local' : 'multi_local',
          'draft_count': localDrafts.length,
          'forced_domain': forcedDomain?.storageKey,
          'remote': false,
          'fallback_used': false,
          'domains': _captureDraftDomains(localDrafts),
        },
      );
      return localDrafts;
    }

    final aiCaptureGate = await _recordFeatureGateChecked(
      EntitlementFeature.aiAssistedCaptures,
      source: 'capture_parser',
      trigger: 'prepare_capture',
    );
    if (!aiCaptureGate.allowed) {
      await _recordAnalyticsEvent(
        'capture_parsed',
        source: 'capture_parser',
        metadata: <String, Object?>{
          'parser': 'local_fallback',
          'draft_count': localDrafts.length,
          'remote': false,
          'fallback_used': true,
          'domains': _captureDraftDomains(localDrafts),
          'reason_code': 'entitlement_ai_capture_quota',
        },
      );
      await _recordAnalyticsEvent(
        'fallback_used',
        source: 'capture_parser',
        metadata: const <String, Object?>{
          'operation': 'capture_parse',
          'reason_code': 'entitlement_ai_capture_quota',
        },
      );
      return localDrafts;
    }

    try {
      final parsed = await _aiGatewayClient.parseCapture(
        locale: currentLocaleTag,
        privacySettings: _privacySettings,
        text: trimmed,
      );
      if (parsed != null && parsed.items.isNotEmpty) {
        final gatewayDrafts = _captureParser.parse(
          text: trimmed,
          privacySettings: _privacySettings,
          gatewayItems: parsed.items,
        );
        await _recordAnalyticsEvent(
          'capture_parsed',
          source: 'capture_gateway',
          metadata: <String, Object?>{
            'parser': 'gateway_parse',
            'draft_count': gatewayDrafts.length,
            'remote': true,
            'fallback_used': false,
            'domains': _captureDraftDomains(gatewayDrafts),
          },
        );
        return gatewayDrafts;
      }
      final classification = await classifyCaptureText(trimmed);
      if (classification == null) {
        await _recordAnalyticsEvent(
          'capture_parsed',
          source: 'capture_parser',
          metadata: <String, Object?>{
            'parser': 'local_fallback',
            'draft_count': localDrafts.length,
            'remote': false,
            'fallback_used': true,
            'domains': _captureDraftDomains(localDrafts),
            'reason_code': 'classification_unavailable',
          },
        );
        await _recordAnalyticsEvent(
          'fallback_used',
          source: 'capture_parser',
          metadata: const <String, Object?>{
            'operation': 'capture_classification',
            'reason_code': 'classification_unavailable',
          },
        );
        return localDrafts;
      }
      final classifiedDrafts = _captureParser.parse(
        text: trimmed,
        privacySettings: _privacySettings,
        gatewayClassification: classification,
      );
      final classificationFallback = classification.trace['clientFallback'] ==
              true ||
          classification.trace['mock'] == true ||
          classification.trace['mock_mode'] == true;
      await _recordAnalyticsEvent(
        'capture_parsed',
        source: classificationFallback
            ? 'capture_parser'
            : 'capture_classification',
        metadata: <String, Object?>{
          'parser': classificationFallback
              ? 'classification_fallback'
              : 'gateway_classification',
          'draft_count': classifiedDrafts.length,
          'remote': !classificationFallback,
          'fallback_used': classificationFallback,
          'domains': _captureDraftDomains(classifiedDrafts),
        },
      );
      if (classificationFallback) {
        await _recordAnalyticsEvent(
          'fallback_used',
          source: 'capture_parser',
          metadata: const <String, Object?>{
            'operation': 'capture_classification',
            'reason_code': 'classification_fallback',
          },
        );
      }
      return classifiedDrafts;
    } catch (_) {
      await _recordAnalyticsEvent(
        'capture_parsed',
        source: 'capture_parser',
        metadata: <String, Object?>{
          'parser': 'local_fallback',
          'draft_count': localDrafts.length,
          'remote': false,
          'fallback_used': true,
          'domains': _captureDraftDomains(localDrafts),
          'reason_code': 'gateway_parse_exception',
        },
      );
      await _recordAnalyticsEvent(
        'fallback_used',
        source: 'capture_parser',
        metadata: const <String, Object?>{
          'operation': 'capture_parse',
          'reason_code': 'gateway_parse_exception',
        },
      );
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
      final event = LifeEventFactory.create(
        domain: draft.domain.wireName,
        type: draft.eventType,
        summary: draft.text,
        privacyLevel: draft.privacyLevel,
        payload: {
          'summary': draft.text,
          'capturedFrom': 'capture_screen',
          'rationale': draft.rationale,
          'confidence': draft.confidence,
          'hints': draft.hints,
          'multiCapture': drafts.length > 1,
        },
      );
      await _recordEvent(
        event: event,
        refreshPlan: false,
        notifyAfter: false,
      );
      await _upsertMentalLoadItem(
        mentalLoadItemFromDraft(
          draft,
          userId: 'local-user',
          sourceEventId: event.eventId,
        ),
      );
      final shoppingNeed = _deriveShoppingNeedFromDraft(
        draft,
        sourceEventId: event.eventId,
      );
      if (shoppingNeed != null) {
        await _upsertShoppingNeed(shoppingNeed);
      }
      await _createReminderCandidateIfNeeded(draft);
    }

    await _recordAnalyticsEvent(
      'capture_created',
      source: 'capture_screen',
      metadata: <String, Object?>{
        'draft_count': drafts.length,
        'multi_capture': drafts.length > 1,
        'domains': _captureDraftDomains(drafts),
        'ai_allowed_draft_count': drafts
            .where(
              (draft) =>
                  draft.privacyLevel == DataPermission.aiAllowed.storageKey,
            )
            .length,
      },
    );
    await _refreshMissionPlan();
    await refreshDecisionPlan(notify: false);
    await refreshShoppingPlan(notify: false);
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

  Future<void> refreshDecisionPlan({bool notify = true}) async {
    final dto = await _aiGatewayClient.fetchDecisionPlan(
      locale: currentLocaleTag,
      privacySettings: _privacySettings,
      mentalLoadItems: _mentalLoadItems
          .map((item) => Map<String, Object?>.from(item.toJson()))
          .toList(growable: false),
    );
    final remoteCards =
        dto.decisions.map(_decisionCardFromDto).toList(growable: false);
    final nextCards =
        remoteCards.isNotEmpty ? remoteCards : _buildLocalDecisionFallback();
    _decisionCards = nextCards;
    await _localStore.saveDecisionCards(_decisionCards);
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshShoppingPlan({bool notify = true}) async {
    final derivedNeeds = _deriveLocalShoppingNeeds();
    if (derivedNeeds.isNotEmpty) {
      _shoppingNeeds = _mergeById(
        _shoppingNeeds,
        derivedNeeds,
        (item) => item.id,
      );
      await _localStore.saveShoppingNeeds(_shoppingNeeds);
    }

    final dto = await _aiGatewayClient.optimizeShoppingList(
      locale: currentLocaleTag,
      privacySettings: _privacySettings,
      shoppingNeeds: _shoppingNeeds
          .map((item) => Map<String, Object?>.from(item.toJson()))
          .toList(growable: false),
      pantryContext: _pantryItems
          .map((item) => Map<String, Object?>.from(item.toJson()))
          .toList(growable: false),
      financeContext: _expenses
          .map((item) => Map<String, Object?>.from(item.toJson()))
          .toList(growable: false),
      wardrobeContext: _purchaseIntentions
          .map((item) => Map<String, Object?>.from(item.toJson()))
          .toList(growable: false),
      homememoryContext: <Map<String, Object?>>[
        ..._ownedItems.map((item) => Map<String, Object?>.from(item.toJson())),
        ..._purchaseProofs
            .map((item) => Map<String, Object?>.from(item.toJson())),
      ],
    );

    final nextNeeds =
        dto.needs.map(_shoppingNeedFromDto).toList(growable: false);
    if (nextNeeds.isNotEmpty) {
      _shoppingNeeds = _mergeById(
        _shoppingNeeds,
        nextNeeds,
        (item) => item.id,
      );
      await _localStore.saveShoppingNeeds(_shoppingNeeds);
    }

    final evidenceCards = dto.productEvidence
        .map(_productEvidenceCardFromDto)
        .toList(growable: false);
    if (evidenceCards.isNotEmpty) {
      for (final card in evidenceCards) {
        await _upsertProductEvidenceCard(card);
      }
    }

    final shoppingDecisions =
        dto.decisions.map(_decisionCardFromDto).toList(growable: false);
    if (shoppingDecisions.isNotEmpty) {
      _decisionCards = _mergeById(
        _decisionCards,
        shoppingDecisions,
        (item) => item.id,
      );
      await _localStore.saveDecisionCards(_decisionCards);
    }

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> fetchProductEvidenceForNeed(
    ShoppingNeed need, {
    bool notify = true,
  }) async {
    if (!featureFlagEnabled('shopping_external_sources', fallback: false)) {
      await _upsertProductEvidenceCard(
        ProductEvidenceCard(
          id: 'evidence-flag-${need.id}',
          userId: need.userId,
          productName: need.title,
          brand: null,
          merchantName: null,
          price: need.budgetHint,
          currency: need.currency,
          source: 'external_sources_disabled',
          checkedAtIso: DateTime.now().toUtc().toIso8601String(),
          reviewSummary: null,
          sustainabilityStatus: 'insufficient_verified_data',
          confidence: 0.0,
          disclaimer: 'External shopping evidence is disabled by feature flag.',
          trace: const <String, Object?>{
            'feature_flag_blocked': true,
          },
        ),
      );
      if (notify) {
        notifyListeners();
      }
      return;
    }

    final dto = await _aiGatewayClient.fetchProductEvidence(
      locale: currentLocaleTag,
      privacySettings: _privacySettings,
      productName: need.title,
    );
    if (dto == null) {
      return;
    }
    await _upsertProductEvidenceCard(_productEvidenceCardFromDto(dto));
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> acceptDecisionCard(String id) async {
    await _updateDecisionCardStatus(id, 'accepted');
  }

  Future<void> completeDecisionCard(String id) async {
    await _updateDecisionCardStatus(id, 'completed');
  }

  Future<void> postponeDecisionCard(String id) async {
    await _updateDecisionCardStatus(id, 'postponed');
  }

  Future<void> rejectDecisionCard(String id) async {
    await _updateDecisionCardStatus(id, 'rejected');
  }

  Future<String?> createReminderFromDecisionCard(String id) async {
    final card = _decisionCards.firstWhere(
      (item) => item.id == id,
      orElse: () => primaryDecisionCard ?? _buildFallbackDecisionCard(),
    );
    final start = DateTime.now().toUtc().add(const Duration(hours: 2));
    final calendarItem = CalendarItem(
      id: _entityId('calendar'),
      title: card.title,
      startIso: start.toIso8601String(),
      endIso: start.add(const Duration(minutes: 30)).toIso8601String(),
      location: 'MindFlow',
      energy: 'steady',
    );
    await _upsertCalendarItem(calendarItem);
    await _recordEvent(
      event: calendarItem.toLifeEvent(
        'decision_reminder_created',
        privacyLevel: _privacyLevelForDomain('calendar'),
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    await _updateDecisionCardStatus(id, 'scheduled', notifyAfter: false);
    notifyListeners();
    return _controllerText('reminder_created');
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

  Future<void> deleteJournalEntryById(String id) => _deleteEntity<JournalEntry>(
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

  Future<void> deleteCalendarItemById(String id) => _deleteEntity<CalendarItem>(
        id: id,
        current: _calendarItems,
        idOf: (item) => item.id,
        assign: (next) => _calendarItems = next,
        deleteFromStore: _localStore.deleteCalendarItem,
      );

  Future<void> deleteRecipeRescueById(String id) => _deleteEntity<RecipeRescue>(
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

  OwnedItem? ownedItemById(String id) {
    for (final item in _ownedItems) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  List<PurchaseProof> purchaseProofsForItem(String ownedItemId) {
    final items = _purchaseProofs
        .where((item) => item.ownedItemId == ownedItemId)
        .toList(growable: false);
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  PurchaseProof? purchaseProofById(String id) {
    for (final item in _purchaseProofs) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  WarrantyRecord? warrantyRecordForItem(String ownedItemId) {
    for (final item in _warrantyRecords.reversed) {
      if (item.ownedItemId == ownedItemId) {
        return item;
      }
    }
    return null;
  }

  List<MaintenanceReminder> maintenanceRemindersForItem(String ownedItemId) {
    final items = _maintenanceReminders
        .where((item) => item.ownedItemId == ownedItemId)
        .toList(growable: false);
    items.sort((left, right) => left.dueDate.compareTo(right.dueDate));
    return items;
  }

  List<ClaimDraft> claimDraftsForItem(String ownedItemId) {
    final items = _claimDrafts
        .where((item) => item.ownedItemId == ownedItemId)
        .toList(growable: false);
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  List<EvidenceAttachment> evidenceAttachmentsForItem(String ownedItemId) {
    final items = _evidenceAttachments
        .where((item) => item.ownedItemId == ownedItemId)
        .toList(growable: false);
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  EvidenceAttachment? evidenceAttachmentById(String id) {
    for (final item in _evidenceAttachments) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Future<String?> saveOwnedItemManual({
    String? id,
    required String name,
    String brand = '',
    String model = '',
    String serialNumber = '',
    String category = 'general',
    String? purchaseDate,
    double? purchasePrice,
    String currency = 'EUR',
    String store = '',
    int? warrantyMonths,
    String notes = '',
    String privacyLevel = 'local_only',
    bool createWarrantyReminder = false,
  }) async {
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final itemId = id ?? _entityId('owned-item');
    final warrantyUntil = warrantyMonths == null || purchaseDate == null
        ? null
        : _addMonthsToIso(purchaseDate, warrantyMonths);
    String? reminderId;
    if (createWarrantyReminder && warrantyUntil != null) {
      reminderId = _entityId('maintenance');
    }

    final ownedItem = OwnedItem(
      id: itemId,
      userId: 'local-user',
      name: name.trim(),
      brand: brand.trim(),
      model: model.trim(),
      serialNumber: serialNumber.trim(),
      category: category.trim().isEmpty ? 'general' : category.trim(),
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      currency: currency.trim().isEmpty ? 'EUR' : currency.trim(),
      store: store.trim(),
      warrantyUntil: warrantyUntil,
      warrantySource: warrantyMonths == null
          ? WarrantySource.unknown
          : WarrantySource.explicit,
      maintenanceReminderIds:
          reminderId == null ? const <String>[] : <String>[reminderId],
      notes: notes.trim(),
      privacyLevel: privacyLevel,
      createdAt: nowIso,
      updatedAt: nowIso,
    );

    await _upsertOwnedItem(ownedItem);

    WarrantyRecord? warrantyRecord;
    if (warrantyMonths != null) {
      warrantyRecord = WarrantyRecord(
        id: _entityId('warranty'),
        userId: 'local-user',
        ownedItemId: itemId,
        warrantyUntil: warrantyUntil,
        warrantySource: WarrantySource.explicit,
        warrantyMonths: warrantyMonths,
        disclaimer: _controllerText('warranty_verify_disclaimer'),
        createdAt: nowIso,
      );
      await _upsertWarrantyRecord(warrantyRecord);
    }

    MaintenanceReminder? reminder;
    if (reminderId != null && warrantyUntil != null) {
      reminder = MaintenanceReminder(
        id: reminderId,
        userId: 'local-user',
        ownedItemId: itemId,
        title: _controllerText('review_warranty_before_expiration'),
        dueDate: _daysBeforeIso(warrantyUntil, 14),
        recurrence: 'none',
        status: MaintenanceReminderStatus.scheduled,
        createdAt: nowIso,
      );
      await _upsertMaintenanceReminder(reminder);
    }

    await _recordEvent(
      event: _homeMemoryEvent(
        type: 'owned_item_created',
        summary: ownedItem.displayName,
        privacyLevel: privacyLevel,
        payload: {
          'ownedItemId': itemId,
          'category': ownedItem.category,
          'store': ownedItem.store,
        },
      ),
      refreshPlan: false,
      notifyAfter: false,
    );

    if (warrantyRecord != null) {
      await _recordEvent(
        event: _homeMemoryEvent(
          type: 'warranty_detected',
          summary: ownedItem.displayName,
          privacyLevel: privacyLevel,
          payload: {
            'ownedItemId': itemId,
            'warrantyUntil': warrantyRecord.warrantyUntil,
            'warrantySource': warrantyRecord.warrantySource,
          },
        ),
        refreshPlan: false,
        notifyAfter: false,
      );
    }

    if (reminder != null) {
      await _recordEvent(
        event: _homeMemoryEvent(
          type: 'maintenance_scheduled',
          summary: reminder.title,
          privacyLevel: privacyLevel,
          payload: {
            'ownedItemId': itemId,
            'maintenanceReminderId': reminder.id,
            'dueDate': reminder.dueDate,
          },
        ),
        refreshPlan: false,
        notifyAfter: false,
      );
    }

    await _rebuildDerivedLifeGraphRelations(notifyStore: true);
    await _refreshMissionPlan();
    notifyListeners();
    return _controllerText(
      id == null ? 'owned_item_saved' : 'owned_item_updated',
    );
  }

  Future<String?> saveManualPurchaseProof({
    required String productName,
    String brand = '',
    String model = '',
    String serialNumber = '',
    String category = 'general',
    String store = '',
    String? purchaseDate,
    double? price,
    String currency = 'EUR',
    int? warrantyMonths,
    String notes = '',
    String? fileRef,
    String privacyLevel = 'local_only',
    bool createWarrantyReminder = true,
  }) async {
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final ownedItemId = _entityId('owned-item');
    final proofId = _entityId('proof');
    final warrantyUntil = warrantyMonths == null || purchaseDate == null
        ? null
        : _addMonthsToIso(purchaseDate, warrantyMonths);
    String? reminderId;
    if (createWarrantyReminder && warrantyUntil != null) {
      reminderId = _entityId('maintenance');
    }
    final storedProofFileRef = await _persistSubmissionAsset(
      collection: 'purchase_proofs',
      entityId: proofId,
      sourcePath: fileRef,
    );

    final ownedItem = OwnedItem(
      id: ownedItemId,
      userId: 'local-user',
      name: productName.trim(),
      brand: brand.trim(),
      model: model.trim(),
      serialNumber: serialNumber.trim(),
      category: category.trim().isEmpty ? 'general' : category.trim(),
      purchaseDate: purchaseDate,
      purchasePrice: price,
      currency: currency.trim().isEmpty ? 'EUR' : currency.trim(),
      store: store.trim(),
      warrantyUntil: warrantyUntil,
      warrantySource: warrantyMonths == null
          ? WarrantySource.unknown
          : WarrantySource.explicit,
      proofIds: <String>[proofId],
      maintenanceReminderIds:
          reminderId == null ? const <String>[] : <String>[reminderId],
      notes: notes.trim(),
      privacyLevel: privacyLevel,
      createdAt: nowIso,
      updatedAt: nowIso,
    );

    final purchaseProof = PurchaseProof(
      id: proofId,
      userId: 'local-user',
      ownedItemId: ownedItemId,
      sourceType: PurchaseProofSourceType.manualEntry,
      merchantName: store.trim(),
      purchaseDate: purchaseDate,
      totalAmount: price,
      currency: currency.trim().isEmpty ? 'EUR' : currency.trim(),
      rawText: _buildManualProofText(
        productName: productName.trim(),
        brand: brand.trim(),
        model: model.trim(),
        store: store.trim(),
        purchaseDate: purchaseDate,
        price: price,
        currency: currency.trim().isEmpty ? 'EUR' : currency.trim(),
        warrantyMonths: warrantyMonths,
        notes: notes.trim(),
      ),
      fileRef: storedProofFileRef,
      extractedFields: {
        'product_name': productName.trim(),
        'brand': brand.trim(),
        'model': model.trim(),
        'merchant_name': store.trim(),
        'purchase_date': purchaseDate,
        'total_amount': price,
        'currency': currency.trim().isEmpty ? 'EUR' : currency.trim(),
        'warranty_months': warrantyMonths,
      },
      privacyLevel: privacyLevel,
      createdAt: nowIso,
    );

    await _upsertOwnedItem(ownedItem);
    await _upsertPurchaseProof(purchaseProof);

    WarrantyRecord? warrantyRecord;
    if (warrantyMonths != null) {
      warrantyRecord = WarrantyRecord(
        id: _entityId('warranty'),
        userId: 'local-user',
        ownedItemId: ownedItemId,
        warrantyUntil: warrantyUntil,
        warrantySource: WarrantySource.explicit,
        warrantyMonths: warrantyMonths,
        disclaimer: _controllerText('warranty_verify_disclaimer'),
        createdAt: nowIso,
      );
      await _upsertWarrantyRecord(warrantyRecord);
    }

    MaintenanceReminder? reminder;
    if (reminderId != null && warrantyUntil != null) {
      reminder = MaintenanceReminder(
        id: reminderId,
        userId: 'local-user',
        ownedItemId: ownedItemId,
        title: _controllerText('review_warranty_before_expiration'),
        dueDate: _daysBeforeIso(warrantyUntil, 14),
        recurrence: 'none',
        status: MaintenanceReminderStatus.scheduled,
        createdAt: nowIso,
      );
      await _upsertMaintenanceReminder(reminder);
    }

    await _recordEvent(
      event: _homeMemoryEvent(
        type: 'purchase_proof_added',
        summary: ownedItem.displayName,
        privacyLevel: privacyLevel,
        evidenceHash: proofId,
        payload: {
          'ownedItemId': ownedItemId,
          'purchaseProofId': proofId,
          'merchantName': purchaseProof.merchantName,
          'hasAmount': purchaseProof.totalAmount != null,
        },
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    await _recordEvent(
      event: _homeMemoryEvent(
        type: 'owned_item_created',
        summary: ownedItem.displayName,
        privacyLevel: privacyLevel,
        payload: {
          'ownedItemId': ownedItemId,
          'category': ownedItem.category,
          'store': ownedItem.store,
        },
      ),
      refreshPlan: false,
      notifyAfter: false,
    );

    if (warrantyRecord != null) {
      await _recordEvent(
        event: _homeMemoryEvent(
          type: 'warranty_detected',
          summary: ownedItem.displayName,
          privacyLevel: privacyLevel,
          payload: {
            'ownedItemId': ownedItemId,
            'warrantyUntil': warrantyRecord.warrantyUntil,
            'warrantySource': warrantyRecord.warrantySource,
          },
        ),
        refreshPlan: false,
        notifyAfter: false,
      );
    }

    if (reminder != null) {
      await _recordEvent(
        event: _homeMemoryEvent(
          type: 'maintenance_scheduled',
          summary: reminder.title,
          privacyLevel: privacyLevel,
          payload: {
            'ownedItemId': ownedItemId,
            'maintenanceReminderId': reminder.id,
            'dueDate': reminder.dueDate,
          },
        ),
        refreshPlan: false,
        notifyAfter: false,
      );
      await _upsertMentalLoadItem(
        _homeMemoryMentalLoadItem(
          id: 'mental-maintenance-${reminder.id}',
          type: 'maintenance_due',
          title: reminder.title,
          summary: _controllerText('maintenance_due_summary', {
            'item': ownedItem.displayName,
          }),
          urgencyScore: 0.74,
          dueHint: reminder.dueDate,
          privacyLevel: ownedItem.privacyLevel,
          sourceEventId: reminder.id,
          trace: <String, Object?>{
            'owned_item_id': ownedItem.id,
            'derived_from': 'maintenance_scheduled',
          },
        ),
      );
    }

    if (warrantyRecord != null) {
      await _upsertMentalLoadItem(
        _homeMemoryMentalLoadItem(
          id: 'mental-warranty-${ownedItem.id}',
          type: 'warranty_review',
          title: _controllerText('warranty_review_title', {
            'item': ownedItem.displayName,
          }),
          summary: _controllerText('warranty_review_summary', {
            'date': warrantyRecord.warrantyUntil ?? '',
          }),
          urgencyScore: 0.68,
          dueHint: warrantyRecord.warrantyUntil,
          privacyLevel: ownedItem.privacyLevel,
          sourceEventId: warrantyRecord.id,
          trace: <String, Object?>{
            'owned_item_id': ownedItem.id,
            'derived_from': 'warranty_detected',
            'warranty_until': warrantyRecord.warrantyUntil,
          },
        ),
      );
    }

    await _upsertProductEvidenceCard(
      _productEvidenceCardFromPurchaseProof(
        ownedItem: ownedItem,
        proof: purchaseProof,
      ),
    );

    await _rebuildDerivedLifeGraphRelations(notifyStore: true);
    await _refreshMissionPlan();
    await refreshDecisionPlan(notify: false);
    await refreshShoppingPlan(notify: false);
    notifyListeners();
    return _controllerText('purchase_proof_saved');
  }

  Future<String?> saveMaintenanceReminder({
    String? id,
    required String ownedItemId,
    required String title,
    required String dueDate,
    String recurrence = 'none',
    String status = MaintenanceReminderStatus.scheduled,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final reminder = MaintenanceReminder(
      id: id ?? _entityId('maintenance'),
      userId: 'local-user',
      ownedItemId: ownedItemId,
      title: title.trim(),
      dueDate: dueDate.trim(),
      recurrence: recurrence.trim().isEmpty ? 'none' : recurrence.trim(),
      status: MaintenanceReminderStatus.normalize(status),
      createdAt: nowIso,
    );
    await _upsertMaintenanceReminder(reminder);

    final target = ownedItemById(ownedItemId);
    if (target != null &&
        !target.maintenanceReminderIds.contains(reminder.id)) {
      await _upsertOwnedItem(
        OwnedItem(
          id: target.id,
          userId: target.userId,
          name: target.name,
          brand: target.brand,
          model: target.model,
          serialNumber: target.serialNumber,
          category: target.category,
          purchaseDate: target.purchaseDate,
          purchasePrice: target.purchasePrice,
          currency: target.currency,
          store: target.store,
          warrantyUntil: target.warrantyUntil,
          warrantySource: target.warrantySource,
          proofIds: target.proofIds,
          maintenanceReminderIds: <String>[
            ...target.maintenanceReminderIds,
            reminder.id,
          ],
          claimDraftIds: target.claimDraftIds,
          notes: target.notes,
          privacyLevel: target.privacyLevel,
          createdAt: target.createdAt,
          updatedAt: nowIso,
        ),
      );
    }

    await _recordEvent(
      event: _homeMemoryEvent(
        type: 'maintenance_scheduled',
        summary: reminder.title,
        privacyLevel: target?.privacyLevel ??
            _privacySettings
                .permissionForWireDomain(
                  'system',
                )
                .storageKey,
        payload: {
          'ownedItemId': ownedItemId,
          'maintenanceReminderId': reminder.id,
          'dueDate': reminder.dueDate,
        },
      ),
    );
    await _rebuildDerivedLifeGraphRelations(notifyStore: true);
    await _upsertMentalLoadItem(
      _homeMemoryMentalLoadItem(
        id: 'mental-maintenance-${reminder.id}',
        type: 'maintenance_due',
        title: reminder.title,
        summary: _controllerText('maintenance_due_summary', {
          'item': target?.displayName ?? title.trim(),
        }),
        urgencyScore: 0.72,
        dueHint: reminder.dueDate,
        privacyLevel: target?.privacyLevel ?? 'local_only',
        sourceEventId: reminder.id,
        trace: <String, Object?>{
          'owned_item_id': ownedItemId,
          'derived_from': 'maintenance_scheduled',
          'due_date': reminder.dueDate,
        },
      ),
    );
    await refreshDecisionPlan(notify: false);
    await refreshShoppingPlan(notify: false);
    notifyListeners();
    return _controllerText(id == null
        ? 'maintenance_reminder_saved'
        : 'maintenance_reminder_updated');
  }

  Future<String?> saveClaimDraft({
    String? id,
    required String ownedItemId,
    required String issueDescription,
    String recipientHint = '',
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final item = ownedItemById(ownedItemId);
    final title = item == null
        ? _controllerText('claim_draft_default_title')
        : _controllerText('claim_draft_title_for_item', {
            'item': item.displayName,
          });
    final claimDraft = ClaimDraft(
      id: id ?? _entityId('claim'),
      userId: 'local-user',
      ownedItemId: ownedItemId,
      title: title,
      issueDescription: issueDescription.trim(),
      generatedMessage: _buildLocalClaimMessage(
        item: item,
        issueDescription: issueDescription.trim(),
        recipientHint: recipientHint.trim(),
      ),
      recipientHint: recipientHint.trim(),
      status: ClaimDraftStatus.draft,
      disclaimer: _controllerText('claim_disclaimer'),
      privacyLevel: item?.privacyLevel ?? 'local_only',
      createdAt: nowIso,
    );
    await _upsertClaimDraft(claimDraft);

    if (item != null && !item.claimDraftIds.contains(claimDraft.id)) {
      await _upsertOwnedItem(
        OwnedItem(
          id: item.id,
          userId: item.userId,
          name: item.name,
          brand: item.brand,
          model: item.model,
          serialNumber: item.serialNumber,
          category: item.category,
          purchaseDate: item.purchaseDate,
          purchasePrice: item.purchasePrice,
          currency: item.currency,
          store: item.store,
          warrantyUntil: item.warrantyUntil,
          warrantySource: item.warrantySource,
          proofIds: item.proofIds,
          maintenanceReminderIds: item.maintenanceReminderIds,
          claimDraftIds: <String>[...item.claimDraftIds, claimDraft.id],
          notes: item.notes,
          privacyLevel: item.privacyLevel,
          createdAt: item.createdAt,
          updatedAt: nowIso,
        ),
      );
    }

    await _recordEvent(
      event: _homeMemoryEvent(
        type: 'claim_draft_created',
        summary: claimDraft.title,
        privacyLevel: claimDraft.privacyLevel,
        payload: {
          'ownedItemId': ownedItemId,
          'claimDraftId': claimDraft.id,
          'recipientHint': claimDraft.recipientHint,
        },
      ),
    );
    await _rebuildDerivedLifeGraphRelations(notifyStore: true);
    await _upsertMentalLoadItem(
      _homeMemoryMentalLoadItem(
        id: 'mental-claim-${claimDraft.id}',
        type: 'claim_candidate',
        title: _controllerText('claim_candidate_title', {
          'item': item?.displayName ?? title,
        }),
        summary: _controllerText('claim_candidate_summary'),
        urgencyScore: 0.78,
        privacyLevel: claimDraft.privacyLevel,
        sourceEventId: claimDraft.id,
        trace: <String, Object?>{
          'owned_item_id': ownedItemId,
          'derived_from': 'claim_draft_created',
        },
      ),
    );
    await refreshDecisionPlan(notify: false);
    await refreshShoppingPlan(notify: false);
    notifyListeners();
    return _controllerText(
      id == null ? 'claim_draft_saved' : 'claim_draft_updated',
    );
  }

  Future<String?> saveEvidenceAttachment({
    String? id,
    required String ownedItemId,
    String? proofId,
    required String type,
    String? fileRef,
    String description = '',
    String privacyLevel = 'local_only',
  }) async {
    final attachmentId = id ?? _entityId('evidence');
    final existing = id == null ? null : evidenceAttachmentById(id);
    final storedFileRef = await _persistSubmissionAsset(
      collection: 'evidence_attachments',
      entityId: attachmentId,
      sourcePath: fileRef ?? existing?.fileRef,
    );
    if (existing != null &&
        existing.fileRef != null &&
        existing.fileRef != storedFileRef) {
      await _submissionAssetVault.deleteStoredAsset(existing.fileRef);
    }
    final attachment = EvidenceAttachment(
      id: attachmentId,
      userId: 'local-user',
      ownedItemId: ownedItemId,
      proofId: proofId,
      type: EvidenceAttachmentType.normalize(type),
      fileRef: storedFileRef,
      description: description.trim(),
      privacyLevel: privacyLevel,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    await _upsertEvidenceAttachment(attachment);
    await _recordEvent(
      event: _homeMemoryEvent(
        type: 'evidence_attachment_added',
        summary: description.trim().isEmpty ? attachment.type : description,
        privacyLevel: privacyLevel,
        evidenceHash: attachment.id,
        payload: {
          'ownedItemId': ownedItemId,
          'evidenceAttachmentId': attachment.id,
          'proofId': proofId,
          'type': attachment.type,
        },
      ),
    );
    await _rebuildDerivedLifeGraphRelations(notifyStore: true);
    return _controllerText(
      id == null ? 'evidence_attachment_saved' : 'evidence_attachment_updated',
    );
  }

  Future<String> exportLocalDataJson() async {
    await _recordAnalyticsEvent(
      'export_requested',
      source: 'local_export',
      metadata: const <String, Object?>{
        'export_format': 'json',
      },
    );
    final snapshot = await _buildLocalDataSnapshot();
    return const JsonEncoder.withIndent('  ').convert(snapshot);
  }

  Future<LocalExportResult> exportLocalDataFile() async {
    final assetEntries = await _submissionAssetVault
        .collectManifestEntries(_submissionAssetRefs);
    await _recordFeatureGateChecked(
      EntitlementFeature.exportBundles,
      source: 'local_export',
      trigger: 'bundle_export',
    );
    await _recordAnalyticsEvent(
      'export_requested',
      source: 'local_export',
      metadata: <String, Object?>{
        'export_format': 'bundle',
        'asset_count': assetEntries.length,
        'included_asset_count':
            assetEntries.where((entry) => entry.available).length,
      },
    );
    final snapshot = await _buildLocalDataSnapshot(assetEntries: assetEntries);
    final jsonPayload = const JsonEncoder.withIndent('  ').convert(snapshot);
    final exportAssets = assetEntries
        .where((entry) => entry.available)
        .map(
          (entry) => LocalExportAsset(
            sourcePath: entry.sourcePath,
            bundleRelativePath: entry.bundleRelativePath,
            byteCount: entry.byteCount,
          ),
        )
        .toList(growable: false);
    return _localExportService.saveExportBundle(
      baseFileName: 'golife_local_export',
      jsonPayload: jsonPayload,
      assets: exportAssets,
    );
  }

  Future<Map<String, Object?>> _buildLocalDataSnapshot({
    List<SubmissionAssetManifestEntry>? assetEntries,
  }) async {
    final resolvedAssetEntries = assetEntries ??
        await _submissionAssetVault
            .collectManifestEntries(_submissionAssetRefs);
    return <String, Object?>{
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'locale_preference': _localePreference.storageKey,
      'profile_preferences': _profilePreferences.toJson(),
      'privacy_settings': _privacySettings.toJson(),
      'runtime_config': _runtimeConfig?.toJson(),
      'entitlement': _entitlement.toJson(),
      'storage_security': {
        'sensitive_local_encryption': _sensitiveLocalEncryptionEnabled,
        'submission_assets_stored_separately': true,
        'encrypted_collections': const <String>[
          'life_events',
          'missions',
          'daily_risks',
          'mission_sets',
          'lifegraph_relations',
          'expenses',
          'calendar_items',
          'journal_entries',
          'quick_notes',
          'evidence_items',
          'owned_items',
          'purchase_proofs',
          'claim_drafts',
          'evidence_attachments',
          'privacy_audit_entries',
          'analytics_events',
          'entitlement_state',
          'mental_load_items',
          'decision_cards',
          'shopping_needs',
          'product_evidence_cards',
        ],
      },
      'submission_assets': {
        'storage_mode': 'separate_private_files',
        'managed_ref_prefix': ProtectedSubmissionAssetVault.managedRefPrefix,
        'bundle_directory': 'assets',
        'asset_count': resolvedAssetEntries.length,
        'included_asset_count':
            resolvedAssetEntries.where((entry) => entry.available).length,
        'entries': resolvedAssetEntries
            .map((entry) => entry.toJson())
            .toList(growable: false),
      },
      'life_events':
          lifeEvents.map((item) => item.toJson()).toList(growable: false),
      'missions':
          _dailyMissions.map((item) => item.toJson()).toList(growable: false),
      'daily_risks': _cachedDailyRisks
          .map((item) => item.toJson())
          .toList(growable: false),
      'mission_sets':
          _missionSets.map((item) => item.toJson()).toList(growable: false),
      'mission_feedback':
          _missionFeedback.map((item) => item.toJson()).toList(growable: false),
      'evidence_items':
          _evidenceItems.map((item) => item.toJson()).toList(growable: false),
      'lifegraph_relations': _lifeGraphRelations
          .map((item) => item.toJson())
          .toList(growable: false),
      'privacy_audit_entries': _privacyAuditEntries
          .map((item) => item.toJson())
          .toList(growable: false),
      'analytics_events':
          _analyticsEvents.map((item) => item.toJson()).toList(growable: false),
      'analytics_summary':
          _localAnalyticsRepository.buildSummary(_analyticsEvents),
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
      'owned_items':
          _ownedItems.map((item) => item.toJson()).toList(growable: false),
      'purchase_proofs':
          _purchaseProofs.map((item) => item.toJson()).toList(growable: false),
      'warranty_records':
          _warrantyRecords.map((item) => item.toJson()).toList(growable: false),
      'maintenance_reminders': _maintenanceReminders
          .map((item) => item.toJson())
          .toList(growable: false),
      'claim_drafts':
          _claimDrafts.map((item) => item.toJson()).toList(growable: false),
      'evidence_attachments': _evidenceAttachments
          .map((item) => item.toJson())
          .toList(growable: false),
      'mental_load_items':
          _mentalLoadItems.map((item) => item.toJson()).toList(growable: false),
      'decision_cards':
          _decisionCards.map((item) => item.toJson()).toList(growable: false),
      'shopping_needs':
          _shoppingNeeds.map((item) => item.toJson()).toList(growable: false),
      'product_evidence_cards': _productEvidenceCards
          .map((item) => item.toJson())
          .toList(growable: false),
    };
  }

  Iterable<String?> get _submissionAssetRefs sync* {
    for (final proof in _purchaseProofs) {
      yield proof.fileRef;
    }
    for (final attachment in _evidenceAttachments) {
      yield attachment.fileRef;
    }
  }

  Future<String?> _persistSubmissionAsset({
    required String collection,
    required String entityId,
    String? sourcePath,
  }) async {
    return _submissionAssetVault.persistSubmissionAsset(
      collection: collection,
      entityId: entityId,
      sourcePath: sourcePath,
    );
  }

  Future<void> deleteAllLocalData() async {
    await _recordAnalyticsEvent(
      'delete_requested',
      source: 'local_delete',
      metadata: <String, Object?>{
        'event_count': totalEventCount,
        'mission_set_count': _missionSets.length,
        'analytics_event_count': _analyticsEvents.length,
      },
    );
    await _localStore.saveDemoSeedEnabled(false);
    await _localStore.deleteAllData();
    await _lifeGraphRepository.clear();
    await _submissionAssetVault.clearVault();
    _privacySettings = PrivacySettings.defaults();
    _localePreference = AppLocalePreference.system;
    _profilePreferences = AppProfilePreferences.defaults();
    _runtimeConfig = null;
    _dailyMissions = <DailyMission>[];
    _cachedDailyRisks = <DailyRisk>[];
    _missionSets = <MissionSet>[];
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
    _ownedItems = <OwnedItem>[];
    _purchaseProofs = <PurchaseProof>[];
    _warrantyRecords = <WarrantyRecord>[];
    _maintenanceReminders = <MaintenanceReminder>[];
    _claimDrafts = <ClaimDraft>[];
    _evidenceAttachments = <EvidenceAttachment>[];
    _evidenceItems = <EvidenceItem>[];
    _lifeGraphRelations = <LifeGraphRelation>[];
    _privacyAuditEntries = <PrivacyAuditEntry>[];
    _analyticsEvents = <AnalyticsEvent>[];
    _entitlement = Entitlement.disabledSafeDefault();
    _mentalLoadItems = <MentalLoadItem>[];
    _decisionCards = <DecisionCard>[];
    _shoppingNeeds = <ShoppingNeed>[];
    _productEvidenceCards = <ProductEvidenceCard>[];
    _sessionAnalyticsMarkers.clear();
    notifyListeners();
  }

  Future<void> clearAiHistory() async {
    _dailyMissions = <DailyMission>[];
    _cachedDailyRisks = <DailyRisk>[];
    _missionSets = <MissionSet>[];
    _missionFeedback = <MissionFeedback>[];
    _decisionCards = <DecisionCard>[];
    _productEvidenceCards = <ProductEvidenceCard>[];
    await _localStore.saveDailyMissions(_dailyMissions);
    await _localStore.saveDailyRisks(_cachedDailyRisks);
    await _localStore.saveMissionSets(_missionSets);
    await _localStore.saveMissionFeedback(_missionFeedback);
    await _localStore.saveDecisionCards(_decisionCards);
    await _localStore.saveProductEvidenceCards(_productEvidenceCards);
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

  List<String> _captureDraftDomains(List<CaptureDraftItem> drafts) {
    final domains = drafts.map((draft) => draft.domain.wireName).toSet().toList()
      ..sort();
    return domains;
  }

  Future<void> trackMissionViewed(DailyMission mission) {
    final missionSet = currentMissionSet;
    return _recordAnalyticsEvent(
      'mission_viewed',
      source: 'dashboard',
      metadata: <String, Object?>{
        'mission_id': mission.id,
        'mission_set_id': missionSet?.missionSetId,
        'recommendation_type': mission.recommendationType,
        'domain_targets': mission.domainTargets,
        'source_state': (mission.trace['sourceState'] ??
                mission.trace['source_state'] ??
                missionSet?.sourceState.storageKey)
            ?.toString(),
        'fallback_used': mission.trace['fallbackUsed'] == true ||
            mission.trace['fallback_used'] == true ||
            mission.trace['clientFallback'] == true ||
            mission.trace['mock'] == true ||
            missionSet?.rankingTrace['fallbackUsed'] == true,
      },
    );
  }

  Future<void> trackLifeGraphViewed({
    required int resultCount,
    required int eventCount,
    required int relationCount,
    required int evidenceCount,
    required int auditCount,
    String? domainFilter,
    required String privacyFilter,
    required String dateWindow,
  }) {
    return _recordAnalyticsEvent(
      'lifegraph_viewed',
      source: 'lifegraph_screen',
      metadata: <String, Object?>{
        'domain_filter': domainFilter ?? 'all',
        'privacy_filter': privacyFilter,
        'date_window': dateWindow,
        'result_count': resultCount,
        'event_count': eventCount,
        'relation_count': relationCount,
        'evidence_count': evidenceCount,
        'audit_count': auditCount,
      },
    );
  }

  Future<void> trackLifeGraphFiltered({
    required int resultCount,
    required int eventCount,
    required int relationCount,
    required int evidenceCount,
    required int auditCount,
    String? domainFilter,
    required String privacyFilter,
    required String dateWindow,
  }) {
    return _recordAnalyticsEvent(
      'lifegraph_filtered',
      source: 'lifegraph_screen',
      metadata: <String, Object?>{
        'domain_filter': domainFilter ?? 'all',
        'privacy_filter': privacyFilter,
        'date_window': dateWindow,
        'result_count': resultCount,
        'event_count': eventCount,
        'relation_count': relationCount,
        'evidence_count': evidenceCount,
        'audit_count': auditCount,
      },
    );
  }

  Future<void> trackLifeGraphSearchUsed({
    required int resultCount,
    required int eventCount,
    required int relationCount,
    required int evidenceCount,
    required int auditCount,
    String? domainFilter,
    required String privacyFilter,
    required String dateWindow,
    required String queryLengthBucket,
  }) {
    return _recordAnalyticsEvent(
      'lifegraph_search_used',
      source: 'lifegraph_screen',
      metadata: <String, Object?>{
        'domain_filter': domainFilter ?? 'all',
        'privacy_filter': privacyFilter,
        'date_window': dateWindow,
        'result_count': resultCount,
        'event_count': eventCount,
        'relation_count': relationCount,
        'evidence_count': evidenceCount,
        'audit_count': auditCount,
        'query_length_bucket': queryLengthBucket,
      },
    );
  }

  Future<void> trackBillingDisabledViewed() {
    return _recordSessionAnalyticsEvent(
      marker: 'billing_disabled_viewed',
      eventName: 'billing_disabled_viewed',
      source: 'billing_settings',
      metadata: <String, Object?>{
        'plan': _entitlement.plan.storageKey,
        'billing_provider': _entitlement.billingProvider,
        'renewal_state': _entitlement.renewalState,
        'export_delete_always_available': true,
      },
    );
  }

  Future<void> trackRestoreUnavailableViewed() {
    return _recordSessionAnalyticsEvent(
      marker: 'restore_unavailable_viewed',
      eventName: 'restore_unavailable_viewed',
      source: 'billing_settings',
      metadata: const <String, Object?>{
        'restore_purchases': false,
        'billing_provider': entitlementBillingProviderDisabled,
      },
    );
  }

  Future<void> trackEntitlementGateViewed(EntitlementFeature feature) {
    return _recordFeatureGateChecked(
      feature,
      source: 'billing_settings',
      trigger: 'plan_billing_card',
      oncePerSession: true,
    );
  }

  Future<void> _recordSessionAnalyticsEvent({
    required String marker,
    required String eventName,
    required String source,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    if (_sessionAnalyticsMarkers.contains(marker)) {
      return;
    }
    _sessionAnalyticsMarkers.add(marker);
    await _recordAnalyticsEvent(
      eventName,
      source: source,
      metadata: metadata,
    );
  }

  Future<EntitlementGateResult> _recordFeatureGateChecked(
    EntitlementFeature feature, {
    required String source,
    String? trigger,
    bool oncePerSession = false,
  }) async {
    final marker = 'feature_gate_checked:${feature.storageKey}:$source:$trigger';
    final result = entitlementGateForFeature(feature);
    if (!oncePerSession || !_sessionAnalyticsMarkers.contains(marker)) {
      if (oncePerSession) {
        _sessionAnalyticsMarkers.add(marker);
      }
      await _recordAnalyticsEvent(
        'feature_gate_checked',
        source: source,
        metadata: <String, Object?>{
          ...result.toAnalyticsMetadata(),
          'plan': _entitlement.plan.storageKey,
          'billing_provider': _entitlement.billingProvider,
          if (trigger != null) 'trigger': trigger,
        },
      );
    }
    return result;
  }

  Future<void> _recordAnalyticsEvent(
    String eventName, {
    required String source,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    _analyticsEvents = await _localAnalyticsRepository.appendEvent(
      _analyticsEvents,
      AnalyticsEvent(
        eventId: 'analytics-${DateTime.now().microsecondsSinceEpoch}',
        eventName: eventName,
        timestampIso: DateTime.now().toUtc().toIso8601String(),
        locale: currentLocaleTag,
        source: source,
        metadata: metadata,
      ),
    );
  }

  Map<String, Object?> _missionFeedbackAnalyticsMetadata(
    DailyMission mission,
    MissionFeedback feedback,
  ) {
    final missionSet = currentMissionSet;
    final sourceState = (mission.trace['sourceState'] ??
            mission.trace['source_state'] ??
            missionSet?.sourceState.storageKey)
        ?.toString();
    final fallbackUsed = mission.trace['fallbackUsed'] == true ||
        mission.trace['fallback_used'] == true ||
        mission.trace['clientFallback'] == true ||
        mission.trace['mock'] == true ||
        missionSet?.rankingTrace['fallbackUsed'] == true;
    return <String, Object?>{
      'mission_id': mission.id,
      'mission_set_id': missionSet?.missionSetId,
      'feedback_status': feedback.status.storageKey,
      'recommendation_type': mission.recommendationType,
      'domain_targets': mission.domainTargets,
      'source_state': sourceState,
      'fallback_used': fallbackUsed,
      if (feedback.rejectionReasonCategory != null)
        'rejection_reason': feedback.rejectionReasonCategory!.storageKey,
      if (feedback.effortFeedback != null)
        'effort_feedback': feedback.effortFeedback!.storageKey,
      'repeated_flag': feedback.repeatedFlag,
    };
  }

  String _fallbackReasonCode(Map<String, Object?> trace) {
    final rawValue = (trace['fallbackReason'] ??
            trace['fallback_reason'] ??
            trace['sourceState'] ??
            trace['source_state'] ??
            'fallback')
        .toString()
        .trim()
        .toLowerCase();
    final normalized = rawValue.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return normalized.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  Future<LifeEvent> _recordEvent({
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
    await _syncDerivedEvidenceItems(notifyStore: true);
    if (refreshPlan) {
      await _refreshMissionPlan();
    }
    if (notifyAfter) {
      notifyListeners();
    }
    return nextEvent;
  }

  Future<void> _refreshMissionPlan() async {
    final dto = await _aiGatewayClient.fetchDailyPlan(
      locale: currentLocaleTag,
      privacySettings: _privacySettings,
      lifeEvents: lifeEvents,
    );
    final createdAt =
        _stringOrFallback(dto.trace['createdAt'], DateTime.now().toUtc());
    final missionTrace = <String, Object?>{
      ...dto.trace,
      'missionSetId': dto.missionSetId,
      'date': dto.date,
      'sourceState': dto.sourceState.storageKey,
      'fallbackUsed': dto.fallbackUsed,
      'createdAt': createdAt,
      if (dto.policyVersion != null) 'policyVersion': dto.policyVersion,
      if (dto.rankingVersion != null) 'rankingVersion': dto.rankingVersion,
    };
    _dailyMissions = mapMissionPlan(dto);
    _cachedDailyRisks = _extractDailyRisksFromMission(
      _dailyMissions.isEmpty ? null : _dailyMissions.first,
    );
    _missionSets = _upsertById(
      _missionSets,
      MissionSet(
        missionSetId: dto.missionSetId,
        date: dto.date,
        sourceState: dto.sourceState,
        missions: _dailyMissions,
        rankingTrace: missionTrace,
        createdAt: createdAt,
      ),
      (item) => item.missionSetId,
    );
    await _localStore.saveDailyMissions(_dailyMissions);
    await _localStore.saveDailyRisks(_cachedDailyRisks);
    await _localStore.saveMissionSets(_missionSets);
    await _recordAnalyticsEvent(
      'mission_set_generated',
      source: 'mission_planner',
      metadata: <String, Object?>{
        'mission_set_id': dto.missionSetId,
        'date': dto.date,
        'source_state': dto.sourceState.storageKey,
        'fallback_used': dto.fallbackUsed,
        'policy_version': dto.policyVersion,
        'ranking_version': dto.rankingVersion,
        'mission_count': _dailyMissions.length,
        'risk_count': _cachedDailyRisks.length,
        'ai_eligible_event_count': aiEligibleEvents.length,
        'blocked_event_count': blockedFromAiEvents.length,
      },
    );
    if (dto.fallbackUsed || dto.sourceState != MissionSourceState.live) {
      await _recordAnalyticsEvent(
        'fallback_used',
        source: 'mission_planner',
        metadata: <String, Object?>{
          'operation': 'daily_plan',
          'mission_set_id': dto.missionSetId,
          'source_state': dto.sourceState.storageKey,
          'reason_code': _fallbackReasonCode(dto.trace),
        },
      );
    }
  }

  DecisionCard _decisionCardFromDto(DecisionCardDto dto) {
    return DecisionCard(
      id: dto.decisionId,
      userId: dto.userId,
      title: dto.title,
      recommendedAction: dto.recommendedAction,
      alternatives: dto.alternatives,
      domainTargets: dto.domainTargets,
      sourceItems: dto.sourceItems,
      evidence: dto.evidence,
      confidence: dto.confidence,
      uncertainty: dto.uncertainty,
      privacySummary: PrivacySummary(
        aiEnabled: dto.privacySummary.aiEnabled,
        sentEventCount: dto.privacySummary.sentEventCount,
        blockedEventCount: dto.privacySummary.blockedEventCount,
        allowedDomains: dto.privacySummary.allowedDomains,
        blockedDomains: dto.privacySummary.blockedDomains,
        localOnlyCollections: dto.privacySummary.localOnlyCollections,
        trace: dto.privacySummary.trace,
      ),
      confirmationRequired: dto.confirmationRequired,
      actionContract: ActionContract(
        actionType: dto.actionContract.actionType,
        requiresConfirmation: dto.actionContract.requiresConfirmation,
        destructive: dto.actionContract.destructive,
        external: dto.actionContract.external,
        payloadPreview: dto.actionContract.payloadPreview,
        forbiddenActions: dto.actionContract.forbiddenActions,
      ),
      status: dto.status,
      evidenceStatus: dto.evidenceStatus,
      rankingScore: dto.rankingScore,
      createdAtIso: dto.createdAtIso,
      updatedAtIso: dto.updatedAtIso,
      trace: dto.trace,
    );
  }

  ShoppingNeed _shoppingNeedFromDto(ShoppingNeedDto dto) {
    return ShoppingNeed(
      id: dto.needId,
      userId: dto.userId,
      needType: dto.needType,
      title: dto.title,
      sourceDomain: dto.sourceDomain,
      sourceEventIds: dto.sourceEventIds,
      urgencyScore: dto.urgencyScore,
      budgetHint: dto.budgetHint,
      currency: dto.currency,
      sustainabilityPreference: dto.sustainabilityPreference,
      state: dto.state,
      createdAtIso: dto.createdAtIso,
      updatedAtIso: dto.updatedAtIso,
      trace: dto.trace,
    );
  }

  ProductEvidenceCard _productEvidenceCardFromDto(ProductEvidenceCardDto dto) {
    return ProductEvidenceCard(
      id: dto.id,
      userId: dto.userId,
      productName: dto.productName,
      brand: dto.brand,
      merchantName: dto.merchantName,
      price: dto.price,
      currency: dto.currency,
      source: dto.source,
      checkedAtIso: dto.checkedAtIso,
      reviewSummary: dto.reviewSummary,
      sustainabilityStatus: dto.sustainabilityStatus,
      confidence: dto.confidence,
      disclaimer: dto.disclaimer,
      trace: dto.trace,
    );
  }

  List<DecisionCard> _buildLocalDecisionFallback() {
    if (_dailyMissions.isNotEmpty) {
      return _dailyMissions
          .map(
            (mission) => decisionCardFromMission(
              mission,
              privacySettings: _privacySettings,
              sentEventCount: aiEligibleEventCount,
              blockedEventCount: blockedFromAiEvents.length,
              localOnlyCollections: alwaysLocalCollectionLabels,
            ),
          )
          .toList(growable: false);
    }
    if (_mentalLoadItems.isEmpty) {
      return const <DecisionCard>[];
    }
    return <DecisionCard>[_buildFallbackDecisionCard()];
  }

  DecisionCard _buildFallbackDecisionCard() {
    final source = _mentalLoadItems.isEmpty ? null : _mentalLoadItems.first;
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return DecisionCard(
      id: source?.id ?? 'decision-local-fallback',
      userId: 'local-user',
      title: source?.title ?? 'Review your top pending item',
      recommendedAction: source?.summary ??
          'Decide whether to act now, postpone, or keep this local.',
      alternatives: const <String>[
        'Postpone until later today',
        'Keep it as a local reminder',
      ],
      domainTargets:
          source == null ? const <String>['decision'] : <String>[source.domain],
      sourceItems: source == null ? const <String>[] : <String>[source.id],
      evidence: source == null ? const <String>[] : source.evidenceRefs,
      confidence: source?.confidence ?? 0.58,
      uncertainty:
          'Generated locally because no remote decision plan was available.',
      privacySummary: PrivacySummary(
        aiEnabled: _privacySettings.aiEnabled,
        sentEventCount: aiEligibleEventCount,
        blockedEventCount: blockedFromAiEvents.length,
        allowedDomains: _privacySettings.aiAllowedWireDomains,
        blockedDomains: DomainKey.values
            .where(
                (domain) => !_privacySettings.aiAllowedDomains.contains(domain))
            .map((domain) => domain.wireName)
            .toList(growable: false),
        localOnlyCollections: alwaysLocalCollectionLabels,
        trace: const <String, Object?>{'provider': 'local'},
      ),
      confirmationRequired: true,
      actionContract: ActionContract(
        actionType: 'review_and_confirm',
        requiresConfirmation: true,
        destructive: false,
        external: false,
        payloadPreview: source == null
            ? const <String, Object?>{}
            : <String, Object?>{'mental_load_item_id': source.id},
        forbiddenActions: const <String>[
          'external_action_without_confirmation',
        ],
      ),
      status: 'draft',
      evidenceStatus: source == null || source.evidenceRefs.isEmpty
          ? 'insufficient_verified_data'
          : 'local_only',
      rankingScore: source?.urgencyScore ?? 0.58,
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      trace: const <String, Object?>{
        'clientFallback': true,
        'fallbackReason': 'local_decision_fallback',
      },
    );
  }

  List<ShoppingNeed> _deriveLocalShoppingNeeds() {
    final derived = <ShoppingNeed>[
      for (final item in _mentalLoadItems)
        if (item.domain == 'shopping' ||
            item.domain == 'pantry' ||
            item.domain == 'wardrobe' ||
            item.domain == 'homememory')
          ShoppingNeed(
            id: 'need-from-${item.id}',
            userId: item.userId,
            needType: item.type == 'shopping' ? 'restock' : item.type,
            title: item.title,
            sourceDomain: item.domain,
            sourceEventIds: item.sourceEventId == null
                ? const <String>[]
                : <String>[item.sourceEventId!],
            urgencyScore: item.urgencyScore,
            budgetHint: item.amountHint,
            currency: item.currencyHint,
            sustainabilityPreference:
                item.trace['sustainability_preference']?.toString(),
            state: item.state == 'completed' ? 'fulfilled' : 'draft',
            createdAtIso: item.createdAtIso,
            updatedAtIso: item.updatedAtIso,
            trace: <String, Object?>{
              ...item.trace,
              'derived_from': 'mental_load_item',
            },
          ),
      for (final item in _purchaseIntentions)
        ShoppingNeed(
          id: 'need-purchase-${item.id}',
          userId: 'local-user',
          needType: 'compare_before_buying',
          title: item.label,
          sourceDomain: 'wardrobe',
          sourceEventIds: const <String>[],
          urgencyScore: 0.44,
          budgetHint: null,
          currency: null,
          sustainabilityPreference: 'reuse_first',
          state: 'draft',
          createdAtIso: DateTime.now().toUtc().toIso8601String(),
          updatedAtIso: DateTime.now().toUtc().toIso8601String(),
          trace: const <String, Object?>{
            'derived_from': 'purchase_intention',
          },
        ),
      for (final item in warrantyEndingSoonItems)
        ShoppingNeed(
          id: 'need-warranty-${item.id}',
          userId: item.userId,
          needType: 'replacement_research',
          title: 'Review replacement options for ${item.displayName}',
          sourceDomain: 'homememory',
          sourceEventIds: const <String>[],
          urgencyScore: 0.72,
          budgetHint: item.purchasePrice,
          currency: item.currency,
          sustainabilityPreference: 'repair_or_replace_if_needed',
          state: 'draft',
          createdAtIso: item.updatedAt,
          updatedAtIso: item.updatedAt,
          trace: const <String, Object?>{
            'derived_from': 'warranty_ending_soon',
          },
        ),
    ];
    return _dedupeById(derived, (item) => item.id);
  }

  ShoppingNeed? _deriveShoppingNeedFromDraft(
    CaptureDraftItem draft, {
    required String sourceEventId,
  }) {
    final domain = draft.domain;
    if (domain != DomainKey.finance &&
        domain != DomainKey.pantry &&
        domain != DomainKey.wardrobe &&
        domain != DomainKey.shopping &&
        domain != DomainKey.homememory) {
      return null;
    }
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final needType = switch (domain) {
      DomainKey.finance => 'budget_check',
      DomainKey.pantry => 'restock',
      DomainKey.wardrobe => 'compare_before_buying',
      DomainKey.shopping => 'shopping',
      DomainKey.homememory => 'replacement_research',
      _ => 'shopping',
    };
    return ShoppingNeed(
      id: 'need-${draft.id}',
      userId: 'local-user',
      needType: needType,
      title: draft.text,
      sourceDomain: domain.wireName,
      sourceEventIds: <String>[sourceEventId],
      urgencyScore: draft.confidence,
      budgetHint: draft.hints['amount'] is num
          ? (draft.hints['amount'] as num).toDouble()
          : null,
      currency: draft.hints['currency']?.toString(),
      sustainabilityPreference:
          draft.hints['sustainability_preference']?.toString(),
      state: 'draft',
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      trace: <String, Object?>{
        'derived_from': 'capture_draft',
        'draft_domain': domain.wireName,
      },
    );
  }

  Future<void> _createReminderCandidateIfNeeded(CaptureDraftItem draft) async {
    final dueHint = draft.hints['time_hint']?.toString() ??
        draft.hints['expiry_hint']?.toString();
    if (dueHint == null || dueHint.isEmpty) {
      return;
    }
    final title = 'Reminder: ${draft.text}';
    final exists = _calendarItems.any((item) => item.title == title);
    if (exists) {
      return;
    }
    final start = DateTime.now().toUtc().add(
          dueHint.contains('today')
              ? const Duration(hours: 4)
              : const Duration(days: 1),
        );
    await _upsertCalendarItem(
      CalendarItem(
        id: _entityId('calendar'),
        title: title,
        startIso: start.toIso8601String(),
        endIso: start.add(const Duration(minutes: 30)).toIso8601String(),
        location: dueHint,
        energy: 'steady',
      ),
    );
  }

  Future<void> _updateDecisionCardStatus(
    String id,
    String status, {
    bool notifyAfter = true,
  }) async {
    final current = _decisionCards.firstWhere(
      (item) => item.id == id,
      orElse: () => _buildFallbackDecisionCard(),
    );
    final updated = current.copyWith(
      status: status,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      trace: <String, Object?>{
        ...current.trace,
        'last_local_action': status,
      },
    );
    await _upsertDecisionCard(updated);
    await _recordEvent(
      event: LifeEventFactory.create(
        domain: 'decision',
        type: 'decision_$status',
        summary: updated.title,
        privacyLevel: _privacyLevelForDomain('decision'),
        payload: <String, Object?>{
          'decision_id': updated.id,
          'status': status,
          'recommended_action': updated.recommendedAction,
        },
      ),
      refreshPlan: false,
      notifyAfter: false,
    );
    if (notifyAfter) {
      notifyListeners();
    }
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
      effortFeedback: _missionEffortFeedback(targetMission),
      repeatedFlag: _missionWasRepeated(targetMission),
      trace: targetMission.trace,
    );

    _missionFeedback = <MissionFeedback>[
      ..._missionFeedback,
      feedback,
    ];
    await _localStore.saveMissionFeedback(_missionFeedback);
    final analyticsMetadata = _missionFeedbackAnalyticsMetadata(
      targetMission,
      feedback,
    );
    await _recordAnalyticsEvent(
      'feedback_submitted',
      source: 'mission_feedback',
      metadata: analyticsMetadata,
    );
    switch (status) {
      case MissionFeedbackStatus.accepted:
        await _recordAnalyticsEvent(
          'mission_accepted',
          source: 'mission_feedback',
          metadata: analyticsMetadata,
        );
        break;
      case MissionFeedbackStatus.completed:
        await _recordAnalyticsEvent(
          'mission_completed',
          source: 'mission_feedback',
          metadata: analyticsMetadata,
        );
        break;
      case MissionFeedbackStatus.rejected:
        await _recordAnalyticsEvent(
          'mission_rejected',
          source: 'mission_feedback',
          metadata: analyticsMetadata,
        );
        break;
      case MissionFeedbackStatus.useful:
      case MissionFeedbackStatus.edited:
        break;
    }

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

  MissionEffortFeedback? _missionEffortFeedback(DailyMission mission) {
    final effortScore = mission.ranking?.effortScore;
    if (effortScore == null) {
      return null;
    }
    if (effortScore >= 0.8) {
      return MissionEffortFeedback.low;
    }
    if (effortScore >= 0.6) {
      return MissionEffortFeedback.balanced;
    }
    return MissionEffortFeedback.high;
  }

  bool _missionWasRepeated(DailyMission mission) {
    final learningKey = _missionLearningKey(mission);
    if (learningKey == null) {
      return false;
    }
    for (final feedback in _missionFeedback) {
      final trace = feedback.trace;
      final mapped = trace['learning_keys_by_suggestion_id'];
      if (mapped is Map &&
          mapped[feedback.missionId]?.toString() == learningKey) {
        return true;
      }
    }
    return false;
  }

  String? _missionLearningKey(DailyMission mission) {
    final mapped = mission.trace['learning_keys_by_suggestion_id'];
    if (mapped is Map) {
      final value = mapped[mission.id];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    if (mission.domainTargets.isEmpty) {
      return null;
    }
    final sortedDomains = List<String>.from(mission.domainTargets)..sort();
    return '${mission.recommendationType}|${sortedDomains.join('+')}';
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
      case 'calendar':
        await _upsertCalendarItem(_calendarItemFromCapture(draft));
        return;
      case 'journal':
        await _upsertQuickNote(_quickNoteFromCapture(draft));
        return;
      case 'recipe':
        await _upsertRecipeRescue(_recipeRescueFromCapture(draft));
        return;
      case 'shopping':
      case 'homememory':
      case 'decision':
      case 'mission':
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

  CalendarItem _calendarItemFromCapture(CaptureDraftItem draft) {
    final start = DateTime.now().toUtc().add(const Duration(hours: 2));
    return CalendarItem(
      id: _entityId('calendar'),
      title: draft.text,
      startIso: start.toIso8601String(),
      endIso: start.add(const Duration(minutes: 30)).toIso8601String(),
      location: 'Captured',
      energy: 'steady',
    );
  }

  QuickNote _quickNoteFromCapture(CaptureDraftItem draft) {
    return QuickNote(
      id: _entityId('note'),
      text: draft.text,
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      privacyLevel: draft.privacyLevel,
    );
  }

  RecipeRescue _recipeRescueFromCapture(CaptureDraftItem draft) {
    return RecipeRescue(
      id: _entityId('recipe'),
      title: draft.text,
      summary: draft.rationale,
      ingredientNames: draft.text
          .split(RegExp(r',| y | and ', caseSensitive: false))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .take(4)
          .toList(growable: false),
      estimatedMinutes: 20,
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

  Future<void> _upsertOwnedItem(OwnedItem ownedItem) async {
    _ownedItems = _upsertById(_ownedItems, ownedItem, (item) => item.id);
    await _localStore.upsertOwnedItem(ownedItem);
  }

  Future<void> _upsertPurchaseProof(PurchaseProof purchaseProof) async {
    _purchaseProofs =
        _upsertById(_purchaseProofs, purchaseProof, (item) => item.id);
    await _localStore.upsertPurchaseProof(purchaseProof);
  }

  Future<void> _upsertWarrantyRecord(WarrantyRecord warrantyRecord) async {
    _warrantyRecords =
        _upsertById(_warrantyRecords, warrantyRecord, (item) => item.id);
    await _localStore.upsertWarrantyRecord(warrantyRecord);
  }

  Future<void> _upsertMaintenanceReminder(
    MaintenanceReminder maintenanceReminder,
  ) async {
    _maintenanceReminders = _upsertById(
      _maintenanceReminders,
      maintenanceReminder,
      (item) => item.id,
    );
    await _localStore.upsertMaintenanceReminder(maintenanceReminder);
  }

  Future<void> _upsertClaimDraft(ClaimDraft claimDraft) async {
    _claimDrafts = _upsertById(_claimDrafts, claimDraft, (item) => item.id);
    await _localStore.upsertClaimDraft(claimDraft);
  }

  Future<void> _upsertEvidenceAttachment(
    EvidenceAttachment evidenceAttachment,
  ) async {
    _evidenceAttachments = _upsertById(
      _evidenceAttachments,
      evidenceAttachment,
      (item) => item.id,
    );
    await _localStore.upsertEvidenceAttachment(evidenceAttachment);
  }

  Future<void> _upsertMentalLoadItem(MentalLoadItem item) async {
    _mentalLoadItems = _upsertById(_mentalLoadItems, item, (value) => value.id);
    await _localStore.upsertMentalLoadItem(item);
  }

  Future<void> _upsertDecisionCard(DecisionCard card) async {
    _decisionCards = _upsertById(_decisionCards, card, (value) => value.id);
    await _localStore.upsertDecisionCard(card);
  }

  Future<void> _upsertShoppingNeed(ShoppingNeed need) async {
    _shoppingNeeds = _upsertById(_shoppingNeeds, need, (value) => value.id);
    await _localStore.upsertShoppingNeed(need);
  }

  Future<void> _upsertProductEvidenceCard(ProductEvidenceCard card) async {
    _productEvidenceCards =
        _upsertById(_productEvidenceCards, card, (value) => value.id);
    await _localStore.upsertProductEvidenceCard(card);
  }

  Future<void> _syncDerivedEvidenceItems({
    required bool notifyStore,
  }) async {
    final derived = <EvidenceItem>[
      for (final event in lifeEvents)
        if ((event.evidenceHash ?? '').trim().isNotEmpty)
          EvidenceItem(
            evidenceId: 'event-evidence-${event.eventId}',
            sourceType: event.source,
            localPayloadRef: 'life_event:${event.eventId}',
            privacyClass: _evidencePrivacyClassForLevel(event.privacyLevel),
            allowedForAi: _eventEligibleForAi(event),
            createdAt: event.timestampIso,
            hash: event.evidenceHash!.trim(),
          ),
      for (final proof in _purchaseProofs)
        EvidenceItem(
          evidenceId: proof.id,
          sourceType: 'purchase_proof',
          localPayloadRef: proof.fileRef ?? 'purchase_proof:${proof.id}',
          privacyClass: _evidencePrivacyClassForLevel(proof.privacyLevel),
          allowedForAi:
              proof.privacyLevel == DataPermission.aiAllowed.storageKey,
          createdAt: proof.createdAt,
          hash: proof.id,
        ),
      for (final attachment in _evidenceAttachments)
        EvidenceItem(
          evidenceId: attachment.id,
          sourceType: 'evidence_attachment:${attachment.type}',
          localPayloadRef:
              attachment.fileRef ?? 'evidence_attachment:${attachment.id}',
          privacyClass: _evidencePrivacyClassForLevel(attachment.privacyLevel),
          allowedForAi:
              attachment.privacyLevel == DataPermission.aiAllowed.storageKey,
          createdAt: attachment.createdAt,
          hash: attachment.id,
        ),
    ];
    derived.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    _evidenceItems = _dedupeById(derived, (item) => item.evidenceId);
    if (notifyStore) {
      await _localStore.saveEvidenceItems(_evidenceItems);
    }
  }

  Future<void> _rebuildDerivedLifeGraphRelations({
    required bool notifyStore,
  }) async {
    final relations = <LifeGraphRelation>[];
    final groupedByOwnedItem = <String, List<LifeEvent>>{};
    for (final event in lifeEvents) {
      final ownedItemId = event.payload['ownedItemId']?.toString();
      if (ownedItemId == null || ownedItemId.isEmpty) {
        continue;
      }
      groupedByOwnedItem.putIfAbsent(ownedItemId, () => <LifeEvent>[]).add(
            event,
          );
    }

    for (final events in groupedByOwnedItem.values) {
      final ownedItemEvent = _firstEventOfType(events, 'owned_item_created');
      if (ownedItemEvent == null) {
        continue;
      }
      for (final proofEvent in events.where(
        (event) => event.type == 'purchase_proof_added',
      )) {
        relations.add(
          _lifeGraphRelation(
            fromEventId: ownedItemEvent.eventId,
            toEventId: proofEvent.eventId,
            relationType: 'homememory.proof',
            confidence: 0.96,
            createdAt: proofEvent.timestampIso,
          ),
        );
      }
      for (final warrantyEvent in events.where(
        (event) => event.type == 'warranty_detected',
      )) {
        relations.add(
          _lifeGraphRelation(
            fromEventId: ownedItemEvent.eventId,
            toEventId: warrantyEvent.eventId,
            relationType: 'homememory.warranty',
            confidence: 0.98,
            createdAt: warrantyEvent.timestampIso,
          ),
        );
      }
      for (final reminderEvent in events.where(
        (event) => event.type == 'maintenance_scheduled',
      )) {
        relations.add(
          _lifeGraphRelation(
            fromEventId: ownedItemEvent.eventId,
            toEventId: reminderEvent.eventId,
            relationType: 'homememory.reminder',
            confidence: 0.98,
            createdAt: reminderEvent.timestampIso,
          ),
        );
      }
      for (final claimEvent in events.where(
        (event) => event.type == 'claim_draft_created',
      )) {
        relations.add(
          _lifeGraphRelation(
            fromEventId: ownedItemEvent.eventId,
            toEventId: claimEvent.eventId,
            relationType: 'homememory.claim',
            confidence: 0.94,
            createdAt: claimEvent.timestampIso,
          ),
        );
      }
      for (final evidenceEvent in events.where(
        (event) => event.type == 'evidence_attachment_added',
      )) {
        relations.add(
          _lifeGraphRelation(
            fromEventId: ownedItemEvent.eventId,
            toEventId: evidenceEvent.eventId,
            relationType: 'homememory.evidence',
            confidence: 0.96,
            createdAt: evidenceEvent.timestampIso,
          ),
        );
        final proofId = evidenceEvent.payload['proofId']?.toString();
        if (proofId == null || proofId.isEmpty) {
          continue;
        }
        final matchingProofEvent = events.cast<LifeEvent?>().firstWhere(
              (candidate) =>
                  candidate?.type == 'purchase_proof_added' &&
                  candidate?.payload['purchaseProofId']?.toString() == proofId,
              orElse: () => null,
            );
        if (matchingProofEvent == null) {
          continue;
        }
        relations.add(
          _lifeGraphRelation(
            fromEventId: matchingProofEvent.eventId,
            toEventId: evidenceEvent.eventId,
            relationType: 'homememory.proof_attachment',
            confidence: 0.93,
            createdAt: evidenceEvent.timestampIso,
          ),
        );
      }
    }

    relations.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    _lifeGraphRelations = _dedupeById(relations, (item) => item.relationId);
    if (notifyStore) {
      await _localStore.saveLifeGraphRelations(_lifeGraphRelations);
    }
  }

  LifeGraphRelation _lifeGraphRelation({
    required String fromEventId,
    required String toEventId,
    required String relationType,
    required double confidence,
    required String createdAt,
  }) {
    return LifeGraphRelation(
      relationId: '$relationType:$fromEventId:$toEventId',
      fromEventId: fromEventId,
      toEventId: toEventId,
      relationType: relationType,
      confidence: confidence,
      createdAt: createdAt,
    );
  }

  LifeEvent? _firstEventOfType(List<LifeEvent> events, String type) {
    for (final event in events) {
      if (event.type == type) {
        return event;
      }
    }
    return null;
  }

  EvidencePrivacyClass _evidencePrivacyClassForLevel(String privacyLevel) {
    switch (privacyLevel) {
      case 'ai_allowed':
        return EvidencePrivacyClass.aiAllowed;
      case 'sync_allowed':
        return EvidencePrivacyClass.private;
      default:
        return EvidencePrivacyClass.localOnly;
    }
  }

  MentalLoadItem _homeMemoryMentalLoadItem({
    required String id,
    required String type,
    required String title,
    required String summary,
    required double urgencyScore,
    required String privacyLevel,
    required String sourceEventId,
    String? dueHint,
    double effortScore = 0.24,
    bool requiresConfirmation = true,
    Map<String, Object?> trace = const <String, Object?>{},
  }) {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return MentalLoadItem(
      id: id,
      userId: 'local-user',
      domain: 'homememory',
      type: type,
      title: title,
      summary: summary,
      sourceEventId: sourceEventId,
      urgencyScore: urgencyScore,
      effortScore: effortScore,
      confidence: 0.72,
      state: 'pending',
      dueHint: dueHint,
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      privacyLevel: privacyLevel,
      requiresConfirmation: requiresConfirmation,
      evidenceRefs:
          sourceEventId.isEmpty ? const <String>[] : <String>[sourceEventId],
      amountHint: null,
      currencyHint: null,
      trace: trace,
    );
  }

  ProductEvidenceCard _productEvidenceCardFromPurchaseProof({
    required OwnedItem ownedItem,
    required PurchaseProof proof,
  }) {
    return ProductEvidenceCard(
      id: 'evidence-proof-${proof.id}',
      userId: proof.userId,
      productName: ownedItem.displayName,
      brand: ownedItem.brand.isEmpty ? null : ownedItem.brand,
      merchantName: proof.merchantName.isEmpty ? null : proof.merchantName,
      price: proof.totalAmount,
      currency: proof.currency,
      source: 'local_purchase_proof',
      checkedAtIso: proof.createdAt,
      reviewSummary: proof.rawText,
      sustainabilityStatus: 'local_only',
      confidence: 0.56,
      disclaimer: _controllerText('purchase_proof_evidence_disclaimer'),
      trace: <String, Object?>{
        'derived_from': 'purchase_proof',
        'owned_item_id': ownedItem.id,
        'proof_id': proof.id,
      },
    );
  }

  String _taskNotesFromHints(Map<String, Object?> hints) {
    final dueHint = hints['time_hint']?.toString();
    if (dueHint == null || dueHint.isEmpty) {
      return _controllerText('captured_from_quick_capture');
    }
    return _controllerText('captured_due_hint', {'due': dueHint});
  }

  LifeEvent _homeMemoryEvent({
    required String type,
    required String summary,
    required String privacyLevel,
    String? evidenceHash,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    return LifeEventFactory.create(
      domain: 'system',
      type: type,
      summary: summary,
      privacyLevel: privacyLevel,
      evidenceHash: evidenceHash,
      payload: <String, Object?>{
        ...payload,
        'module': 'homememory',
      },
    );
  }

  String _buildManualProofText({
    required String productName,
    required String brand,
    required String model,
    required String store,
    required String? purchaseDate,
    required double? price,
    required String currency,
    required int? warrantyMonths,
    required String notes,
  }) {
    final lines = <String>[
      'Product: $productName',
      if (brand.isNotEmpty) 'Brand: $brand',
      if (model.isNotEmpty) 'Model: $model',
      if (store.isNotEmpty) 'Merchant: $store',
      if (purchaseDate != null && purchaseDate.isNotEmpty)
        'Purchase date: $purchaseDate',
      if (price != null) 'Amount: ${price.toStringAsFixed(2)} $currency',
      if (warrantyMonths != null) 'Warranty months: $warrantyMonths',
      if (notes.isNotEmpty) 'Notes: $notes',
    ];
    return lines.join('\n');
  }

  String _buildLocalClaimMessage({
    required OwnedItem? item,
    required String issueDescription,
    required String recipientHint,
  }) {
    final itemName = item?.displayName ?? _controllerText('claim_item_generic');
    final seller =
        item == null || item.store.trim().isEmpty ? '' : item.store.trim();
    return _controllerText(
      'claim_draft_template',
      {
        'item': itemName,
        'seller':
            seller.isEmpty ? _controllerText('claim_seller_generic') : seller,
        'issue': issueDescription,
        'recipient': recipientHint.isEmpty
            ? _controllerText('claim_recipient_generic')
            : recipientHint,
      },
    );
  }

  String? _addMonthsToIso(String rawDate, int months) {
    final date = _tryParseDate(rawDate);
    if (date == null) {
      return null;
    }
    final monthIndex = date.month + months;
    final year = date.year + ((monthIndex - 1) ~/ 12);
    final month = ((monthIndex - 1) % 12) + 1;
    final day = date.day > _daysInMonth(year, month)
        ? _daysInMonth(year, month)
        : date.day;
    return DateTime.utc(year, month, day).toIso8601String();
  }

  String _daysBeforeIso(String rawDate, int days) {
    final date = _tryParseDate(rawDate);
    if (date == null) {
      return rawDate;
    }
    return date.subtract(Duration(days: days)).toUtc().toIso8601String();
  }

  DateTime? _tryParseDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawDate)?.toUtc();
  }

  int _daysInMonth(int year, int month) {
    final nextMonth = month == 12
        ? DateTime.utc(year + 1, 1, 1)
        : DateTime.utc(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
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
      'reminder_created' => _localizedControllerString(
          en: 'Reminder created from this decision.',
          es: 'Recordatorio creado a partir de esta decision.',
          ptBr: 'Lembrete criado a partir desta decisao.',
          ja: 'ã“ã®æ±ºå®šã‹ã‚‰ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã‚’ä½œæˆã—ã¾ã—ãŸã€‚',
          zhHans: 'å·²æ ¹æ®æ­¤å†³ç­–åˆ›å»ºæé†’ã€‚',
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
      'owned_item_saved' => _localizedControllerString(
          en: 'Item saved.',
          es: 'Objeto guardado.',
          ptBr: 'Item salvo.',
          ja: 'アイテムを保存しました。',
          zhHans: '物品已保存。',
        ),
      'owned_item_updated' => _localizedControllerString(
          en: 'Item updated.',
          es: 'Objeto actualizado.',
          ptBr: 'Item atualizado.',
          ja: 'アイテムを更新しました。',
          zhHans: '物品已更新。',
        ),
      'purchase_proof_saved' => _localizedControllerString(
          en: 'Proof and item saved.',
          es: 'Comprobante y objeto guardados.',
          ptBr: 'Comprovante e item salvos.',
          ja: '証憑とアイテムを保存しました。',
          zhHans: '凭证和物品已保存。',
        ),
      'maintenance_reminder_saved' => _localizedControllerString(
          en: 'Maintenance reminder saved.',
          es: 'Recordatorio guardado.',
          ptBr: 'Lembrete salvo.',
          ja: 'メンテナンスのリマインダーを保存しました。',
          zhHans: '维护提醒已保存。',
        ),
      'maintenance_reminder_updated' => _localizedControllerString(
          en: 'Maintenance reminder updated.',
          es: 'Recordatorio actualizado.',
          ptBr: 'Lembrete atualizado.',
          ja: 'メンテナンスのリマインダーを更新しました。',
          zhHans: '维护提醒已更新。',
        ),
      'claim_draft_saved' => _localizedControllerString(
          en: 'Claim draft saved.',
          es: 'Borrador de reclamacion guardado.',
          ptBr: 'Rascunho de reclamacao salvo.',
          ja: '申し立て下書きを保存しました。',
          zhHans: '申诉草稿已保存。',
        ),
      'claim_draft_updated' => _localizedControllerString(
          en: 'Claim draft updated.',
          es: 'Borrador de reclamacion actualizado.',
          ptBr: 'Rascunho de reclamacao atualizado.',
          ja: '申し立て下書きを更新しました。',
          zhHans: '申诉草稿已更新。',
        ),
      'evidence_attachment_saved' => _localizedControllerString(
          en: 'Evidence saved.',
          es: 'Evidencia guardada.',
          ptBr: 'Evidencia salva.',
          ja: '証拠を保存しました。',
          zhHans: '证据已保存。',
        ),
      'evidence_attachment_updated' => _localizedControllerString(
          en: 'Evidence updated.',
          es: 'Evidencia actualizada.',
          ptBr: 'Evidencia atualizada.',
          ja: '証拠を更新しました。',
          zhHans: '证据已更新。',
        ),
      'warranty_verify_disclaimer' => _localizedControllerString(
          en: 'Estimated warranty. Verify with seller or manufacturer.',
          es: 'Garantia estimada. Verificala con el vendedor o fabricante.',
          ptBr: 'Garantia estimada. Verifique com o vendedor ou fabricante.',
          ja: '推定保証です。販売者またはメーカーで確認してください。',
          zhHans: '这是估算保修。请向商家或厂商核实。',
        ),
      'review_warranty_before_expiration' => _localizedControllerString(
          en: 'Review warranty before expiration',
          es: 'Revisar garantia antes del vencimiento',
          ptBr: 'Revisar garantia antes do vencimento',
          ja: '保証期限前に確認する',
          zhHans: '在保修到期前检查',
        ),
      'maintenance_due_summary' => _localizedControllerString(
          en: 'Maintenance due for {item}.',
          es: 'Mantenimiento pendiente para {item}.',
          ptBr: 'Manutencao pendente para {item}.',
          ptPt: 'Manutencao pendente para {item}.',
          fr: 'Maintenance a prevoir pour {item}.',
          it: 'Manutenzione prevista per {item}.',
          de: 'Wartung faellig fuer {item}.',
          ja: 'Maintenance due for {item}.',
          zhHans: 'Maintenance due for {item}.',
        ),
      'warranty_review_title' => _localizedControllerString(
          en: 'Review warranty for {item}',
          es: 'Revisar garantia de {item}',
          ptBr: 'Revisar garantia de {item}',
          ptPt: 'Rever garantia de {item}',
          fr: 'Verifier la garantie de {item}',
          it: 'Controlla la garanzia di {item}',
          de: 'Garantie fuer {item} pruefen',
          ja: 'Review warranty for {item}',
          zhHans: 'Review warranty for {item}',
        ),
      'warranty_review_summary' => _localizedControllerString(
          en: 'Warranty review suggested before {date}.',
          es: 'Conviene revisar la garantia antes de {date}.',
          ptBr: 'Vale revisar a garantia antes de {date}.',
          ptPt: 'Vale a pena rever a garantia antes de {date}.',
          fr: 'Verifier la garantie avant {date}.',
          it: 'Controlla la garanzia prima di {date}.',
          de: 'Garantie vor {date} pruefen.',
          ja: 'Warranty review suggested before {date}.',
          zhHans: 'Warranty review suggested before {date}.',
        ),
      'claim_draft_default_title' => _localizedControllerString(
          en: 'Draft claim',
          es: 'Borrador de reclamacion',
          ptBr: 'Rascunho de reclamacao',
          ja: '申し立て下書き',
          zhHans: '申诉草稿',
        ),
      'claim_candidate_title' => _localizedControllerString(
          en: 'Claim candidate for {item}',
          es: 'Posible reclamacion para {item}',
          ptBr: 'Possivel reclamacao para {item}',
          ptPt: 'Possivel reclamacao para {item}',
          fr: 'Reclamation potentielle pour {item}',
          it: 'Possibile reclamo per {item}',
          de: 'Moegliche Reklamation fuer {item}',
          ja: 'Claim candidate for {item}',
          zhHans: 'Claim candidate for {item}',
        ),
      'claim_candidate_summary' => _localizedControllerString(
          en: 'Drafted locally. Verify warranty, seller policy, and next steps before sending.',
          es: 'Borrador generado en local. Verifica garantia, politica del vendedor y siguientes pasos antes de enviarlo.',
          ptBr:
              'Rascunho gerado localmente. Verifique garantia, politica do vendedor e proximos passos antes de enviar.',
          ptPt:
              'Rascunho gerado localmente. Verifica a garantia, a politica do vendedor e os proximos passos antes de enviar.',
          fr: 'Brouillon genere en local. Verifie la garantie, la politique du vendeur et les prochaines etapes avant envoi.',
          it: 'Bozza generata in locale. Verifica garanzia, politica del venditore e prossimi passi prima di inviare.',
          de: 'Lokal erstellter Entwurf. Vor dem Senden Garantie, Haendlerregeln und naechste Schritte pruefen.',
          ja: 'Claim drafted locally. Verify details before sending.',
          zhHans: 'Claim drafted locally. Verify details before sending.',
        ),
      'claim_draft_title_for_item' => _localizedControllerString(
          en: 'Claim draft for {item}',
          es: 'Borrador de reclamacion para {item}',
          ptBr: 'Rascunho de reclamacao para {item}',
          ja: '{item} の申し立て下書き',
          zhHans: '{item} 的申诉草稿',
        ),
      'purchase_proof_evidence_disclaimer' => _localizedControllerString(
          en: 'Derived from a local purchase proof. Verify product details and sustainability claims with the seller.',
          es: 'Derivado de un comprobante local. Verifica detalles del producto y claims de sostenibilidad con el vendedor.',
          ptBr:
              'Derivado de um comprovante local. Verifique detalhes do produto e claims de sustentabilidade com o vendedor.',
          ptPt:
              'Derivado de um comprovativo local. Verifica detalhes do produto e claims de sustentabilidade com o vendedor.',
          fr: 'Derive d une preuve d achat locale. Verifie les details produit et les claims de durabilite avec le vendeur.',
          it: 'Derivato da una prova di acquisto locale. Verifica dettagli prodotto e claim di sostenibilita con il venditore.',
          de: 'Aus lokalem Kaufbeleg abgeleitet. Produktdetails und Nachhaltigkeitsaussagen mit dem Haendler pruefen.',
          ja: 'Derived from local purchase proof. Verify details with the seller.',
          zhHans:
              'Derived from local purchase proof. Verify details with the seller.',
        ),
      'claim_disclaimer' => _localizedControllerString(
          en: 'No legal advice. Verify warranty and seller policies. Send outside the app.',
          es: 'No es asesoria legal. Verifica la garantia y las politicas del vendedor. Envia fuera de la app.',
          ptBr:
              'Isto nao e aconselhamento juridico. Verifique a garantia e as politicas do vendedor. Envie fora do app.',
          ja: '法律アドバイスではありません。保証と販売者の方針を確認し、アプリ外で送信してください。',
          zhHans: '不构成法律建议。请核实保修和商家政策，并在应用外发送。',
        ),
      'claim_item_generic' => _localizedControllerString(
          en: 'the item',
          es: 'el objeto',
          ptBr: 'o item',
          ja: 'このアイテム',
          zhHans: '该物品',
        ),
      'claim_seller_generic' => _localizedControllerString(
          en: 'the seller',
          es: 'el vendedor',
          ptBr: 'o vendedor',
          ja: '販売者',
          zhHans: '商家',
        ),
      'claim_recipient_generic' => _localizedControllerString(
          en: 'support team',
          es: 'equipo de soporte',
          ptBr: 'equipe de suporte',
          ja: 'サポートチーム',
          zhHans: '支持团队',
        ),
      'claim_draft_template' => _localizedControllerString(
          en: 'Hello {recipient},\n\nI am contacting you about {item}. The issue is: {issue}.\n\nI would like to review the available warranty or return options. Please let me know the next steps.\n\nThank you.',
          es: 'Hola {recipient},\n\nTe escribo por {item}. El problema es: {issue}.\n\nQuiero revisar las opciones disponibles de garantia o devolucion. Por favor, indicame los siguientes pasos.\n\nGracias.',
          ptBr:
              'Ola {recipient},\n\nEstou entrando em contato sobre {item}. O problema e: {issue}.\n\nGostaria de revisar as opcoes disponiveis de garantia ou devolucao. Por favor, informe os proximos passos.\n\nObrigado.',
          ja: '{recipient} 様\n\n{item} についてご連絡しています。問題は次のとおりです: {issue}。\n\n利用可能な保証または返品の選択肢を確認したいです。次の手順をお知らせください。\n\nよろしくお願いします。',
          zhHans:
              '{recipient} 你好，\n\n我就 {item} 与你联系。问题是：{issue}。\n\n我希望了解可用的保修或退货选项。请告知下一步该如何处理。\n\n谢谢。',
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
    String? ptPt,
    String? fr,
    String? it,
    String? de,
    required String ja,
    required String zhHans,
  }) {
    return pickLocalizedValue(
      currentLocaleTag,
      en: en,
      es: es,
      ptBr: ptBr,
      ptPt: ptPt,
      fr: fr,
      it: it,
      de: de,
      ja: ja,
      zhHans: zhHans,
    );
  }

  double? _extractFirstAmount(String text) {
    final match = RegExp(r'(\d+[.,]?\d{0,2})').firstMatch(text);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  String _stringOrFallback(Object? rawValue, DateTime fallbackValue) {
    final value = rawValue?.toString().trim();
    if (value == null || value.isEmpty) {
      return fallbackValue.toIso8601String();
    }
    return value;
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

List<T> _mergeById<T>(
  List<T> current,
  List<T> incoming,
  String Function(T value) idOf,
) {
  var next = current;
  for (final item in incoming) {
    next = _upsertById(next, item, idOf);
  }
  return next;
}

List<T> _dedupeById<T>(
  List<T> values,
  String Function(T value) idOf,
) {
  final seen = <String>{};
  final next = <T>[];
  for (final item in values) {
    final id = idOf(item);
    if (seen.add(id)) {
      next.add(item);
    }
  }
  return List<T>.unmodifiable(next);
}
