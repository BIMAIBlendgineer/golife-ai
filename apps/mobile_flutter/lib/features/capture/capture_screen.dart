import 'package:flutter/material.dart';

import '../../core/ai_client/dto/ai_gateway_dto.dart';
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
  DomainKey? _selectedDomain;
  CaptureClassificationDto? _classification;
  bool _isSubmitting = false;

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
    final selectedDomain = _selectedDomain;
    final permission = selectedDomain == null
        ? null
        : widget.controller.privacySettings.permissionFor(selectedDomain);
    final recentEvents =
        widget.controller.lifeEvents.take(6).toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Capture', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Write one quick note. You can route it manually or let the gateway classify it first and confirm before saving.',
            style: theme.textTheme.bodyLarge,
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
                Text('Route', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      selected: selectedDomain == null,
                      label: const Text('Auto'),
                      onSelected: (_) {
                        setState(() {
                          _selectedDomain = null;
                          _classification = null;
                        });
                      },
                    ),
                    for (final domain in [
                      DomainKey.tasks,
                      DomainKey.habits,
                      DomainKey.week,
                      DomainKey.finance,
                      DomainKey.pantry,
                      DomainKey.wardrobe,
                    ])
                      ChoiceChip(
                        selected: selectedDomain == domain,
                        label: Text(domain.label),
                        onSelected: (_) {
                          setState(() {
                            _selectedDomain = domain;
                            _classification = null;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  selectedDomain == null
                      ? 'Auto mode will classify the note first, then ask you to confirm.'
                      : 'Current privacy for ${selectedDomain.label}: ${permission?.label ?? 'Local'}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (_) {
                    if (_classification != null) {
                      setState(() {
                        _classification = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _hintFor(selectedDomain),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _handlePrimaryAction,
                      icon: Icon(
                        selectedDomain == null
                            ? Icons.auto_awesome_outlined
                            : Icons.add_task_rounded,
                      ),
                      label: Text(
                        selectedDomain == null
                            ? 'Classify capture'
                            : 'Save event',
                      ),
                    ),
                    if (_classification != null)
                      OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _saveClassifiedEvent,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirm and save'),
                      ),
                  ],
                ),
                if (_classification != null) ...[
                  const SizedBox(height: 16),
                  _ClassificationCard(
                    classification: _classification!,
                  ),
                ],
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
                    '${event.domain} - ${event.eventType}',
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

  Future<void> _handlePrimaryAction() async {
    if (_selectedDomain == null) {
      await _classifyCapture();
      return;
    }
    await _saveManualEvent(_selectedDomain!);
  }

  Future<void> _classifyCapture() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final classification = await widget.controller.classifyCaptureText(text);
      if (!mounted) {
        return;
      }
      setState(() {
        _classification = classification;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _saveManualEvent(DomainKey domain) async {
    await _saveEvent(
      domain: domain,
      eventType: null,
    );
  }

  Future<void> _saveClassifiedEvent() async {
    final classification = _classification;
    if (classification == null) {
      return;
    }

    final domain = domainKeyFromWireName(classification.domain);
    if (domain == null) {
      return;
    }

    await _saveEvent(
      domain: domain,
      eventType: classification.eventType,
    );
  }

  Future<void> _saveEvent({
    required DomainKey domain,
    required String? eventType,
  }) async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.controller.captureEvent(
        domain: domain,
        text: text,
        eventType: eventType,
      );
      _textController.clear();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _classification == null
                ? 'LifeEvent captured.'
                : 'Classified event confirmed and captured.',
          ),
        ),
      );
      setState(() {
        _classification = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _hintFor(DomainKey? domain) {
    switch (domain) {
      case null:
        return 'Example: Compre cafe 4.50 y la lechuga vence manana';
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

class _ClassificationCard extends StatelessWidget {
  const _ClassificationCard({
    required this.classification,
  });

  final CaptureClassificationDto classification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0E4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Classification preview', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${classification.domain} - ${classification.eventType}',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Confidence ${(classification.confidence * 100).round()}%',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(classification.rationale, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
