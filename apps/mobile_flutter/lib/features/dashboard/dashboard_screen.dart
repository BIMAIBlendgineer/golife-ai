import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/daily_risk.dart';
import '../app_state/golife_controller.dart';
import 'signal_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final missions = controller.dailyMissions;
    final primaryMission = missions.isEmpty ? null : missions.first;
    final secondaryMissions = missions.length > 1
        ? missions.skip(1).toList(growable: false)
        : const <DailyMission>[];
    final risks = controller.dailyRisks;
    final gatewayStatusMessage = controller.gatewayStatusMessage;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1080 ? 2 : 1;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('3 Missions for today', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Home Today turns the graph into small actions: one main mission, two support missions, visible evidence and fast feedback.',
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
                label: const Text('Capturar'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/journal'),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Escribir'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/copilot'),
                icon: const Icon(Icons.record_voice_over_rounded),
                label: const Text('Hablar'),
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
                  primaryMission?.title ?? 'Loading missions...',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  primaryMission?.body ??
                      'Bootstrapping local events, ranked missions and gateway trace.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFF2E5D2),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetaPill(
                      label: controller.isReady ? 'Ready' : 'Booting',
                      color: const Color(0xFFD06447),
                    ),
                    _MetaPill(
                      label: controller.gatewayStatusLabel,
                      color: const Color(0xFF5D7A68),
                    ),
                    _MetaPill(
                      label: controller.latestFeedbackLabel,
                      color: const Color(0xFF8A6C2F),
                    ),
                    _MetaPill(
                      label: '${risks.length} risks',
                      color: const Color(0xFF7A5167),
                    ),
                    if (primaryMission != null)
                      _MetaPill(
                        label:
                            '${(primaryMission.confidence * 100).round()}% confidence',
                        color: const Color(0xFF4C6A4F),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (primaryMission != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final domain in primaryMission.domainTargets)
                        Chip(
                          label: Text(domain),
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
                      label: const Text('Explain'),
                    ),
                    FilledButton.icon(
                      onPressed: primaryMission == null
                          ? null
                          : () => controller.markMissionUseful(primaryMission),
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('Useful'),
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
                      label: const Text('Do now'),
                    ),
                    OutlinedButton.icon(
                      onPressed: primaryMission == null
                          ? null
                          : () => controller.rejectMission(primaryMission),
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('Not useful'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'AI data disclosure',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sent now: ${controller.aiEligibleEventCount} local events. Blocked locally: ${controller.totalEventCount - controller.aiEligibleEventCount}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFF2E5D2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Risks today', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (risks.isEmpty)
            Text(
              'No explicit daily risks were detected from the current AI-eligible graph.',
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final risk in risks)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DailyRiskCard(risk: risk),
              ),
          const SizedBox(height: 20),
          Text('Support missions', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (secondaryMissions.isEmpty)
            Text(
              'Secondary missions will appear once the daily plan is available.',
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final mission in secondaryMissions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MissionSupportCard(
                  mission: mission,
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
                eyebrow: 'Critical task',
                title: controller.criticalTask.title,
                body:
                    '${controller.criticalTask.timeboxLabel} - ${controller.criticalTask.priorityLabel}',
                color: const Color(0xFFD06447),
              ),
              SignalCard(
                eyebrow: 'Recovery habit',
                title: controller.recoveryHabit.title,
                body:
                    'Cue: ${controller.recoveryHabit.cue} - ${controller.recoveryHabit.streakLabel}',
                color: const Color(0xFF5D7A68),
              ),
              SignalCard(
                eyebrow: 'Relevant spend',
                title: controller.financeSummary.label,
                body: controller.financeSummary.reflectionLabel,
                color: const Color(0xFF8A6C2F),
              ),
              SignalCard(
                eyebrow: 'Use this food',
                title: controller.pantrySummary.name,
                body: controller.pantrySummary.rescueHint,
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
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(mission.body, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(
                  'Why this one today',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Confidence ${(mission.confidence * 100).round()}% - ${mission.recommendationType}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text('Evidence', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final item in mission.evidence)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item', style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text('Data used for this mission',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final item in controller.missionDataUsed(mission))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item', style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text('Data sent to AI', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final item in controller.dataSentToAiPreview())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item', style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text('Blocked from AI', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final item in controller.dataBlockedFromAiPreview())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('- $item', style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 16),
                Text('Uncertainty', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(mission.uncertainty, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text('Trace', style: theme.textTheme.titleLarge),
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
            '${risk.severity.toUpperCase()} RISK',
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
    required this.onExplain,
    required this.onAccept,
    required this.onComplete,
  });

  final DailyMission mission;
  final VoidCallback onExplain;
  final Future<void> Function() onAccept;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
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
          Text(mission.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(mission.body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final domain in mission.domainTargets)
                Chip(label: Text(domain)),
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
                label: const Text('Explain'),
              ),
              TextButton.icon(
                onPressed: () {
                  onAccept();
                },
                icon: const Icon(Icons.playlist_add_check_circle_outlined),
                label: const Text('Accept'),
              ),
              TextButton.icon(
                onPressed: () {
                  onComplete();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Do now'),
              ),
            ],
          ),
        ],
      ),
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
