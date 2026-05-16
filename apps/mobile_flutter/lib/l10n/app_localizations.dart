import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
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

  /// No description provided for @navLifeGraph.
  ///
  /// In en, this message translates to:
  /// **'LifeGraph'**
  String get navLifeGraph;

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

  /// No description provided for @languagePortuguesePortugal.
  ///
  /// In en, this message translates to:
  /// **'Portuguese Portugal'**
  String get languagePortuguesePortugal;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

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

  /// No description provided for @languageChineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get languageChineseTraditional;

  /// No description provided for @profilePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile preferences'**
  String get profilePreferencesTitle;

  /// No description provided for @profilePreferencesBody.
  ///
  /// In en, this message translates to:
  /// **'Set language, theme, AI style, and current plan from one local-first profile center.'**
  String get profilePreferencesBody;

  /// No description provided for @deliveryPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications and rhythm'**
  String get deliveryPreferencesTitle;

  /// No description provided for @regionalPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Region and units'**
  String get regionalPreferencesTitle;

  /// No description provided for @preferencesLocalOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'These preferences stay local on this device until live sync and billing are connected.'**
  String get preferencesLocalOnlyHint;

  /// No description provided for @themePreference.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themePreference;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @notificationsPreference.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPreference;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get notificationsDisabled;

  /// No description provided for @quietHoursPreference.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get quietHoursPreference;

  /// No description provided for @quietHoursOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get quietHoursOff;

  /// No description provided for @quietHours2207.
  ///
  /// In en, this message translates to:
  /// **'22:00-07:00'**
  String get quietHours2207;

  /// No description provided for @quietHours2308.
  ///
  /// In en, this message translates to:
  /// **'23:00-08:00'**
  String get quietHours2308;

  /// No description provided for @measurementUnitsPreference.
  ///
  /// In en, this message translates to:
  /// **'Measurement units'**
  String get measurementUnitsPreference;

  /// No description provided for @unitMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitMetric;

  /// No description provided for @unitImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitImperial;

  /// No description provided for @regionCountryPreference.
  ///
  /// In en, this message translates to:
  /// **'Region or country'**
  String get regionCountryPreference;

  /// No description provided for @regionAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get regionAuto;

  /// No description provided for @regionUs.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get regionUs;

  /// No description provided for @regionSpain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get regionSpain;

  /// No description provided for @regionBrazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get regionBrazil;

  /// No description provided for @regionPortugal.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get regionPortugal;

  /// No description provided for @regionFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get regionFrance;

  /// No description provided for @regionItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get regionItaly;

  /// No description provided for @regionGermany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get regionGermany;

  /// No description provided for @regionJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get regionJapan;

  /// No description provided for @regionChinaMainland.
  ///
  /// In en, this message translates to:
  /// **'Mainland China'**
  String get regionChinaMainland;

  /// No description provided for @regionTaiwan.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get regionTaiwan;

  /// No description provided for @reminderFrequencyPreference.
  ///
  /// In en, this message translates to:
  /// **'Reminder frequency'**
  String get reminderFrequencyPreference;

  /// No description provided for @reminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get reminderOff;

  /// No description provided for @reminderDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reminderDaily;

  /// No description provided for @reminderWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get reminderWeekdays;

  /// No description provided for @reminderWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reminderWeekly;

  /// No description provided for @aiResponseStyle.
  ///
  /// In en, this message translates to:
  /// **'AI preference'**
  String get aiResponseStyle;

  /// No description provided for @aiBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get aiBrief;

  /// No description provided for @aiDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get aiDetailed;

  /// No description provided for @backupSyncPreference.
  ///
  /// In en, this message translates to:
  /// **'Backup and sync'**
  String get backupSyncPreference;

  /// No description provided for @backupSyncOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get backupSyncOff;

  /// No description provided for @backupSyncOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get backupSyncOn;

  /// No description provided for @currentPlanPreference.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get currentPlanPreference;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planPlus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get planPlus;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planPro;

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

  /// No description provided for @privacyRuntimeSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Runtime audit snapshot'**
  String get privacyRuntimeSnapshotTitle;

  /// No description provided for @privacyRuntimeSnapshotBody.
  ///
  /// In en, this message translates to:
  /// **'These counts come from the local persistence layer used for export, traceability, and privacy review.'**
  String get privacyRuntimeSnapshotBody;

  /// No description provided for @privacyMetricEvidenceItems.
  ///
  /// In en, this message translates to:
  /// **'Evidence items'**
  String get privacyMetricEvidenceItems;

  /// No description provided for @privacyMetricRelations.
  ///
  /// In en, this message translates to:
  /// **'Relations'**
  String get privacyMetricRelations;

  /// No description provided for @privacyMetricAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'Audit entries'**
  String get privacyMetricAuditEntries;

  /// No description provided for @lifeGraphOpenTimeline.
  ///
  /// In en, this message translates to:
  /// **'Open LifeGraph timeline'**
  String get lifeGraphOpenTimeline;

  /// No description provided for @dataControls.
  ///
  /// In en, this message translates to:
  /// **'Data controls'**
  String get dataControls;

  /// No description provided for @dataControlsBody.
  ///
  /// In en, this message translates to:
  /// **'Export saves the full local graph snapshot as a protected JSON file on this device. Delete all wipes local data and disables demo reseeding.'**
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

  /// No description provided for @exportSavedFile.
  ///
  /// In en, this message translates to:
  /// **'Protected local export bundle saved as {fileName}.'**
  String exportSavedFile(Object fileName);

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

  /// No description provided for @clearAiHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear AI history'**
  String get clearAiHistory;

  /// No description provided for @clearAiHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear AI history?'**
  String get clearAiHistoryTitle;

  /// No description provided for @clearAiHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'This clears saved missions, daily risks, and AI feedback history on this device.'**
  String get clearAiHistoryBody;

  /// No description provided for @clearAiHistoryDone.
  ///
  /// In en, this message translates to:
  /// **'AI history cleared.'**
  String get clearAiHistoryDone;

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

  /// No description provided for @privacyRecentEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent LifeGraph events'**
  String get privacyRecentEventsTitle;

  /// No description provided for @privacyRecentEventsBody.
  ///
  /// In en, this message translates to:
  /// **'Review recent local events, their privacy level, and whether they can be used for AI-backed missions.'**
  String get privacyRecentEventsBody;

  /// No description provided for @privacyRecentEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent events to review yet.'**
  String get privacyRecentEventsEmpty;

  /// No description provided for @privacyAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy audit'**
  String get privacyAuditTitle;

  /// No description provided for @privacyAuditBody.
  ///
  /// In en, this message translates to:
  /// **'Every event-level privacy change is logged locally on this device.'**
  String get privacyAuditBody;

  /// No description provided for @privacyAuditEmpty.
  ///
  /// In en, this message translates to:
  /// **'No local privacy audit entries yet.'**
  String get privacyAuditEmpty;

  /// No description provided for @lifeGraphTitle.
  ///
  /// In en, this message translates to:
  /// **'LifeGraph'**
  String get lifeGraphTitle;

  /// No description provided for @lifeGraphIntro.
  ///
  /// In en, this message translates to:
  /// **'Browse the local event timeline, inspect linked evidence and relations, and verify how privacy changes affect what the system can use.'**
  String get lifeGraphIntro;

  /// No description provided for @lifeGraphMetricVisibleEvents.
  ///
  /// In en, this message translates to:
  /// **'Visible events'**
  String get lifeGraphMetricVisibleEvents;

  /// No description provided for @lifeGraphMetricEvidenceItems.
  ///
  /// In en, this message translates to:
  /// **'Matched evidence'**
  String get lifeGraphMetricEvidenceItems;

  /// No description provided for @lifeGraphMetricRelations.
  ///
  /// In en, this message translates to:
  /// **'Matched relations'**
  String get lifeGraphMetricRelations;

  /// No description provided for @lifeGraphMetricAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'Matched audit entries'**
  String get lifeGraphMetricAuditEntries;

  /// No description provided for @lifeGraphFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Search and filters'**
  String get lifeGraphFiltersTitle;

  /// No description provided for @lifeGraphFiltersBody.
  ///
  /// In en, this message translates to:
  /// **'Filter the local graph by domain, date window, privacy level, and summary text.'**
  String get lifeGraphFiltersBody;

  /// No description provided for @lifeGraphSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search summary, domain, type, or source'**
  String get lifeGraphSearchHint;

  /// No description provided for @lifeGraphFilterDomainTitle.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get lifeGraphFilterDomainTitle;

  /// No description provided for @lifeGraphFilterDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get lifeGraphFilterDateTitle;

  /// No description provided for @lifeGraphFilterPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get lifeGraphFilterPrivacyTitle;

  /// No description provided for @lifeGraphFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get lifeGraphFilterAll;

  /// No description provided for @lifeGraphFilterDate7d.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get lifeGraphFilterDate7d;

  /// No description provided for @lifeGraphFilterDate30d.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get lifeGraphFilterDate30d;

  /// No description provided for @lifeGraphFilterDate90d.
  ///
  /// In en, this message translates to:
  /// **'90d'**
  String get lifeGraphFilterDate90d;

  /// No description provided for @lifeGraphTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get lifeGraphTimelineTitle;

  /// No description provided for @lifeGraphTimelineBody.
  ///
  /// In en, this message translates to:
  /// **'Events stay grouped by day so you can inspect the graph as a navigable local history, not a flat export blob.'**
  String get lifeGraphTimelineBody;

  /// No description provided for @lifeGraphNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events match the current filters.'**
  String get lifeGraphNoEvents;

  /// No description provided for @lifeGraphDateGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'{date} | {count} events'**
  String lifeGraphDateGroupTitle(Object date, int count);

  /// No description provided for @lifeGraphEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked evidence'**
  String get lifeGraphEvidenceTitle;

  /// No description provided for @lifeGraphEvidenceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No linked evidence for this event.'**
  String get lifeGraphEvidenceEmpty;

  /// No description provided for @lifeGraphRelationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked relations'**
  String get lifeGraphRelationsTitle;

  /// No description provided for @lifeGraphRelationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No linked relations for this event.'**
  String get lifeGraphRelationsEmpty;

  /// No description provided for @lifeGraphAuditNone.
  ///
  /// In en, this message translates to:
  /// **'No event-level privacy changes recorded for this event yet.'**
  String get lifeGraphAuditNone;

  /// No description provided for @lifeGraphOpenPrivacyAudit.
  ///
  /// In en, this message translates to:
  /// **'Open privacy audit'**
  String get lifeGraphOpenPrivacyAudit;

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

  /// No description provided for @collectionMissionSets.
  ///
  /// In en, this message translates to:
  /// **'Mission snapshots'**
  String get collectionMissionSets;

  /// No description provided for @collectionEvidenceItems.
  ///
  /// In en, this message translates to:
  /// **'Evidence items'**
  String get collectionEvidenceItems;

  /// No description provided for @collectionLifeGraphRelations.
  ///
  /// In en, this message translates to:
  /// **'LifeGraph relations'**
  String get collectionLifeGraphRelations;

  /// No description provided for @collectionPrivacyAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'Privacy audit entries'**
  String get collectionPrivacyAuditEntries;

  /// No description provided for @collectionOwnedItems.
  ///
  /// In en, this message translates to:
  /// **'Owned items'**
  String get collectionOwnedItems;

  /// No description provided for @collectionPurchaseProofs.
  ///
  /// In en, this message translates to:
  /// **'Purchase proofs'**
  String get collectionPurchaseProofs;

  /// No description provided for @collectionClaimDrafts.
  ///
  /// In en, this message translates to:
  /// **'Claim drafts'**
  String get collectionClaimDrafts;

  /// No description provided for @collectionEvidenceAttachments.
  ///
  /// In en, this message translates to:
  /// **'Evidence attachments'**
  String get collectionEvidenceAttachments;

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

  /// No description provided for @privacyEventSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get privacyEventSource;

  /// No description provided for @privacyEventAiEligible.
  ///
  /// In en, this message translates to:
  /// **'AI eligible'**
  String get privacyEventAiEligible;

  /// No description provided for @privacyEventId.
  ///
  /// In en, this message translates to:
  /// **'Event ID'**
  String get privacyEventId;

  /// No description provided for @privacyAuditChangedAt.
  ///
  /// In en, this message translates to:
  /// **'Changed at'**
  String get privacyAuditChangedAt;

  /// No description provided for @valueYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get valueYes;

  /// No description provided for @valueNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get valueNo;

  /// No description provided for @valueUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get valueUnknown;

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

  /// No description provided for @missionSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission snapshot'**
  String get missionSnapshotTitle;

  /// No description provided for @missionSnapshotBody.
  ///
  /// In en, this message translates to:
  /// **'This is the persisted local snapshot for the current mission set.'**
  String get missionSnapshotBody;

  /// No description provided for @missionSnapshotId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get missionSnapshotId;

  /// No description provided for @missionSnapshotDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get missionSnapshotDate;

  /// No description provided for @missionSnapshotSourceState.
  ///
  /// In en, this message translates to:
  /// **'Source state'**
  String get missionSnapshotSourceState;

  /// No description provided for @missionSnapshotCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get missionSnapshotCreatedAt;

  /// No description provided for @missionSnapshotMissionCount.
  ///
  /// In en, this message translates to:
  /// **'Mission count'**
  String get missionSnapshotMissionCount;

  /// No description provided for @missionSnapshotFallbackUsed.
  ///
  /// In en, this message translates to:
  /// **'Fallback used'**
  String get missionSnapshotFallbackUsed;

  /// No description provided for @missionSnapshotPolicyVersion.
  ///
  /// In en, this message translates to:
  /// **'Policy version'**
  String get missionSnapshotPolicyVersion;

  /// No description provided for @missionSnapshotRankingVersion.
  ///
  /// In en, this message translates to:
  /// **'Ranking version'**
  String get missionSnapshotRankingVersion;

  /// No description provided for @missionSnapshotRankingTrace.
  ///
  /// In en, this message translates to:
  /// **'Ranking trace'**
  String get missionSnapshotRankingTrace;

  /// No description provided for @missionSnapshotSourceStateLocal.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get missionSnapshotSourceStateLocal;

  /// No description provided for @missionSnapshotSourceStateDegraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get missionSnapshotSourceStateDegraded;

  /// No description provided for @missionSetSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'MissionSet'**
  String get missionSetSectionTitle;

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

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get navRecipes;

  /// No description provided for @homeMemoryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'RecallBox'**
  String get homeMemoryEyebrow;

  /// No description provided for @homeMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'HomeMemory'**
  String get homeMemoryTitle;

  /// No description provided for @homeMemorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Things, receipts, warranties, and reminders.'**
  String get homeMemorySubtitle;

  /// No description provided for @homeMemoryDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Local purchase memory'**
  String get homeMemoryDisclosureTitle;

  /// No description provided for @homeMemoryDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'Receipts, draft claims, and evidence stay local-first in this MVP. GoLife turns them into reminders and next actions without promising legal review.'**
  String get homeMemoryDisclosureBody;

  /// No description provided for @homeMemoryWarrantySoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Warranty ending soon'**
  String get homeMemoryWarrantySoonTitle;

  /// No description provided for @homeMemoryWarrantySoonEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active warranty close to expiration.'**
  String get homeMemoryWarrantySoonEmpty;

  /// No description provided for @homeMemoryRecentProofsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent proofs'**
  String get homeMemoryRecentProofsTitle;

  /// No description provided for @homeMemoryRecentProofsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No proofs captured yet.'**
  String get homeMemoryRecentProofsEmpty;

  /// No description provided for @homeMemoryRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance reminders'**
  String get homeMemoryRemindersTitle;

  /// No description provided for @homeMemoryRemindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled.'**
  String get homeMemoryRemindersEmpty;

  /// No description provided for @homeMemoryClaimsTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim drafts'**
  String get homeMemoryClaimsTitle;

  /// No description provided for @homeMemoryClaimsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No draft claims yet.'**
  String get homeMemoryClaimsEmpty;

  /// No description provided for @homeMemoryActionAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item manually'**
  String get homeMemoryActionAddItem;

  /// No description provided for @homeMemoryActionAddProof.
  ///
  /// In en, this message translates to:
  /// **'Add proof'**
  String get homeMemoryActionAddProof;

  /// No description provided for @homeMemoryActionCreateReminder.
  ///
  /// In en, this message translates to:
  /// **'Create reminder'**
  String get homeMemoryActionCreateReminder;

  /// No description provided for @homeMemoryActionDraftClaim.
  ///
  /// In en, this message translates to:
  /// **'Draft claim'**
  String get homeMemoryActionDraftClaim;

  /// No description provided for @homeMemoryActionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open HomeMemory'**
  String get homeMemoryActionOpen;

  /// No description provided for @homeMemoryItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Owned items'**
  String get homeMemoryItemsTitle;

  /// No description provided for @homeMemoryItemsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No owned items stored yet.'**
  String get homeMemoryItemsEmpty;

  /// No description provided for @homeMemoryWarrantyUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Warranty until {date}'**
  String homeMemoryWarrantyUntilLabel(Object date);

  /// No description provided for @homeMemoryItemNoMeta.
  ///
  /// In en, this message translates to:
  /// **'No purchase metadata yet.'**
  String get homeMemoryItemNoMeta;

  /// No description provided for @homeMemorySectionItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get homeMemorySectionItem;

  /// No description provided for @homeMemorySectionProofs.
  ///
  /// In en, this message translates to:
  /// **'Proofs'**
  String get homeMemorySectionProofs;

  /// No description provided for @homeMemorySectionWarranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get homeMemorySectionWarranty;

  /// No description provided for @homeMemorySectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get homeMemorySectionReminders;

  /// No description provided for @homeMemorySectionClaims.
  ///
  /// In en, this message translates to:
  /// **'Claim drafts'**
  String get homeMemorySectionClaims;

  /// No description provided for @homeMemorySectionEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get homeMemorySectionEvidence;

  /// No description provided for @homeMemoryFieldProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get homeMemoryFieldProductName;

  /// No description provided for @homeMemoryFieldBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get homeMemoryFieldBrand;

  /// No description provided for @homeMemoryFieldModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get homeMemoryFieldModel;

  /// No description provided for @homeMemoryFieldSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get homeMemoryFieldSerialNumber;

  /// No description provided for @homeMemoryFieldStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get homeMemoryFieldStore;

  /// No description provided for @homeMemoryFieldPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get homeMemoryFieldPurchaseDate;

  /// No description provided for @homeMemoryFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get homeMemoryFieldPrice;

  /// No description provided for @homeMemoryFieldCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get homeMemoryFieldCurrency;

  /// No description provided for @homeMemoryFieldWarrantyMonths.
  ///
  /// In en, this message translates to:
  /// **'Warranty months'**
  String get homeMemoryFieldWarrantyMonths;

  /// No description provided for @homeMemoryFieldWarrantyUntil.
  ///
  /// In en, this message translates to:
  /// **'Warranty until'**
  String get homeMemoryFieldWarrantyUntil;

  /// No description provided for @homeMemoryFieldDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get homeMemoryFieldDueDate;

  /// No description provided for @homeMemoryFieldRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get homeMemoryFieldRecurrence;

  /// No description provided for @homeMemoryFieldIssueDescription.
  ///
  /// In en, this message translates to:
  /// **'Issue description'**
  String get homeMemoryFieldIssueDescription;

  /// No description provided for @homeMemoryFieldRecipientHint.
  ///
  /// In en, this message translates to:
  /// **'Recipient hint'**
  String get homeMemoryFieldRecipientHint;

  /// No description provided for @homeMemoryCreateWarrantyReminder.
  ///
  /// In en, this message translates to:
  /// **'Create a reminder before warranty expiration'**
  String get homeMemoryCreateWarrantyReminder;

  /// No description provided for @homeMemoryDefaultReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Review warranty before expiration'**
  String get homeMemoryDefaultReminderTitle;

  /// No description provided for @homeMemorySelectItem.
  ///
  /// In en, this message translates to:
  /// **'Select item'**
  String get homeMemorySelectItem;

  /// No description provided for @homeMemoryClaimDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'No legal advice. Verify warranty and seller policies. Send outside the app.'**
  String get homeMemoryClaimDisclaimer;

  /// No description provided for @homeMemoryNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get homeMemoryNoNotes;

  /// No description provided for @homeMemoryUnknownMerchant.
  ///
  /// In en, this message translates to:
  /// **'Unknown merchant'**
  String get homeMemoryUnknownMerchant;

  /// No description provided for @homeMemoryUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get homeMemoryUnknownDate;

  /// No description provided for @homeMemoryUnknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get homeMemoryUnknownValue;

  /// No description provided for @homeMemoryNoProofs.
  ///
  /// In en, this message translates to:
  /// **'No proofs attached yet.'**
  String get homeMemoryNoProofs;

  /// No description provided for @homeMemoryWarrantyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Warranty unknown.'**
  String get homeMemoryWarrantyUnknown;

  /// No description provided for @homeMemoryNoReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.'**
  String get homeMemoryNoReminders;

  /// No description provided for @homeMemoryNoClaims.
  ///
  /// In en, this message translates to:
  /// **'No claim drafts yet.'**
  String get homeMemoryNoClaims;

  /// No description provided for @homeMemoryNoEvidence.
  ///
  /// In en, this message translates to:
  /// **'No evidence attached yet.'**
  String get homeMemoryNoEvidence;

  /// No description provided for @homeMemoryEvidencePresent.
  ///
  /// In en, this message translates to:
  /// **'Evidence attachment available.'**
  String get homeMemoryEvidencePresent;

  /// No description provided for @homeMemoryWarrantyStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get homeMemoryWarrantyStatusUnknown;

  /// No description provided for @homeMemoryWarrantyStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'expired'**
  String get homeMemoryWarrantyStatusExpired;

  /// No description provided for @homeMemoryWarrantyStatusActive.
  ///
  /// In en, this message translates to:
  /// **'active warranty'**
  String get homeMemoryWarrantyStatusActive;

  /// No description provided for @homeMemoryEverydaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{itemCount} items | {warrantyCount} warranties ending soon'**
  String homeMemoryEverydaySubtitle(int itemCount, int warrantyCount);

  /// No description provided for @homeMemoryEverydayBody.
  ///
  /// In en, this message translates to:
  /// **'Keep receipts, owned items, warranties, reminders, and draft claims in one local memory surface.'**
  String get homeMemoryEverydayBody;

  /// No description provided for @entityTask.
  ///
  /// In en, this message translates to:
  /// **'task'**
  String get entityTask;

  /// No description provided for @entityHabit.
  ///
  /// In en, this message translates to:
  /// **'habit'**
  String get entityHabit;

  /// No description provided for @entityExpense.
  ///
  /// In en, this message translates to:
  /// **'expense'**
  String get entityExpense;

  /// No description provided for @entityPantryItem.
  ///
  /// In en, this message translates to:
  /// **'pantry item'**
  String get entityPantryItem;

  /// No description provided for @entityPurchaseIntention.
  ///
  /// In en, this message translates to:
  /// **'purchase intention'**
  String get entityPurchaseIntention;

  /// No description provided for @entityWeekPlan.
  ///
  /// In en, this message translates to:
  /// **'week plan'**
  String get entityWeekPlan;

  /// No description provided for @entityJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'journal entry'**
  String get entityJournalEntry;

  /// No description provided for @entityQuickNote.
  ///
  /// In en, this message translates to:
  /// **'quick note'**
  String get entityQuickNote;

  /// No description provided for @entityCalendarItem.
  ///
  /// In en, this message translates to:
  /// **'calendar item'**
  String get entityCalendarItem;

  /// No description provided for @entityRecipeRescue.
  ///
  /// In en, this message translates to:
  /// **'recipe rescue'**
  String get entityRecipeRescue;

  /// No description provided for @actionNewEntity.
  ///
  /// In en, this message translates to:
  /// **'New {entity}'**
  String actionNewEntity(Object entity);

  /// No description provided for @actionEditEntity.
  ///
  /// In en, this message translates to:
  /// **'Edit {entity}'**
  String actionEditEntity(Object entity);

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get actionComplete;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get actionCheckIn;

  /// No description provided for @actionReflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get actionReflect;

  /// No description provided for @actionMarkUsed.
  ///
  /// In en, this message translates to:
  /// **'Mark used'**
  String get actionMarkUsed;

  /// No description provided for @actionUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get actionUsed;

  /// No description provided for @actionPause24h.
  ///
  /// In en, this message translates to:
  /// **'Pause 24h'**
  String get actionPause24h;

  /// No description provided for @actionReplan.
  ///
  /// In en, this message translates to:
  /// **'Replan'**
  String get actionReplan;

  /// No description provided for @actionReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get actionReview;

  /// No description provided for @actionKeepLocal.
  ///
  /// In en, this message translates to:
  /// **'Keep local'**
  String get actionKeepLocal;

  /// No description provided for @actionOpenJournal.
  ///
  /// In en, this message translates to:
  /// **'Open journal'**
  String get actionOpenJournal;

  /// No description provided for @actionOpenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get actionOpenCalendar;

  /// No description provided for @actionOpenRecipes.
  ///
  /// In en, this message translates to:
  /// **'Open recipes'**
  String get actionOpenRecipes;

  /// No description provided for @actionCookNow.
  ///
  /// In en, this message translates to:
  /// **'Cook now'**
  String get actionCookNow;

  /// No description provided for @actionCooked.
  ///
  /// In en, this message translates to:
  /// **'Cooked'**
  String get actionCooked;

  /// No description provided for @actionTimeBlock.
  ///
  /// In en, this message translates to:
  /// **'Time block'**
  String get actionTimeBlock;

  /// No description provided for @actionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get actionSaving;

  /// No description provided for @domainTasksEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Execution'**
  String get domainTasksEyebrow;

  /// No description provided for @domainTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'TaskDoctor is now a local-first task board with direct create, edit, and complete flows.'**
  String get domainTasksDescription;

  /// No description provided for @domainHabitsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Continuity'**
  String get domainHabitsEyebrow;

  /// No description provided for @domainHabitsDescription.
  ///
  /// In en, this message translates to:
  /// **'LifeQuest now supports direct habit creation and recovery-friendly check-ins.'**
  String get domainHabitsDescription;

  /// No description provided for @domainMoneyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Awareness'**
  String get domainMoneyEyebrow;

  /// No description provided for @domainMoneyDescription.
  ///
  /// In en, this message translates to:
  /// **'MoneyMirror stays conservative: log, edit, and reflect locally without crossing into regulated advice.'**
  String get domainMoneyDescription;

  /// No description provided for @domainPantryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Rescue'**
  String get domainPantryEyebrow;

  /// No description provided for @domainPantryDescription.
  ///
  /// In en, this message translates to:
  /// **'FridgeZero now keeps a rescue board where ingredients can be created, edited, and marked used.'**
  String get domainPantryDescription;

  /// No description provided for @domainClosetEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Anti-consumption'**
  String get domainClosetEyebrow;

  /// No description provided for @domainClosetDescription.
  ///
  /// In en, this message translates to:
  /// **'ClosetLess remains an intention-first board, now with editable pauses and purchase reasons.'**
  String get domainClosetDescription;

  /// No description provided for @domainWeekEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get domainWeekEyebrow;

  /// No description provided for @domainWeekDescription.
  ///
  /// In en, this message translates to:
  /// **'WeekPilot stays intentionally light, but now supports quick creation and direct replanning.'**
  String get domainWeekDescription;

  /// No description provided for @domainJournalEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Private by default'**
  String get domainJournalEyebrow;

  /// No description provided for @domainJournalDescription.
  ///
  /// In en, this message translates to:
  /// **'Journal and notes stay local-first so the app can learn from your day without turning into therapy.'**
  String get domainJournalDescription;

  /// No description provided for @domainCalendarEyebrow.
  ///
  /// In en, this message translates to:
  /// **'QuickCal'**
  String get domainCalendarEyebrow;

  /// No description provided for @domainCalendarDescription.
  ///
  /// In en, this message translates to:
  /// **'QuickCal starts as a fast local layer for time blocks and overload detection, not a full sync engine.'**
  String get domainCalendarDescription;

  /// No description provided for @domainRecipesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Recipe Rescue'**
  String get domainRecipesEyebrow;

  /// No description provided for @domainRecipesDescription.
  ///
  /// In en, this message translates to:
  /// **'Recipe Rescue turns pantry context into simple local meal plans that can mark ingredients as used.'**
  String get domainRecipesDescription;

  /// No description provided for @domainEverydayEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Life OS'**
  String get domainEverydayEyebrow;

  /// No description provided for @domainEverydayDescription.
  ///
  /// In en, this message translates to:
  /// **'Journal, calendar, and recipes live together here so the shell stays lighter while everyday context keeps growing.'**
  String get domainEverydayDescription;

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks captured yet.'**
  String get tasksEmpty;

  /// No description provided for @habitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits captured yet.'**
  String get habitsEmpty;

  /// No description provided for @moneyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses captured yet.'**
  String get moneyEmpty;

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pantry items captured yet.'**
  String get pantryEmpty;

  /// No description provided for @closetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No purchase intentions captured yet.'**
  String get closetEmpty;

  /// No description provided for @weekEmpty.
  ///
  /// In en, this message translates to:
  /// **'No week plans captured yet.'**
  String get weekEmpty;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet.'**
  String get journalEmpty;

  /// No description provided for @quickNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No quick notes yet.'**
  String get quickNotesEmpty;

  /// No description provided for @calendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'No calendar items yet.'**
  String get calendarEmpty;

  /// No description provided for @recipesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipe rescues yet.'**
  String get recipesEmpty;

  /// No description provided for @calendarOverloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Overload detected'**
  String get calendarOverloadTitle;

  /// No description provided for @calendarOverloadBody.
  ///
  /// In en, this message translates to:
  /// **'There are already four or more local calendar items. Protect the smallest non-critical block first.'**
  String get calendarOverloadBody;

  /// No description provided for @calendarCalmTitle.
  ///
  /// In en, this message translates to:
  /// **'Calm calendar'**
  String get calendarCalmTitle;

  /// No description provided for @calendarCalmBody.
  ///
  /// In en, this message translates to:
  /// **'Use QuickCal for fast local blocks before adding full calendar sync.'**
  String get calendarCalmBody;

  /// No description provided for @everydayContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Everyday context'**
  String get everydayContextTitle;

  /// No description provided for @everydayContextBody.
  ///
  /// In en, this message translates to:
  /// **'Use writing, time blocks, and recipe rescue to give Today better context without turning the app into six crowded tabs.'**
  String get everydayContextBody;

  /// No description provided for @everydayJournalBody.
  ///
  /// In en, this message translates to:
  /// **'Capture reflection and short notes locally, with privacy-first defaults.'**
  String get everydayJournalBody;

  /// No description provided for @everydayCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'Keep a quick local calendar before you need full sync.'**
  String get everydayCalendarBody;

  /// No description provided for @everydayRecipesBody.
  ///
  /// In en, this message translates to:
  /// **'Turn pantry context into low-friction meals and mark ingredients used.'**
  String get everydayRecipesBody;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldEstimatedMinutes.
  ///
  /// In en, this message translates to:
  /// **'Estimated minutes'**
  String get fieldEstimatedMinutes;

  /// No description provided for @fieldPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get fieldPriority;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldCue.
  ///
  /// In en, this message translates to:
  /// **'Cue'**
  String get fieldCue;

  /// No description provided for @fieldCadence.
  ///
  /// In en, this message translates to:
  /// **'Cadence'**
  String get fieldCadence;

  /// No description provided for @fieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get fieldLabel;

  /// No description provided for @fieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fieldAmount;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get fieldQuantity;

  /// No description provided for @fieldRescueHint.
  ///
  /// In en, this message translates to:
  /// **'Rescue hint'**
  String get fieldRescueHint;

  /// No description provided for @fieldReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get fieldReason;

  /// No description provided for @fieldTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get fieldTheme;

  /// No description provided for @fieldFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get fieldFocus;

  /// No description provided for @fieldMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get fieldMood;

  /// No description provided for @fieldBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get fieldBody;

  /// No description provided for @fieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// No description provided for @fieldStartIso.
  ///
  /// In en, this message translates to:
  /// **'Start ISO'**
  String get fieldStartIso;

  /// No description provided for @fieldEndIso.
  ///
  /// In en, this message translates to:
  /// **'End ISO'**
  String get fieldEndIso;

  /// No description provided for @fieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get fieldLocation;

  /// No description provided for @fieldEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get fieldEnergy;

  /// No description provided for @fieldSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get fieldSummary;

  /// No description provided for @fieldIngredientsCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Ingredients (comma separated)'**
  String get fieldIngredientsCommaSeparated;

  /// No description provided for @chipRescue.
  ///
  /// In en, this message translates to:
  /// **'Rescue'**
  String get chipRescue;

  /// No description provided for @chipPurchaseIntention.
  ///
  /// In en, this message translates to:
  /// **'Purchase intention'**
  String get chipPurchaseIntention;

  /// No description provided for @chipJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get chipJournal;

  /// No description provided for @chipNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get chipNote;

  /// No description provided for @chipLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get chipLocalOnly;

  /// No description provided for @statusTaskInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get statusTaskInbox;

  /// No description provided for @statusTaskActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusTaskActive;

  /// No description provided for @statusTaskDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusTaskDone;

  /// No description provided for @priorityGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get priorityGentle;

  /// No description provided for @priorityStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get priorityStandard;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @cadenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get cadenceDaily;

  /// No description provided for @cadenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get cadenceWeekdays;

  /// No description provided for @cadenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get cadenceWeekly;

  /// No description provided for @recipeStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get recipeStatusDraft;

  /// No description provided for @recipeStatusCooked.
  ///
  /// In en, this message translates to:
  /// **'Cooked'**
  String get recipeStatusCooked;

  /// No description provided for @unitMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutesShort;

  /// No description provided for @journalQuickNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick notes'**
  String get journalQuickNotesTitle;

  /// No description provided for @messageTaskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated.'**
  String get messageTaskUpdated;

  /// No description provided for @messageHabitCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Habit checked in.'**
  String get messageHabitCheckedIn;

  /// No description provided for @messageExpenseRevisited.
  ///
  /// In en, this message translates to:
  /// **'Expense revisited.'**
  String get messageExpenseRevisited;

  /// No description provided for @messagePantryItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Pantry item updated.'**
  String get messagePantryItemUpdated;

  /// No description provided for @messagePurchaseIntentionPaused.
  ///
  /// In en, this message translates to:
  /// **'Purchase intention paused.'**
  String get messagePurchaseIntentionPaused;

  /// No description provided for @messageWeekPlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'Week plan updated.'**
  String get messageWeekPlanUpdated;

  /// No description provided for @messageJournalLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Journal stays local on this device.'**
  String get messageJournalLocalOnly;

  /// No description provided for @messageNoteLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Note stays local on this device.'**
  String get messageNoteLocalOnly;

  /// No description provided for @messageOpeningEditor.
  ///
  /// In en, this message translates to:
  /// **'Opening editor.'**
  String get messageOpeningEditor;

  /// No description provided for @messageRecipeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recipe rescue updated.'**
  String get messageRecipeUpdated;

  /// No description provided for @messageEntitySaved.
  ///
  /// In en, this message translates to:
  /// **'{entity} saved.'**
  String messageEntitySaved(Object entity);

  /// No description provided for @messageEntityDeleted.
  ///
  /// In en, this message translates to:
  /// **'{entity} deleted.'**
  String messageEntityDeleted(Object entity);

  /// No description provided for @taskTimeboxFirstBlock.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min first block'**
  String taskTimeboxFirstBlock(int minutes);

  /// No description provided for @habitStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String habitStreakDays(int count);

  /// No description provided for @everydayJournalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{entryCount} entries | {noteCount} quick notes'**
  String everydayJournalSubtitle(int entryCount, int noteCount);

  /// No description provided for @overloadDetected.
  ///
  /// In en, this message translates to:
  /// **'detected'**
  String get overloadDetected;

  /// No description provided for @overloadNotDetected.
  ///
  /// In en, this message translates to:
  /// **'not detected'**
  String get overloadNotDetected;

  /// No description provided for @everydayCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{blockCount} local blocks | overload {status}'**
  String everydayCalendarSubtitle(int blockCount, Object status);

  /// No description provided for @everydayRecipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} rescue ideas'**
  String everydayRecipesSubtitle(int count);

  /// No description provided for @labelToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get labelToday;

  /// No description provided for @mockCriticalTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish the next critical task'**
  String get mockCriticalTaskTitle;

  /// No description provided for @mockCriticalTaskBody.
  ///
  /// In en, this message translates to:
  /// **'Protect a {minutes}-minute block for the next critical step and keep priority at {priority}.'**
  String mockCriticalTaskBody(int minutes, String priority);

  /// No description provided for @mockRecoveryHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the recovery rhythm alive'**
  String get mockRecoveryHabitTitle;

  /// No description provided for @mockFinanceSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Review the spend signal'**
  String get mockFinanceSummaryTitle;

  /// No description provided for @mockFinanceSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Check {label} and decide whether {amount} still reflects a real need.'**
  String mockFinanceSummaryBody(String label, String amount);

  /// No description provided for @mockPantrySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Use one ingredient already at home'**
  String get mockPantrySummaryTitle;

  /// No description provided for @mockPantrySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Start with the oldest ingredient before opening a new shopping loop.'**
  String get mockPantrySummaryBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'pt',
        'zh'
      ].contains(locale.languageCode);

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
          case 'Hant':
            return AppLocalizationsZhHant();
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
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
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
