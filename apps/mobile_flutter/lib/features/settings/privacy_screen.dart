import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/app_locale.dart';
import '../../core/i18n/app_localized_values.dart';
import '../../core/legal/legal_document_registry.dart';
import '../../core/lifegraph/life_event.dart';
import '../../core/monetization/billing_runtime_models.dart';
import '../../core/monetization/entitlement_service.dart';
import '../../core/privacy/privacy_models.dart';
import '../../core/settings/app_profile_preferences.dart';
import '../../domains/monetization/entitlement.dart';
import '../../domains/privacy/privacy_audit_entry.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({
    super.key,
    required this.controller,
    this.onOpenExternalUrl,
  });

  final GoLifeController controller;
  final Future<void> Function(String url)? onOpenExternalUrl;

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
          Text(
            l10n.privacyRuntimeSnapshotTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.privacyRuntimeSnapshotBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: _PrivacyMetricCard(
                  label: l10n.privacyMetricEvidenceItems,
                  value: controller.evidenceItems.length.toString(),
                  tone: const Color(0xFF6C5B3D),
                ),
              ),
              SizedBox(
                width: 220,
                child: _PrivacyMetricCard(
                  label: l10n.privacyMetricRelations,
                  value: controller.lifeGraphRelations.length.toString(),
                  tone: const Color(0xFF7A5167),
                ),
              ),
              SizedBox(
                width: 220,
                child: _PrivacyMetricCard(
                  label: l10n.privacyMetricAuditEntries,
                  value: controller.privacyAuditEntries.length.toString(),
                  tone: const Color(0xFF1F4C5B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/lifegraph'),
              icon: const Icon(Icons.timeline_rounded),
              label: Text(l10n.lifeGraphOpenTimeline),
            ),
          ),
          const SizedBox(height: 24),
          _PlanBillingCard(
            controller: controller,
            onOpenExternalUrl: onOpenExternalUrl,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.privacyLegalTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.privacyLegalBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final item in _legalCards(l10n))
                _LegalDocumentCard(
                  item: item,
                  onOpen: (url) => _openExternalUrl(context, url),
                  onCopy: (url) => _copyExternalUrl(context, url),
                ),
            ],
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
          const SizedBox(height: 24),
          Text(
            l10n.privacyRecentEventsTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.privacyRecentEventsBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (controller.lifeEvents.isEmpty)
            Text(
              l10n.privacyRecentEventsEmpty,
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final event in controller.lifeEvents.take(8))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecentLifeEventCard(
                  controller: controller,
                  event: event,
                ),
              ),
          const SizedBox(height: 24),
          Text(
            l10n.privacyAuditTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.privacyAuditBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (controller.privacyAuditEntries.isEmpty)
            Text(
              l10n.privacyAuditEmpty,
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final entry in controller.privacyAuditEntries.take(8))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PrivacyAuditEntryCard(entry: entry),
              ),
        ],
      ),
    );
  }

  List<_LegalDocumentCardModel> _legalCards(AppLocalizations l10n) {
    return GoLifeLegalDocuments.publicLinks
        .map(
          (link) => _LegalDocumentCardModel(
            id: link.id,
            url: link.url,
            title: _legalTitle(link.id, l10n),
            body: _legalBody(link.id, l10n),
          ),
        )
        .toList(growable: false);
  }

  String _legalTitle(LegalDocumentId id, AppLocalizations l10n) {
    switch (id) {
      case LegalDocumentId.privacyPolicy:
        return l10n.privacyLegalPolicyTitle;
      case LegalDocumentId.termsOfService:
        return l10n.privacyLegalTermsTitle;
      case LegalDocumentId.support:
        return l10n.privacyLegalSupportTitle;
    }
  }

  String _legalBody(LegalDocumentId id, AppLocalizations l10n) {
    switch (id) {
      case LegalDocumentId.privacyPolicy:
        return l10n.privacyLegalPolicyBody;
      case LegalDocumentId.termsOfService:
        return l10n.privacyLegalTermsBody;
      case LegalDocumentId.support:
        return l10n.privacyLegalSupportBody;
    }
  }

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    if (onOpenExternalUrl != null) {
      await onOpenExternalUrl!(url);
      return;
    }

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) {
      return;
    }
    await _copyExternalUrl(context, url, useFallbackMessage: true);
  }

  Future<void> _copyExternalUrl(
    BuildContext context,
    String url, {
    bool useFallbackMessage = false,
  }) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          useFallbackMessage
              ? AppLocalizations.of(context)!.privacyLegalOpenFallback
              : AppLocalizations.of(context)!.privacyLegalCopied,
        ),
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

