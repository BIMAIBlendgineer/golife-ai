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
import '../../domains/monetization/billing_audit_entry.dart';
import '../../domains/monetization/entitlement.dart';
import '../../domains/privacy/privacy_audit_entry.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import '../shared/premium_ui.dart';

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
    final encrypted = controller.sensitiveLocalEncryptionEnabled;
    final settingsIndexItems = _settingsIndexItems(l10n);

    return GoLifeScreen(
      title: l10n.navSettings,
      subtitle: _settingsIntro(l10n),
      badge: GoLifeStatusPill(
        label: _settingsStatusLabel(encrypted, l10n),
        icon: encrypted
            ? Icons.verified_user_rounded
            : Icons.shield_moon_outlined,
        accent: encrypted ? GoLifeAccent.emerald : GoLifeAccent.amber,
      ),
      children: [
        GoLifeCard(
          accent: encrypted ? GoLifeAccent.emerald : GoLifeAccent.amber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GoLifeSectionTitle(
                title: _settingsIndexTitle(l10n),
                subtitle: encrypted
                    ? l10n.privacyEncryptedActive
                    : l10n.privacyEncryptedUnavailable,
              ),
              const SizedBox(height: 16),
              for (var index = 0;
                  index < settingsIndexItems.length;
                  index++) ...[
                if (index > 0) const SizedBox(height: 12),
                _SettingsIndexRow(item: settingsIndexItems[index]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: _settingsPrivacyCenterTitle(l10n),
          subtitle: _settingsPrivacyCenterBody(l10n),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: _PrivacyMetricCard(
                label: l10n.privacyMetricTotalEvents,
                value: controller.totalEventCount.toString(),
                tone: const Color(0xFF1F4C5B),
              ),
            ),
            SizedBox(
              width: 220,
              child: _PrivacyMetricCard(
                label: l10n.privacyMetricAiEligible,
                value: controller.aiEligibleEventCount.toString(),
                tone: const Color(0xFF5D7A68),
              ),
            ),
            SizedBox(
              width: 220,
              child: _PrivacyMetricCard(
                label: l10n.privacyMetricBlockedLocal,
                value:
                    '${controller.totalEventCount - controller.aiEligibleEventCount}',
                tone: const Color(0xFFD06447),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.privacyCenter,
          subtitle: _settingsPreferencesBody(l10n),
        ),
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
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.privacyRuntimeSnapshotTitle,
          subtitle: l10n.privacyRuntimeSnapshotBody,
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
        const SizedBox(height: 20),
        _PlanBillingCard(
          controller: controller,
          onOpenExternalUrl: onOpenExternalUrl,
        ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.privacyLegalTitle,
          subtitle: l10n.privacyLegalBody,
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
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.dataControls,
          subtitle: l10n.dataControlsBody,
        ),
        const SizedBox(height: 12),
        GoLifeCard(
          accent: GoLifeAccent.blue,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                key: const ValueKey<String>('privacy-export-json'),
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
        ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.domainControls,
          subtitle: _settingsDomainControlsBody(l10n),
        ),
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
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.privacyRecentEventsTitle,
          subtitle: l10n.privacyRecentEventsBody,
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
              child: _RecentLifeEventCard(controller: controller, event: event),
            ),
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.privacyAuditTitle,
          subtitle: l10n.privacyAuditBody,
        ),
        const SizedBox(height: 12),
        if (controller.privacyAuditEntries.isEmpty)
          Text(l10n.privacyAuditEmpty, style: theme.textTheme.bodyMedium)
        else
          for (final entry in controller.privacyAuditEntries.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PrivacyAuditEntryCard(entry: entry),
            ),
      ],
    );
  }

  List<_SettingsIndexItem> _settingsIndexItems(AppLocalizations l10n) {
    return <_SettingsIndexItem>[
      _SettingsIndexItem(
        icon: Icons.person_outline_rounded,
        title: _settingsAccountTitle(l10n),
        body: _settingsAccountBody(l10n),
      ),
      _SettingsIndexItem(
        icon: Icons.workspace_premium_outlined,
        title: l10n.billingPlanTitle,
        body: _settingsPremiumBody(l10n),
      ),
      _SettingsIndexItem(
        icon: Icons.shield_outlined,
        title: l10n.privacyTitle,
        body: _settingsPrivacyBody(l10n),
      ),
      _SettingsIndexItem(
        icon: Icons.auto_awesome_outlined,
        title: _settingsAiDataTitle(l10n),
        body: _settingsAiDataBody(l10n),
      ),
      _SettingsIndexItem(
        icon: Icons.language_rounded,
        title: l10n.language,
        body: _settingsLanguageBody(l10n),
      ),
      _SettingsIndexItem(
        icon: Icons.contrast_rounded,
        title: l10n.themePreference,
        body: _settingsThemeBody(l10n),
      ),
      _SettingsIndexItem(
        icon: Icons.download_outlined,
        title: l10n.exportJson,
        body: _settingsExportBody(l10n),
      ),
      _SettingsIndexItem(
        icon: Icons.delete_outline_rounded,
        title: l10n.deleteAllLocalData,
        body: _settingsDeleteBody(l10n),
      ),
    ];
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

class _SettingsIndexItem {
  const _SettingsIndexItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _SettingsIndexRow extends StatelessWidget {
  const _SettingsIndexRow({required this.item});

  final _SettingsIndexItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GoLifePalette.ink700.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: GoLifePalette.lineStrong.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: GoLifePalette.violet.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: GoLifePalette.violetBright, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(item.body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _settingsIntro(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Premium, privacy, AI and local controls in one place.',
      es: 'Premium, privacidad, IA y controles locales en un solo lugar.',
      ptBr: 'Premium, privacidade, IA e controles locais em um so lugar.',
      ptPt: 'Premium, privacidade, IA e controlos locais num so lugar.',
      fr: 'Premium, confidentialite, IA et controles locaux au meme endroit.',
      it: 'Premium, privacy, IA e controlli locali in un solo posto.',
      de: 'Premium, Datenschutz, KI und lokale Kontrollen an einem Ort.',
      ja: 'Premium, privacy, AI and local controls in one place.',
      zhHans: 'Premium, privacy, AI and local controls in one place.',
      zhHant: 'Premium, privacy, AI and local controls in one place.',
    );

String _settingsStatusLabel(bool encrypted, AppLocalizations l10n) =>
    pickLocalizedValue(
      l10n.localeName,
      en: encrypted ? 'Local protected' : 'Review privacy',
      es: encrypted ? 'Local protegido' : 'Revisar privacidad',
      ptBr: encrypted ? 'Local protegido' : 'Rever privacidade',
      ptPt: encrypted ? 'Local protegido' : 'Rever privacidade',
      fr: encrypted ? 'Local protege' : 'Verifier la confidentialite',
      it: encrypted ? 'Locale protetto' : 'Rivedi privacy',
      de: encrypted ? 'Lokal geschuetzt' : 'Datenschutz pruefen',
      ja: encrypted ? 'Local protected' : 'Review privacy',
      zhHans: encrypted ? 'Local protected' : 'Review privacy',
      zhHant: encrypted ? 'Local protected' : 'Review privacy',
    );

String _settingsIndexTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Quick index',
      es: 'Indice rapido',
      ptBr: 'Indice rapido',
      ptPt: 'Indice rapido',
      fr: 'Index rapide',
      it: 'Indice rapido',
      de: 'Schnelluebersicht',
      ja: 'Quick index',
      zhHans: 'Quick index',
      zhHant: 'Quick index',
    );

String _settingsPrivacyCenterBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'What stays local, what AI can use, and what remains blocked.',
      es: 'Que se queda local, que puede usar la IA y que sigue bloqueado.',
      ptBr:
          'O que fica local, o que a IA pode usar e o que continua bloqueado.',
      ptPt:
          'O que fica local, o que a IA pode usar e o que continua bloqueado.',
      fr: 'Ce qui reste local, ce que l IA peut utiliser et ce qui reste bloque.',
      it: 'Cosa resta locale, cosa puo usare l IA e cosa rimane bloccato.',
      de: 'Was lokal bleibt, was KI nutzen darf und was blockiert bleibt.',
      ja: 'What stays local, what AI can use, and what remains blocked.',
      zhHans: 'What stays local, what AI can use, and what remains blocked.',
      zhHant: 'What stays local, what AI can use, and what remains blocked.',
    );

String _settingsDomainControlsBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Adjust local, sync, and AI permissions per domain.',
      es: 'Ajusta permisos local, sync e IA por dominio.',
      ptBr: 'Ajuste permissoes locais, sync e IA por dominio.',
      ptPt: 'Ajusta permissoes locais, sync e IA por dominio.',
      fr: 'Ajuste les autorisations locales, sync et IA par domaine.',
      it: 'Regola i permessi locali, sync e IA per dominio.',
      de: 'Passe lokale, Sync- und KI-Berechtigungen pro Bereich an.',
      ja: 'Adjust local, sync, and AI permissions per domain.',
      zhHans: 'Adjust local, sync, and AI permissions per domain.',
      zhHant: 'Adjust local, sync, and AI permissions per domain.',
    );

String _settingsAccountTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Account',
      es: 'Cuenta',
      ptBr: 'Conta',
      ptPt: 'Conta',
      fr: 'Compte',
      it: 'Account',
      de: 'Konto',
      ja: 'Account',
      zhHans: 'Account',
      zhHant: 'Account',
    );

