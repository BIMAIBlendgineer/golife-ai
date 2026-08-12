import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const requiredSettingsPtBrKeys = <String>[
  'aiBrief',
  'aiDetailed',
  'aiResponseStyle',
  'backupSyncOff',
  'backupSyncOn',
  'backupSyncPreference',
  'billingAuditEmpty',
  'billingAuditTitle',
  'billingCatalogEmpty',
  'billingCatalogTitle',
  'billingCurrentPlanLabel',
  'billingDecisionCopy',
  'billingDecisionOpen',
  'billingDisabledLabel',
  'billingExportDeleteAlwaysAvailable',
  'billingExportDeleteLabel',
  'billingFeatureGatesTitle',
  'billingGateAiCaptures',
  'billingGateAlwaysAvailable',
  'billingGateExportBundles',
  'billingGateMissionRefreshes',
  'billingGateQuotaExhausted',
  'billingGateValue',
  'billingGateWithinQuota',
  'billingLastProductLabel',
  'billingLastValidatedLabel',
  'billingModeGooglePlayLive',
  'billingModeGooglePlaySandbox',
  'billingModeLabel',
  'billingPlanBody',
  'billingPlanBodySandbox',
  'billingPlanFree',
  'billingPlanPremium',
  'billingPlanPro',
  'billingPlanTitle',
  'billingProviderGooglePlay',
  'billingProviderLabel',
  'billingPurchaseSandbox',
  'billingRefreshNow',
  'billingRenewalActive',
  'billingRenewalCancelled',
  'billingRenewalDisabled',
  'billingRenewalExpired',
  'billingRenewalGrace',
  'billingRenewalPaused',
  'billingRenewalPending',
  'billingRenewalRefunded',
  'billingRenewalStateLabel',
  'billingRestoreAvailable',
  'billingRestoreLabel',
  'billingRestoreNow',
  'billingRestoreUnavailable',
  'billingSandboxInternalOnly',
  'billingStatusLabel',
  'billingStoredPurchaseLabel',
  'clearAiHistory',
  'clearAiHistoryBody',
  'clearAiHistoryDone',
  'clearAiHistoryTitle',
  'cancel',
  'dataControls',
  'dataControlsBody',
  'deleteAll',
  'deleteAllBody',
  'deleteAllDone',
  'deleteAllLocalData',
  'deleteAllTitle',
  'deliveryPreferencesTitle',
  'domainControls',
  'exportCopied',
  'exportJson',
  'exportSavedFile',
  'fieldDomain',
  'fieldPrivacy',
  'language',
  'languageEnglish',
  'languagePortugueseBrazil',
  'languageSpanish',
  'languageSystem',
  'lifeGraphOpenTimeline',
  'measurementUnitsPreference',
  'navSettings',
  'nothingAiEnabled',
  'notificationsDisabled',
  'notificationsEnabled',
  'notificationsPreference',
  'preferencesLocalOnlyHint',
  'privacyAuditBody',
  'privacyAuditChangedAt',
  'privacyAuditEmpty',
  'privacyAuditTitle',
  'privacyDisclosureAiBody',
  'privacyDisclosureAiTitle',
  'privacyDisclosureEncryptedBody',
  'privacyDisclosureEncryptedTitle',
  'privacyDisclosureLocalBody',
  'privacyDisclosureLocalTitle',
  'privacyEncryptedActive',
  'privacyEncryptedUnavailable',
  'privacyEventAiEligible',
  'privacyEventId',
  'privacyEventSource',
  'privacyLegalBody',
  'privacyLegalCopy',
  'privacyLegalCopied',
  'privacyLegalOpen',
  'privacyLegalPolicyBody',
  'privacyLegalPolicyTitle',
  'privacyLegalSupportBody',
  'privacyLegalSupportTitle',
  'privacyLegalTermsBody',
  'privacyLegalTermsTitle',
  'privacyLegalTitle',
  'privacyLegalOpenFallback',
  'privacyMetricAiEligible',
  'privacyMetricAuditEntries',
  'privacyMetricBlockedLocal',
  'privacyMetricEvidenceItems',
  'privacyMetricRelations',
  'privacyMetricTotalEvents',
  'privacyRecentEventsBody',
  'privacyRecentEventsEmpty',
  'privacyRecentEventsTitle',
  'privacyTitle',
  'profilePreferencesBody',
  'profilePreferencesTitle',
  'quietHours2207',
  'quietHours2308',
  'quietHoursOff',
  'quietHoursPreference',
  'regionalPreferencesTitle',
  'regionAuto',
  'regionBrazil',
  'regionChinaMainland',
  'regionCountryPreference',
  'regionFrance',
  'regionGermany',
  'regionItaly',
  'regionJapan',
  'regionPortugal',
  'regionSpain',
  'regionTaiwan',
  'regionUs',
  'reminderDaily',
  'reminderFrequencyPreference',
  'reminderOff',
  'reminderWeekdays',
  'reminderWeekly',
  'themeDark',
  'themeLight',
  'themePreference',
  'themeSystem',
  'unitImperial',
  'unitMetric',
  'valueNo',
  'valueYes',
  'valueUnknown',
  '@billingGateValue',
];

Map<String, dynamic> _readPtBr() {
  final file = File('lib/l10n/app_pt_BR.arb');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  test('PT-BR defines every Settings localization key explicitly', () {
    final resources = _readPtBr();
    final missing = requiredSettingsPtBrKeys
        .where((key) => !resources.containsKey(key))
        .toList(growable: false);
    expect(missing, isEmpty);
  });

  test(
      'PT-BR Settings resources contain no replacement question marks inside words',
      () {
    final resources = _readPtBr();
    final corrupt = <String>[];
    for (final key in requiredSettingsPtBrKeys) {
      final value = resources[key];
      if (value is String &&
          (value.contains('??') || RegExp(r'\w\?\w').hasMatch(value))) {
        corrupt.add('$key: $value');
      }
    }
    expect(corrupt, isEmpty);

    expect(resources['languageSystem'], 'Padrão do sistema');
    expect(resources['languageEnglish'], 'Inglês');
    expect(resources['languageSpanish'], 'Espanhol');
    expect(resources['languagePortugueseBrazil'], 'Português (Brasil)');
    expect(resources['profilePreferencesTitle'], 'Preferências do perfil');
    expect(resources['billingPlanTitle'], 'Plano e cobrança');
    expect(resources['privacyLegalPolicyTitle'], 'Política de privacidade');
  });
}