class _LegalDocumentCardModel {
  const _LegalDocumentCardModel({
    required this.id,
    required this.title,
    required this.body,
    required this.url,
  });

  final LegalDocumentId id;
  final String title;
  final String body;
  final String url;
}

class _LegalDocumentCard extends StatelessWidget {
  const _LegalDocumentCard({
    required this.item,
    required this.onOpen,
    required this.onCopy,
  });

  final _LegalDocumentCardModel item;
  final Future<void> Function(String url) onOpen;
  final Future<void> Function(String url) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(item.body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          SelectableText(
            item.url,
            key: ValueKey<String>('legal-url-${item.id.storageKey}'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: ValueKey<String>('legal-open-${item.id.storageKey}'),
                onPressed: () => onOpen(item.url),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.privacyLegalOpen),
              ),
              TextButton.icon(
                key: ValueKey<String>('legal-copy-${item.id.storageKey}'),
                onPressed: () => onCopy(item.url),
                icon: const Icon(Icons.copy_all_rounded),
                label: Text(l10n.privacyLegalCopy),
              ),
            ],
          ),
        ],
      ),
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
      ],
    );
  }
}

class _PlanBillingCard extends StatefulWidget {
  const _PlanBillingCard({
    required this.controller,
    this.onOpenExternalUrl,
  });

  final GoLifeController controller;
  final Future<void> Function(String url)? onOpenExternalUrl;

  @override
  State<_PlanBillingCard> createState() => _PlanBillingCardState();
}