String _settingsAccountBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Language, profile and local preferences.',
      es: 'Idioma, perfil y preferencias locales.',
      ptBr: 'Idioma, perfil e preferencias locais.',
      ptPt: 'Idioma, perfil e preferencias locais.',
      fr: 'Langue, profil et preferences locales.',
      it: 'Lingua, profilo e preferenze locali.',
      de: 'Sprache, Profil und lokale Einstellungen.',
      ja: 'Language, profile and local preferences.',
      zhHans: 'Language, profile and local preferences.',
      zhHant: 'Language, profile and local preferences.',
    );

String _settingsPremiumBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Subscription status, catalog, restore and billing audit.',
      es: 'Estado de suscripcion, catalogo, restaurar y auditoria de billing.',
      ptBr:
          'Status da assinatura, catalogo, restauracao e auditoria de billing.',
      ptPt: 'Estado da subscricao, catalogo, restaurar e auditoria de billing.',
      fr: 'Etat de l abonnement, catalogue, restauration et audit de facturation.',
      it: 'Stato abbonamento, catalogo, ripristino e audit billing.',
      de: 'Abo-Status, Katalog, Wiederherstellung und Billing-Audit.',
      ja: 'Subscription status, catalog, restore and billing audit.',
      zhHans: 'Subscription status, catalog, restore and billing audit.',
      zhHant: 'Subscription status, catalog, restore and billing audit.',
    );

