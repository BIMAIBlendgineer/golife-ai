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
  String get navLifeGraph => 'LifeGraph';

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
  String get languagePortuguesePortugal => 'Portuguese Portugal';

  @override
  String get languageFrench => 'French';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageGerman => 'German';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageChineseSimplified => 'Simplified Chinese';

  @override
  String get languageChineseTraditional => 'Traditional Chinese';

  @override
  String get profilePreferencesTitle => 'Profile preferences';

  @override
  String get profilePreferencesBody =>
      'Set language, theme, and AI style from one local-first profile center.';

  @override
  String get deliveryPreferencesTitle => 'Notifications and rhythm';

  @override
  String get regionalPreferencesTitle => 'Region and units';

  @override
  String get preferencesLocalOnlyHint =>
      'These preferences stay local on this device until live sync and billing are connected.';

  @override
  String get themePreference => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notificationsPreference => 'Notifications';

  @override
  String get notificationsEnabled => 'Enabled';

  @override
  String get notificationsDisabled => 'Disabled';

  @override
  String get quietHoursPreference => 'Quiet hours';

  @override
  String get quietHoursOff => 'Off';

  @override
  String get quietHours2207 => '22:00-07:00';

  @override
  String get quietHours2308 => '23:00-08:00';

  @override
  String get measurementUnitsPreference => 'Measurement units';

  @override
  String get unitMetric => 'Metric';

  @override
  String get unitImperial => 'Imperial';

  @override
  String get regionCountryPreference => 'Region or country';

  @override
  String get regionAuto => 'Auto';

  @override
  String get regionUs => 'United States';

  @override
  String get regionSpain => 'Spain';

  @override
  String get regionBrazil => 'Brazil';

  @override
  String get regionPortugal => 'Portugal';

  @override
  String get regionFrance => 'France';

  @override
  String get regionItaly => 'Italy';

  @override
  String get regionGermany => 'Germany';

  @override
  String get regionJapan => 'Japan';

  @override
  String get regionChinaMainland => 'Mainland China';

  @override
  String get regionTaiwan => 'Taiwan';

  @override
  String get reminderFrequencyPreference => 'Reminder frequency';

  @override
  String get reminderOff => 'Off';

  @override
  String get reminderDaily => 'Daily';

  @override
  String get reminderWeekdays => 'Weekdays';

  @override
  String get reminderWeekly => 'Weekly';

  @override
  String get aiResponseStyle => 'AI preference';

  @override
  String get aiBrief => 'Brief';

  @override
  String get aiDetailed => 'Detailed';

  @override
  String get backupSyncPreference => 'Backup and sync';

  @override
  String get backupSyncOff => 'Off';

  @override
  String get backupSyncOn => 'On';

  @override
  String get currentPlanPreference => 'Current plan';

  @override
  String get planFree => 'Free';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPro => 'Pro';

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
  String get privacyRuntimeSnapshotTitle => 'Runtime audit snapshot';

  @override
  String get privacyRuntimeSnapshotBody =>
      'These counts come from the local persistence layer used for export, traceability, and privacy review.';

  @override
  String get privacyMetricEvidenceItems => 'Evidence items';

  @override
  String get privacyMetricRelations => 'Relations';

  @override
  String get privacyMetricAuditEntries => 'Audit entries';

  @override
  String get billingPlanTitle => 'Plan and billing';

  @override
  String get billingPlanBody =>
      'This release includes a safe local entitlement runtime. Real purchases, restore, and renewal handling stay disabled.';

  @override
  String get billingPlanBodySandbox =>
      'This release includes Google Play Billing sandbox for internal Android testing. Premium access only activates after backend verification succeeds.';

  @override
  String get billingCurrentPlanLabel => 'Current plan';

  @override
  String get billingProviderLabel => 'Billing provider';

  @override
  String get billingModeLabel => 'Billing mode';

  @override
  String get billingRenewalStateLabel => 'Renewal state';

  @override
  String get billingStatusLabel => 'Sandbox status';

  @override
  String get billingRestoreLabel => 'Restore purchases';

  @override
  String get billingExportDeleteLabel => 'Export and delete';

  @override
  String get billingDisabledLabel => 'Disabled in this release';

  @override
  String get billingProviderGooglePlay => 'Google Play';

  @override
  String get billingModeGooglePlaySandbox => 'Google Play sandbox';

  @override
  String get billingModeGooglePlayLive => 'Google Play live';

  @override
  String get billingRenewalDisabled => 'Disabled';

  @override
  String get billingRenewalPending => 'Pending';

  @override
  String get billingRenewalActive => 'Active';

  @override
  String get billingRenewalGrace => 'Grace period';

  @override
  String get billingRenewalPaused => 'Paused';

  @override
  String get billingRenewalExpired => 'Expired';

  @override
  String get billingRenewalRefunded => 'Refunded';

  @override
  String get billingRestoreAvailable => 'Available in this sandbox release';

  @override
  String get billingRestoreUnavailable => 'Unavailable in this release';

  @override
  String get billingExportDeleteAlwaysAvailable => 'Always available';

  @override
  String get billingLastValidatedLabel => 'Last validated';

  @override
  String get billingFeatureGatesTitle => 'Feature gates';

  @override
  String get billingGateMissionRefreshes => 'Daily mission refreshes';

  @override
  String get billingGateAiCaptures => 'AI-assisted captures';

  @override
  String get billingGateExportBundles => 'Export bundles';

  @override
  String billingGateValue(int remaining, int limit) {
    return '$remaining remaining of $limit';
  }

  @override
  String get billingGateAlwaysAvailable => 'Not enforced in this release';

  @override
  String get billingGateWithinQuota => 'Within the local quota window';

  @override
  String get billingGateQuotaExhausted =>
      'Quota exhausted, local fallback stays available';

  @override
  String get billingCatalogTitle => 'Sandbox catalog';

  @override
  String get billingCatalogEmpty =>
      'No Google Play sandbox products are available on this device right now.';

  @override
  String get billingSandboxInternalOnly =>
      'Sandbox purchases are for internal Android testing only. Export and delete stay available regardless of plan state.';

  @override
  String get billingPurchaseSandbox => 'Start sandbox purchase';

  @override
  String get billingRestoreNow => 'Restore sandbox purchases';

  @override
  String get billingDecisionOpen => 'Open billing decision';

  @override
  String get billingDecisionCopy => 'Copy billing decision URL';

  @override
  String get billingPlanFree => 'Free';

  @override
  String get billingPlanPremium => 'Premium';

  @override
  String get billingPlanPro => 'Pro';

  @override
  String get privacyLegalTitle => 'Store and legal';

  @override
  String get privacyLegalBody =>
      'Public privacy, terms, and support URLs for this release live here and are also referenced in the release artifact.';

  @override
  String get privacyLegalPolicyTitle => 'Privacy policy';

  @override
  String get privacyLegalPolicyBody =>
      'Public policy for local storage, AI permissions, analytics boundaries, export, and delete.';

  @override
  String get privacyLegalTermsTitle => 'Terms of service';

  @override
  String get privacyLegalTermsBody =>
      'Product scope, limits, fallback behavior, and the current billing-disabled baseline.';

  @override
  String get privacyLegalSupportTitle => 'Support';

  @override
  String get privacyLegalSupportBody =>
      'Public support path for bugs, privacy issues, and store review questions.';

  @override
  String get privacyLegalOpen => 'Open link';

  @override
  String get privacyLegalCopy => 'Copy URL';

  @override
  String get privacyLegalCopied => 'Public URL copied.';

  @override
  String get privacyLegalOpenFallback =>
      'Could not open the link. The URL was copied instead.';

  @override
  String get lifeGraphOpenTimeline => 'Open LifeGraph timeline';

  @override
  String get dataControls => 'Data controls';

  @override
  String get dataControlsBody =>
      'Export saves the full local graph snapshot as a protected JSON file on this device. Delete all wipes local data and disables demo reseeding.';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get deleteAllLocalData => 'Delete all local data';

  @override
  String get domainControls => 'Domain controls';

  @override
  String get exportCopied => 'Local JSON export copied to clipboard.';

  @override
  String exportSavedFile(Object fileName) {
    return 'Protected local export bundle saved as $fileName.';
  }

  @override
  String get deleteAllTitle => 'Delete all local data?';

  @override
  String get deleteAllBody =>
      'This wipes local events, entities, missions, feedback, privacy settings, cached runtime config, and language preference on this device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clearAiHistory => 'Clear AI history';

  @override
  String get clearAiHistoryTitle => 'Clear AI history?';

  @override
  String get clearAiHistoryBody =>
      'This clears saved missions, daily risks, and AI feedback history on this device.';

  @override
  String get clearAiHistoryDone => 'AI history cleared.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deleteAllDone => 'All local data deleted.';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount events · $aiCount currently AI-eligible';
  }

  @override
  String get privacyRecentEventsTitle => 'Recent LifeGraph events';

  @override
  String get privacyRecentEventsBody =>
      'Review recent local events, their privacy level, and whether they can be used for AI-backed missions.';

  @override
  String get privacyRecentEventsEmpty => 'No recent events to review yet.';

  @override
  String get privacyAuditTitle => 'Privacy audit';

  @override
  String get privacyAuditBody =>
      'Every event-level privacy change is logged locally on this device.';

  @override
  String get privacyAuditEmpty => 'No local privacy audit entries yet.';

  @override
  String get lifeGraphTitle => 'LifeGraph';

  @override
  String get lifeGraphIntro =>
      'Browse the local event timeline, inspect linked evidence and relations, and verify how privacy changes affect what the system can use.';

  @override
  String get lifeGraphMetricVisibleEvents => 'Visible events';

  @override
  String get lifeGraphMetricEvidenceItems => 'Matched evidence';

  @override
  String get lifeGraphMetricRelations => 'Matched relations';

  @override
  String get lifeGraphMetricAuditEntries => 'Matched audit entries';

  @override
  String get lifeGraphFiltersTitle => 'Search and filters';

  @override
  String get lifeGraphFiltersBody =>
      'Filter the local graph by domain, date window, privacy level, and summary text.';

  @override
  String get lifeGraphSearchHint => 'Search summary, domain, type, or source';

  @override
  String get lifeGraphFilterDomainTitle => 'Domain';

  @override
  String get lifeGraphFilterDateTitle => 'Date';

  @override
  String get lifeGraphFilterPrivacyTitle => 'Privacy';

  @override
  String get lifeGraphFilterAll => 'All';

  @override
  String get lifeGraphFilterDate7d => '7d';

  @override
  String get lifeGraphFilterDate30d => '30d';

  @override
  String get lifeGraphFilterDate90d => '90d';

  @override
  String get lifeGraphTimelineTitle => 'Timeline';

  @override
  String get lifeGraphTimelineBody =>
      'Events stay grouped by day so you can inspect the graph as a navigable local history, not a flat export blob.';

  @override
  String get lifeGraphNoEvents => 'No events match the current filters.';

  @override
  String lifeGraphDateGroupTitle(Object date, int count) {
    return '$date | $count events';
  }

  @override
  String get lifeGraphEvidenceTitle => 'Linked evidence';

  @override
  String get lifeGraphEvidenceEmpty => 'No linked evidence for this event.';

  @override
  String get lifeGraphRelationsTitle => 'Linked relations';

  @override
  String get lifeGraphRelationsEmpty => 'No linked relations for this event.';

  @override
  String get lifeGraphAuditNone =>
      'No event-level privacy changes recorded for this event yet.';

  @override
  String get lifeGraphOpenPrivacyAudit => 'Open privacy audit';

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
  String get collectionMissionSets => 'Mission snapshots';

  @override
  String get collectionEvidenceItems => 'Evidence items';

  @override
  String get collectionLifeGraphRelations => 'LifeGraph relations';

  @override
  String get collectionPrivacyAuditEntries => 'Privacy audit entries';

  @override
  String get collectionOwnedItems => 'Owned items';

  @override
  String get collectionPurchaseProofs => 'Purchase proofs';

  @override
  String get collectionClaimDrafts => 'Claim drafts';

  @override
  String get collectionEvidenceAttachments => 'Evidence attachments';

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
  String get privacyEventSource => 'Source';

  @override
  String get privacyEventAiEligible => 'AI eligible';

  @override
  String get privacyEventId => 'Event ID';

  @override
  String get privacyAuditChangedAt => 'Changed at';

  @override
  String get valueYes => 'Yes';

  @override
  String get valueNo => 'No';

  @override
  String get valueUnknown => 'Unknown';

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
  String get missionSnapshotTitle => 'Mission snapshot';

  @override
  String get missionSnapshotBody =>
      'This is the persisted local snapshot for the current mission set.';

  @override
  String get missionSnapshotId => 'ID';

  @override
  String get missionSnapshotDate => 'Date';

  @override
  String get missionSnapshotSourceState => 'Source state';

  @override
  String get missionSnapshotCreatedAt => 'Created at';

  @override
  String get missionSnapshotMissionCount => 'Mission count';

  @override
  String get missionSnapshotFallbackUsed => 'Fallback used';

  @override
  String get missionSnapshotPolicyVersion => 'Policy version';

  @override
  String get missionSnapshotRankingVersion => 'Ranking version';

  @override
  String get missionSnapshotRankingTrace => 'Ranking trace';

  @override
  String get missionSnapshotSourceStateLocal => 'Local only';

  @override
  String get missionSnapshotSourceStateDegraded => 'Degraded';

  @override
  String get missionSetSectionTitle => 'MissionSet';

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

  @override
  String get navJournal => 'Journal';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get homeMemoryEyebrow => 'RecallBox';

  @override
  String get homeMemoryTitle => 'HomeMemory';

  @override
  String get homeMemorySubtitle =>
      'Things, receipts, warranties, and reminders.';

  @override
  String get homeMemoryDisclosureTitle => 'Local purchase memory';

  @override
  String get homeMemoryDisclosureBody =>
      'Receipts, draft claims, and evidence stay local-first in this MVP. GoLife turns them into reminders and next actions without promising legal review.';

  @override
  String get homeMemoryWarrantySoonTitle => 'Warranty ending soon';

  @override
  String get homeMemoryWarrantySoonEmpty =>
      'No active warranty close to expiration.';

  @override
  String get homeMemoryRecentProofsTitle => 'Recent proofs';

  @override
  String get homeMemoryRecentProofsEmpty => 'No proofs captured yet.';

  @override
  String get homeMemoryRemindersTitle => 'Maintenance reminders';

  @override
  String get homeMemoryRemindersEmpty => 'No reminders scheduled.';

  @override
  String get homeMemoryClaimsTitle => 'Claim drafts';

  @override
  String get homeMemoryClaimsEmpty => 'No draft claims yet.';

  @override
  String get homeMemoryActionAddItem => 'Add item manually';

  @override
  String get homeMemoryActionAddProof => 'Add proof';

  @override
  String get homeMemoryActionCreateReminder => 'Create reminder';

  @override
  String get homeMemoryActionDraftClaim => 'Draft claim';

  @override
  String get homeMemoryActionOpen => 'Open HomeMemory';

  @override
  String get homeMemoryItemsTitle => 'Owned items';

  @override
  String get homeMemoryItemsEmpty => 'No owned items stored yet.';

  @override
  String homeMemoryWarrantyUntilLabel(Object date) {
    return 'Warranty until $date';
  }

  @override
  String get homeMemoryItemNoMeta => 'No purchase metadata yet.';

  @override
  String get homeMemorySectionItem => 'Item';

  @override
  String get homeMemorySectionProofs => 'Proofs';

  @override
  String get homeMemorySectionWarranty => 'Warranty';

  @override
  String get homeMemorySectionReminders => 'Reminders';

  @override
  String get homeMemorySectionClaims => 'Claim drafts';

  @override
  String get homeMemorySectionEvidence => 'Evidence';

  @override
  String get homeMemoryFieldProductName => 'Product name';

  @override
  String get homeMemoryFieldBrand => 'Brand';

  @override
  String get homeMemoryFieldModel => 'Model';

  @override
  String get homeMemoryFieldSerialNumber => 'Serial number';

  @override
  String get homeMemoryFieldStore => 'Store';

  @override
  String get homeMemoryFieldPurchaseDate => 'Purchase date';

  @override
  String get homeMemoryFieldPrice => 'Price';

  @override
  String get homeMemoryFieldCurrency => 'Currency';

  @override
  String get homeMemoryFieldWarrantyMonths => 'Warranty months';

  @override
  String get homeMemoryFieldWarrantyUntil => 'Warranty until';

  @override
  String get homeMemoryFieldDueDate => 'Due date';

  @override
  String get homeMemoryFieldRecurrence => 'Recurrence';

  @override
  String get homeMemoryFieldIssueDescription => 'Issue description';

  @override
  String get homeMemoryFieldRecipientHint => 'Recipient hint';

  @override
  String get homeMemoryCreateWarrantyReminder =>
      'Create a reminder before warranty expiration';

  @override
  String get homeMemoryDefaultReminderTitle =>
      'Review warranty before expiration';

  @override
  String get homeMemorySelectItem => 'Select item';

  @override
  String get homeMemoryClaimDisclaimer =>
      'No legal advice. Verify warranty and seller policies. Send outside the app.';

  @override
  String get homeMemoryNoNotes => 'No notes';

  @override
  String get homeMemoryUnknownMerchant => 'Unknown merchant';

  @override
  String get homeMemoryUnknownDate => 'Unknown date';

  @override
  String get homeMemoryUnknownValue => 'Unknown';

  @override
  String get homeMemoryNoProofs => 'No proofs attached yet.';

  @override
  String get homeMemoryWarrantyUnknown => 'Warranty unknown.';

  @override
  String get homeMemoryNoReminders => 'No reminders yet.';

  @override
  String get homeMemoryNoClaims => 'No claim drafts yet.';

  @override
  String get homeMemoryNoEvidence => 'No evidence attached yet.';

  @override
  String get homeMemoryEvidencePresent => 'Evidence attachment available.';

  @override
  String get homeMemoryWarrantyStatusUnknown => 'unknown';

  @override
  String get homeMemoryWarrantyStatusExpired => 'expired';

  @override
  String get homeMemoryWarrantyStatusActive => 'active warranty';

  @override
  String homeMemoryEverydaySubtitle(int itemCount, int warrantyCount) {
    return '$itemCount items | $warrantyCount warranties ending soon';
  }

  @override
  String get homeMemoryEverydayBody =>
      'Keep receipts, owned items, warranties, reminders, and draft claims in one local memory surface.';

  @override
  String get entityTask => 'task';

  @override
  String get entityHabit => 'habit';

  @override
  String get entityExpense => 'expense';

  @override
  String get entityPantryItem => 'pantry item';

  @override
  String get entityPurchaseIntention => 'purchase intention';

  @override
  String get entityWeekPlan => 'week plan';

  @override
  String get entityJournalEntry => 'journal entry';

  @override
  String get entityQuickNote => 'quick note';

  @override
  String get entityCalendarItem => 'calendar item';

  @override
  String get entityRecipeRescue => 'recipe rescue';

  @override
  String actionNewEntity(Object entity) {
    return 'New $entity';
  }

  @override
  String actionEditEntity(Object entity) {
    return 'Edit $entity';
  }

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionComplete => 'Complete';

  @override
  String get actionDone => 'Done';

  @override
  String get actionCheckIn => 'Check in';

  @override
  String get actionReflect => 'Reflect';

  @override
  String get actionMarkUsed => 'Mark used';

  @override
  String get actionUsed => 'Used';

  @override
  String get actionPause24h => 'Pause 24h';

  @override
  String get actionReplan => 'Replan';

  @override
  String get actionReview => 'Review';

  @override
  String get actionKeepLocal => 'Keep local';

  @override
  String get actionOpenJournal => 'Open journal';

  @override
  String get actionOpenCalendar => 'Open calendar';

  @override
  String get actionOpenRecipes => 'Open recipes';

  @override
  String get actionCookNow => 'Cook now';

  @override
  String get actionCooked => 'Cooked';

  @override
  String get actionTimeBlock => 'Time block';

  @override
  String get actionSaving => 'Saving...';

  @override
  String get domainTasksEyebrow => 'Execution';

  @override
  String get domainTasksDescription =>
      'TaskDoctor is now a local-first task board with direct create, edit, and complete flows.';

  @override
  String get domainHabitsEyebrow => 'Continuity';

  @override
  String get domainHabitsDescription =>
      'LifeQuest now supports direct habit creation and recovery-friendly check-ins.';

  @override
  String get domainMoneyEyebrow => 'Awareness';

  @override
  String get domainMoneyDescription =>
      'MoneyMirror stays conservative: log, edit, and reflect locally without crossing into regulated advice.';

  @override
  String get domainPantryEyebrow => 'Rescue';

  @override
  String get domainPantryDescription =>
      'FridgeZero now keeps a rescue board where ingredients can be created, edited, and marked used.';

  @override
  String get domainClosetEyebrow => 'Anti-consumption';

  @override
  String get domainClosetDescription =>
      'ClosetLess remains an intention-first board, now with editable pauses and purchase reasons.';

  @override
  String get domainWeekEyebrow => 'Planner';

  @override
  String get domainWeekDescription =>
      'WeekPilot stays intentionally light, but now supports quick creation and direct replanning.';

  @override
  String get domainJournalEyebrow => 'Private by default';

  @override
  String get domainJournalDescription =>
      'Journal and notes stay local-first so the app can learn from your day without turning into therapy.';

  @override
  String get domainCalendarEyebrow => 'QuickCal';

  @override
  String get domainCalendarDescription =>
      'QuickCal starts as a fast local layer for time blocks and overload detection, not a full sync engine.';

  @override
  String get domainRecipesEyebrow => 'Recipe Rescue';

  @override
  String get domainRecipesDescription =>
      'Recipe Rescue turns pantry context into simple local meal plans that can mark ingredients as used.';

  @override
  String get domainEverydayEyebrow => 'Life OS';

  @override
  String get domainEverydayDescription =>
      'Journal, calendar, and recipes live together here so the shell stays lighter while everyday context keeps growing.';

  @override
  String get tasksEmpty => 'No tasks captured yet.';

  @override
  String get habitsEmpty => 'No habits captured yet.';

  @override
  String get moneyEmpty => 'No expenses captured yet.';

  @override
  String get pantryEmpty => 'No pantry items captured yet.';

  @override
  String get closetEmpty => 'No purchase intentions captured yet.';

  @override
  String get weekEmpty => 'No week plans captured yet.';

  @override
  String get journalEmpty => 'No journal entries yet.';

  @override
  String get quickNotesEmpty => 'No quick notes yet.';

  @override
  String get calendarEmpty => 'No calendar items yet.';

  @override
  String get recipesEmpty => 'No recipe rescues yet.';

  @override
  String get calendarOverloadTitle => 'Overload detected';

  @override
  String get calendarOverloadBody =>
      'There are already four or more local calendar items. Protect the smallest non-critical block first.';

  @override
  String get calendarCalmTitle => 'Calm calendar';

  @override
  String get calendarCalmBody =>
      'Use QuickCal for fast local blocks before adding full calendar sync.';

  @override
  String get everydayContextTitle => 'Everyday context';

  @override
  String get everydayContextBody =>
      'Use writing, time blocks, and recipe rescue to give Today better context without turning the app into six crowded tabs.';

  @override
  String get everydayJournalBody =>
      'Capture reflection and short notes locally, with privacy-first defaults.';

  @override
  String get everydayCalendarBody =>
      'Keep a quick local calendar before you need full sync.';

  @override
  String get everydayRecipesBody =>
      'Turn pantry context into low-friction meals and mark ingredients used.';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldEstimatedMinutes => 'Estimated minutes';

  @override
  String get fieldPriority => 'Priority';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldCue => 'Cue';

  @override
  String get fieldCadence => 'Cadence';

  @override
  String get fieldLabel => 'Label';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldQuantity => 'Quantity';

  @override
  String get fieldRescueHint => 'Rescue hint';

  @override
  String get fieldReason => 'Reason';

  @override
  String get fieldTheme => 'Theme';

  @override
  String get fieldFocus => 'Focus';

  @override
  String get fieldMood => 'Mood';

  @override
  String get fieldBody => 'Body';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldStartIso => 'Start ISO';

  @override
  String get fieldEndIso => 'End ISO';

  @override
  String get fieldLocation => 'Location';

  @override
  String get fieldEnergy => 'Energy';

  @override
  String get fieldSummary => 'Summary';

  @override
  String get fieldIngredientsCommaSeparated => 'Ingredients (comma separated)';

  @override
  String get chipRescue => 'Rescue';

  @override
  String get chipPurchaseIntention => 'Purchase intention';

  @override
  String get chipJournal => 'Journal';

  @override
  String get chipNote => 'Note';

  @override
  String get chipLocalOnly => 'Local only';

  @override
  String get statusTaskInbox => 'Inbox';

  @override
  String get statusTaskActive => 'Active';

  @override
  String get statusTaskDone => 'Done';

  @override
  String get priorityGentle => 'Gentle';

  @override
  String get priorityStandard => 'Standard';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get cadenceDaily => 'Daily';

  @override
  String get cadenceWeekdays => 'Weekdays';

  @override
  String get cadenceWeekly => 'Weekly';

  @override
  String get recipeStatusDraft => 'Draft';

  @override
  String get recipeStatusCooked => 'Cooked';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get journalQuickNotesTitle => 'Quick notes';

  @override
  String get messageTaskUpdated => 'Task updated.';

  @override
  String get messageHabitCheckedIn => 'Habit checked in.';

  @override
  String get messageExpenseRevisited => 'Expense revisited.';

  @override
  String get messagePantryItemUpdated => 'Pantry item updated.';

  @override
  String get messagePurchaseIntentionPaused => 'Purchase intention paused.';

  @override
  String get messageWeekPlanUpdated => 'Week plan updated.';

  @override
  String get messageJournalLocalOnly => 'Journal stays local on this device.';

  @override
  String get messageNoteLocalOnly => 'Note stays local on this device.';

  @override
  String get messageOpeningEditor => 'Opening editor.';

  @override
  String get messageRecipeUpdated => 'Recipe rescue updated.';

  @override
  String messageEntitySaved(Object entity) {
    return '$entity saved.';
  }

  @override
  String messageEntityDeleted(Object entity) {
    return '$entity deleted.';
  }

  @override
  String taskTimeboxFirstBlock(int minutes) {
    return '$minutes min first block';
  }

  @override
  String habitStreakDays(int count) {
    return '$count-day streak';
  }

  @override
  String everydayJournalSubtitle(int entryCount, int noteCount) {
    return '$entryCount entries | $noteCount quick notes';
  }

  @override
  String get overloadDetected => 'detected';

  @override
  String get overloadNotDetected => 'not detected';

  @override
  String everydayCalendarSubtitle(int blockCount, Object status) {
    return '$blockCount local blocks | overload $status';
  }

  @override
  String everydayRecipesSubtitle(int count) {
    return '$count rescue ideas';
  }

  @override
  String get labelToday => 'Today';

  @override
  String get mockCriticalTaskTitle => 'Finish the next critical task';

  @override
  String mockCriticalTaskBody(int minutes, String priority) {
    return 'Protect a $minutes-minute block for the next critical step and keep priority at $priority.';
  }

  @override
  String get mockRecoveryHabitTitle => 'Keep the recovery rhythm alive';

  @override
  String get mockFinanceSummaryTitle => 'Review the spend signal';

  @override
  String mockFinanceSummaryBody(String label, String amount) {
    return 'Check $label and decide whether $amount still reflects a real need.';
  }

  @override
  String get mockPantrySummaryTitle => 'Use one ingredient already at home';

  @override
  String get mockPantrySummaryBody =>
      'Start with the oldest ingredient before opening a new shopping loop.';
}