class _PlanBillingCardState extends State<_PlanBillingCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.trackBillingDisabledViewed();
      widget.controller.trackRestoreUnavailableViewed();
      widget.controller
          .trackEntitlementGateViewed(EntitlementFeature.dailyMissionRefreshes);
      widget.controller
          .trackEntitlementGateViewed(EntitlementFeature.aiAssistedCaptures);
      widget.controller
          .trackEntitlementGateViewed(EntitlementFeature.exportBundles);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final entitlement = controller.entitlement;
    final billingState = controller.billingRuntimeState;
    final billingConfig = billingState.config;
    final missionRefreshGate = controller.entitlementGateForFeature(
      EntitlementFeature.dailyMissionRefreshes,
    );
    final aiCaptureGate = controller.entitlementGateForFeature(
      EntitlementFeature.aiAssistedCaptures,
    );
    final exportGate = controller.entitlementGateForFeature(
      EntitlementFeature.exportBundles,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.billingPlanTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            billingConfig.enabled
                ? l10n.billingPlanBodySandbox
                : l10n.billingPlanBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _BillingFactRow(
            label: l10n.billingCurrentPlanLabel,
            value: _entitlementPlanLabel(entitlement.plan, l10n),
          ),
          _BillingFactRow(
            label: l10n.billingProviderLabel,
            value: _billingProviderLabel(billingState, l10n),
          ),
          _BillingFactRow(
            label: l10n.billingModeLabel,
            value: _billingModeLabel(billingState, l10n),
          ),
          _BillingFactRow(
            label: l10n.billingRenewalStateLabel,
            value: _billingRenewalLabel(entitlement.renewalState, l10n),
          ),
          _BillingFactRow(
            label: l10n.billingStatusLabel,
            value: _billingStatusCodeLabel(billingState.statusCode),
          ),
          _BillingFactRow(
            label: l10n.billingRestoreLabel,
            value: billingConfig.restorePurchases
                ? l10n.billingRestoreAvailable
                : l10n.billingRestoreUnavailable,
          ),
          _BillingFactRow(
            label: l10n.billingExportDeleteLabel,
            value: l10n.billingExportDeleteAlwaysAvailable,
          ),
          if (billingState.lastValidatedAtIso != null)
            _BillingFactRow(
              label: l10n.billingLastValidatedLabel,
              value: billingState.lastValidatedAtIso!,
            ),
          if (billingConfig.enabled) ...[
            const SizedBox(height: 8),
            Text(
              l10n.billingSandboxInternalOnly,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            l10n.billingFeatureGatesTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _BillingGateRow(
            label: l10n.billingGateMissionRefreshes,
            gate: missionRefreshGate,
          ),
          _BillingGateRow(
            label: l10n.billingGateAiCaptures,
            gate: aiCaptureGate,
          ),
          _BillingGateRow(
            label: l10n.billingGateExportBundles,
            gate: exportGate,
            forceAlwaysAvailable: true,
          ),
          if (billingConfig.enabled) ...[
            const SizedBox(height: 14),
            Text(
              l10n.billingCatalogTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (billingState.catalog.isEmpty)
              Text(
                l10n.billingCatalogEmpty,
                style: theme.textTheme.bodyMedium,
              )
            else
              for (final item in billingState.catalog)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BillingCatalogCard(
                    item: item,
                    purchaseLabel: l10n.billingPurchaseSandbox,
                    onPurchase: () => _buyCatalogItem(context, item),
                  ),
                ),
            const SizedBox(height: 8),
            if (billingConfig.restorePurchases)
              FilledButton.tonalIcon(
                key: const ValueKey<String>('billing-restore-purchases'),
                onPressed: () => _restorePurchases(context),
                icon: const Icon(Icons.restore_rounded),
                label: Text(l10n.billingRestoreNow),
              ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey<String>('billing-open-decision'),
                onPressed: () => _openDecisionDocument(context),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.billingDecisionOpen),
              ),
              TextButton.icon(
                key: const ValueKey<String>('billing-copy-decision'),
                onPressed: () => _copyDecisionDocument(context),
                icon: const Icon(Icons.copy_all_rounded),
                label: Text(l10n.billingDecisionCopy),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openDecisionDocument(BuildContext context) async {
    final url =
        widget.controller.billingRuntimeState.config.decisionDocumentUrl;
    if (widget.onOpenExternalUrl != null) {
      await widget.onOpenExternalUrl!(url);
      return;
    }

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) {
      return;
    }
    await _copyDecisionDocument(context, useFallbackMessage: true);
  }

  Future<void> _copyDecisionDocument(
    BuildContext context, {
    bool useFallbackMessage = false,
  }) async {
    await Clipboard.setData(
      ClipboardData(
          text:
              widget.controller.billingRuntimeState.config.decisionDocumentUrl),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          useFallbackMessage
              ? AppLocalizations.of(context)!.privacyLegalOpenFallback
              : AppLocalizations.of(context)!.privacyLegalCopied,
        ),
      ),
    );
  }

  Future<void> _buyCatalogItem(
    BuildContext context,
    BillingCatalogItem item,
  ) async {
    final result =
        await widget.controller.buyBillingCatalogProduct(item.productId);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }

  Future<void> _restorePurchases(BuildContext context) async {
    final result = await widget.controller.restoreBillingPurchases();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }
}

class _BillingCatalogCard extends StatelessWidget {
  const _BillingCatalogCard({
    required this.item,
    required this.purchaseLabel,
    required this.onPurchase,
  });

  final BillingCatalogItem item;
  final String purchaseLabel;
  final Future<void> Function() onPurchase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(item.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(item.priceLabel, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            key: ValueKey<String>('billing-buy-${item.productId}'),
            onPressed: onPurchase,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: Text(purchaseLabel),
          ),
        ],
      ),
    );
  }
}

class _BillingGateRow extends StatelessWidget {
  const _BillingGateRow({
    required this.label,
    required this.gate,
    this.forceAlwaysAvailable = false,
  });