String _settingsPrivacyBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Local-only, sync and AI permissions by domain and event.',
      es: 'Permisos local-only, sync e IA por dominio y por evento.',
      ptBr: 'Permissoes local-only, sync e IA por dominio e evento.',
      ptPt: 'Permissoes local-only, sync e IA por dominio e evento.',
      fr: 'Autorisations local-only, sync et IA par domaine et evenement.',
      it: 'Permessi local-only, sync e IA per dominio ed evento.',
      de: 'Local-only-, Sync- und KI-Berechtigungen pro Bereich und Ereignis.',
      ja: 'Local-only, sync and AI permissions by domain and event.',
      zhHans: 'Local-only, sync and AI permissions by domain and event.',
      zhHant: 'Local-only, sync and AI permissions by domain and event.',
    );

String _settingsAiDataTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'AI and data',
      es: 'IA y datos',
      ptBr: 'IA e dados',
      ptPt: 'IA e dados',
      fr: 'IA et donnees',
      it: 'IA e dati',
      de: 'KI und Daten',
      ja: 'AI and data',
      zhHans: 'AI and data',
      zhHant: 'AI and data',
    );

String _settingsAiDataBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'What was used, what stayed blocked and what remains local.',
      es: 'Que se uso, que quedo bloqueado y que sigue local.',
      ptBr: 'O que foi usado, o que ficou bloqueado e o que permanece local.',
      ptPt: 'O que foi usado, o que ficou bloqueado e o que permanece local.',
      fr: 'Ce qui a ete utilise, ce qui est bloque et ce qui reste local.',
      it: 'Cosa e stato usato, cosa e rimasto bloccato e cosa resta locale.',
      de: 'Was genutzt wurde, was blockiert blieb und was lokal bleibt.',
      ja: 'What was used, what stayed blocked and what remains local.',
      zhHans: 'What was used, what stayed blocked and what remains local.',
      zhHant: 'What was used, what stayed blocked and what remains local.',
    );

