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
}
