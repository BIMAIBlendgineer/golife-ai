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
            'Every domain decides whether data stays local, can sync, or can be summarized for AI.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          for (final domain in DomainKey.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DomainPermissionCard(
                domain: domain,
                selected: controller.privacySettings.permissionFor(domain),
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

class _DomainPermissionCard extends StatelessWidget {
  const _DomainPermissionCard({
    required this.domain,
    required this.selected,
    required this.onChanged,
  });

  final DomainKey domain;
  final DataPermission selected;
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
