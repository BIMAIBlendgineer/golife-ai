import 'package:flutter/material.dart';

import '../../core/privacy/privacy_models.dart';
import '../app_state/golife_controller.dart';

class CopilotScreen extends StatelessWidget {
  const CopilotScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final mission = controller.dailyMission;
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
            'The app now prefers the real AI gateway and only falls back to the local mock path when the backend fails or times out.',
            style: theme.textTheme.bodyLarge,
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
                      ? const Color(0xFF5D7A68).withOpacity(0.18)
                      : const Color(0xFF1F1A17).withOpacity(0.06),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.74),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latest trace', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (mission == null)
                  Text('No mission loaded yet.', style: theme.textTheme.bodyMedium)
                else ...[
                  Text(mission.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final entry in mission.trace.entries)
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
