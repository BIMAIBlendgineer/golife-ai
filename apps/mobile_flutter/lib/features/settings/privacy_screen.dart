import 'package:flutter/material.dart';

import '../../core/i18n/app_locale.dart';
import '../../core/i18n/app_localized_values.dart';
import '../../core/privacy/privacy_models.dart';
import '../../core/settings/app_profile_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.privacyTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.privacyIntro,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.sensitiveLocalEncryptionEnabled
                  ? const Color(0xFFEDF4EE)
                  : const Color(0xFFF6EEE7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.sensitiveLocalEncryptionEnabled
                    ? const Color(0xFFB6C8B4)
                    : const Color(0xFFD6C0A7),
              ),
            ),
            child: Text(
              controller.sensitiveLocalEncryptionEnabled
                  ? l10n.privacyEncryptedActive
                  : l10n.privacyEncryptedUnavailable,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.privacyCenter, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _LanguageCard(controller: controller),
          const SizedBox(height: 12),
          _ProfilePreferencesCard(controller: controller),
          const SizedBox(height: 12),
          _DeliveryPreferencesCard(controller: controller),
          const SizedBox(height: 12),
          _RegionalPreferencesCard(controller: controller),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PrivacyDisclosureCard(
                title: l10n.privacyDisclosureEncryptedTitle,
                body: l10n.privacyDisclosureEncryptedBody,
                items: controller.localizedEncryptedCollectionLabels(l10n),
              ),
              _PrivacyDisclosureCard(
                title: l10n.privacyDisclosureLocalTitle,
                body: l10n.privacyDisclosureLocalBody,
                items: controller.localizedAlwaysLocalCollectionLabels(l10n),
              ),
              _PrivacyDisclosureCard(
                title: l10n.privacyDisclosureAiTitle,
                body: l10n.privacyDisclosureAiBody,
                items: controller.privacySettings.aiAllowedDomains.isEmpty
                    ? <String>[l10n.nothingAiEnabled]
                    : controller.privacySettings.aiAllowedDomains
                        .map((domain) => domain.localizedLabel(l10n))
                        .toList(growable: false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _PrivacyMetricCard(
                  label: l10n.privacyMetricTotalEvents,
                  value: controller.totalEventCount.toString(),
                  tone: const Color(0xFF1F4C5B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrivacyMetricCard(
                  label: l10n.privacyMetricAiEligible,
                  value: controller.aiEligibleEventCount.toString(),
                  tone: const Color(0xFF5D7A68),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PrivacyMetricCard(
            label: l10n.privacyMetricBlockedLocal,
            value:
                '${controller.totalEventCount - controller.aiEligibleEventCount}',
            tone: const Color(0xFFD06447),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(theme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dataControls, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  l10n.dataControlsBody,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _exportLocalJson(context),
                      icon: const Icon(Icons.download_outlined),
                      label: Text(l10n.exportJson),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDeleteAll(context),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.deleteAllLocalData),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmClearAiHistory(context),
                      icon: const Icon(Icons.history_toggle_off_outlined),
                      label: Text(l10n.clearAiHistory),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.domainControls, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final domain in DomainKey.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DomainPermissionCard(
                domain: domain,
                selected: controller.privacySettings.permissionFor(domain),
                eventCount: controller.eventCountFor(domain.wireName),
                aiEligibleCount: controller.aiEligibleEventCountFor(domain),
                onChanged: (permission) async {
                  await controller.updatePermission(domain, permission);
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _exportLocalJson(BuildContext context) async {
    final exportResult = await controller.exportLocalDataFile();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.exportSavedFile(exportResult.fileName),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.deleteAllTitle),
              content: Text(AppLocalizations.of(context)!.deleteAllBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context)!.deleteAll),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    await controller.deleteAllLocalData();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.deleteAllDone)),
    );
  }

  Future<void> _confirmClearAiHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.clearAiHistoryTitle),
              content: Text(AppLocalizations.of(context)!.clearAiHistoryBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context)!.clearAiHistory),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    await controller.clearAiHistory();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.clearAiHistoryDone)),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.language, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in AppLocalePreference.values)
                ChoiceChip(
                  label: Text(_languageLabel(option, l10n)),
                  selected: controller.localePreference == option,
                  onSelected: (_) => controller.updateLocalePreference(option),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalePreference option, AppLocalizations l10n) {
    switch (option) {
      case AppLocalePreference.system:
        return l10n.languageSystem;
      case AppLocalePreference.en:
        return l10n.languageEnglish;
      case AppLocalePreference.es:
        return l10n.languageSpanish;
      case AppLocalePreference.ptBr:
        return l10n.languagePortugueseBrazil;
      case AppLocalePreference.ptPt:
        return l10n.languagePortuguesePortugal;
      case AppLocalePreference.fr:
        return l10n.languageFrench;
      case AppLocalePreference.it:
        return l10n.languageItalian;
      case AppLocalePreference.de:
        return l10n.languageGerman;
      case AppLocalePreference.ja:
        return l10n.languageJapanese;
      case AppLocalePreference.zhHans:
        return l10n.languageChineseSimplified;
      case AppLocalePreference.zhHant:
        return l10n.languageChineseTraditional;
    }
  }
}

