import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../domains/mindflow/decision_card.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/missions/mission_set.dart';
import '../../domains/shopping/product_evidence_card.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import 'signal_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final missions = controller.dailyMissions;
    final primaryMission = missions.isEmpty ? null : missions.first;
    final secondaryMissions = missions.length > 1
        ? missions.skip(1).toList(growable: false)
        : const <DailyMission>[];
    final currentMissionSet = controller.currentMissionSet;
    final risks = controller.dailyRisks;
    final gatewayStatusMessage = controller.gatewayStatusMessage;
    final disclosureSummary = primaryMission == null
        ? l10n.dashboardDisclosurePending
        : controller.localizedMissionDeliverySummary(primaryMission, l10n);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1080 ? 2 : 1;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardMissionCountTitle(missions.length),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dashboardMissionIntro,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/capture'),
                icon: const Icon(Icons.bolt_rounded),
                label: Text(l10n.navCapture),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/journal'),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(l10n.actionWrite),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/decisions'),
                icon: const Icon(Icons.rule_folder_outlined),
                label: Text(_decisionsLabel(l10n)),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/shopping'),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(_shoppingLabel(l10n)),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/copilot'),
                icon: const Icon(Icons.record_voice_over_rounded),
                label: Text(l10n.actionChat),
              ),
            ],
          ),
          if (gatewayStatusMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD6C0A7),
                ),
              ),
              child: Text(
                gatewayStatusMessage,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1A17),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryMission == null
                      ? l10n.dashboardLoadingMissions
                      : controller.localizedMissionTitle(primaryMission, l10n),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  primaryMission == null
                      ? l10n.dashboardBootstrappingMission
                      : controller.localizedMissionBody(primaryMission, l10n),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFF2E5D2),
                  ),
                ),
                if (primaryMission != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.localizedMissionRankingReason(
                      primaryMission,
                      l10n,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFE3D3BC),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaPill(
                      label: controller.isReady
                          ? l10n.statusReady
                          : l10n.statusBooting,
                      color: const Color(0xFFD06447),
                    ),
                    _MetaPill(
                      label: controller.localizedGatewayStatusLabel(l10n),
                      color: const Color(0xFF5D7A68),
                    ),
                    _MetaPill(
                      label: controller.localizedLatestFeedbackLabel(l10n),
                      color: const Color(0xFF8A6C2F),
                    ),
                    _MetaPill(
                      label: l10n.dashboardRiskCount(risks.length),
                      color: const Color(0xFF7A5167),
                    ),
                    if (primaryMission != null)
                      _MetaPill(
                        label: l10n.dashboardConfidencePill(
                          (primaryMission.confidence * 100).round(),
                        ),
                        color: const Color(0xFF4C6A4F),
                      ),
                    if (primaryMission != null)
                      _MetaPill(
                        label: controller.localizedMissionEffortLabel(
                            primaryMission, l10n),
                        color: const Color(0xFF6C5B3D),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (primaryMission != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          controller.localizedMissionDeliveryLabel(
                            primaryMission,
                            l10n,
                          ),
                        ),
                        backgroundColor: const Color(0xFFD6C0A7),
                      ),
                      for (final domain in primaryMission.domainTargets)
                        Chip(
                          label: Text(domain.localizedDomainLabel(l10n)),
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          labelStyle: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: primaryMission == null
                          ? null
                          : () => _showExplanationSheet(
                                context,
                                primaryMission,
                              ),
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(l10n.actionExplain),
                    ),
                    FilledButton.icon(
                      onPressed: primaryMission == null
                          ? null
                          : () => controller.markMissionUseful(primaryMission),
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: Text(l10n.actionUseful),
                    ),
                    FilledButton.icon(
                      onPressed: primaryMission == null
                          ? null
                          : () async {
                              final message =
                                  await controller.completeMissionAction(
                                primaryMission,
                              );
                              if (context.mounted && message != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(l10n.actionDoNow),
                    ),
                    OutlinedButton.icon(
                      onPressed: primaryMission == null
                          ? null
                          : () => controller.rejectMission(primaryMission),
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: Text(l10n.actionNotUseful),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dashboardAiDisclosureTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dashboardAiDisclosureSummary(
                    disclosureSummary,
                    controller.aiEligibleEventCount,
                    controller.totalEventCount -
                        controller.aiEligibleEventCount,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFF2E5D2),
                  ),
                ),
                if (currentMissionSet != null) ...[
                  const SizedBox(height: 16),
                  _MissionSnapshotCard(
                    missionSet: currentMissionSet,
                    l10n: l10n,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (controller.primaryMentalLoadItem != null)
            _MentalLoadSummaryCard(controller: controller),
          if (controller.primaryMentalLoadItem != null)
            const SizedBox(height: 12),
          if (controller.primaryDecisionCard != null)
            _DecisionPreviewCard(controller: controller),
          if (controller.primaryDecisionCard != null)
            const SizedBox(height: 12),
          if (controller.secondaryDecisionCards.isNotEmpty)
            _SecondaryDecisionListCard(controller: controller),
          if (controller.secondaryDecisionCards.isNotEmpty)
            const SizedBox(height: 12),
          if (controller.hasShoppingAlert)
            _ShoppingAlertCard(controller: controller),
          const SizedBox(height: 20),
          Text(l10n.dashboardRisksTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (risks.isEmpty)
            Text(
              l10n.dashboardNoRisks,
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final risk in risks)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DailyRiskCard(risk: risk),
              ),
          const SizedBox(height: 20),
          Text(
            l10n.dashboardSupportMissionsTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (secondaryMissions.isEmpty)
            Text(
              l10n.dashboardNoSupportMissions,
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final mission in secondaryMissions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MissionSupportCard(
                  mission: mission,
                  title: controller.localizedMissionTitle(mission, l10n),
                  body: controller.localizedMissionBody(mission, l10n),
                  sourceLabel:
                      controller.localizedMissionDeliveryLabel(mission, l10n),
                  effortLabel:
                      controller.localizedMissionEffortLabel(mission, l10n),
                  onExplain: () => _showExplanationSheet(context, mission),
                  onAccept: () => controller.acceptMission(mission),
                  onComplete: () async {
                    final message = await controller.completeMissionAction(
                      mission,
                    );
                    if (context.mounted && message != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  },
                ),
              ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: width >= 1080 ? 1.65 : 1.2,
            children: [
              SignalCard(
                eyebrow: l10n.signalCriticalTask,
                title: l10n.mockCriticalTaskTitle,
                body: l10n.mockCriticalTaskBody(
                  controller.criticalTask.estimatedMinutes,
                  l10n.priorityCritical,
                ),
                color: const Color(0xFFD06447),
              ),
              SignalCard(
                eyebrow: l10n.signalRecoveryHabit,
                title: l10n.mockRecoveryHabitTitle,
                body: l10n.signalRecoveryHabitBody(
                  controller.recoveryHabit.cue,
                  l10n.habitStreakDays(controller.recoveryHabit.streak),
                ),
                color: const Color(0xFF5D7A68),
              ),
              SignalCard(
                eyebrow: l10n.signalRelevantSpend,
                title: l10n.mockFinanceSummaryTitle,
                body: l10n.mockFinanceSummaryBody(
                  controller.financeSummary.label,
                  controller.financeSummary.amount.toStringAsFixed(2),
                ),
                color: const Color(0xFF8A6C2F),
              ),
              SignalCard(
                eyebrow: l10n.signalUseThisFood,
                title: l10n.mockPantrySummaryTitle,
                body: l10n.mockPantrySummaryBody,
                color: const Color(0xFF4C6A4F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExplanationSheet(BuildContext context, DailyMission mission) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFFF8EF),
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.localizedMissionTitle(mission, l10n),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  controller.localizedMissionBody(mission, l10n),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dashboardWhyThisToday,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _DisclosurePanel(
                  title:
                      controller.localizedMissionDeliveryLabel(mission, l10n),
                  body:
                      controller.localizedMissionDeliverySummary(mission, l10n),
                ),
                if (mission.ranking != null) ...[
                  const SizedBox(height: 12),
                  _DisclosurePanel(
                    title: controller.localizedMissionEffortLabel(
                      mission,
                      l10n,
                    ),
                    body: controller.localizedMissionRankingReason(
                      mission,
                      l10n,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  l10n.dashboardConfidenceWithType(
                    (mission.confidence * 100).round(),
                    mission.recommendationType,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(l10n.labelEvidence, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final item in controller.localizedMissionEvidence(
                  mission,
                  l10n,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item', style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.labelDataUsedForMission,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final item in controller.missionDataUsed(mission))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item', style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text(l10n.labelDataSentToAi, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                _DisclosureList(
                  items: controller.dataSentToAiForMission(mission),
                  emptyLabel: l10n.dashboardNothingSent,
                ),
                const SizedBox(height: 16),
                Text(l10n.labelBlockedFromAi,
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                _DisclosureList(
                  items: controller.dataBlockedForMission(mission),
                  emptyLabel: l10n.dashboardNothingBlocked,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.labelAlwaysLocalOnDevice,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _DisclosureList(
                  items: controller.localizedAlwaysLocalCollectionLabels(l10n),
                  emptyLabel: l10n.dashboardNoAlwaysLocalCollections,
                ),
                const SizedBox(height: 16),
                Text(l10n.labelEncryptedLocally,
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                _DisclosureList(
                  items: controller.localizedEncryptedCollectionLabels(l10n),
                  emptyLabel: l10n.dashboardNoEncryptedCollections,
                ),
                const SizedBox(height: 16),
                Text(l10n.labelUncertainty, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  controller.localizedMissionUncertainty(mission, l10n),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (controller.currentMissionSet != null) ...[
                  Text(
                    l10n.missionSetSectionTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _MissionSnapshotDetails(
                    missionSet: controller.currentMissionSet!,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(l10n.labelTrace, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final entry in mission.trace.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _decisionsLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Decisions',
      es: 'Decisiones',
      ptBr: 'Decisoes',
      ptPt: 'Decisoes',
      fr: 'Decisions',
      it: 'Decisioni',
      de: 'Entscheidungen',
      ja: 'Decisions',
      zhHans: 'Decisions',
      zhHant: 'Decisions',
    );

String _shoppingLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Shopping',
      es: 'Shopping',
      ptBr: 'Shopping',
      ptPt: 'Shopping',
      fr: 'Achats',
      it: 'Shopping',
      de: 'Einkaufen',
      ja: 'Shopping',
      zhHans: 'Shopping',
      zhHant: 'Shopping',
    );

String _mentalLoadSummaryTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Mental load summary',
      es: 'Resumen de carga mental',
      ptBr: 'Resumo da carga mental',
      ptPt: 'Resumo da carga mental',
      fr: 'Resume de charge mentale',
      it: 'Riepilogo del carico mentale',
      de: 'Zusammenfassung der mentalen Last',
      ja: 'Mental load summary',
      zhHans: 'Mental load summary',
      zhHant: 'Mental load summary',
    );

String _mentalLoadSummaryBody(
  AppLocalizations l10n,
  int count,
  String title,
) =>
    pickLocalizedValue(
      l10n.localeName,
      en: '$count pending items. Top item: $title',
      es: '$count items pendientes. Tema principal: $title',
      ptBr: '$count itens pendentes. Item principal: $title',
      ptPt: '$count itens pendentes. Item principal: $title',
      fr: '$count elements en attente. Principal: $title',
      it: '$count elementi in sospeso. Priorita: $title',
      de: '$count offene Elemente. Oberstes Thema: $title',
      ja: '$count pending items. Top item: $title',
      zhHans: '$count pending items. Top item: $title',
      zhHant: '$count pending items. Top item: $title',
    );

String _primaryDecisionTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Primary decision',
      es: 'Decision principal',
      ptBr: 'Decisao principal',
      ptPt: 'Decisao principal',
      fr: 'Decision principale',
      it: 'Decisione principale',
      de: 'Primaere Entscheidung',
      ja: 'Primary decision',
      zhHans: 'Primary decision',
      zhHant: 'Primary decision',
    );

String _secondaryDecisionsTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Secondary decisions',
      es: 'Decisiones secundarias',
      ptBr: 'Decisoes secundarias',
      ptPt: 'Decisoes secundarias',
      fr: 'Decisions secondaires',
      it: 'Decisioni secondarie',
      de: 'Sekundaere Entscheidungen',
      ja: 'Secondary decisions',
      zhHans: 'Secondary decisions',
      zhHant: 'Secondary decisions',
    );

String _openDecisionsLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Open decisions',
      es: 'Abrir decisiones',
      ptBr: 'Abrir decisoes',
      ptPt: 'Abrir decisoes',
      fr: 'Ouvrir les decisions',
      it: 'Apri decisioni',
      de: 'Entscheidungen oeffnen',
      ja: 'Open decisions',
      zhHans: 'Open decisions',
      zhHant: 'Open decisions',
    );

String _postponeLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Postpone',
      es: 'Posponer',
      ptBr: 'Adiar',
      ptPt: 'Adiar',
      fr: 'Reporter',
      it: 'Posticipa',
      de: 'Verschieben',
      ja: 'Postpone',
      zhHans: 'Postpone',
      zhHant: 'Postpone',
    );

String _createReminderLabel(AppLocalizations l10n) =>
    l10n.homeMemoryActionCreateReminder;

String _shoppingAlertTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Shopping alert',
      es: 'Alerta de shopping',
      ptBr: 'Alerta de shopping',
      ptPt: 'Alerta de shopping',
      fr: 'Alerte achats',
      it: 'Avviso shopping',
      de: 'Shopping-Hinweis',
      ja: 'Shopping alert',
      zhHans: 'Shopping alert',
      zhHant: 'Shopping alert',
    );

String _noProductEvidenceLoaded(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'No product evidence loaded yet.',
      es: 'Todavia no hay evidencia de producto cargada.',
      ptBr: 'Ainda nao ha evidencia de produto carregada.',
      ptPt: 'Ainda nao ha evidencia de produto carregada.',
      fr: 'Aucune preuve produit chargee pour le moment.',
      it: 'Nessuna evidenza prodotto caricata.',
      de: 'Noch keine Produktevidenz geladen.',
      ja: 'No product evidence loaded yet.',
      zhHans: 'No product evidence loaded yet.',
      zhHant: 'No product evidence loaded yet.',
    );

String _openShoppingLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Open shopping',
      es: 'Abrir shopping',
      ptBr: 'Abrir shopping',
      ptPt: 'Abrir shopping',
      fr: 'Ouvrir les achats',
      it: 'Apri shopping',
      de: 'Shopping oeffnen',
      ja: 'Open shopping',
      zhHans: 'Open shopping',
      zhHant: 'Open shopping',
    );

String _loadEvidenceLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Load evidence',
      es: 'Cargar evidencia',
      ptBr: 'Carregar evidencia',
      ptPt: 'Carregar evidencia',
      fr: 'Charger les preuves',
      it: 'Carica evidenza',
      de: 'Evidenz laden',
      ja: 'Load evidence',
      zhHans: 'Load evidence',
      zhHant: 'Load evidence',
    );

String _decisionEvidenceStatusLabel(AppLocalizations l10n, String value) {
  switch (value) {
    case 'local_only':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Local only',
        es: 'Solo local',
        ptBr: 'So local',
        ptPt: 'So local',
        fr: 'Local uniquement',
        it: 'Solo locale',
        de: 'Nur lokal',
        ja: 'Local only',
        zhHans: 'Local only',
        zhHant: 'Local only',
      );
    case 'insufficient_verified_data':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Insufficient evidence',
        es: 'Evidencia insuficiente',
        ptBr: 'Evidencia insuficiente',
        ptPt: 'Evidencia insuficiente',
        fr: 'Preuves insuffisantes',
        it: 'Evidenza insufficiente',
        de: 'Unzureichende Evidenz',
        ja: 'Insufficient evidence',
        zhHans: 'Insufficient evidence',
        zhHant: 'Insufficient evidence',
      );
    default:
      return value;
  }
}

String _shoppingEvidenceSummary(
  AppLocalizations l10n,
  ProductEvidenceCard card,
) =>
    '${_decisionEvidenceStatusLabel(l10n, card.sustainabilityStatus)}: ${card.disclaimer}';

void _showDecisionExplanationSheet(
  BuildContext context,
  GoLifeController controller,
  DecisionCard card,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFF8EF),
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(card.recommendedAction, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              Text(l10n.labelEvidence, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final item in card.evidence)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('- $item', style: theme.textTheme.bodyMedium),
                ),
              const SizedBox(height: 16),
              Text(l10n.labelBlockedFromAi, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                card.privacySummary.blockedDomains.isEmpty
                    ? l10n.dashboardNothingBlocked
                    : card.privacySummary.blockedDomains.join(', '),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(l10n.labelAlwaysLocalOnDevice,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                card.privacySummary.localOnlyCollections.join(', '),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(l10n.labelUncertainty, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(card.uncertainty, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    },
  );
}

void _showShoppingExplanationSheet(
  BuildContext context,
  GoLifeController controller,
  String title,
  ProductEvidenceCard? evidence,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFF8EF),
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                evidence == null
                    ? _noProductEvidenceLoaded(l10n)
                    : _shoppingEvidenceSummary(l10n, evidence),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(l10n.labelDataUsedForMission,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                controller
                    .localizedAlwaysLocalCollectionLabels(l10n)
                    .join(', '),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(l10n.labelBlockedFromAi, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                controller.blockedFromAiEvents.isEmpty
                    ? l10n.dashboardNothingBlocked
                    : controller.blockedFromAiEvents
                        .map((event) => event.domain.localizedDomainLabel(l10n))
                        .join(', '),
                style: theme.textTheme.bodyMedium,
              ),
              if (evidence != null) ...[
                const SizedBox(height: 16),
                Text(l10n.labelTrace, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final entry in evidence.trace.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _DailyRiskCard extends StatelessWidget {
  const _DailyRiskCard({
    required this.risk,
  });

  final DailyRisk risk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEE7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _severityColor(risk.severity).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardRiskSeverityLabel(risk.severity.toUpperCase()),
            style: theme.textTheme.labelLarge?.copyWith(
              color: _severityColor(risk.severity),
            ),
          ),
          const SizedBox(height: 8),
          Text(risk.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(risk.summary, style: theme.textTheme.bodyMedium),
          if (risk.domainTargets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final domain in risk.domainTargets)
                  Chip(label: Text(domain)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFD06447);
      case 'medium':
        return const Color(0xFF8A6C2F);
      default:
        return const Color(0xFF5D7A68);
    }
  }
}

class _MentalLoadSummaryCard extends StatelessWidget {
  const _MentalLoadSummaryCard({
    required this.controller,
  });

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final item = controller.primaryMentalLoadItem;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (item == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_mentalLoadSummaryTitle(l10n),
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            _mentalLoadSummaryBody(
              l10n,
              controller.pendingMentalLoadItems.length,
              item.title,
            ),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(item.summary, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DecisionPreviewCard extends StatelessWidget {
  const _DecisionPreviewCard({
    required this.controller,
  });

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final card = controller.primaryDecisionCard;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (card == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0E4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_primaryDecisionTitle(l10n), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(card.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(card.recommendedAction, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                  label: Text(
                      _decisionEvidenceStatusLabel(l10n, card.evidenceStatus))),
              Chip(
                  label: Text(l10n.dashboardConfidencePill(
                      (card.confidence * 100).round()))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _showDecisionExplanationSheet(
                  context,
                  controller,
                  card,
                ),
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l10n.actionExplain),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/decisions'),
                icon: const Icon(Icons.visibility_outlined),
                label: Text(_openDecisionsLabel(l10n)),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await controller.acceptDecisionCard(card.id);
                },
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: Text(l10n.actionAccept),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await controller.postponeDecisionCard(card.id);
                },
                icon: const Icon(Icons.schedule_outlined),
                label: Text(_postponeLabel(l10n)),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final message =
                      await controller.createReminderFromDecisionCard(card.id);
                  if (context.mounted && message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(_createReminderLabel(l10n)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShoppingAlertCard extends StatelessWidget {
  const _ShoppingAlertCard({
    required this.controller,
  });

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final need = controller.activeShoppingNeeds.first;
    final evidence = controller.productEvidenceForTitle(need.title);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEE7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD6C0A7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_shoppingAlertTitle(l10n), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(need.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            evidence == null
                ? _noProductEvidenceLoaded(l10n)
                : _shoppingEvidenceSummary(l10n, evidence),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _showShoppingExplanationSheet(
                  context,
                  controller,
                  need.title,
                  evidence,
                ),
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l10n.actionExplain),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/shopping'),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(_openShoppingLabel(l10n)),
              ),
              if (evidence == null)
                OutlinedButton.icon(
                  onPressed: () async {
                    await controller.fetchProductEvidenceForNeed(need);
                  },
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(_loadEvidenceLabel(l10n)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecondaryDecisionListCard extends StatelessWidget {
  const _SecondaryDecisionListCard({
    required this.controller,
  });

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_secondaryDecisionsTitle(l10n),
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final card in controller.secondaryDecisionCards.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F0E4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(card.recommendedAction,
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/decisions'),
              icon: const Icon(Icons.rule_folder_outlined),
              label: Text(_openDecisionsLabel(l10n)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionSupportCard extends StatelessWidget {
  const _MissionSupportCard({
    required this.mission,
    required this.title,
    required this.body,
    required this.sourceLabel,
    required this.effortLabel,
    required this.onExplain,
    required this.onAccept,
    required this.onComplete,
  });

  final DailyMission mission;
  final String title;
  final String body;
  final String sourceLabel;
  final String effortLabel;
  final VoidCallback onExplain;
  final Future<void> Function() onAccept;
  final Future<void> Function() onComplete;

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
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium),
          if ((mission.ranking?.rankingReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              mission.ranking!.rankingReason,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(sourceLabel)),
              if (mission.ranking != null)
                Chip(
                  label: Text(effortLabel),
                ),
              for (final domain in mission.domainTargets)
                Chip(label: Text(domain.localizedDomainLabel(l10n))),
              Chip(
                label: Text('${(mission.confidence * 100).round()}%'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TextButton.icon(
                onPressed: onExplain,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l10n.actionExplain),
              ),
              TextButton.icon(
                onPressed: () {
                  onAccept();
                },
                icon: const Icon(Icons.playlist_add_check_circle_outlined),
                label: Text(l10n.actionAccept),
              ),
              TextButton.icon(
                onPressed: () {
                  onComplete();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.actionDoNow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisclosurePanel extends StatelessWidget {
  const _DisclosurePanel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEE7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6C0A7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MissionSnapshotCard extends StatelessWidget {
  const _MissionSnapshotCard({
    required this.missionSet,
    required this.l10n,
  });

  final MissionSet missionSet;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.missionSnapshotTitle,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.missionSnapshotBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFF2E5D2),
            ),
          ),
          const SizedBox(height: 14),
          _MissionSnapshotDetails(
            missionSet: missionSet,
            l10n: l10n,
            lightText: true,
          ),
        ],
      ),
    );
  }
}

class _MissionSnapshotDetails extends StatelessWidget {
  const _MissionSnapshotDetails({
    required this.missionSet,
    required this.l10n,
    this.lightText = false,
  });

  final MissionSet missionSet;
  final AppLocalizations l10n;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rankingTrace = missionSet.rankingTrace;
    final textColor =
        lightText ? const Color(0xFFF2E5D2) : theme.colorScheme.onSurface;
    final traceEntries = rankingTrace.entries
        .where((entry) => entry.key != 'missionSetId' && entry.key != 'date')
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SnapshotFactRow(
          label: l10n.missionSnapshotId,
          value: missionSet.missionSetId,
          lightText: lightText,
        ),
        _SnapshotFactRow(
          label: l10n.missionSnapshotDate,
          value: missionSet.date,
          lightText: lightText,
        ),
        _SnapshotFactRow(
          label: l10n.missionSnapshotSourceState,
          value: _missionSourceStateLabel(l10n, missionSet.sourceState),
          lightText: lightText,
        ),
        _SnapshotFactRow(
          label: l10n.missionSnapshotCreatedAt,
          value: missionSet.createdAt,
          lightText: lightText,
        ),
        _SnapshotFactRow(
          label: l10n.missionSnapshotMissionCount,
          value: missionSet.missions.length.toString(),
          lightText: lightText,
        ),
        _SnapshotFactRow(
          label: l10n.missionSnapshotFallbackUsed,
          value: _traceBoolLabel(
            l10n,
            rankingTrace['fallbackUsed'] ?? rankingTrace['fallback_used'],
          ),
          lightText: lightText,
        ),
        _SnapshotFactRow(
          label: l10n.missionSnapshotPolicyVersion,
          value: _traceStringOrFallback(
            rankingTrace,
            const <String>['policyVersion', 'policy_version'],
            l10n.valueUnknown,
          ),
          lightText: lightText,
        ),
        _SnapshotFactRow(
          label: l10n.missionSnapshotRankingVersion,
          value: _traceStringOrFallback(
            rankingTrace,
            const <String>['rankingVersion', 'ranking_version'],
            l10n.valueUnknown,
          ),
          lightText: lightText,
        ),
        if (traceEntries.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.missionSnapshotRankingTrace,
            style: theme.textTheme.titleMedium?.copyWith(color: textColor),
          ),
          const SizedBox(height: 8),
          for (final entry in traceEntries.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
            ),
        ],
      ],
    );
  }
}

class _SnapshotFactRow extends StatelessWidget {
  const _SnapshotFactRow({
    required this.label,
    required this.value,
    this.lightText = false,
  });

  final String label;
  final String value;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        lightText ? const Color(0xFFF2E5D2) : theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
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

class _DisclosureList extends StatelessWidget {
  const _DisclosureList({
    required this.items,
    required this.emptyLabel,
  });

  final List<String> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:
                Text('- $item', style: Theme.of(context).textTheme.bodyMedium),
          ),
      ],
    );
  }
}

String _missionSourceStateLabel(
  AppLocalizations l10n,
  MissionSourceState sourceState,
) {
  switch (sourceState) {
    case MissionSourceState.live:
      return l10n.gatewayLive;
    case MissionSourceState.fallback:
      return l10n.gatewayLocalFallback;
    case MissionSourceState.offline:
      return l10n.gatewayNoConnection;
    case MissionSourceState.local:
      return l10n.missionSnapshotSourceStateLocal;
    case MissionSourceState.degraded:
      return l10n.missionSnapshotSourceStateDegraded;
  }
}

String _traceStringOrFallback(
  Map<String, Object?> trace,
  List<String> keys,
  String fallback,
) {
  for (final key in keys) {
    final value = trace[key]?.toString().trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return fallback;
}

String _traceBoolLabel(AppLocalizations l10n, Object? value) {
  if (value == true) {
    return l10n.valueYes;
  }
  if (value == false) {
    return l10n.valueNo;
  }
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true') {
    return l10n.valueYes;
  }
  if (normalized == 'false') {
    return l10n.valueNo;
  }
  return l10n.valueUnknown;
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
