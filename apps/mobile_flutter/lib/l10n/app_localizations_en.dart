// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GoLife AI';

  @override
  String get appShellTaglineReady =>
      'Life operating system shell with explicit privacy boundaries.';

  @override
  String get appShellTaglineBooting =>
      'Bootstrapping privacy, mission mock and local graph...';

  @override
  String get navigate => 'Navigate';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCapture => 'Capture';

  @override
  String get navWeek => 'Week';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navHabits => 'Habits';

  @override
  String get navMoney => 'Money';

  @override
  String get navPantry => 'Pantry';

  @override
  String get navCloset => 'Closet';

  @override
  String get navEveryday => 'Everyday';

  @override
  String get navCopilot => 'Copilot';

  @override
  String get navSettings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortugueseBrazil => 'Portuguese Brazil';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageChineseSimplified => 'Simplified Chinese';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyIntro =>
      'Each event stays local unless both the domain permission and the event privacy level allow AI. This screen also gives you direct local export and delete controls.';

  @override
  String get privacyEncryptedActive =>
      'Sensitive local encryption is active for Journal, Quick Notes, and Finance records stored on this device.';

  @override
  String get privacyEncryptedUnavailable =>
      'Sensitive local encryption is unavailable in this runtime. Treat Journal, Quick Notes, and Finance as not protected at rest until secure storage is available again.';

  @override
  String get privacyCenter => 'Privacy center';

  @override
  String get privacyDisclosureEncryptedTitle => 'Encrypted locally';

  @override
  String get privacyDisclosureEncryptedBody =>
      'These collections are protected at rest on this device.';

  @override
  String get privacyDisclosureLocalTitle => 'Always local';

  @override
  String get privacyDisclosureLocalBody =>
      'These items stay on the device and do not go to AI routing.';

  @override
  String get privacyDisclosureAiTitle => 'Can be sent to AI if allowed';

  @override
  String get privacyDisclosureAiBody =>
      'Only domains with AI permission and AI-allowed events can be sent.';

  @override
  String get privacyMetricTotalEvents => 'Total events';

  @override
  String get privacyMetricAiEligible => 'AI-eligible';

  @override
  String get privacyMetricBlockedLocal => 'Blocked locally';

  @override
  String get dataControls => 'Data controls';

  @override
  String get dataControlsBody =>
      'Export copies the full local graph snapshot as JSON. Delete all wipes local data and disables demo reseeding.';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get deleteAllLocalData => 'Delete all local data';

  @override
  String get domainControls => 'Domain controls';

  @override
  String get exportCopied => 'Local JSON export copied to clipboard.';

  @override
  String get deleteAllTitle => 'Delete all local data?';

  @override
  String get deleteAllBody =>
      'This wipes local events, entities, missions, feedback, privacy settings, cached runtime config, and language preference on this device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deleteAllDone => 'All local data deleted.';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount events · $aiCount currently AI-eligible';
  }

  @override
  String get permissionLocal => 'Local';

  @override
  String get permissionSync => 'Sync';

  @override
  String get permissionAi => 'AI';

  @override
  String get domainHabits => 'Habits';

  @override
  String get domainTasks => 'Tasks';

  @override
  String get domainWeek => 'Week';

  @override
  String get domainFinance => 'Money';

  @override
  String get domainPantry => 'Pantry';

  @override
  String get domainWardrobe => 'Closet';

  @override
  String get domainCopilot => 'Copilot';

  @override
  String get collectionFinanceRecords => 'Finance records';

  @override
  String get collectionJournalEntries => 'Journal entries';

  @override
  String get collectionQuickNotes => 'Quick notes';

  @override
  String get collectionPrivacySettings => 'Privacy settings';

  @override
  String get collectionRuntimeConfigCache => 'Runtime config cache';

  @override
  String get collectionDeviceEncryptionKey => 'Device encryption key';

  @override
  String get nothingAiEnabled => 'Nothing is AI-enabled right now';

  @override
  String get gatewayLive => 'Gateway live';

  @override
  String get gatewayNoConnection => 'No connection';

  @override
  String get gatewayUnavailable => 'AI temporarily unavailable';

  @override
  String get gatewayLocalFallback => 'Using local fallback';

  @override
  String get feedbackNone => 'No feedback yet';

  @override
  String get feedbackUseful => 'Useful';

  @override
  String get feedbackRejected => 'Rejected';

  @override
  String get feedbackAccepted => 'Accepted';

  @override
  String get feedbackCompleted => 'Completed';

  @override
  String get feedbackEdited => 'Edited';

  @override
  String get missionDeliveryAi => 'AI-assisted';

  @override
  String get missionDeliveryFallback => 'Fallback local';

  @override
  String get missionDeliveryLocal => 'Local';

  @override
  String get missionDeliverySummaryAi =>
      'GoLife used AI for this mission after local privacy filtering.';

  @override
  String get missionDeliverySummaryFallback =>
      'GoLife stayed local because the gateway was unavailable or degraded.';

  @override
  String get missionDeliverySummaryLocal =>
      'GoLife kept this mission local on the device.';

  @override
  String get actionWrite => 'Write';

  @override
  String get actionChat => 'Chat';

  @override
  String get actionExplain => 'Explain';

  @override
  String get actionUseful => 'Useful';

  @override
  String get actionDoNow => 'Do now';

  @override
  String get actionNotUseful => 'Not useful';

  @override
  String get actionAccept => 'Accept';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionSave => 'Save';

  @override
  String get actionParseCapture => 'Parse capture';

  @override
  String get actionReparseCapture => 'Re-parse capture';

  @override
  String actionSaveCaptureItems(int count) {
    return 'Save $count items';
  }

  @override
  String get statusReady => 'Ready';

  @override
  String get statusBooting => 'Booting';

  @override
  String get labelEvidence => 'Evidence';

  @override
  String get labelDataUsedForMission => 'Data used for this mission';

  @override
  String get labelDataSentToAi => 'Data sent to AI';

  @override
  String get labelBlockedFromAi => 'Blocked from AI';

  @override
  String get labelAlwaysLocalOnDevice => 'Always local on this device';

  @override
  String get labelEncryptedLocally => 'Encrypted locally';

  @override
  String get labelUncertainty => 'Uncertainty';

  @override
  String get labelTrace => 'Trace';

  @override
  String get fieldDomain => 'Domain';

  @override
  String get fieldPrivacy => 'Privacy';

  @override
  String get dashboardDisclosurePending =>
      'GoLife keeps data local until a mission is ready.';

  @override
  String dashboardMissionCountTitle(int count) {
    return '$count missions for today';
  }

  @override
  String get dashboardMissionIntro =>
      'Home Today turns the graph into small actions: one main mission, two support missions, visible evidence and fast feedback.';

  @override
  String get dashboardLoadingMissions => 'Loading missions...';

  @override
  String get dashboardBootstrappingMission =>
      'Bootstrapping local events, ranked missions and gateway trace.';

  @override
  String dashboardRiskCount(int count) {
    return '$count risks';
  }

  @override
  String dashboardConfidencePill(int percent) {
    return '$percent% confidence';
  }

  @override
  String get dashboardAiDisclosureTitle => 'AI data disclosure';

  @override
  String dashboardAiDisclosureSummary(
      Object summary, int sentCount, int blockedCount) {
    return '$summary Sent now: $sentCount local events. Blocked locally: $blockedCount.';
  }

  @override
  String get dashboardRisksTitle => 'Risks today';

  @override
  String get dashboardNoRisks =>
      'No explicit daily risks were detected from the current AI-eligible graph.';

  @override
  String get dashboardSupportMissionsTitle => 'Support missions';

  @override
  String get dashboardNoSupportMissions =>
      'Secondary missions will appear once the daily plan is available.';

  @override
  String get signalCriticalTask => 'Critical task';

  @override
  String get signalRecoveryHabit => 'Recovery habit';

  @override
  String signalRecoveryHabitBody(Object cue, Object streak) {
    return 'Cue: $cue - $streak';
  }

  @override
  String get signalRelevantSpend => 'Relevant spend';

  @override
  String get signalUseThisFood => 'Use this food';

  @override
  String get dashboardWhyThisToday => 'Why this one today';

  @override
  String dashboardConfidenceWithType(int percent, Object type) {
    return 'Confidence $percent% - $type';
  }

  @override
  String get dashboardNothingSent =>
      'Nothing was sent for this mission. GoLife stayed local for this step.';

  @override
  String get dashboardNothingBlocked =>
      'No mission-specific items were blocked from AI for this step.';

  @override
  String get dashboardNoAlwaysLocalCollections =>
      'No always-local collections configured.';

  @override
  String get dashboardNoEncryptedCollections =>
      'No encrypted collections configured.';

  @override
  String dashboardRiskSeverityLabel(Object severity) {
    return '$severity risk';
  }

  @override
  String get captureTitle => 'Capture';

  @override
  String get captureIntro =>
      'Write one sentence. GoLife can split it into several drafts, let you edit domain and privacy per item, then save all of them together.';

  @override
  String get captureRouteTitle => 'Route';

  @override
  String get captureAutoRoute => 'Auto';

  @override
  String get captureAutoModeBody =>
      'Auto mode will try to split and classify each clause first.';

  @override
  String captureCurrentDefaultPrivacy(Object domain, Object permission) {
    return 'Current default privacy for $domain: $permission';
  }

  @override
  String get captureDraftsToConfirm => 'Drafts to confirm';

  @override
  String get captureRecentEvents => 'Recent events';

  @override
  String capturePrivacyLabel(Object privacy) {
    return 'Privacy: $privacy';
  }

  @override
  String captureItemsCaptured(int count) {
    return '$count item(s) captured.';
  }

  @override
  String get captureEditItemTitle => 'Edit item';

  @override
  String get captureHintAuto =>
      'Example: I bought coffee for 4.50, lettuce expires tomorrow, and I need to pay internet.';

  @override
  String get captureHintTasks => 'Example: submit rent receipt before lunch';

  @override
  String get captureHintHabits => 'Example: walked 15 minutes after dinner';

  @override
  String get captureHintWeek =>
      'Example: Friday focus should stay on admin work';

  @override
  String get captureHintFinance =>
      'Example: bought coffee and sandwich for 8.50';

  @override
  String get captureHintPantry => 'Example: spinach expires tomorrow';

  @override
  String get captureHintWardrobe =>
      'Example: thinking about buying another black jacket';

  @override
  String get captureHintCopilot => 'Example: a mission note';

  @override
  String get copilotTitle => 'Copilot';

  @override
  String get copilotIntro =>
      'The copilot now works around a ranked daily plan: visible trace, three missions and local fallback when the gateway is unavailable.';

  @override
  String get copilotBoundariesTitle => 'Reflection boundaries';

  @override
  String get copilotBoundariesBody =>
      'GoLife helps with daily organization and practical reflection. It does not diagnose, provide therapy, or replace professional care. If something feels urgent or unsafe, use real crisis or medical support.';

  @override
  String get copilotTodayPlanTitle => 'Today plan';

  @override
  String get copilotNoPlan => 'No mission plan loaded yet.';

  @override
  String get copilotLatestTraceTitle => 'Latest trace';

  @override
  String get copilotNoTrace => 'No mission loaded yet.';
}