class _ProfilePreferencesCard extends StatelessWidget {
  const _ProfilePreferencesCard({required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _PreferenceCard(
      title: l10n.profilePreferencesTitle,
      body: l10n.profilePreferencesBody,
      children: [
        _PreferenceChoiceGroup<AppThemePreference>(
          label: l10n.themePreference,
          selected: controller.profilePreferences.themePreference,
          options: [
            _ChoiceOption(
              value: AppThemePreference.system,
              label: l10n.themeSystem,
            ),
            _ChoiceOption(
              value: AppThemePreference.light,
              label: l10n.themeLight,
            ),
            _ChoiceOption(
              value: AppThemePreference.dark,
              label: l10n.themeDark,
            ),
          ],
          onSelected: controller.updateThemePreference,
        ),
        _PreferenceChoiceGroup<AiDetailPreference>(
          label: l10n.aiResponseStyle,
          selected: controller.profilePreferences.aiDetail,
          options: [
            _ChoiceOption(
              value: AiDetailPreference.brief,
              label: l10n.aiBrief,
            ),
            _ChoiceOption(
              value: AiDetailPreference.detailed,
              label: l10n.aiDetailed,
            ),
          ],
          onSelected: controller.updateAiDetailPreference,
        ),
        _PreferenceChoiceGroup<CurrentPlanPreference>(
          label: l10n.currentPlanPreference,
          selected: controller.profilePreferences.currentPlan,
          options: [
            _ChoiceOption(
              value: CurrentPlanPreference.free,
              label: l10n.planFree,
            ),
            _ChoiceOption(
              value: CurrentPlanPreference.plus,
              label: l10n.planPlus,
            ),
            _ChoiceOption(
              value: CurrentPlanPreference.pro,
              label: l10n.planPro,
            ),
          ],
          onSelected: controller.updateCurrentPlanPreference,
        ),
      ],
    );
  }
}

class _DeliveryPreferencesCard extends StatelessWidget {
  const _DeliveryPreferencesCard({required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _PreferenceCard(
      title: l10n.deliveryPreferencesTitle,
      body: l10n.preferencesLocalOnlyHint,
      children: [
        _PreferenceChoiceGroup<NotificationPreference>(
          label: l10n.notificationsPreference,
          selected: controller.profilePreferences.notifications,
          options: [
            _ChoiceOption(
              value: NotificationPreference.enabled,
              label: l10n.notificationsEnabled,
            ),
            _ChoiceOption(
              value: NotificationPreference.disabled,
              label: l10n.notificationsDisabled,
            ),
          ],
          onSelected: controller.updateNotificationsPreference,
        ),
        _PreferenceChoiceGroup<QuietHoursPreference>(
          label: l10n.quietHoursPreference,
          selected: controller.profilePreferences.quietHours,
          options: [
            _ChoiceOption(
              value: QuietHoursPreference.off,
              label: l10n.quietHoursOff,
            ),
            _ChoiceOption(
              value: QuietHoursPreference.from2200To0700,
              label: l10n.quietHours2207,
            ),
            _ChoiceOption(
              value: QuietHoursPreference.from2300To0800,
              label: l10n.quietHours2308,
            ),
          ],
          onSelected: controller.updateQuietHoursPreference,
        ),
        _PreferenceChoiceGroup<ReminderFrequencyPreference>(
          label: l10n.reminderFrequencyPreference,
          selected: controller.profilePreferences.reminderFrequency,
          options: [
            _ChoiceOption(
              value: ReminderFrequencyPreference.off,
              label: l10n.reminderOff,
            ),
            _ChoiceOption(
              value: ReminderFrequencyPreference.daily,
              label: l10n.reminderDaily,
            ),
            _ChoiceOption(
              value: ReminderFrequencyPreference.weekdays,
              label: l10n.reminderWeekdays,
            ),
            _ChoiceOption(
              value: ReminderFrequencyPreference.weekly,
              label: l10n.reminderWeekly,
            ),
          ],
          onSelected: controller.updateReminderFrequencyPreference,
        ),
        _PreferenceChoiceGroup<BackupSyncPreference>(
          label: l10n.backupSyncPreference,
          selected: controller.profilePreferences.backupSync,
          options: [
            _ChoiceOption(
              value: BackupSyncPreference.off,
              label: l10n.backupSyncOff,
            ),
            _ChoiceOption(
              value: BackupSyncPreference.on,
              label: l10n.backupSyncOn,
            ),
          ],
          onSelected: controller.updateBackupSyncPreference,
        ),
      ],
    );
  }
}

class _RegionalPreferencesCard extends StatelessWidget {
  const _RegionalPreferencesCard({required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _PreferenceCard(
      title: l10n.regionalPreferencesTitle,
      body: l10n.preferencesLocalOnlyHint,
      children: [
        _PreferenceChoiceGroup<MeasurementUnitPreference>(
          label: l10n.measurementUnitsPreference,
          selected: controller.profilePreferences.measurementUnits,
          options: [
            _ChoiceOption(
              value: MeasurementUnitPreference.metric,
              label: l10n.unitMetric,
            ),
            _ChoiceOption(
              value: MeasurementUnitPreference.imperial,
              label: l10n.unitImperial,
            ),
          ],
          onSelected: controller.updateMeasurementUnitsPreference,
        ),
        _PreferenceChoiceGroup<RegionPreference>(
          label: l10n.regionCountryPreference,
          selected: controller.profilePreferences.region,
          options: [
            _ChoiceOption(value: RegionPreference.auto, label: l10n.regionAuto),
            _ChoiceOption(value: RegionPreference.us, label: l10n.regionUs),
            _ChoiceOption(value: RegionPreference.es, label: l10n.regionSpain),
            _ChoiceOption(
              value: RegionPreference.br,
              label: l10n.regionBrazil,
            ),
            _ChoiceOption(
              value: RegionPreference.pt,
              label: l10n.regionPortugal,
            ),
            _ChoiceOption(
              value: RegionPreference.fr,
              label: l10n.regionFrance,
            ),
            _ChoiceOption(value: RegionPreference.it, label: l10n.regionItaly),
            _ChoiceOption(
              value: RegionPreference.de,
              label: l10n.regionGermany,
            ),
            _ChoiceOption(value: RegionPreference.jp, label: l10n.regionJapan),
            _ChoiceOption(
              value: RegionPreference.cn,
              label: l10n.regionChinaMainland,
            ),
            _ChoiceOption(
              value: RegionPreference.tw,
              label: l10n.regionTaiwan,
            ),
          ],
          onSelected: controller.updateRegionPreference,
        ),
      ],
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: 16),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _PreferenceChoiceGroup<T> extends StatelessWidget {
  const _PreferenceChoiceGroup({
    required this.label,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final T selected;
  final List<_ChoiceOption<T>> options;
  final Future<void> Function(T value) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option.label),
                selected: option.value == selected,
                onSelected: (_) => onSelected(option.value),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceOption<T> {
  const _ChoiceOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class _PrivacyMetricCard extends StatelessWidget {
  const _PrivacyMetricCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _DomainPermissionCard extends StatelessWidget {
  const _DomainPermissionCard({
    required this.domain,
    required this.selected,
    required this.eventCount,
    required this.aiEligibleCount,
    required this.onChanged,
  });

  final DomainKey domain;
  final DataPermission selected;
  final int eventCount;
  final int aiEligibleCount;
  final Future<void> Function(DataPermission) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            domain.localizedLabel(AppLocalizations.of(context)!),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.domainEventsEligible(
              eventCount,
              aiEligibleCount,
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final permission in DataPermission.values)
                ChoiceChip(
                  label: Text(
                    permission.localizedLabel(AppLocalizations.of(context)!),
                  ),
                  selected: permission == selected,
                  onSelected: (_) {
                    onChanged(permission);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyDisclosureCard extends StatelessWidget {
  const _PrivacyDisclosureCard({
    required this.title,
    required this.body,
    required this.items,
  });

  final String title;
  final String body;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '- $item',
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark
        ? const Color(0xFF241C18).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.76),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark ? const Color(0x33E6CDB9) : const Color(0x12FFFFFF),
    ),
  );
}
