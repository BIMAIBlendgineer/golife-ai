import 'package:flutter/material.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../core/privacy/privacy_models.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import 'capture_parser.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late final TextEditingController _textController;
  DomainKey? _selectedDomain;
  List<CaptureDraftItem> _drafts = const <CaptureDraftItem>[];
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedDomain = _selectedDomain;
    final permission = selectedDomain == null
        ? null
        : widget.controller.privacySettings.permissionFor(selectedDomain);
    final recentEvents =
        widget.controller.lifeEvents.take(6).toList(growable: false);
    final gatewayStatusMessage = widget.controller.gatewayStatusMessage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.captureTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.captureIntro,
            style: theme.textTheme.bodyLarge,
          ),
          if (gatewayStatusMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD6C0A7)),
              ),
              child: Text(
                gatewayStatusMessage,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
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
                Text(l10n.captureRouteTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      selected: selectedDomain == null,
                      label: Text(l10n.captureAutoRoute),
                      onSelected: (_) {
                        setState(() {
                          _selectedDomain = null;
                          _drafts = const <CaptureDraftItem>[];
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
                        label: Text(domain.localizedLabel(l10n)),
                        onSelected: (_) {
                          setState(() {
                            _selectedDomain = domain;
                            _drafts = const <CaptureDraftItem>[];
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  selectedDomain == null
                      ? l10n.captureAutoModeBody
                      : l10n.captureCurrentDefaultPrivacy(
                          selectedDomain.localizedLabel(l10n),
                          (permission ?? DataPermission.localOnly)
                              .localizedLabel(l10n),
                        ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (_) {
                    if (_drafts.isNotEmpty) {
                      setState(() {
                        _drafts = const <CaptureDraftItem>[];
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
                      onPressed: _isSubmitting ? null : _prepareDrafts,
                      icon: Icon(
                        selectedDomain == null
                            ? Icons.auto_awesome_outlined
                            : Icons.rule_folder_outlined,
                      ),
                      label: Text(
                        _drafts.isEmpty
                            ? l10n.actionParseCapture
                            : l10n.actionReparseCapture,
                      ),
                    ),
                    if (_drafts.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _saveDrafts,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(l10n.actionSaveCaptureItems(_drafts.length)),
                      ),
                  ],
                ),
                if (_drafts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n.captureDraftsToConfirm,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  for (final draft in _drafts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CaptureDraftCard(
                        draft: draft,
                        onDomainChanged: (domain) {
                          final permission = widget.controller.privacySettings
                              .permissionFor(domain);
                          _updateDraft(
                            draft.id,
                            draft.copyWith(
                              domain: domain,
                              eventType: _defaultEventType(domain),
                              privacyLevel: permission.storageKey,
                            ),
                          );
                        },
                        onPrivacyChanged: (permission) {
                          _updateDraft(
                            draft.id,
                            draft.copyWith(
                              privacyLevel: permission.storageKey,
                            ),
                          );
                        },
                        onEditText: () => _editDraftText(draft),
                        onRemove: () => _removeDraft(draft.id),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.captureRecentEvents, style: theme.textTheme.titleLarge),
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
                    '${event.domain.localizedDomainLabel(l10n)} - ${event.eventType}',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(event.summary, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Text(
                    l10n.capturePrivacyLabel(
                      event.privacyLevel.localizedPermissionLabel(l10n),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _prepareDrafts() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final drafts = await widget.controller.prepareCaptureDrafts(
        text: text,
        forcedDomain: _selectedDomain,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _drafts = drafts;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _saveDrafts() async {
    final l10n = AppLocalizations.of(context)!;
    if (_drafts.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.controller.captureDrafts(_drafts);
      _textController.clear();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.captureItemsCaptured(_drafts.length)),
        ),
      );
      setState(() {
        _drafts = const <CaptureDraftItem>[];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _editDraftText(CaptureDraftItem draft) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: draft.text);
    final updatedText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.captureEditItemTitle),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.actionSave),
            ),
          ],
        );
      },
    );
    if (updatedText == null || updatedText.isEmpty) {
      return;
    }
    _updateDraft(
      draft.id,
      draft.copyWith(text: updatedText),
    );
  }

  void _updateDraft(String id, CaptureDraftItem next) {
    setState(() {
      _drafts = _drafts.map((draft) {
        return draft.id == id ? next : draft;
      }).toList(growable: false);
    });
  }

  void _removeDraft(String id) {
    setState(() {
      _drafts =
          _drafts.where((draft) => draft.id != id).toList(growable: false);
    });
  }

  String _hintFor(DomainKey? domain) {
    final l10n = AppLocalizations.of(context)!;
    switch (domain) {
      case null:
        return l10n.captureHintAuto;
      case DomainKey.tasks:
        return l10n.captureHintTasks;
      case DomainKey.habits:
        return l10n.captureHintHabits;
      case DomainKey.week:
        return l10n.captureHintWeek;
      case DomainKey.finance:
        return l10n.captureHintFinance;
      case DomainKey.pantry:
        return l10n.captureHintPantry;
      case DomainKey.wardrobe:
        return l10n.captureHintWardrobe;
      case DomainKey.copilot:
        return l10n.captureHintCopilot;
    }
  }

  String _defaultEventType(DomainKey domain) {
    switch (domain) {
      case DomainKey.tasks:
        return 'task_captured';
      case DomainKey.habits:
        return 'habit_logged';
      case DomainKey.week:
        return 'week_note_captured';
      case DomainKey.finance:
        return 'expense_logged';
      case DomainKey.pantry:
        return 'ingredient_flagged';
      case DomainKey.wardrobe:
        return 'purchase_intention';
      case DomainKey.copilot:
        return 'note_captured';
    }
  }
}

class _CaptureDraftCard extends StatelessWidget {
  const _CaptureDraftCard({
    required this.draft,
    required this.onDomainChanged,
    required this.onPrivacyChanged,
    required this.onEditText,
    required this.onRemove,
  });

  final CaptureDraftItem draft;
  final ValueChanged<DomainKey> onDomainChanged;
  final ValueChanged<DataPermission> onPrivacyChanged;
  final VoidCallback onEditText;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentPermission = DataPermission.values.firstWhere(
      (permission) => permission.storageKey == draft.privacyLevel,
      orElse: () => DataPermission.localOnly,
    );

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
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.text,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onEditText,
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.actionEdit,
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.actionRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            draft.rationale,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DomainKey>(
                  initialValue: draft.domain,
                  decoration: InputDecoration(
                    labelText: l10n.fieldDomain,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DomainKey.tasks,
                    DomainKey.habits,
                    DomainKey.week,
                    DomainKey.finance,
                    DomainKey.pantry,
                    DomainKey.wardrobe,
                  ].map((domain) {
                    return DropdownMenuItem(
                      value: domain,
                      child: Text(domain.localizedLabel(l10n)),
                    );
                  }).toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      onDomainChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<DataPermission>(
                  initialValue: currentPermission,
                  decoration: InputDecoration(
                    labelText: l10n.fieldPrivacy,
                    border: OutlineInputBorder(),
                  ),
                  items: DataPermission.values.map((permission) {
                    return DropdownMenuItem(
                      value: permission,
                      child: Text(permission.localizedLabel(l10n)),
                    );
                  }).toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      onPrivacyChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(draft.eventType)),
              Chip(label: Text('${(draft.confidence * 100).round()}%')),
            ],
          ),
        ],
      ),
    );
  }
}
