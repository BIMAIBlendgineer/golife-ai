import 'package:flutter/material.dart';

import '../../core/privacy/privacy_models.dart';
import '../app_state/golife_controller.dart';

class CopilotScreen extends StatelessWidget {
  const CopilotScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final primaryMission = controller.dailyMission;
    final missions = controller.dailyMissions;
    final allowed = controller.privacySettings.aiAllowedDomains;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Copilot', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'The copilot now works around a ranked daily plan: visible trace, three missions and local fallback when the gateway is unavailable.',
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
                Text('Reflection boundaries',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'GoLife helps with daily organization and practical reflection. It does not diagnose, provide therapy, or replace professional care. If something feels urgent or unsafe, use real crisis or medical support.',
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
                  label: Text(domain.label),
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
                Text('Today plan', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (missions.isEmpty)
                  Text(
                    'No mission plan loaded yet.',
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
                            '${mission.domainTargets.join(" + ")} - ${(mission.confidence * 100).round()}%',
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
                Text('Latest trace', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (primaryMission == null)
                  Text('No mission loaded yet.',
                      style: theme.textTheme.bodyMedium)
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
