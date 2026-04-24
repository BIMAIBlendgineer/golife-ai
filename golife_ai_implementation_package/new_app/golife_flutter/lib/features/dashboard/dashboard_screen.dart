import 'package:flutter/material.dart';

import '../app_state/golife_controller.dart';
import 'signal_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final mission = controller.dailyMission;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1080 ? 2 : 1;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mission of the day', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'A mock daily loop powered by local privacy settings and a sample life graph.',
            style: theme.textTheme.bodyMedium,
          ),
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
                  mission?.title ?? 'Loading mission...',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  mission?.body ?? 'Bootstrapping shell state and mock AI trace.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFFF2E5D2)),
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
                      label: mission?.requiresConfirmation == true
                          ? 'Needs confirmation'
                          : 'Auto-safe',
                      color: const Color(0xFF5D7A68),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.tonalIcon(
                  onPressed: mission == null
                      ? null
                      : () => _showExplanationSheet(context, controller),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Explain'),
                ),
              ],
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

  void _showExplanationSheet(BuildContext context, GoLifeController controller) {
    final mission = controller.dailyMission;
    if (mission == null) {
      return;
    }

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
                const SizedBox(height: 18),
                Text('Evidence', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final item in mission.evidence)
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
        color: color.withOpacity(0.18),
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
