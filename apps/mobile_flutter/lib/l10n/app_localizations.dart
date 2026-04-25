import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GoLife AI'**
  String get appTitle;

  /// No description provided for @appShellTaglineReady.
  ///
  /// In en, this message translates to:
  /// **'Life operating system shell with explicit privacy boundaries.'**
  String get appShellTaglineReady;

  /// No description provided for @appShellTaglineBooting.
  ///
  /// In en, this message translates to:
  /// **'Bootstrapping privacy, mission mock and local graph...'**
  String get appShellTaglineBooting;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get navCapture;

  /// No description provided for @navWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get navWeek;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get navHabits;

  /// No description provided for @navMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get navMoney;

  /// No description provided for @navPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get navPantry;

  /// No description provided for @navCloset.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get navCloset;

  /// No description provided for @navEveryday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get navEveryday;

  /// No description provided for @navCopilot.
  ///
  /// In en, this message translates to:
  /// **'Copilot'**
  String get navCopilot;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Portuguese Brazil'**
  String get languagePortugueseBrazil;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get languageChineseSimplified;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Each event stays local unless both the domain permission and the event privacy level allow AI. This screen also gives you direct local export and delete controls.'**
  String get privacyIntro;

  /// No description provided for @privacyEncryptedActive.
  ///
  /// In en, this message translates to:
  /// **'Sensitive local encryption is active for Journal, Quick Notes, and Finance records stored on this device.'**
  String get privacyEncryptedActive;

  /// No description provided for @privacyEncryptedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sensitive local encryption is unavailable in this runtime. Treat Journal, Quick Notes, and Finance as not protected at rest until secure storage is available again.'**
  String get privacyEncryptedUnavailable;

  /// No description provided for @privacyCenter.
  ///
  /// In en, this message translates to:
  /// **'Privacy center'**
  String get privacyCenter;

  /// No description provided for @privacyDisclosureEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted locally'**
  String get privacyDisclosureEncryptedTitle;

  /// No description provided for @privacyDisclosureEncryptedBody.
  ///
  /// In en, this message translates to:
  /// **'These collections are protected at rest on this device.'**
  String get privacyDisclosureEncryptedBody;

  /// No description provided for @privacyDisclosureLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Always local'**
  String get privacyDisclosureLocalTitle;

  /// No description provided for @privacyDisclosureLocalBody.
  ///
  /// In en, this message translates to:
  /// **'These items stay on the device and do not go to AI routing.'**
  String get privacyDisclosureLocalBody;

  /// No description provided for @privacyDisclosureAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Can be sent to AI if allowed'**
  String get privacyDisclosureAiTitle;

  /// No description provided for @privacyDisclosureAiBody.
  ///
  /// In en, this message translates to:
  /// **'Only domains with AI permission and AI-allowed events can be sent.'**
  String get privacyDisclosureAiBody;

  /// No description provided for @privacyMetricTotalEvents.
  ///
  /// In en, this message translates to:
  /// **'Total events'**
  String get privacyMetricTotalEvents;

  /// No description provided for @privacyMetricAiEligible.
  ///
  /// In en, this message translates to:
  /// **'AI-eligible'**
  String get privacyMetricAiEligible;

  /// No description provided for @privacyMetricBlockedLocal.
  ///
  /// In en, this message translates to:
  /// **'Blocked locally'**
  String get privacyMetricBlockedLocal;

  /// No description provided for @dataControls.
  ///
  /// In en, this message translates to:
  /// **'Data controls'**
  String get dataControls;

  /// No description provided for @dataControlsBody.
  ///
  /// In en, this message translates to:
  /// **'Export copies the full local graph snapshot as JSON. Delete all wipes local data and disables demo reseeding.'**
  String get dataControlsBody;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @deleteAllLocalData.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data'**
  String get deleteAllLocalData;

  /// No description provided for @domainControls.
  ///
  /// In en, this message translates to:
  /// **'Domain controls'**
  String get domainControls;

  /// No description provided for @exportCopied.
  ///
  /// In en, this message translates to:
  /// **'Local JSON export copied to clipboard.'**
  String get exportCopied;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'This wipes local events, entities, missions, feedback, privacy settings, cached runtime config, and language preference on this device.'**
  String get deleteAllBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @deleteAllDone.
  ///
  /// In en, this message translates to:
  /// **'All local data deleted.'**
  String get deleteAllDone;

  /// No description provided for @domainEventsEligible.
  ///
  /// In en, this message translates to:
  /// **'{eventCount} events · {aiCount} currently AI-eligible'**
  String domainEventsEligible(int eventCount, int aiCount);

  /// No description provided for @permissionLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get permissionLocal;

  /// No description provided for @permissionSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get permissionSync;

  /// No description provided for @permissionAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get permissionAi;

  /// No description provided for @domainHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get domainHabits;

  /// No description provided for @domainTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get domainTasks;

  /// No description provided for @domainWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get domainWeek;

  /// No description provided for @domainFinance.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get domainFinance;

  /// No description provided for @domainPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get domainPantry;

  /// No description provided for @domainWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get domainWardrobe;

  /// No description provided for @domainCopilot.
  ///
  /// In en, this message translates to:
  /// **'Copilot'**
  String get domainCopilot;

  /// No description provided for @collectionFinanceRecords.
  ///
  /// In en, this message translates to:
  /// **'Finance records'**
  String get collectionFinanceRecords;

  /// No description provided for @collectionJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'Journal entries'**
  String get collectionJournalEntries;

  /// No description provided for @collectionQuickNotes.
  ///
  /// In en, this message translates to:
  /// **'Quick notes'**
  String get collectionQuickNotes;

  /// No description provided for @collectionPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get collectionPrivacySettings;

  /// No description provided for @collectionRuntimeConfigCache.
  ///
  /// In en, this message translates to:
  /// **'Runtime config cache'**
  String get collectionRuntimeConfigCache;

  /// No description provided for @collectionDeviceEncryptionKey.
  ///
  /// In en, this message translates to:
  /// **'Device encryption key'**
  String get collectionDeviceEncryptionKey;

  /// No description provided for @nothingAiEnabled.
  ///
  /// In en, this message translates to:
  /// **'Nothing is AI-enabled right now'**
  String get nothingAiEnabled;

  /// No description provided for @gatewayLive.
  ///
  /// In en, this message translates to:
  /// **'Gateway live'**
  String get gatewayLive;

  /// No description provided for @gatewayNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get gatewayNoConnection;

  /// No description provided for @gatewayUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI temporarily unavailable'**
  String get gatewayUnavailable;

  /// No description provided for @gatewayLocalFallback.
  ///
  /// In en, this message translates to:
  /// **'Using local fallback'**
  String get gatewayLocalFallback;

  /// No description provided for @feedbackNone.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet'**
  String get feedbackNone;

  /// No description provided for @feedbackUseful.
  ///
  /// In en, this message translates to:
  /// **'Useful'**
  String get feedbackUseful;

  /// No description provided for @feedbackRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get feedbackRejected;

  /// No description provided for @feedbackAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get feedbackAccepted;

  /// No description provided for @feedbackCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get feedbackCompleted;

  /// No description provided for @feedbackEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get feedbackEdited;

  /// No description provided for @missionDeliveryAi.
  ///
  /// In en, this message translates to:
  /// **'AI-assisted'**
  String get missionDeliveryAi;

  /// No description provided for @missionDeliveryFallback.
  ///
  /// In en, this message translates to:
  /// **'Fallback local'**
  String get missionDeliveryFallback;

  /// No description provided for @missionDeliveryLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get missionDeliveryLocal;

  /// No description provided for @missionDeliverySummaryAi.
  ///
  /// In en, this message translates to:
  /// **'GoLife used AI for this mission after local privacy filtering.'**
  String get missionDeliverySummaryAi;

  /// No description provided for @missionDeliverySummaryFallback.
  ///
  /// In en, this message translates to:
  /// **'GoLife stayed local because the gateway was unavailable or degraded.'**
  String get missionDeliverySummaryFallback;

  /// No description provided for @missionDeliverySummaryLocal.
  ///
  /// In en, this message translates to:
  /// **'GoLife kept this mission local on the device.'**
  String get missionDeliverySummaryLocal;

  /// No description provided for @actionWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get actionWrite;

  /// No description provided for @actionChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get actionChat;

  /// No description provided for @actionExplain.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get actionExplain;

  /// No description provided for @actionUseful.
  ///
  /// In en, this message translates to:
  /// **'Useful'**
  String get actionUseful;

  /// No description provided for @actionDoNow.
  ///
  /// In en, this message translates to:
  /// **'Do now'**
  String get actionDoNow;

  /// No description provided for @actionNotUseful.
  ///
  /// In en, this message translates to:
  /// **'Not useful'**
  String get actionNotUseful;

  /// No description provided for @actionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionParseCapture.
  ///
  /// In en, this message translates to:
  /// **'Parse capture'**
  String get actionParseCapture;

  /// No description provided for @actionReparseCapture.
  ///
  /// In en, this message translates to:
  /// **'Re-parse capture'**
  String get actionReparseCapture;

  /// No description provided for @actionSaveCaptureItems.
  ///
  /// In en, this message translates to:
  /// **'Save {count} items'**
  String actionSaveCaptureItems(int count);

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusBooting.
  ///
  /// In en, this message translates to:
  /// **'Booting'**
  String get statusBooting;

  /// No description provided for @labelEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get labelEvidence;

  /// No description provided for @labelDataUsedForMission.
  ///
  /// In en, this message translates to:
  /// **'Data used for this mission'**
  String get labelDataUsedForMission;

  /// No description provided for @labelDataSentToAi.
  ///
  /// In en, this message translates to:
  /// **'Data sent to AI'**
  String get labelDataSentToAi;

  /// No description provided for @labelBlockedFromAi.
  ///
  /// In en, this message translates to:
  /// **'Blocked from AI'**
  String get labelBlockedFromAi;

  /// No description provided for @labelAlwaysLocalOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Always local on this device'**
  String get labelAlwaysLocalOnDevice;

  /// No description provided for @labelEncryptedLocally.
  ///
  /// In en, this message translates to:
  /// **'Encrypted locally'**
  String get labelEncryptedLocally;

  /// No description provided for @labelUncertainty.
  ///
  /// In en, this message translates to:
  /// **'Uncertainty'**
  String get labelUncertainty;

  /// No description provided for @labelTrace.
  ///
  /// In en, this message translates to:
  /// **'Trace'**
  String get labelTrace;

  /// No description provided for @fieldDomain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get fieldDomain;

  /// No description provided for @fieldPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get fieldPrivacy;

  /// No description provided for @dashboardDisclosurePending.
  ///
  /// In en, this message translates to:
  /// **'GoLife keeps data local until a mission is ready.'**
  String get dashboardDisclosurePending;

  /// No description provided for @dashboardMissionCountTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} missions for today'**
  String dashboardMissionCountTitle(int count);

  /// No description provided for @dashboardMissionIntro.
  ///
  /// In en, this message translates to:
  /// **'Home Today turns the graph into small actions: one main mission, two support missions, visible evidence and fast feedback.'**
  String get dashboardMissionIntro;

  /// No description provided for @dashboardLoadingMissions.
  ///
  /// In en, this message translates to:
  /// **'Loading missions...'**
  String get dashboardLoadingMissions;

  /// No description provided for @dashboardBootstrappingMission.
  ///
  /// In en, this message translates to:
  /// **'Bootstrapping local events, ranked missions and gateway trace.'**
  String get dashboardBootstrappingMission;

  /// No description provided for @dashboardRiskCount.
  ///
  /// In en, this message translates to:
  /// **'{count} risks'**
  String dashboardRiskCount(int count);

  /// No description provided for @dashboardConfidencePill.
  ///
  /// In en, this message translates to:
  /// **'{percent}% confidence'**
  String dashboardConfidencePill(int percent);

  /// No description provided for @dashboardAiDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'AI data disclosure'**
  String get dashboardAiDisclosureTitle;

  /// No description provided for @dashboardAiDisclosureSummary.
  ///
  /// In en, this message translates to:
  /// **'{summary} Sent now: {sentCount} local events. Blocked locally: {blockedCount}.'**
  String dashboardAiDisclosureSummary(
      Object summary, int sentCount, int blockedCount);

  /// No description provided for @dashboardRisksTitle.
  ///
  /// In en, this message translates to:
  /// **'Risks today'**
  String get dashboardRisksTitle;

  /// No description provided for @dashboardNoRisks.
  ///
  /// In en, this message translates to:
  /// **'No explicit daily risks were detected from the current AI-eligible graph.'**
  String get dashboardNoRisks;

  /// No description provided for @dashboardSupportMissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Support missions'**
  String get dashboardSupportMissionsTitle;

  /// No description provided for @dashboardNoSupportMissions.
  ///
  /// In en, this message translates to:
  /// **'Secondary missions will appear once the daily plan is available.'**
  String get dashboardNoSupportMissions;

  /// No description provided for @signalCriticalTask.
  ///
  /// In en, this message translates to:
  /// **'Critical task'**
  String get signalCriticalTask;

  /// No description provided for @signalRecoveryHabit.
  ///
  /// In en, this message translates to:
  /// **'Recovery habit'**
  String get signalRecoveryHabit;

  /// No description provided for @signalRecoveryHabitBody.
  ///
  /// In en, this message translates to:
  /// **'Cue: {cue} - {streak}'**
  String signalRecoveryHabitBody(Object cue, Object streak);

  /// No description provided for @signalRelevantSpend.
  ///
  /// In en, this message translates to:
  /// **'Relevant spend'**
  String get signalRelevantSpend;

  /// No description provided for @signalUseThisFood.
  ///
  /// In en, this message translates to:
  /// **'Use this food'**
  String get signalUseThisFood;

  /// No description provided for @dashboardWhyThisToday.
  ///
  /// In en, this message translates to:
  /// **'Why this one today'**
  String get dashboardWhyThisToday;

  /// No description provided for @dashboardConfidenceWithType.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent}% - {type}'**
  String dashboardConfidenceWithType(int percent, Object type);

  /// No description provided for @dashboardNothingSent.
  ///
  /// In en, this message translates to:
  /// **'Nothing was sent for this mission. GoLife stayed local for this step.'**
  String get dashboardNothingSent;

  /// No description provided for @dashboardNothingBlocked.
  ///
  /// In en, this message translates to:
  /// **'No mission-specific items were blocked from AI for this step.'**
  String get dashboardNothingBlocked;

  /// No description provided for @dashboardNoAlwaysLocalCollections.
  ///
  /// In en, this message translates to:
  /// **'No always-local collections configured.'**
  String get dashboardNoAlwaysLocalCollections;

  /// No description provided for @dashboardNoEncryptedCollections.
  ///
  /// In en, this message translates to:
  /// **'No encrypted collections configured.'**
  String get dashboardNoEncryptedCollections;

  /// No description provided for @dashboardRiskSeverityLabel.
  ///
  /// In en, this message translates to:
  /// **'{severity} risk'**
  String dashboardRiskSeverityLabel(Object severity);

  /// No description provided for @captureTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get captureTitle;

  /// No description provided for @captureIntro.
  ///
  /// In en, this message translates to:
  /// **'Write one sentence. GoLife can split it into several drafts, let you edit domain and privacy per item, then save all of them together.'**
  String get captureIntro;

  /// No description provided for @captureRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get captureRouteTitle;

  /// No description provided for @captureAutoRoute.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get captureAutoRoute;

  /// No description provided for @captureAutoModeBody.
  ///
  /// In en, this message translates to:
  /// **'Auto mode will try to split and classify each clause first.'**
  String get captureAutoModeBody;

  /// No description provided for @captureCurrentDefaultPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Current default privacy for {domain}: {permission}'**
  String captureCurrentDefaultPrivacy(Object domain, Object permission);

  /// No description provided for @captureDraftsToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Drafts to confirm'**
  String get captureDraftsToConfirm;

  /// No description provided for @captureRecentEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent events'**
  String get captureRecentEvents;

  /// No description provided for @capturePrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy: {privacy}'**
  String capturePrivacyLabel(Object privacy);

  /// No description provided for @captureItemsCaptured.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) captured.'**
  String captureItemsCaptured(int count);

  /// No description provided for @captureEditItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get captureEditItemTitle;

  /// No description provided for @captureHintAuto.
  ///
  /// In en, this message translates to:
  /// **'Example: I bought coffee for 4.50, lettuce expires tomorrow, and I need to pay internet.'**
  String get captureHintAuto;

  /// No description provided for @captureHintTasks.
  ///
  /// In en, this message translates to:
  /// **'Example: submit rent receipt before lunch'**
  String get captureHintTasks;

  /// No description provided for @captureHintHabits.
  ///
  /// In en, this message translates to:
  /// **'Example: walked 15 minutes after dinner'**
  String get captureHintHabits;

  /// No description provided for @captureHintWeek.
  ///
  /// In en, this message translates to:
  /// **'Example: Friday focus should stay on admin work'**
  String get captureHintWeek;

  /// No description provided for @captureHintFinance.
  ///
  /// In en, this message translates to:
  /// **'Example: bought coffee and sandwich for 8.50'**
  String get captureHintFinance;

  /// No description provided for @captureHintPantry.
  ///
  /// In en, this message translates to:
  /// **'Example: spinach expires tomorrow'**
  String get captureHintPantry;

  /// No description provided for @captureHintWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Example: thinking about buying another black jacket'**
  String get captureHintWardrobe;

  /// No description provided for @captureHintCopilot.
  ///
  /// In en, this message translates to:
  /// **'Example: a mission note'**
  String get captureHintCopilot;

  /// No description provided for @copilotTitle.
  ///
  /// In en, this message translates to:
  /// **'Copilot'**
  String get copilotTitle;

  /// No description provided for @copilotIntro.
  ///
  /// In en, this message translates to:
  /// **'The copilot now works around a ranked daily plan: visible trace, three missions and local fallback when the gateway is unavailable.'**
  String get copilotIntro;

  /// No description provided for @copilotBoundariesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection boundaries'**
  String get copilotBoundariesTitle;

  /// No description provided for @copilotBoundariesBody.
  ///
  /// In en, this message translates to:
  /// **'GoLife helps with daily organization and practical reflection. It does not diagnose, provide therapy, or replace professional care. If something feels urgent or unsafe, use real crisis or medical support.'**
  String get copilotBoundariesBody;

  /// No description provided for @copilotTodayPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Today plan'**
  String get copilotTodayPlanTitle;

  /// No description provided for @copilotNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No mission plan loaded yet.'**
  String get copilotNoPlan;

  /// No description provided for @copilotLatestTraceTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest trace'**
  String get copilotLatestTraceTitle;

  /// No description provided for @copilotNoTrace.
  ///
  /// In en, this message translates to:
  /// **'No mission loaded yet.'**
  String get copilotNoTrace;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
