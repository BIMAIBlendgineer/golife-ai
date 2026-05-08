import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  light,
  dark,
}

extension AppThemePreferenceX on AppThemePreference {
  String get storageKey {
    switch (this) {
      case AppThemePreference.system:
        return 'system';
      case AppThemePreference.light:
        return 'light';
      case AppThemePreference.dark:
        return 'dark';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

enum NotificationPreference {
  enabled,
  disabled,
}

extension NotificationPreferenceX on NotificationPreference {
  String get storageKey {
    switch (this) {
      case NotificationPreference.enabled:
        return 'enabled';
      case NotificationPreference.disabled:
        return 'disabled';
    }
  }
}

enum QuietHoursPreference {
  off,
  from2200To0700,
  from2300To0800,
}

extension QuietHoursPreferenceX on QuietHoursPreference {
  String get storageKey {
    switch (this) {
      case QuietHoursPreference.off:
        return 'off';
      case QuietHoursPreference.from2200To0700:
        return '22-07';
      case QuietHoursPreference.from2300To0800:
        return '23-08';
    }
  }
}

enum MeasurementUnitPreference {
  metric,
  imperial,
}

extension MeasurementUnitPreferenceX on MeasurementUnitPreference {
  String get storageKey {
    switch (this) {
      case MeasurementUnitPreference.metric:
        return 'metric';
      case MeasurementUnitPreference.imperial:
        return 'imperial';
    }
  }
}

enum RegionPreference {
  auto,
  us,
  es,
  br,
  pt,
  fr,
  it,
  de,
  jp,
  cn,
  tw,
}

extension RegionPreferenceX on RegionPreference {
  String get storageKey {
    switch (this) {
      case RegionPreference.auto:
        return 'auto';
      case RegionPreference.us:
        return 'US';
      case RegionPreference.es:
        return 'ES';
      case RegionPreference.br:
        return 'BR';
      case RegionPreference.pt:
        return 'PT';
      case RegionPreference.fr:
        return 'FR';
      case RegionPreference.it:
        return 'IT';
      case RegionPreference.de:
        return 'DE';
      case RegionPreference.jp:
        return 'JP';
      case RegionPreference.cn:
        return 'CN';
      case RegionPreference.tw:
        return 'TW';
    }
  }
}

enum ReminderFrequencyPreference {
  off,
  daily,
  weekdays,
  weekly,
}

extension ReminderFrequencyPreferenceX on ReminderFrequencyPreference {
  String get storageKey {
    switch (this) {
      case ReminderFrequencyPreference.off:
        return 'off';
      case ReminderFrequencyPreference.daily:
        return 'daily';
      case ReminderFrequencyPreference.weekdays:
        return 'weekdays';
      case ReminderFrequencyPreference.weekly:
        return 'weekly';
    }
  }
}

enum AiDetailPreference {
  brief,
  detailed,
}

extension AiDetailPreferenceX on AiDetailPreference {
  String get storageKey {
    switch (this) {
      case AiDetailPreference.brief:
        return 'brief';
      case AiDetailPreference.detailed:
        return 'detailed';
    }
  }
}

enum BackupSyncPreference {
  off,
  on,
}

extension BackupSyncPreferenceX on BackupSyncPreference {
  String get storageKey {
    switch (this) {
      case BackupSyncPreference.off:
        return 'off';
      case BackupSyncPreference.on:
        return 'on';
    }
  }
}

enum CurrentPlanPreference {
  free,
  plus,
  pro,
}

extension CurrentPlanPreferenceX on CurrentPlanPreference {
  String get storageKey {
    switch (this) {
      case CurrentPlanPreference.free:
        return 'free';
      case CurrentPlanPreference.plus:
        return 'plus';
      case CurrentPlanPreference.pro:
        return 'pro';
    }
  }
}

class AppProfilePreferences {
  const AppProfilePreferences({
    required this.themePreference,
    required this.notifications,
    required this.quietHours,
    required this.measurementUnits,
    required this.region,
    required this.reminderFrequency,
    required this.aiDetail,
    required this.backupSync,
    required this.currentPlan,
  });

  final AppThemePreference themePreference;
  final NotificationPreference notifications;
  final QuietHoursPreference quietHours;
  final MeasurementUnitPreference measurementUnits;
  final RegionPreference region;
  final ReminderFrequencyPreference reminderFrequency;
  final AiDetailPreference aiDetail;
  final BackupSyncPreference backupSync;
  final CurrentPlanPreference currentPlan;

  factory AppProfilePreferences.defaults() {
    return const AppProfilePreferences(
      themePreference: AppThemePreference.system,
      notifications: NotificationPreference.enabled,
      quietHours: QuietHoursPreference.off,
      measurementUnits: MeasurementUnitPreference.metric,
      region: RegionPreference.auto,
      reminderFrequency: ReminderFrequencyPreference.daily,
      aiDetail: AiDetailPreference.brief,
      backupSync: BackupSyncPreference.off,
      currentPlan: CurrentPlanPreference.free,
    );
  }

  AppProfilePreferences copyWith({
    AppThemePreference? themePreference,
    NotificationPreference? notifications,
    QuietHoursPreference? quietHours,
    MeasurementUnitPreference? measurementUnits,
    RegionPreference? region,
    ReminderFrequencyPreference? reminderFrequency,
    AiDetailPreference? aiDetail,
    BackupSyncPreference? backupSync,
    CurrentPlanPreference? currentPlan,
  }) {
    return AppProfilePreferences(
      themePreference: themePreference ?? this.themePreference,
      notifications: notifications ?? this.notifications,
      quietHours: quietHours ?? this.quietHours,
      measurementUnits: measurementUnits ?? this.measurementUnits,
      region: region ?? this.region,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      aiDetail: aiDetail ?? this.aiDetail,
      backupSync: backupSync ?? this.backupSync,
      currentPlan: currentPlan ?? this.currentPlan,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'theme_preference': themePreference.storageKey,
      'notifications': notifications.storageKey,
      'quiet_hours': quietHours.storageKey,
      'measurement_units': measurementUnits.storageKey,
      'region': region.storageKey,
      'reminder_frequency': reminderFrequency.storageKey,
      'ai_detail': aiDetail.storageKey,
      'backup_sync': backupSync.storageKey,
      'current_plan': currentPlan.storageKey,
    };
  }

  factory AppProfilePreferences.fromJson(Map<String, dynamic> json) {
    return AppProfilePreferences(
      themePreference: appThemePreferenceFromStorage(
        json['theme_preference']?.toString(),
      ),
      notifications: notificationPreferenceFromStorage(
        json['notifications']?.toString(),
      ),
      quietHours: quietHoursPreferenceFromStorage(
        json['quiet_hours']?.toString(),
      ),
      measurementUnits: measurementUnitPreferenceFromStorage(
        json['measurement_units']?.toString(),
      ),
      region: regionPreferenceFromStorage(json['region']?.toString()),
      reminderFrequency: reminderFrequencyPreferenceFromStorage(
        json['reminder_frequency']?.toString(),
      ),
      aiDetail: aiDetailPreferenceFromStorage(json['ai_detail']?.toString()),
      backupSync: backupSyncPreferenceFromStorage(
        json['backup_sync']?.toString(),
      ),
      currentPlan: currentPlanPreferenceFromStorage(
        json['current_plan']?.toString(),
      ),
    );
  }
}

AppThemePreference appThemePreferenceFromStorage(String? rawValue) {
  return _enumFromStorage(
    rawValue,
    AppThemePreference.values,
    (value) => value.storageKey,
    AppThemePreference.system,
  );
}

NotificationPreference notificationPreferenceFromStorage(String? rawValue) {
  return _enumFromStorage(
    rawValue,
    NotificationPreference.values,
    (value) => value.storageKey,
    NotificationPreference.enabled,
  );
}

QuietHoursPreference quietHoursPreferenceFromStorage(String? rawValue) {
  return _enumFromStorage(
    rawValue,
    QuietHoursPreference.values,
    (value) => value.storageKey,
    QuietHoursPreference.off,
  );
}

MeasurementUnitPreference measurementUnitPreferenceFromStorage(
  String? rawValue,
) {
  return _enumFromStorage(
    rawValue,
    MeasurementUnitPreference.values,
    (value) => value.storageKey,
    MeasurementUnitPreference.metric,
  );
}

RegionPreference regionPreferenceFromStorage(String? rawValue) {
  return _enumFromStorage(
    rawValue,
    RegionPreference.values,
    (value) => value.storageKey,
    RegionPreference.auto,
  );
}

ReminderFrequencyPreference reminderFrequencyPreferenceFromStorage(
  String? rawValue,
) {
  return _enumFromStorage(
    rawValue,
    ReminderFrequencyPreference.values,
    (value) => value.storageKey,
    ReminderFrequencyPreference.daily,
  );
}

AiDetailPreference aiDetailPreferenceFromStorage(String? rawValue) {
  return _enumFromStorage(
    rawValue,
    AiDetailPreference.values,
    (value) => value.storageKey,
    AiDetailPreference.brief,
  );
}

BackupSyncPreference backupSyncPreferenceFromStorage(String? rawValue) {
  return _enumFromStorage(
    rawValue,
    BackupSyncPreference.values,
    (value) => value.storageKey,
    BackupSyncPreference.off,
  );
}

CurrentPlanPreference currentPlanPreferenceFromStorage(String? rawValue) {
  return _enumFromStorage(
    rawValue,
    CurrentPlanPreference.values,
    (value) => value.storageKey,
    CurrentPlanPreference.free,
  );
}

T _enumFromStorage<T>(
  String? rawValue,
  List<T> values,
  String Function(T value) storageKeyFor,
  T fallback,
) {
  for (final value in values) {
    if (storageKeyFor(value).toLowerCase() == (rawValue ?? '').toLowerCase()) {
      return value;
    }
  }
  return fallback;
}
