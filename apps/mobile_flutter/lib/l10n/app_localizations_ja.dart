// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'GoLife AI';

  @override
  String get appShellTaglineReady => '明示的なプライバシー境界を持つライフ OS シェル。';

  @override
  String get appShellTaglineBooting => 'プライバシー、ミッション、ローカルグラフを初期化中...';

  @override
  String get navigate => '移動';

  @override
  String get navDashboard => 'ホーム';

  @override
  String get navCapture => 'キャプチャ';

  @override
  String get navWeek => '週';

  @override
  String get navTasks => 'タスク';

  @override
  String get navHabits => '習慣';

  @override
  String get navMoney => 'お金';

  @override
  String get navPantry => '食料';

  @override
  String get navCloset => 'クローゼット';

  @override
  String get navEveryday => '毎日';

  @override
  String get navCopilot => 'コパイロット';

  @override
  String get navSettings => '設定';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム設定';

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
  String get privacyTitle => 'プライバシー';

  @override
  String get privacyIntro =>
      'ドメイン権限とプライバシーレベルの両方が AI を許可するまで、すべてのイベントはローカルに保持されます。';

  @override
  String get privacyEncryptedActive =>
      'Journal、Quick Notes、Finance の機密データはこのデバイスで暗号化されています。';

  @override
  String get privacyEncryptedUnavailable =>
      'この環境では機密ローカル暗号化が利用できません。secure storage が回復するまで、保護されていないと考えてください。';

  @override
  String get privacyCenter => 'プライバシーセンター';

  @override
  String get privacyDisclosureEncryptedTitle => 'ローカルで暗号化';

  @override
  String get privacyDisclosureEncryptedBody => 'これらのコレクションはこのデバイスで保護されます。';

  @override
  String get privacyDisclosureLocalTitle => '常にローカル';

  @override
  String get privacyDisclosureLocalBody =>
      'これらの項目はデバイスにとどまり、AI ルーティングに送信されません。';

  @override
  String get privacyDisclosureAiTitle => '許可された場合のみ AI 送信可';

  @override
  String get privacyDisclosureAiBody => 'AI 権限があり AI-allowed のイベントだけが送信されます。';

  @override
  String get privacyMetricTotalEvents => '総イベント';

  @override
  String get privacyMetricAiEligible => 'AI 送信可';

  @override
  String get privacyMetricBlockedLocal => 'ローカルでブロック';

  @override
  String get dataControls => 'データ操作';

  @override
  String get dataControlsBody =>
      'Export でローカルグラフの JSON スナップショットを出力し、Delete all でローカルデータを消去します。';

  @override
  String get exportJson => 'JSON をエクスポート';

  @override
  String get deleteAllLocalData => 'ローカルデータを全削除';

  @override
  String get domainControls => 'ドメイン制御';

  @override
  String get exportCopied => 'ローカル JSON エクスポートをクリップボードにコピーしました。';

  @override
  String get deleteAllTitle => 'すべてのローカルデータを削除しますか?';

  @override
  String get deleteAllBody =>
      'これはローカルイベント、エンティティ、ミッション、フィードバック、プライバシー設定、runtime config キャッシュ、言語設定を削除します。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get deleteAll => 'すべて削除';

  @override
  String get deleteAllDone => 'すべてのローカルデータを削除しました。';

  @override
  String domainEventsEligible(int eventCount, int aiCount) {
    return '$eventCount events · $aiCount currently AI-eligible';
  }

  @override
  String get permissionLocal => 'ローカル';

  @override
  String get permissionSync => '同期';

  @override
  String get permissionAi => 'AI';

  @override
  String get domainHabits => '習慣';

  @override
  String get domainTasks => 'タスク';

  @override
  String get domainWeek => '週';

  @override
  String get domainFinance => 'お金';

  @override
  String get domainPantry => '食料';

  @override
  String get domainWardrobe => 'クローゼット';

  @override
  String get domainCopilot => 'コパイロット';

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
  String get actionWrite => '書く';

  @override
  String get actionChat => '会話';

  @override
  String get actionExplain => '説明';

  @override
  String get actionUseful => '役立つ';

  @override
  String get actionDoNow => '今すぐ行う';

  @override
  String get actionNotUseful => '役立たない';

  @override
  String get actionAccept => '受け入れる';

  @override
  String get actionEdit => '編集';

  @override
  String get actionRemove => '削除';

  @override
  String get actionSave => '保存';

  @override
  String get actionParseCapture => 'キャプチャを解析';

  @override
  String get actionReparseCapture => 'もう一度解析';

  @override
  String actionSaveCaptureItems(int count) {
    return '$count items';
  }

  @override
  String get statusReady => '準備完了';

  @override
  String get statusBooting => '起動中';

  @override
  String get labelEvidence => '根拠';

  @override
  String get labelDataUsedForMission => 'このミッションで使ったデータ';

  @override
  String get labelDataSentToAi => 'AI に送信したデータ';

  @override
  String get labelBlockedFromAi => 'AI からブロック';

  @override
  String get labelAlwaysLocalOnDevice => 'このデバイスで常にローカル';

  @override
  String get labelEncryptedLocally => 'ローカルで暗号化';

  @override
  String get labelUncertainty => '不確実性';

  @override
  String get labelTrace => 'トレース';

  @override
  String get fieldDomain => 'ドメイン';

  @override
  String get fieldPrivacy => 'プライバシー';

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
  String get captureTitle => 'キャプチャ';

  @override
  String get captureIntro =>
      '1 文書いてください。GoLife はそれを複数の下書きに分割し、各項目のドメインとプライバシーを編集して一括保存できます。';

  @override
  String get captureRouteTitle => 'ルート';

  @override
  String get captureAutoRoute => '自動';

  @override
  String get captureAutoModeBody => '自動モードでは、まず各句を分割し分類します。';

  @override
  String captureCurrentDefaultPrivacy(Object domain, Object permission) {
    return '$domain の現在の既定プライバシー: $permission';
  }

  @override
  String get captureDraftsToConfirm => '確認する下書き';

  @override
  String get captureRecentEvents => '最近のイベント';

  @override
  String capturePrivacyLabel(Object privacy) {
    return 'プライバシー: $privacy';
  }

  @override
  String captureItemsCaptured(int count) {
    return '$count item(s) captured.';
  }

  @override
  String get captureEditItemTitle => '項目を編集';

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
  String get copilotTitle => 'コパイロット';

  @override
  String get copilotIntro =>
      'The copilot now works around a ranked daily plan: visible trace, three missions and local fallback when the gateway is unavailable.';

  @override
  String get copilotBoundariesTitle => '内省の境界';

  @override
  String get copilotBoundariesBody =>
      'GoLife helps with daily organization and practical reflection. It does not diagnose, provide therapy, or replace professional care. If something feels urgent or unsafe, use real crisis or medical support.';

  @override
  String get copilotTodayPlanTitle => '今日のプラン';

  @override
  String get copilotNoPlan => 'まだミッションプランがありません。';

  @override
  String get copilotLatestTraceTitle => '最新のトレース';

  @override
  String get copilotNoTrace => 'まだミッションがありません。';

  @override
  String get navJournal => 'Journal';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navRecipes => 'Recipes';

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
}
