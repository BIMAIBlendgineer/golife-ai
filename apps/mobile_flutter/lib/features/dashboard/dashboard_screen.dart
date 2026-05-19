import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/missions/mission_set.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import '../shared/premium_ui.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _completedMissionTitle;
  List<String> _completedImpact = const <String>[];

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;
    final missions = controller.dailyMissions;
    final primaryMission = missions.isEmpty ? null : missions.first;
    final secondaryMissions = missions.skip(1).take(2).toList(growable: false);
    final risks = controller.dailyRisks;
    final gatewayStatusMessage = controller.gatewayStatusMessage;

    return GoLifeScreen(
      title: l10n.labelToday,
      subtitle: _todaySubtitle(l10n),
      badge: GoLifeStatusPill(
        label: controller.localizedGatewayStatusLabel(l10n),
        icon: _deliveryIcon(controller.gatewayStatusLabel),
        accent: _deliveryAccent(controller.gatewayStatusLabel),
      ),
      children: [
        if (_completedMissionTitle != null) ...[
          _CompletionCard(
            title: _completedMissionTitle!,
            impact: _completedImpact,
            onYes: () async {
              if (primaryMission != null) {
                await controller.markMissionUseful(primaryMission);
              }
              if (mounted) {
                setState(() => _completedMissionTitle = null);
              }
            },
            onNo: () async {
              if (primaryMission != null) {
                await controller.rejectMission(primaryMission);
              }
              if (mounted) {
                setState(() => _completedMissionTitle = null);
              }
            },
            onLater: () {
              setState(() => _completedMissionTitle = null);
            },
          ),
          const SizedBox(height: 16),
        ],
        if (gatewayStatusMessage != null) ...[
          GoLifeCard(
            accent: GoLifeAccent.amber,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_moon_outlined,
                  color: GoLifePalette.amber,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    gatewayStatusMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (primaryMission == null)
          GoLifeEmptyState(
            title: _todayEmptyTitle(l10n),
            body: _todayEmptyBody(l10n),
            icon: Icons.auto_awesome_outlined,
            action: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/capture'),
                  icon: const Icon(Icons.bolt_rounded),
                  label: Text(_understandDayLabel(l10n)),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final example in _captureExamples(l10n))
                      Chip(label: Text(example)),
                  ],
                ),
              ],
            ),
          )
        else ...[
          _MissionHeroCard(
            controller: controller,
            mission: primaryMission,
            onExplain: () =>
                _showMissionExplanationSheet(context, primaryMission),
            onDoNow: () => _completeMission(primaryMission),
            onNotUseful: () => controller.rejectMission(primaryMission),
          ),
          const SizedBox(height: 16),
          GoLifeCard(
            accent: GoLifeAccent.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoLifeSectionTitle(
                  title: l10n.dashboardAiDisclosureTitle,
                  subtitle: controller.localizedMissionDeliverySummary(
                    primaryMission,
                    l10n,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GoLifeStatusPill(
                      label: controller.localizedMissionDeliveryLabel(
                        primaryMission,
                        l10n,
                      ),
                      icon: Icons.lock_outline_rounded,
                      accent: GoLifeAccent.blue,
                    ),
                    GoLifeStatusPill(
                      label: '${controller.aiEligibleEventCount}',
                      icon: Icons.auto_awesome_rounded,
                      accent: GoLifeAccent.emerald,
                    ),
                    GoLifeStatusPill(
                      label:
                          '${controller.totalEventCount - controller.aiEligibleEventCount}',
                      icon: Icons.shield_outlined,
                      accent: GoLifeAccent.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      _showMissionExplanationSheet(context, primaryMission),
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(_viewDataLabel(l10n)),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: _secondaryMissionsTitle(l10n),
          subtitle: _secondaryMissionsBody(l10n),
        ),
        const SizedBox(height: 12),
        if (secondaryMissions.isEmpty)
          GoLifeCard(
            child: Text(
              l10n.dashboardNoSupportMissions,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          for (final mission in secondaryMissions) ...[
            _SupportMissionCard(
              controller: controller,
              mission: mission,
              onExplain: () => _showMissionExplanationSheet(context, mission),
              onDoNow: () => _completeMission(mission),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 20),
        GoLifeSectionTitle(
          title: l10n.dashboardRisksTitle,
          subtitle: _risksSubtitle(l10n),
        ),
        const SizedBox(height: 12),
        if (risks.isEmpty)
          GoLifeCard(
            accent: GoLifeAccent.emerald,
            child: Text(
              l10n.dashboardNoRisks,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          for (final risk in risks) ...[
            _RiskCard(risk: risk),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 20),
        GoLifeCard(
          accent: GoLifeAccent.violet,
          filled: true,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capturePromptTitle(l10n),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _capturePromptBody(l10n),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GoLifePalette.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.go('/capture'),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(l10n.navCapture),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _completeMission(DailyMission mission) async {
    final message = await widget.controller.completeMissionAction(mission);
    if (!mounted) {
      return;
    }
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() {
      _completedMissionTitle = widget.controller.localizedMissionTitle(
        mission,
        AppLocalizations.of(context)!,
      );
      _completedImpact = _impactForMission(
        mission,
        AppLocalizations.of(context)!,
      );
    });
  }

  void _showMissionExplanationSheet(
    BuildContext context,
    DailyMission mission,
  ) {
    widget.controller.trackMissionViewed(mission);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final missionSet = widget.controller.currentMissionSet;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.controller.localizedMissionTitle(mission, l10n),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.controller.localizedMissionBody(mission, l10n),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  GoLifeCard(
                    accent: GoLifeAccent.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoLifeSectionTitle(
                          title: l10n.dashboardWhyThisToday,
                          subtitle: widget.controller
                              .localizedMissionRankingReason(mission, l10n),
                        ),
                        const SizedBox(height: 14),
                        _DetailList(
                          items: widget.controller.localizedMissionEvidence(
                            mission,
                            l10n,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GoLifeCard(
                    accent: GoLifeAccent.amber,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoLifeSectionTitle(
                          title: _uncertaintyTitle(l10n),
                          subtitle: mission.uncertainty,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.controller.localizedMissionDeliverySummary(
                            mission,
                            l10n,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GoLifeCard(
                    accent: GoLifeAccent.emerald,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoLifeSectionTitle(
                          title: l10n.labelDataUsedForMission,
                          subtitle: _dataUsedBody(l10n),
                        ),
                        const SizedBox(height: 12),
                        _DetailList(
                          items: widget.controller.missionDataUsed(mission),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.labelDataSentToAi,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _DetailList(
                          items: widget.controller.dataSentToAiForMission(
                            mission,
                          ),
                          emptyLabel: _nothingSentLabel(l10n),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.labelBlockedFromAi,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _DetailList(
                          items: widget.controller.dataBlockedForMission(
                            mission,
                          ),
                          emptyLabel: l10n.dashboardNothingBlocked,
                        ),
                      ],
                    ),
                  ),
                  if (missionSet != null) ...[
                    const SizedBox(height: 12),
                    GoLifeCard(
                      accent: GoLifeAccent.neutral,
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(
                          _technicalTraceTitle(l10n),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          _technicalTraceBody(l10n),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        children: [
                          const SizedBox(height: 12),
                          _MissionSetDetails(missionSet: missionSet),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MissionHeroCard extends StatelessWidget {
  const _MissionHeroCard({
    required this.controller,
    required this.mission,
    required this.onExplain,
    required this.onDoNow,
    required this.onNotUseful,
  });

  final GoLifeController controller;
  final DailyMission mission;
  final VoidCallback onExplain;
  final Future<void> Function() onDoNow;
  final Future<void> Function() onNotUseful;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GoLifeCard(
      accent: GoLifeAccent.violet,
      filled: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GoLifeStatusPill(
                label: controller.localizedMissionDeliveryLabel(mission, l10n),
                icon: Icons.lock_outline_rounded,
                accent: GoLifeAccent.blue,
              ),
              GoLifeStatusPill(
                label: controller.localizedMissionEffortLabel(mission, l10n),
                icon: Icons.schedule_rounded,
                accent: GoLifeAccent.amber,
              ),
              GoLifeStatusPill(
                label: l10n.dashboardConfidencePill(
                  (mission.confidence * 100).round(),
                ),
                icon: Icons.verified_rounded,
                accent: GoLifeAccent.emerald,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            controller.localizedMissionTitle(mission, l10n),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            controller.localizedMissionBody(mission, l10n),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: GoLifePalette.textSecondary),
          ),
          const SizedBox(height: 14),
          Text(
            controller.localizedMissionRankingReason(mission, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final evidence
                  in controller.localizedMissionEvidence(mission, l10n).take(3))
                Chip(label: Text(evidence)),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () async {
              await onDoNow();
            },
            icon: const Icon(Icons.check_circle_outline),
            label: Text(AppLocalizations.of(context)!.actionDoNow),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onExplain,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l10n.actionExplain),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await onNotUseful();
                },
                icon: const Icon(Icons.thumb_down_alt_outlined),
                label: Text(l10n.actionNotUseful),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportMissionCard extends StatelessWidget {
  const _SupportMissionCard({
    required this.controller,
    required this.mission,
    required this.onExplain,
    required this.onDoNow,
  });

  final GoLifeController controller;
  final DailyMission mission;
  final VoidCallback onExplain;
  final Future<void> Function() onDoNow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GoLifeTimelineCard(
      title: controller.localizedMissionTitle(mission, l10n),
      subtitle: controller.localizedMissionBody(mission, l10n),
      accent: GoLifeAccent.blue,
      meta: [
        GoLifeStatusPill(
          label: controller.localizedMissionEffortLabel(mission, l10n),
          accent: GoLifeAccent.amber,
        ),
        ...mission.domainTargets.take(2).map(
              (domain) => GoLifeStatusPill(
                label: domain.localizedDomainLabel(l10n),
                accent: GoLifeAccent.neutral,
              ),
            ),
      ],
      actions: [
        TextButton.icon(
          onPressed: onExplain,
          icon: const Icon(Icons.visibility_outlined),
          label: Text(l10n.actionExplain),
        ),
        FilledButton.tonalIcon(
          onPressed: () async {
            await onDoNow();
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(l10n.actionDoNow),
        ),
      ],
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.risk});

  final DailyRisk risk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GoLifeCard(
      accent: GoLifeAccent.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(risk.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(risk.summary, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GoLifeStatusPill(
                label: risk.severity,
                icon: Icons.warning_amber_rounded,
                accent: GoLifeAccent.danger,
              ),
              ...risk.domainTargets.take(2).map(
                    (domain) => GoLifeStatusPill(
                      label: domain.localizedDomainLabel(l10n),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.title,
    required this.impact,
    required this.onYes,
    required this.onNo,
    required this.onLater,
  });

  final String title;
  final List<String> impact;
  final Future<void> Function() onYes;
  final Future<void> Function() onNo;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GoLifeCard(
      accent: GoLifeAccent.emerald,
      filled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoLifeStatusPill(
            label: _missionCompletedLabel(l10n),
            icon: Icons.check_circle_rounded,
            accent: GoLifeAccent.emerald,
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          for (final item in impact)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '- $item',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: 14),
          Text(
            _wasUsefulLabel(l10n),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonal(
                onPressed: () async {
                  await onYes();
                },
                child: Text(l10n.valueYes),
              ),
              OutlinedButton(
                onPressed: () async {
                  await onNo();
                },
                child: Text(l10n.valueNo),
              ),
              TextButton(onPressed: onLater, child: Text(_laterLabel(l10n))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailList extends StatelessWidget {
  const _DetailList({required this.items, this.emptyLabel});

  final List<String> items;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyLabel ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '- $item',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _MissionSetDetails extends StatelessWidget {
  const _MissionSetDetails({required this.missionSet});

  final MissionSet missionSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final traceEntries = missionSet.rankingTrace.entries.toList(
      growable: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MissionSet: ${missionSet.missionSetId}',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text('Date: ${missionSet.date}', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          'Created: ${missionSet.createdAt}',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final entry in traceEntries)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

GoLifeAccent _deliveryAccent(String gatewayStatusLabel) {
  final normalized = gatewayStatusLabel.toLowerCase();
  if (normalized.contains('no connection')) {
    return GoLifeAccent.danger;
  }
  if (normalized.contains('fallback') || normalized.contains('unavailable')) {
    return GoLifeAccent.amber;
  }
  return GoLifeAccent.emerald;
}

IconData _deliveryIcon(String gatewayStatusLabel) {
  final normalized = gatewayStatusLabel.toLowerCase();
  if (normalized.contains('no connection')) {
    return Icons.wifi_off_rounded;
  }
  if (normalized.contains('fallback') || normalized.contains('unavailable')) {
    return Icons.shield_moon_outlined;
  }
  return Icons.auto_awesome_rounded;
}

List<String> _impactForMission(DailyMission mission, AppLocalizations l10n) {
  final domains = mission.domainTargets.toSet();
  final impact = <String>[];
  if (domains.contains('pantry')) {
    impact.add(_impactFoodSaved(l10n));
  }
  if (domains.contains('finance') || domains.contains('wardrobe')) {
    impact.add(_impactPurchaseAvoided(l10n));
  }
  if (domains.contains('habit')) {
    impact.add(_impactHabitReinforced(l10n));
  }
  if (domains.contains('task')) {
    impact.add(_impactTaskClosed(l10n));
  }
  return impact.isEmpty
      ? <String>[_impactProgressLogged(l10n)]
      : impact.take(3).toList(growable: false);
}

String _todaySubtitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Your focus for today.',
      es: 'Tu foco de hoy.',
      ptBr: 'Seu foco de hoje.',
      ptPt: 'O teu foco de hoje.',
      fr: 'Ton focus du jour.',
      it: 'Il tuo focus di oggi.',
      de: 'Dein Fokus fuer heute.',
      ja: 'Your focus for today.',
      zhHans: 'Your focus for today.',
      zhHant: 'Your focus for today.',
    );

String _todayEmptyTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: "I don't know enough about your day yet.",
      es: 'Todavía no sé suficiente de tu día.',
      ptBr: 'Ainda nao sei o suficiente sobre o seu dia.',
      ptPt: 'Ainda nao sei o suficiente sobre o teu dia.',
      fr: 'Je ne sais pas encore assez de ta journee.',
      it: 'Non so ancora abbastanza della tua giornata.',
      de: 'Ich weiss noch nicht genug ueber deinen Tag.',
      ja: "I don't know enough about your day yet.",
      zhHans: "I don't know enough about your day yet.",
      zhHant: "I don't know enough about your day yet.",
    );

String _todayEmptyBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Capture one sentence and GoLife will turn it into the next clear step.',
      es: 'Captura una frase y GoLife la convertirá en el siguiente paso claro.',
      ptBr:
          'Capture uma frase e o GoLife a transformara no proximo passo claro.',
      ptPt: 'Captura uma frase e o GoLife transforma-a no proximo passo claro.',
      fr: 'Capture une phrase et GoLife la transformera en prochaine action claire.',
      it: 'Cattura una frase e GoLife la trasformera nel prossimo passo chiaro.',
      de: 'Erfasse einen Satz und GoLife macht daraus den naechsten klaren Schritt.',
      ja: 'Capture one sentence and GoLife will turn it into the next clear step.',
      zhHans:
          'Capture one sentence and GoLife will turn it into the next clear step.',
      zhHant:
          'Capture one sentence and GoLife will turn it into the next clear step.',
    );

String _understandDayLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Understand my day',
      es: 'Entender mi día',
      ptBr: 'Entender o meu dia',
      ptPt: 'Entender o meu dia',
      fr: 'Comprendre ma journee',
      it: 'Capire la mia giornata',
      de: 'Meinen Tag verstehen',
      ja: 'Understand my day',
      zhHans: 'Understand my day',
      zhHant: 'Understand my day',
    );

List<String> _captureExamples(AppLocalizations l10n) => <String>[
      pickLocalizedValue(
        l10n.localeName,
        en: 'coffee cost 4.50',
        es: 'cafe 4,50',
        ptBr: 'cafe 4,50',
        ptPt: 'cafe 4,50',
        fr: 'cafe 4,50',
        it: 'caffe 4,50',
        de: 'Kaffee 4,50',
        ja: 'coffee cost 4.50',
        zhHans: 'coffee cost 4.50',
        zhHant: 'coffee cost 4.50',
      ),
      pickLocalizedValue(
        l10n.localeName,
        en: 'lettuce expires tomorrow',
        es: 'la lechuga vence manana',
        ptBr: 'a alface vence amanha',
        ptPt: 'a alface vence amanha',
        fr: 'la laitue expire demain',
        it: 'la lattuga scade domani',
        de: 'Salat laeuft morgen ab',
        ja: 'lettuce expires tomorrow',
        zhHans: 'lettuce expires tomorrow',
        zhHant: 'lettuce expires tomorrow',
      ),
      pickLocalizedValue(
        l10n.localeName,
        en: 'call the doctor',
        es: 'llamar al medico',
        ptBr: 'ligar para o medico',
        ptPt: 'ligar ao medico',
        fr: 'appeler le medecin',
        it: 'chiamare il medico',
        de: 'Arzt anrufen',
        ja: 'call the doctor',
        zhHans: 'call the doctor',
        zhHant: 'call the doctor',
      ),
    ];

String _viewDataLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'View data used',
      es: 'Ver datos usados',
      ptBr: 'Ver dados usados',
      ptPt: 'Ver dados usados',
      fr: 'Voir les donnees utilisees',
      it: 'Vedi i dati usati',
      de: 'Verwendete Daten ansehen',
      ja: 'View data used',
      zhHans: 'View data used',
      zhHant: 'View data used',
    );

String _secondaryMissionsTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Other missions',
      es: 'Otras misiones',
      ptBr: 'Outras missoes',
      ptPt: 'Outras missoes',
      fr: 'Autres missions',
      it: 'Altre missioni',
      de: 'Weitere Missionen',
      ja: 'Other missions',
      zhHans: 'Other missions',
      zhHant: 'Other missions',
    );

String _secondaryMissionsBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Keep the rest visible, but secondary.',
      es: 'Mantener el resto visible, pero secundario.',
      ptBr: 'Mantenha o resto visivel, mas secundario.',
      ptPt: 'Mantem o resto visivel, mas secundario.',
      fr: 'Garde le reste visible, mais secondaire.',
      it: 'Tieni il resto visibile, ma secondario.',
      de: 'Behalte den Rest sichtbar, aber sekundar.',
      ja: 'Keep the rest visible, but secondary.',
      zhHans: 'Keep the rest visible, but secondary.',
      zhHant: 'Keep the rest visible, but secondary.',
    );

String _risksSubtitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Risks stay compact so they inform, not dominate.',
      es: 'Los riesgos se mantienen compactos para informar, no dominar.',
      ptBr: 'Os riscos ficam compactos para informar, nao dominar.',
      ptPt: 'Os riscos ficam compactos para informar, nao dominar.',
      fr: 'Les risques restent compacts pour informer, pas dominer.',
      it: 'I rischi restano compatti per informare, non dominare.',
      de: 'Risiken bleiben kompakt, damit sie informieren statt dominieren.',
      ja: 'Risks stay compact so they inform, not dominate.',
      zhHans: 'Risks stay compact so they inform, not dominate.',
      zhHant: 'Risks stay compact so they inform, not dominate.',
    );

String _capturePromptTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Capture the next thing before it turns into noise.',
      es: 'Captura lo siguiente antes de que se convierta en ruido.',
      ptBr: 'Capture a proxima coisa antes que vire ruido.',
      ptPt: 'Captura a proxima coisa antes que vire ruido.',
      fr: 'Capture la prochaine chose avant qu elle ne devienne du bruit.',
      it: 'Cattura la prossima cosa prima che diventi rumore.',
      de: 'Erfasse das Naechste, bevor es zu Rauschen wird.',
      ja: 'Capture the next thing before it turns into noise.',
      zhHans: 'Capture the next thing before it turns into noise.',
      zhHant: 'Capture the next thing before it turns into noise.',
    );

String _capturePromptBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Capture keeps Today fresh without opening every module.',
      es: 'Capture mantiene Today fresco sin abrir todos los módulos.',
      ptBr: 'Capture mantém o Today atualizado sem abrir todos os modulos.',
      ptPt: 'Capture mantem o Today atualizado sem abrir todos os modulos.',
      fr: 'Capture garde Today a jour sans ouvrir tous les modules.',
      it: 'Capture mantiene Today fresco senza aprire ogni modulo.',
      de: 'Capture haelt Today aktuell, ohne jedes Modul zu oeffnen.',
      ja: 'Capture keeps Today fresh without opening every module.',
      zhHans: 'Capture keeps Today fresh without opening every module.',
      zhHant: 'Capture keeps Today fresh without opening every module.',
    );

String _uncertaintyTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Uncertainty',
      es: 'Incertidumbre',
      ptBr: 'Incerteza',
      ptPt: 'Incerteza',
      fr: 'Incertitude',
      it: 'Incertezza',
      de: 'Unsicherheit',
      ja: 'Uncertainty',
      zhHans: 'Uncertainty',
      zhHant: 'Uncertainty',
    );

String _dataUsedBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Visible evidence first, technical detail after.',
      es: 'Primero evidencia visible, después detalle técnico.',
      ptBr: 'Primeiro evidencia visivel, depois detalhe tecnico.',
      ptPt: 'Primeiro evidencia visivel, depois detalhe tecnico.',
      fr: 'D abord les preuves visibles, puis le detail technique.',
      it: 'Prima l evidenza visibile, poi il dettaglio tecnico.',
      de: 'Zuerst sichtbare Evidenz, dann technische Details.',
      ja: 'Visible evidence first, technical detail after.',
      zhHans: 'Visible evidence first, technical detail after.',
      zhHant: 'Visible evidence first, technical detail after.',
    );

String _nothingSentLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Nothing was sent to AI for this mission.',
      es: 'No se envió nada a la IA para esta misión.',
      ptBr: 'Nada foi enviado para a IA nesta missao.',
      ptPt: 'Nada foi enviado para a IA nesta missao.',
      fr: 'Rien n a ete envoye a l IA pour cette mission.',
      it: 'Nulla e stato inviato all IA per questa missione.',
      de: 'Fuer diese Mission wurde nichts an die KI gesendet.',
      ja: 'Nothing was sent to AI for this mission.',
      zhHans: 'Nothing was sent to AI for this mission.',
      zhHant: 'Nothing was sent to AI for this mission.',
    );

String _technicalTraceTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Technical trace',
      es: 'Traza técnica',
      ptBr: 'Traco tecnico',
      ptPt: 'Traco tecnico',
      fr: 'Trace technique',
      it: 'Traccia tecnica',
      de: 'Technische Spur',
      ja: 'Technical trace',
      zhHans: 'Technical trace',
      zhHant: 'Technical trace',
    );

String _technicalTraceBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'MissionSet metadata and ranking trace.',
      es: 'Metadatos de MissionSet y traza de ranking.',
      ptBr: 'Metadados do MissionSet e traco de ranking.',
      ptPt: 'Metadados do MissionSet e traco de ranking.',
      fr: 'Metadonnees MissionSet et trace de classement.',
      it: 'Metadati MissionSet e traccia del ranking.',
      de: 'MissionSet-Metadaten und Ranking-Trace.',
      ja: 'MissionSet metadata and ranking trace.',
      zhHans: 'MissionSet metadata and ranking trace.',
      zhHant: 'MissionSet metadata and ranking trace.',
    );

String _missionCompletedLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Mission completed',
      es: 'Mision completada',
      ptBr: 'Missao concluida',
      ptPt: 'Missao concluida',
      fr: 'Mission terminee',
      it: 'Missione completata',
      de: 'Mission erledigt',
      ja: 'Mission completed',
      zhHans: 'Mission completed',
      zhHant: 'Mission completed',
    );

String _wasUsefulLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Was it useful?',
      es: 'Fue util?',
      ptBr: 'Foi util?',
      ptPt: 'Foi util?',
      fr: 'Etait-ce utile ?',
      it: 'E stato utile?',
      de: 'War es hilfreich?',
      ja: 'Was it useful?',
      zhHans: 'Was it useful?',
      zhHant: 'Was it useful?',
    );

String _laterLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Later',
      es: 'Mas tarde',
      ptBr: 'Depois',
      ptPt: 'Mais tarde',
      fr: 'Plus tard',
      it: 'Piu tardi',
      de: 'Spaeter',
      ja: 'Later',
      zhHans: 'Later',
      zhHant: 'Later',
    );

String _impactFoodSaved(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Food waste reduced.',
      es: 'Comida salvada.',
      ptBr: 'Comida salva.',
      ptPt: 'Comida salva.',
      fr: 'Nourriture sauvee.',
      it: 'Cibo salvato.',
      de: 'Lebensmittel gerettet.',
      ja: 'Food waste reduced.',
      zhHans: 'Food waste reduced.',
      zhHant: 'Food waste reduced.',
    );

String _impactPurchaseAvoided(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'One unnecessary purchase avoided.',
      es: 'Compra evitada.',
      ptBr: 'Compra evitada.',
      ptPt: 'Compra evitada.',
      fr: 'Un achat inutile evite.',
      it: 'Un acquisto evitato.',
      de: 'Ein unnoetiger Kauf vermieden.',
      ja: 'One unnecessary purchase avoided.',
      zhHans: 'One unnecessary purchase avoided.',
      zhHant: 'One unnecessary purchase avoided.',
    );

String _impactHabitReinforced(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Habit continuity reinforced.',
      es: 'Habito reforzado.',
      ptBr: 'Habito reforcado.',
      ptPt: 'Habito reforcado.',
      fr: 'Continuite de l habitude renforcee.',
      it: 'Abitudine rinforzata.',
      de: 'Gewohnheit verstaerkt.',
      ja: 'Habit continuity reinforced.',
      zhHans: 'Habit continuity reinforced.',
      zhHant: 'Habit continuity reinforced.',
    );

String _impactTaskClosed(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'One pending item closed.',
      es: 'Tarea cerrada.',
      ptBr: 'Uma pendencia fechada.',
      ptPt: 'Uma pendencia fechada.',
      fr: 'Une tache cloturee.',
      it: 'Un elemento chiuso.',
      de: 'Ein offener Punkt erledigt.',
      ja: 'One pending item closed.',
      zhHans: 'One pending item closed.',
      zhHant: 'One pending item closed.',
    );

String _impactProgressLogged(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Progress logged for your next plan.',
      es: 'Impacto registrado para el siguiente plan.',
      ptBr: 'Progresso registrado para o proximo plano.',
      ptPt: 'Progresso registado para o proximo plano.',
      fr: 'Progression enregistree pour le prochain plan.',
      it: 'Progresso registrato per il prossimo piano.',
      de: 'Fortschritt fuer den naechsten Plan gespeichert.',
      ja: 'Progress logged for your next plan.',
      zhHans: 'Progress logged for your next plan.',
      zhHant: 'Progress logged for your next plan.',
    );
