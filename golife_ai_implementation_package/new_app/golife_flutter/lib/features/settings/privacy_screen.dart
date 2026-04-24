import 'package:flutter/material.dart';

import '../../core/privacy/privacy_models.dart';
import '../app_state/golife_controller.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privacy', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Each event stays local unless both the domain permission and the event privacy level allow AI. This screen shows what the graph can actually send.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _PrivacyMetricCard(
                  label: 'Total events',
                  value: controller.totalEventCount.toString(),
                  tone: const Color(0xFF1F4C5B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrivacyMetricCard(
                  label: 'AI-eligible',
                  value: controller.aiEligibleEventCount.toString(),
                  tone: const Color(0xFF5D7A68),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PrivacyMetricCard(
            label: 'Blocked locally',
            value:
                '${controller.totalEventCount - controller.aiEligibleEventCount}',
            tone: const Color(0xFFD06447),
          ),
          const SizedBox(height: 24),
          Text('Domain controls', style: theme.textTheme.titleLarge),
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
        ],
      ),
    );
  }
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(domain.label, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '$eventCount events - $aiEligibleCount currently AI-eligible',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final permission in DataPermission.values)
                ChoiceChip(
                  label: Text(permission.label),
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
