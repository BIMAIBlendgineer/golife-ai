import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            'Each event stays local unless both the domain permission and the event privacy level allow AI. This screen also gives you direct local export and delete controls.',
            style: theme.textTheme.bodyLarge,
          ),
          if (controller.sensitiveLocalEncryptionEnabled) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF4EE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFB6C8B4),
                ),
              ),
              child: Text(
                'Sensitive local encryption is active for Journal, Quick Notes, and Finance records stored on this device.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data controls', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Export copies the full local graph snapshot as JSON. Delete all wipes local data and disables demo reseeding.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _exportLocalJson(context),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Export JSON'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDeleteAll(context),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete all local data'),
                    ),
                  ],
                ),
              ],
            ),
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

  Future<void> _exportLocalJson(BuildContext context) async {
    final json = await controller.exportLocalDataJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Local JSON export copied to clipboard.'),
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete all local data?'),
              content: const Text(
                'This wipes local events, entities, missions, feedback, privacy settings, and cached runtime config on this device.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete all'),
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
      const SnackBar(
        content: Text('All local data deleted.'),
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
        color: tone.withValues(alpha: 0.12),
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
        color: Colors.white.withValues(alpha: 0.76),
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
