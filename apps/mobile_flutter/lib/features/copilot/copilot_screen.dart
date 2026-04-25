import 'package:flutter/material.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../core/privacy/privacy_models.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';

class CopilotScreen extends StatelessWidget {
  const CopilotScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryMission = controller.dailyMission;
    final missions = controller.dailyMissions;
    final allowed = controller.privacySettings.aiAllowedDomains;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.copilotTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.copilotIntro,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EEE7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD6C0A7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.copilotBoundariesTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.copilotBoundariesBody,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final domain in DomainKey.values)
                Chip(
                  label: Text(domain.localizedLabel(l10n)),
                  backgroundColor: allowed.contains(domain)
                      ? const Color(0xFF5D7A68).withValues(alpha: 0.18)
                      : const Color(0xFF1F1A17).withValues(alpha: 0.06),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.copilotTodayPlanTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (missions.isEmpty)
                  Text(
                    l10n.copilotNoPlan,
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  for (final mission in missions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mission.title,
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${mission.domainTargets.map((domain) => domain.localizedDomainLabel(l10n)).join(" + ")} - ${(mission.confidence * 100).round()}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.copilotLatestTraceTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (primaryMission == null)
                  Text(
                    l10n.copilotNoTrace,
                    style: theme.textTheme.bodyMedium,
                  )
                else ...[
                  Text(primaryMission.title,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final entry in primaryMission.trace.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
