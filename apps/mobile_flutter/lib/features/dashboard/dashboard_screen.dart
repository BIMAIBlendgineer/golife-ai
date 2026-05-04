import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/daily_risk.dart';
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
                        label:
                            controller.localizedMissionEffortLabel(primaryMission, l10n),
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
              ],
            ),
          ),
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
