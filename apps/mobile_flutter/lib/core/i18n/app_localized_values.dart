import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../features/app_state/golife_controller.dart';
import '../../l10n/app_localizations.dart';
import '../privacy/privacy_models.dart';

extension LocalizedDomainKey on DomainKey {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case DomainKey.habits:
        return l10n.domainHabits;
      case DomainKey.tasks:
        return l10n.domainTasks;
      case DomainKey.week:
        return l10n.domainWeek;
      case DomainKey.finance:
        return l10n.domainFinance;
      case DomainKey.pantry:
        return l10n.domainPantry;
      case DomainKey.wardrobe:
        return l10n.domainWardrobe;
      case DomainKey.copilot:
        return l10n.domainCopilot;
    }
  }
}

extension LocalizedDomainWireName on String {
  String localizedDomainLabel(AppLocalizations l10n) {
    final domain = domainKeyFromWireName(this);
    if (domain == null) {
      return this;
    }
    return domain.localizedLabel(l10n);
  }
}

extension LocalizedDataPermission on DataPermission {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case DataPermission.localOnly:
        return l10n.permissionLocal;
      case DataPermission.syncAllowed:
        return l10n.permissionSync;
      case DataPermission.aiAllowed:
        return l10n.permissionAi;
    }
  }
}

extension LocalizedPermissionStorageKey on String {
  String localizedPermissionLabel(AppLocalizations l10n) {
    for (final permission in DataPermission.values) {
      if (permission.storageKey == this) {
        return permission.localizedLabel(l10n);
      }
    }
    return this;
  }
}

extension LocalizedMissionFeedbackStatus on MissionFeedbackStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MissionFeedbackStatus.useful:
        return l10n.feedbackUseful;
      case MissionFeedbackStatus.rejected:
        return l10n.feedbackRejected;
      case MissionFeedbackStatus.accepted:
        return l10n.feedbackAccepted;
      case MissionFeedbackStatus.completed:
        return l10n.feedbackCompleted;
      case MissionFeedbackStatus.edited:
        return l10n.feedbackEdited;
    }
  }
}

extension LocalizedGoLifeController on GoLifeController {
  List<String> localizedEncryptedCollectionLabels(AppLocalizations l10n) {
    return <String>[
      l10n.collectionFinanceRecords,
      l10n.collectionJournalEntries,
      l10n.collectionQuickNotes,
    ];
  }

  List<String> localizedAlwaysLocalCollectionLabels(AppLocalizations l10n) {
    return <String>[
      l10n.collectionPrivacySettings,
      l10n.collectionJournalEntries,
      l10n.collectionQuickNotes,
      l10n.collectionRuntimeConfigCache,
      l10n.collectionDeviceEncryptionKey,
    ];
  }

  List<String> localizedAiSendableCollectionLabels(AppLocalizations l10n) {
    final labels = privacySettings.aiAllowedDomains
        .where((domain) => domain != DomainKey.copilot)
        .map((domain) => domain.localizedLabel(l10n))
        .toList(growable: false);
    if (labels.isEmpty) {
      return <String>[l10n.nothingAiEnabled];
    }
    return labels;
  }

  String localizedLatestFeedbackLabel(AppLocalizations l10n) {
    return latestMissionFeedback?.status.localizedLabel(l10n) ?? l10n.feedbackNone;
  }

  String localizedGatewayStatusLabel(AppLocalizations l10n) {
    final trace = dailyMission?.trace ?? const <String, Object?>{};
    if (trace['remote'] == true) {
      return l10n.gatewayLive;
    }
    final reason = (trace['fallbackReason'] ?? '').toString();
    if (reason == 'no_connection') {
      return l10n.gatewayNoConnection;
    }
    if (reason == 'ai_temporarily_unavailable') {
      return l10n.gatewayUnavailable;
    }
    if (trace['clientFallback'] == true || trace['mock'] == true) {
      return l10n.gatewayLocalFallback;
    }
    return l10n.gatewayLive;
  }

  String localizedMissionDeliveryLabel(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final trace = mission.trace;
    if (trace['remote'] == true) {
      return l10n.missionDeliveryAi;
    }
    if (trace['clientFallback'] == true || trace['mock'] == true) {
      return l10n.missionDeliveryFallback;
    }
    return l10n.missionDeliveryLocal;
  }

  String localizedMissionDeliverySummary(
    DailyMission mission,
    AppLocalizations l10n,
  ) {
    final trace = mission.trace;
    if (trace['remote'] == true) {
      return l10n.missionDeliverySummaryAi;
    }
    if (trace['clientFallback'] == true || trace['mock'] == true) {
      return l10n.missionDeliverySummaryFallback;
    }
    return l10n.missionDeliverySummaryLocal;
  }
}