  final String label;
  final EntitlementGateResult gate;
  final bool forceAlwaysAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = forceAlwaysAvailable
        ? l10n.billingExportDeleteAlwaysAvailable
        : l10n.billingGateValue(gate.remaining, gate.limit);
    final subtitle = forceAlwaysAvailable
        ? l10n.billingGateAlwaysAvailable
        : gate.allowed
            ? l10n.billingGateWithinQuota
            : l10n.billingGateQuotaExhausted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BillingFactRow extends StatelessWidget {
  const _BillingFactRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
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

class _RecentLifeEventCard extends StatelessWidget {
  const _RecentLifeEventCard({
    required this.controller,
    required this.event,
  });

  final GoLifeController controller;
  final LifeEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final aiEligible = _isEventAiEligible(controller, event);
    return Container(
      key: ValueKey<String>('life-event-${event.eventId}'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.summary,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${event.timestampIso} • ${event.eventType}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                  '${l10n.fieldDomain}: ${event.domain.localizedDomainLabel(l10n)}',
                ),
              ),
              Chip(
                label: Text(
                  '${l10n.privacyEventSource}: ${event.source}',
                ),
              ),
              Chip(
                label: Text(
                  '${l10n.fieldPrivacy}: ${event.privacyLevel.localizedPermissionLabel(l10n)}',
                ),
              ),
              Chip(
                label: Text(
                  '${l10n.privacyEventAiEligible}: ${aiEligible ? l10n.valueYes : l10n.valueNo}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final permission in DataPermission.values)
                ChoiceChip(
                  key: ValueKey<String>(
                    'event-privacy-${event.eventId}-${permission.storageKey}',
                  ),
                  label: Text(permission.localizedLabel(l10n)),
                  selected: event.privacyLevel == permission.storageKey,
                  onSelected: (_) async {
                    await controller.updateEventPrivacy(
                        event.eventId, permission);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyAuditEntryCard extends StatelessWidget {
  const _PrivacyAuditEntryCard({required this.entry});

  final PrivacyAuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: ValueKey<String>('privacy-audit-${entry.auditId}'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.privacyEventId}: ${entry.eventId}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${entry.oldPrivacyLevel.localizedPermissionLabel(l10n)} -> ${entry.newPrivacyLevel.localizedPermissionLabel(l10n)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.privacyAuditChangedAt}: ${entry.changedAt}',
            style: theme.textTheme.bodySmall,
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

bool _isEventAiEligible(GoLifeController controller, LifeEvent event) {
  final domain = domainKeyFromWireName(event.domain);
  if (domain == null) {
    return false;
  }
  return controller.privacySettings.permissionFor(domain) ==
          DataPermission.aiAllowed &&
      event.privacyLevel == DataPermission.aiAllowed.storageKey;
}

String _entitlementPlanLabel(
  EntitlementPlan plan,
  AppLocalizations l10n,
) {
  switch (plan) {
    case EntitlementPlan.free:
      return l10n.billingPlanFree;
    case EntitlementPlan.premium:
      return l10n.billingPlanPremium;
    case EntitlementPlan.pro:
      return l10n.billingPlanPro;
  }
}

String _billingProviderLabel(
  BillingRuntimeState billingState,
  AppLocalizations l10n,
) {
  if (billingState.config.provider == entitlementBillingProviderGooglePlay) {
    return l10n.billingProviderGooglePlay;
  }
  return l10n.billingDisabledLabel;
}

String _billingModeLabel(
  BillingRuntimeState billingState,
  AppLocalizations l10n,
) {
  switch (billingState.config.mode) {
    case BillingRuntimeMode.googlePlaySandbox:
      return l10n.billingModeGooglePlaySandbox;
    case BillingRuntimeMode.googlePlayLive:
      return l10n.billingModeGooglePlayLive;
    case BillingRuntimeMode.disabled:
      return l10n.billingDisabledLabel;
  }
}

String _billingRenewalLabel(
  String renewalState,
  AppLocalizations l10n,
) {
  switch (renewalState) {
    case entitlementRenewalStatePending:
      return l10n.billingRenewalPending;
    case entitlementRenewalStateActive:
      return l10n.billingRenewalActive;
    case entitlementRenewalStateGrace:
      return l10n.billingRenewalGrace;
    case entitlementRenewalStatePaused:
      return l10n.billingRenewalPaused;
    case entitlementRenewalStateExpired:
      return l10n.billingRenewalExpired;
    case entitlementRenewalStateRefunded:
      return l10n.billingRenewalRefunded;
    case entitlementRenewalStateDisabled:
    default:
      return l10n.billingRenewalDisabled;
  }
}

String _billingStatusCodeLabel(String statusCode) {
  if (statusCode.trim().isEmpty) {
    return 'unknown';
  }
  return statusCode.replaceAll('_', ' ');
}