String _settingsLanguageBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Switch the language without leaving the device.',
      es: 'Cambia el idioma sin salir del dispositivo.',
      ptBr: 'Troque o idioma sem sair do dispositivo.',
      ptPt: 'Muda o idioma sem sair do dispositivo.',
      fr: 'Change la langue sans quitter l appareil.',
      it: 'Cambia lingua senza uscire dal dispositivo.',
      de: 'Sprache wechseln, ohne das Geraet zu verlassen.',
      ja: 'Switch the language without leaving the device.',
      zhHans: 'Switch the language without leaving the device.',
      zhHant: 'Switch the language without leaving the device.',
    );

String _settingsThemeBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'System, light or dark mode for daily use.',
      es: 'Sistema, claro u oscuro para el uso diario.',
      ptBr: 'Sistema, claro ou escuro para o uso diario.',
      ptPt: 'Sistema, claro ou escuro para o uso diario.',
      fr: 'Mode systeme, clair ou sombre pour le quotidien.',
      it: 'Sistema, chiaro o scuro per l uso quotidiano.',
      de: 'System-, Hell- oder Dunkelmodus fuer den Alltag.',
      ja: 'System, light or dark mode for daily use.',
      zhHans: 'System, light or dark mode for daily use.',
      zhHant: 'System, light or dark mode for daily use.',
    );

String _settingsExportBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Export your local JSON bundle at any time.',
      es: 'Exporta tu paquete JSON local en cualquier momento.',
      ptBr: 'Exporte seu pacote JSON local a qualquer momento.',
      ptPt: 'Exporta o teu pacote JSON local a qualquer momento.',
      fr: 'Exporte ton paquet JSON local a tout moment.',
      it: 'Esporta il tuo bundle JSON locale in ogni momento.',
      de: 'Exportiere dein lokales JSON-Buendel jederzeit.',
      ja: 'Export your local JSON bundle at any time.',
      zhHans: 'Export your local JSON bundle at any time.',
      zhHant: 'Export your local JSON bundle at any time.',
    );

String _settingsDeleteBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Delete local data or clear AI history with explicit confirmation.',
      es: 'Borra datos locales o limpia historial de IA con confirmacion explicita.',
      ptBr:
          'Apague dados locais ou limpe o historico da IA com confirmacao explicita.',
      ptPt:
          'Apaga dados locais ou limpa o historico da IA com confirmacao explicita.',
      fr: 'Supprime les donnees locales ou l historique IA avec confirmation explicite.',
      it: 'Elimina dati locali o cronologia IA con conferma esplicita.',
      de: 'Loesche lokale Daten oder KI-Verlauf mit ausdruecklicher Bestaetigung.',
      ja: 'Delete local data or clear AI history with explicit confirmation.',
      zhHans:
          'Delete local data or clear AI history with explicit confirmation.',
      zhHant:
          'Delete local data or clear AI history with explicit confirmation.',
    );

String _settingsPrivacyCenterTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Privacy dashboard',
      es: 'Dashboard de privacidad',
      ptBr: 'Dashboard de privacidade',
      ptPt: 'Dashboard de privacidade',
      fr: 'Dashboard de confidentialite',
      it: 'Dashboard privacy',
      de: 'Datenschutz-Dashboard',
      ja: 'Privacy dashboard',
      zhHans: 'Privacy dashboard',
      zhHant: 'Privacy dashboard',
    );

