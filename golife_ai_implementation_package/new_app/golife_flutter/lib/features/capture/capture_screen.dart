import 'package:flutter/material.dart';

import '../../core/privacy/privacy_models.dart';
import '../app_state/golife_controller.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late final TextEditingController _textController;
  DomainKey _selectedDomain = DomainKey.tasks;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permission = widget.controller.privacySettings.permissionFor(_selectedDomain);
    final recentEvents = widget.controller.lifeEvents.take(6).toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Capture', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Turn one quick note into a local LifeEvent. Only events already marked as AI-allowed can leave the device.',
            style: theme.textTheme.bodyLarge,
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
                Text('Domain', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final domain in [
                      DomainKey.tasks,
                      DomainKey.habits,
                      DomainKey.week,
                      DomainKey.finance,
                      DomainKey.pantry,
                      DomainKey.wardrobe,
                    ])
                      ChoiceChip(
                        selected: _selectedDomain == domain,
                        label: Text(domain.label),
                        onSelected: (_) {
                          setState(() {
                            _selectedDomain = domain;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Current privacy for ${_selectedDomain.label}: ${permission.label}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: _hintFor(_selectedDomain),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await widget.controller.captureEvent(
                      domain: _selectedDomain,
                      text: _textController.text,
                    );
                    _textController.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('LifeEvent captured.'),
                        ),
                      );
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Save event'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Recent events', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final event in recentEvents)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F0E4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.domain} · ${event.eventType}',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(event.summary, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Text(
                    'privacy: ${event.privacyLevel}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _hintFor(DomainKey domain) {
    switch (domain) {
      case DomainKey.tasks:
        return 'Example: submit rent receipt before lunch';
      case DomainKey.habits:
        return 'Example: walked 15 minutes after dinner';
      case DomainKey.week:
        return 'Example: Friday focus should stay on admin work';
      case DomainKey.finance:
        return 'Example: bought coffee and sandwich for 8.50';
      case DomainKey.pantry:
        return 'Example: spinach expires tomorrow';
      case DomainKey.wardrobe:
        return 'Example: thinking about buying another black jacket';
      case DomainKey.copilot:
        return 'Example: a mission note';
    }
  }
}
