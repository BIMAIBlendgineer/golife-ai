// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'GoLife AI';

  @override
  String get appShellTaglineReady => '带有明确隐私边界的 Life OS shell。';

  @override
  String get appShellTaglineBooting => '正在初始化隐私、任务和本地图谱...';

  @override
  String get navigate => '导航';

  @override
  String get navDashboard => '首页';

  @override
  String get navCapture => '记录';

  @override
  String get navWeek => '本周';

  @override
  String get navTasks => '任务';

  @override
  String get navHabits => '习惯';

  @override
  String get navMoney => '金钱';

  @override
  String get navPantry => '食材';

  @override
  String get navCloset => '衣橱';

  @override
  String get navEveryday => '日常';

  @override
  String get navCopilot => '副驾';

  @override
  String get navSettings => '设置';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortugueseBrazil => 'Português Brasil';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get privacyTitle => '隐私';

  @override
  String get privacyIntro => '只有当域权限和事件隐私等级都允许 AI 时，事件才会被发送。否则都保留在本地。';

  @override
  String get privacyEncryptedActive =>
      'Journal、Quick Notes 和 Finance 的敏感本地数据已在此设备上加密。';

  @override
  String get privacyEncryptedUnavailable =>
      '当前环境不支持敏感本地加密。在 secure storage 恢复前，请视为无静态保护。';

  @override
  String get privacyCenter => '隐私中心';

  @override
  String get privacyDisclosureEncryptedTitle => '本地加密';

  @override
  String get privacyDisclosureEncryptedBody => '这些集合在设备上静态受保护。';

  @override
  String get privacyDisclosureLocalTitle => '始终本地';

  @override
  String get privacyDisclosureLocalBody => '这些数据保留在设备上，不会进入 AI 路由。';

  @override
  String get privacyDisclosureAiTitle => '允许时可发送给 AI';

  @override
  String get privacyDisclosureAiBody => '只有具备 AI 权限的域和 AI-allowed 事件才会被发送。';

  @override
  String get privacyMetricTotalEvents => '总事件';

  @override
  String get privacyMetricAiEligible => 'AI 可发送';

  @override
  String get privacyMetricBlockedLocal => '本地拦截';

  @override
  String get dataControls => '数据控制';

  @override
  String get dataControlsBody =>
      'Export 会导出本地图谱 JSON 快照。Delete all 会清除本地数据并关闭 demo 重置。';

  @override
  String get exportJson => '导出 JSON';

  @override
  String get deleteAllLocalData => '删除所有本地数据';

  @override
  String get domainControls => '域控制';

  @override
  String get exportCopied => '已复制本地 JSON 导出内容。';

  @override
  String get deleteAllTitle => '删除所有本地数据?';

  @override
  String get deleteAllBody => '这将删除本地事件、实体、任务、反馈、隐私设置、runtime config 缓存和语言偏好。';

  @override
  String get cancel => '取消';

  @override
  String get deleteAll => '全部删除';

  @override
  String get deleteAllDone => '所有本地数据已删除。';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount events · $aiCount currently AI-eligible';
  }

  @override
  String get permissionLocal => '本地';

  @override
  String get permissionSync => '同步';

  @override
  String get permissionAi => 'AI';

  @override
  String get domainHabits => '习惯';

  @override
  String get domainTasks => '任务';

  @override
  String get domainWeek => '本周';

  @override
  String get domainFinance => '金钱';

  @override
  String get domainPantry => '食材';

  @override
  String get domainWardrobe => '衣橱';

  @override
  String get domainCopilot => '副驾';

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
  String get actionWrite => '写下';

  @override
  String get actionChat => '对话';

  @override
  String get actionExplain => '解释';

  @override
  String get actionUseful => '有帮助';

  @override
  String get actionDoNow => '现在去做';

  @override
  String get actionNotUseful => '没帮助';

  @override
  String get actionAccept => '接受';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionRemove => '移除';

  @override
  String get actionSave => '保存';

  @override
  String get actionParseCapture => '解析记录';

  @override
  String get actionReparseCapture => '重新解析';

  @override
  String actionSaveCaptureItems(int count) {
    return '保存 $count 项';
  }

  @override
  String get statusReady => '就绪';

  @override
  String get statusBooting => '启动中';

  @override
  String get labelEvidence => '证据';

  @override
  String get labelDataUsedForMission => '此任务使用的数据';

  @override
  String get labelDataSentToAi => '发送到 AI 的数据';

  @override
  String get labelBlockedFromAi => '被 AI 拦截';

  @override
  String get labelAlwaysLocalOnDevice => '始终只在这台设备本地';

  @override
  String get labelEncryptedLocally => '本地加密';

  @override
  String get labelUncertainty => '不确定性';

  @override
  String get labelTrace => '追踪';

  @override
  String get fieldDomain => '域';

  @override
  String get fieldPrivacy => '隐私';

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
  String get captureTitle => '记录';

  @override
  String get captureIntro => '写下一句话。GoLife 可以把它拆成多个草稿，你可以为每一项编辑域和隐私，然后一起保存。';

  @override
  String get captureRouteTitle => '路由';

  @override
  String get captureAutoRoute => '自动';

  @override
  String get captureAutoModeBody => '自动模式会先拆分并分类每一个子句。';

  @override
  String captureCurrentDefaultPrivacy(Object domain, Object permission) {
    return '$domain 的当前默认隐私: $permission';
  }

  @override
  String get captureDraftsToConfirm => '待确认草稿';

  @override
  String get captureRecentEvents => '最近事件';

  @override
  String capturePrivacyLabel(Object privacy) {
    return '隐私: $privacy';
  }

  @override
  String captureItemsCaptured(int count) {
    return '已记录 $count 项。';
  }

  @override
  String get captureEditItemTitle => '编辑项目';

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
  String get copilotTitle => '副驾';

  @override
  String get copilotIntro =>
      'The copilot now works around a ranked daily plan: visible trace, three missions and local fallback when the gateway is unavailable.';

  @override
  String get copilotBoundariesTitle => '反思边界';

  @override
  String get copilotBoundariesBody =>
      'GoLife helps with daily organization and practical reflection. It does not diagnose, provide therapy, or replace professional care. If something feels urgent or unsafe, use real crisis or medical support.';

  @override
  String get copilotTodayPlanTitle => '今日计划';

  @override
  String get copilotNoPlan => '还没有加载任务计划。';

  @override
  String get copilotLatestTraceTitle => '最新追踪';

  @override
  String get copilotNoTrace => '还没有加载任务。';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'GoLife AI';

  @override
  String get appShellTaglineReady => '带有明确隐私边界的 Life OS shell。';

  @override
  String get appShellTaglineBooting => '正在初始化隐私、任务和本地图谱...';

  @override
  String get navigate => '导航';

  @override
  String get navDashboard => '首页';

  @override
  String get navCapture => '记录';

  @override
  String get navWeek => '本周';

  @override
  String get navTasks => '任务';

  @override
  String get navHabits => '习惯';

  @override
  String get navMoney => '金钱';

  @override
  String get navPantry => '食材';

  @override
  String get navCloset => '衣橱';

  @override
  String get navEveryday => '日常';

  @override
  String get navCopilot => '副驾';

  @override
  String get navSettings => '设置';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortugueseBrazil => 'Português Brasil';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get privacyTitle => '隐私';

  @override
  String get privacyIntro => '只有当域权限和事件隐私等级都允许 AI 时，事件才会被发送。否则都保留在本地。';

  @override
  String get privacyEncryptedActive =>
      'Journal、Quick Notes 和 Finance 的敏感本地数据已在此设备上加密。';

  @override
  String get privacyEncryptedUnavailable =>
      '当前环境不支持敏感本地加密。在 secure storage 恢复前，请视为无静态保护。';

  @override
  String get privacyCenter => '隐私中心';

  @override
  String get privacyDisclosureEncryptedTitle => '本地加密';

  @override
  String get privacyDisclosureEncryptedBody => '这些集合在设备上静态受保护。';

  @override
  String get privacyDisclosureLocalTitle => '始终本地';

  @override
  String get privacyDisclosureLocalBody => '这些数据保留在设备上，不会进入 AI 路由。';

  @override
  String get privacyDisclosureAiTitle => '允许时可发送给 AI';

  @override
  String get privacyDisclosureAiBody => '只有具备 AI 权限的域和 AI-allowed 事件才会被发送。';

  @override
  String get privacyMetricTotalEvents => '总事件';

  @override
  String get privacyMetricAiEligible => 'AI 可发送';

  @override
  String get privacyMetricBlockedLocal => '本地拦截';

  @override
  String get dataControls => '数据控制';

  @override
  String get dataControlsBody =>
      'Export 会导出本地图谱 JSON 快照。Delete all 会清除本地数据并关闭 demo 重置。';

  @override
  String get exportJson => '导出 JSON';

  @override
  String get deleteAllLocalData => '删除所有本地数据';

  @override
  String get domainControls => '域控制';

  @override
  String get exportCopied => '已复制本地 JSON 导出内容。';

  @override
  String get deleteAllTitle => '删除所有本地数据?';

  @override
  String get deleteAllBody => '这将删除本地事件、实体、任务、反馈、隐私设置、runtime config 缓存和语言偏好。';

  @override
  String get cancel => '取消';

  @override
  String get deleteAll => '全部删除';

  @override
  String get deleteAllDone => '所有本地数据已删除。';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount events · $aiCount currently AI-eligible';
  }

  @override
  String get permissionLocal => '本地';

  @override
  String get permissionSync => '同步';

  @override
  String get permissionAi => 'AI';

  @override
  String get domainHabits => '习惯';

  @override
  String get domainTasks => '任务';

  @override
  String get domainWeek => '本周';

  @override
  String get domainFinance => '金钱';

  @override
  String get domainPantry => '食材';

  @override
  String get domainWardrobe => '衣橱';

  @override
  String get domainCopilot => '副驾';

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
  String get actionWrite => '写下';

  @override
  String get actionChat => '对话';

  @override
  String get actionExplain => '解释';

  @override
  String get actionUseful => '有帮助';

  @override
  String get actionDoNow => '现在去做';

  @override
  String get actionNotUseful => '没帮助';

  @override
  String get actionAccept => '接受';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionRemove => '移除';

  @override
  String get actionSave => '保存';

  @override
  String get actionParseCapture => '解析记录';

  @override
  String get actionReparseCapture => '重新解析';

  @override
  String actionSaveCaptureItems(int count) {
    return '保存 $count 项';
  }

  @override
  String get statusReady => '就绪';

  @override
  String get statusBooting => '启动中';

  @override
  String get labelEvidence => '证据';

  @override
  String get labelDataUsedForMission => '此任务使用的数据';

  @override
  String get labelDataSentToAi => '发送到 AI 的数据';

  @override
  String get labelBlockedFromAi => '被 AI 拦截';

  @override
  String get labelAlwaysLocalOnDevice => '始终只在这台设备本地';

  @override
  String get labelEncryptedLocally => '本地加密';

  @override
  String get labelUncertainty => '不确定性';

  @override
  String get labelTrace => '追踪';

  @override
  String get fieldDomain => '域';

  @override
  String get fieldPrivacy => '隐私';

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
  String get captureTitle => '记录';

  @override
  String get captureIntro => '写下一句话。GoLife 可以将其拆分为多个草稿，你可以为每一项编辑域和隐私，然后一起保存。';

  @override
  String get captureRouteTitle => '路由';

  @override
  String get captureAutoRoute => '自动';

  @override
  String get captureAutoModeBody => '自动模式会先拆分并分类每一个子句。';

  @override
  String captureCurrentDefaultPrivacy(Object domain, Object permission) {
    return '$domain 的当前默认隐私: $permission';
  }

  @override
  String get captureDraftsToConfirm => '待确认草稿';

  @override
  String get captureRecentEvents => '最近事件';

  @override
  String capturePrivacyLabel(Object privacy) {
    return '隐私: $privacy';
  }

  @override
  String captureItemsCaptured(int count) {
    return '已记录 $count 项。';
  }

  @override
  String get captureEditItemTitle => '编辑项目';

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
  String get copilotTitle => '副驾';

  @override
  String get copilotIntro =>
      'The copilot now works around a ranked daily plan: visible trace, three missions and local fallback when the gateway is unavailable.';

  @override
  String get copilotBoundariesTitle => '反思边界';

  @override
  String get copilotBoundariesBody =>
      'GoLife helps with daily organization and practical reflection. It does not diagnose, provide therapy, or replace professional care. If something feels urgent or unsafe, use real crisis or medical support.';

  @override
  String get copilotTodayPlanTitle => '今日计划';

  @override
  String get copilotNoPlan => '还没有加载任务计划。';

  @override
  String get copilotLatestTraceTitle => '最新追踪';

  @override
  String get copilotNoTrace => '还没有加载任务。';
}