String _settingsPreferencesBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Profile, reminders and regional behavior stay local-first.',
      es: 'Perfil, recordatorios y comportamiento regional se mantienen local-first.',
      ptBr:
          'Perfil, lembretes e comportamento regional permanecem local-first.',
      ptPt: 'Perfil, lembretes e comportamento regional mantem-se local-first.',
      fr: 'Profil, rappels et comportement regional restent local-first.',
      it: 'Profilo, promemoria e comportamento regionale restano local-first.',
      de: 'Profil, Erinnerungen und regionale Einstellungen bleiben local-first.',
      ja: 'Profile, reminders and regional behavior stay local-first.',
      zhHans: 'Profile, reminders and regional behavior stay local-first.',
      zhHant: 'Profile, reminders and regional behavior stay local-first.',
    );

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
            _ChoiceOption(value: AiDetailPreference.brief, label: l10n.aiBrief),
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
  const _PlanBillingCard({required this.controller, this.onOpenExternalUrl});

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
      widget.controller.trackEntitlementGateViewed(
        EntitlementFeature.dailyMissionRefreshes,
      );
      widget.controller.trackEntitlementGateViewed(
        EntitlementFeature.aiAssistedCaptures,
      );
      widget.controller.trackEntitlementGateViewed(
        EntitlementFeature.exportBundles,
      );
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
    final storedBillingState = controller.billingSubscriptionState;
    final billingAuditEntries =
        controller.billingAuditEntries.take(4).toList(growable: false);
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
          if (storedBillingState != null)
            _BillingFactRow(
              label: l10n.billingLastProductLabel,
              value: storedBillingState.productId,
            ),
          if (storedBillingState != null)
            _BillingFactRow(
              label: l10n.billingStoredPurchaseLabel,
              value:
                  '${_billingStatusCodeLabel(storedBillingState.statusCode)} · ${_billingRenewalLabel(storedBillingState.renewalState, l10n)}',
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
            Text(l10n.billingCatalogTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (billingState.catalog.isEmpty)
              Text(l10n.billingCatalogEmpty, style: theme.textTheme.bodyMedium)
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
            if (storedBillingState != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey<String>('billing-refresh-status'),
                onPressed: () => _refreshBillingStatus(context),
                icon: const Icon(Icons.sync_rounded),
                label: Text(l10n.billingRefreshNow),
              ),
            ],
            const SizedBox(height: 14),
            Text(l10n.billingAuditTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (billingAuditEntries.isEmpty)
              Text(l10n.billingAuditEmpty, style: theme.textTheme.bodyMedium)
            else
              for (final entry in billingAuditEntries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BillingAuditCard(entry: entry),
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
        text: widget.controller.billingRuntimeState.config.decisionDocumentUrl,
      ),
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
    final result = await widget.controller.buyBillingCatalogProduct(
      item.productId,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _restorePurchases(BuildContext context) async {
    final result = await widget.controller.restoreBillingPurchases();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _refreshBillingStatus(BuildContext context) async {
    final result = await widget.controller.refreshBillingEntitlement();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
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

class _BillingAuditCard extends StatelessWidget {
  const _BillingAuditCard({required this.entry});

  final BillingAuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.eventType, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            '${entry.statusCode} · ${entry.renewalState}',
            style: theme.textTheme.bodyMedium,
          ),
          if (entry.productId != null && entry.productId!.isNotEmpty)
            Text(entry.productId!, style: theme.textTheme.bodySmall),
          Text(entry.createdAtIso, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BillingFactRow extends StatelessWidget {
  const _BillingFactRow({required this.label, required this.value});

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
            _ChoiceOption(value: RegionPreference.br, label: l10n.regionBrazil),
            _ChoiceOption(
              value: RegionPreference.pt,
              label: l10n.regionPortugal,
            ),
            _ChoiceOption(value: RegionPreference.fr, label: l10n.regionFrance),
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
            _ChoiceOption(value: RegionPreference.tw, label: l10n.regionTaiwan),
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
  const _ChoiceOption({required this.value, required this.label});

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
          Text(value, style: theme.textTheme.headlineSmall),
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
            AppLocalizations.of(
              context,
            )!
                .domainEventsEligible(eventCount, aiEligibleCount),
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
              child: Text('- $item', style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _RecentLifeEventCard extends StatelessWidget {
  const _RecentLifeEventCard({required this.controller, required this.event});

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
          Text(event.summary, style: theme.textTheme.titleMedium),
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
              Chip(label: Text('${l10n.privacyEventSource}: ${event.source}')),
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
                      event.eventId,
                      permission,
                    );
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
        ? GoLifePalette.surface700.withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.88),
    borderRadius: BorderRadius.circular(26),
    border: Border.all(
      color: isDark
          ? GoLifePalette.lineStrong.withValues(alpha: 0.88)
          : const Color(0xFFD7E1FF),
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

String _entitlementPlanLabel(EntitlementPlan plan, AppLocalizations l10n) {
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

String _billingRenewalLabel(String renewalState, AppLocalizations l10n) {
  switch (renewalState) {
    case entitlementRenewalStatePending:
      return l10n.billingRenewalPending;
    case entitlementRenewalStateActive:
      return l10n.billingRenewalActive;
    case entitlementRenewalStateGrace:
      return l10n.billingRenewalGrace;
    case entitlementRenewalStatePaused:
      return l10n.billingRenewalPaused;
    case entitlementRenewalStateCancelled:
      return l10n.billingRenewalCancelled;
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
