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
  String get gatewayNoConnection => '???';

  @override
  String get gatewayUnavailable => 'AI temporarily unavailable';

  @override
  String get gatewayLocalFallback => '????????';

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
  String get dashboardDisclosurePending => '?????????GoLife ??????????';

  @override
  String dashboardMissionCountTitle(int count) {
    return '??? $count ???';
  }

  @override
  String get dashboardMissionIntro =>
      'Home Today ??????????1 ?????2 ????????????????';

  @override
  String get dashboardLoadingMissions => '??????...';

  @override
  String get dashboardBootstrappingMission => '??????????????????????';

  @override
  String dashboardRiskCount(int count) {
    return '$count risks';
  }

  @override
  String dashboardConfidencePill(int percent) {
    return '$percent% confidence';
  }

  @override
  String get dashboardAiDisclosureTitle => 'AI ????';

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
  String get dashboardWhyThisToday => '????????';

  @override
  String dashboardConfidenceWithType(int percent, Object type) {
    return 'Confidence $percent% - $type';
  }

  @override
  String get dashboardNothingSent => '?????????????GoLife ???????????';

  @override
  String get dashboardNothingBlocked => '??????????????????? AI?';

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
  String get copilotIntro => 'Copilot ??????????????????????????????????????';

  @override
  String get copilotBoundariesTitle => '反思边界';

  @override
  String get copilotBoundariesBody =>
      'GoLife ???????????????????????????????????????????????????????????';

  @override
  String get copilotTodayPlanTitle => '今日计划';

  @override
  String get copilotNoPlan => '还没有加载任务计划。';

  @override
  String get copilotLatestTraceTitle => '最新追踪';

  @override
  String get copilotNoTrace => '还没有加载任务。';

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
  String get actionDelete => '删除';

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
      '????????????? Today ?????????????????????????';

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
    return '已删除$entity。';
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
  String get labelToday => '??';

  @override
  String get mockCriticalTaskTitle => '?????????';

  @override
  String mockCriticalTaskBody(int minutes, String priority) {
    return '?????????? $minutes ?????????????? $priority?';
  }

  @override
  String get mockRecoveryHabitTitle => '?????????';

  @override
  String get mockFinanceSummaryTitle => '??????';

  @override
  String mockFinanceSummaryBody(String label, String amount) {
    return '?? $label??? $amount ???????????';
  }

  @override
  String get mockPantrySummaryTitle => '???????????';

  @override
  String get mockPantrySummaryBody => '?????????????????????';
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
  String get gatewayNoConnection => '???';

  @override
  String get gatewayUnavailable => 'AI temporarily unavailable';

  @override
  String get gatewayLocalFallback => '????????';

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
  String get dashboardDisclosurePending => '?????????GoLife ??????????';

  @override
  String dashboardMissionCountTitle(int count) {
    return '??? $count ???';
  }

  @override
  String get dashboardMissionIntro =>
      'Home Today ??????????1 ?????2 ????????????????';

  @override
  String get dashboardLoadingMissions => '??????...';

  @override
  String get dashboardBootstrappingMission => '??????????????????????';

  @override
  String dashboardRiskCount(int count) {
    return '$count risks';
  }

  @override
  String dashboardConfidencePill(int percent) {
    return '$percent% confidence';
  }

  @override
  String get dashboardAiDisclosureTitle => 'AI ????';

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
  String get dashboardWhyThisToday => '????????';

  @override
  String dashboardConfidenceWithType(int percent, Object type) {
    return 'Confidence $percent% - $type';
  }

  @override
  String get dashboardNothingSent => '?????????????GoLife ???????????';

  @override
  String get dashboardNothingBlocked => '??????????????????? AI?';

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
  String get copilotIntro => 'Copilot ??????????????????????????????????????';

  @override
  String get copilotBoundariesTitle => '反思边界';

  @override
  String get copilotBoundariesBody =>
      'GoLife ???????????????????????????????????????????????????????????';

  @override
  String get copilotTodayPlanTitle => '今日计划';

  @override
  String get copilotNoPlan => '还没有加载任务计划。';

  @override
  String get copilotLatestTraceTitle => '最新追踪';

  @override
  String get copilotNoTrace => '还没有加载任务。';

  @override
  String get actionDelete => '删除';

  @override
  String get everydayContextBody =>
      '????????????? Today ?????????????????????????';

  @override
  String messageEntityDeleted(Object entity) {
    return '已删除$entity。';
  }

  @override
  String get labelToday => '??';

  @override
  String get mockCriticalTaskTitle => '?????????';

  @override
  String mockCriticalTaskBody(int minutes, String priority) {
    return '?????????? $minutes ?????????????? $priority?';
  }

  @override
  String get mockRecoveryHabitTitle => '?????????';

  @override
  String get mockFinanceSummaryTitle => '??????';

  @override
  String mockFinanceSummaryBody(String label, String amount) {
    return '?? $label??? $amount ???????????';
  }

  @override
  String get mockPantrySummaryTitle => '???????????';

  @override
  String get mockPantrySummaryBody => '?????????????????????';
}
