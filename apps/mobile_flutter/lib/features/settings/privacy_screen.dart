import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/i18n/app_locale.dart';
import '../../core/i18n/app_localized_values.dart';
import '../../core/privacy/privacy_models.dart';
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
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(24),
            ),
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
    final json = await controller.exportLocalDataJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.exportCopied)),
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
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
      ),
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
      case AppLocalePreference.ja:
        return l10n.languageJapanese;
      case AppLocalePreference.zhHans:
        return l10n.languageChineseSimplified;
    }
  }
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
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            domain.localizedLabel(AppLocalizations.of(context)!),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.domainEventsEligible(
              eventCount,
              aiEligibleCount,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
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
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '- $item',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
