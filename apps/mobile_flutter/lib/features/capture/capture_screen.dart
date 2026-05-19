import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../core/privacy/privacy_models.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import '../shared/premium_ui.dart';
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
  int _savedCount = 0;

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
        widget.controller.lifeEvents.take(3).toList(growable: false);

    return GoLifeScreen(
      title: l10n.captureTitle,
      subtitle: _captureSubtitle(l10n),
      badge: GoLifeStatusPill(
        label: selectedDomain == null
            ? l10n.captureAutoRoute
            : selectedDomain.localizedLabel(l10n),
        icon: Icons.auto_awesome_outlined,
        accent: GoLifeAccent.violet,
      ),
      children: [
        GoLifeCard(
          accent: GoLifeAccent.violet,
          filled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _capturePromptTitle(l10n),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _capturePromptBody(l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: GoLifePalette.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                minLines: 5,
                maxLines: 7,
                onChanged: (_) {
                  if (_drafts.isNotEmpty || _savedCount != 0) {
                    setState(() {
                      _drafts = const <CaptureDraftItem>[];
                      _savedCount = 0;
                    });
                  }
                },
                decoration: InputDecoration(hintText: _hintFor(selectedDomain)),
              ),
              const SizedBox(height: 14),
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
                    DomainKey.finance,
                    DomainKey.pantry,
                    DomainKey.week,
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
              const SizedBox(height: 14),
              Text(
                selectedDomain == null
                    ? l10n.captureAutoModeBody
                    : l10n.captureCurrentDefaultPrivacy(
                        selectedDomain.localizedLabel(l10n),
                        (permission ?? DataPermission.localOnly).localizedLabel(
                          l10n,
                        ),
                      ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _prepareDrafts,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(_understandLabel(l10n)),
              ),
            ],
          ),
        ),
        if (_savedCount > 0) ...[
          const SizedBox(height: 16),
          GoLifeCard(
            accent: GoLifeAccent.emerald,
            filled: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoLifeStatusPill(
                  label: _savedLabel(l10n),
                  icon: Icons.check_circle_rounded,
                  accent: GoLifeAccent.emerald,
                ),
                const SizedBox(height: 12),
                Text(
                  _savedBody(_savedCount, l10n),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      onPressed: () => context.go('/dashboard'),
                      child: Text(_viewUpdatedTodayLabel(l10n)),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _savedCount = 0;
                          _textController.clear();
                        });
                      },
                      child: Text(_captureAnotherLabel(l10n)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (_drafts.isNotEmpty) ...[
          const SizedBox(height: 20),
          GoLifeSectionTitle(
            title: _confirmCaptureTitle(l10n),
            subtitle: _detectedCountLabel(_drafts.length, l10n),
          ),
          const SizedBox(height: 12),
          for (final draft in _drafts) ...[
            _CaptureDraftCard(
              draft: draft,
              onDomainChanged: (domain) {
                final nextPermission =
                    widget.controller.privacySettings.permissionFor(domain);
                _updateDraft(
                  draft.id,
                  draft.copyWith(
                    domain: domain,
                    eventType: _defaultEventType(domain),
                    privacyLevel: nextPermission.storageKey,
                  ),
                );
              },
              onPrivacyChanged: (nextPermission) {
                _updateDraft(
                  draft.id,
                  draft.copyWith(privacyLevel: nextPermission.storageKey),
                );
              },
              onEditText: () => _editDraftText(draft),
              onRemove: () => _removeDraft(draft.id),
            ),
            const SizedBox(height: 12),
          ],
          GoLifeCard(
            accent: GoLifeAccent.blue,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _saveDrafts,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.actionSaveCaptureItems(_drafts.length)),
                ),
                OutlinedButton(
                  onPressed: () => _applyPrivacyToAll(DataPermission.localOnly),
                  child: Text(_bulkPrivacyLocalLabel(l10n)),
                ),
                OutlinedButton(
                  onPressed: () => _applyPrivacyToAll(DataPermission.aiAllowed),
                  child: Text(_bulkPrivacyAiLabel(l10n)),
                ),
              ],
            ),
          ),
        ],
        if (recentEvents.isNotEmpty) ...[
          const SizedBox(height: 20),
          GoLifeSectionTitle(
            title: l10n.captureRecentEvents,
            subtitle: _recentEventsBody(l10n),
          ),
          const SizedBox(height: 12),
          for (final event in recentEvents) ...[
            GoLifeTimelineCard(
              title: event.summary,
              subtitle: event.domain.localizedDomainLabel(l10n),
              accent: GoLifeAccent.neutral,
              meta: [
                GoLifeStatusPill(
                  label: event.privacyLevel.localizedPermissionLabel(l10n),
                  accent: GoLifeAccent.amber,
                ),
                GoLifeStatusPill(
                  label: event.source,
                  accent: GoLifeAccent.blue,
                ),
              ],
              actions: const <Widget>[],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  Future<void> _prepareDrafts() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final drafts = await widget.controller.prepareCaptureDrafts(
        text: text,
        forcedDomain: _selectedDomain,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _savedCount = 0;
        _drafts = drafts;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _saveDrafts() async {
    if (_drafts.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final count = _drafts.length;
      await widget.controller.captureDrafts(_drafts);
      if (!mounted) {
        return;
      }
      setState(() {
        _savedCount = count;
        _drafts = const <CaptureDraftItem>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
          content: TextField(controller: controller, minLines: 2, maxLines: 4),
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
    _updateDraft(draft.id, draft.copyWith(text: updatedText));
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

  void _applyPrivacyToAll(DataPermission permission) {
    setState(() {
      _drafts = _drafts
          .map((draft) => draft.copyWith(privacyLevel: permission.storageKey))
          .toList(growable: false);
    });
  }

  String _hintFor(DomainKey? domain) {
    final l10n = AppLocalizations.of(context)!;
    switch (domain) {
      case null:
        return l10n.captureHintAuto;
      case DomainKey.calendar:
        return l10n.captureHintWeek;
      case DomainKey.journal:
        return l10n.captureHintCopilot;
      case DomainKey.recipes:
        return l10n.captureHintPantry;
      case DomainKey.homememory:
        return l10n.captureHintCopilot;
      case DomainKey.shopping:
        return l10n.captureHintPantry;
      case DomainKey.decisions:
        return l10n.captureHintCopilot;
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
      case DomainKey.calendar:
        return 'calendar_block_captured';
      case DomainKey.journal:
        return 'journal_note_captured';
      case DomainKey.recipes:
        return 'recipe_note_captured';
      case DomainKey.homememory:
        return 'homememory_note_captured';
      case DomainKey.shopping:
        return 'shopping_need_captured';
      case DomainKey.decisions:
        return 'decision_note_captured';
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
    final currentPermission = DataPermission.values.firstWhere(
      (permission) => permission.storageKey == draft.privacyLevel,
      orElse: () => DataPermission.localOnly,
    );
    return GoLifeCard(
      accent: GoLifeAccent.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  draft.text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onEditText,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GoLifeStatusPill(
                label: _draftEventTypeLabel(l10n, draft),
                accent: GoLifeAccent.violet,
              ),
              GoLifeStatusPill(
                label: currentPermission.localizedLabel(l10n),
                accent: GoLifeAccent.amber,
              ),
              GoLifeStatusPill(
                label: '${(draft.confidence * 100).round()}%',
                accent: GoLifeAccent.emerald,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(draft.rationale, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DomainKey>(
                  initialValue: draft.domain,
                  decoration: InputDecoration(labelText: l10n.fieldDomain),
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
                  decoration: InputDecoration(labelText: l10n.fieldPrivacy),
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
        ],
      ),
    );
  }
}

String _captureSubtitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Drop what is in your head.',
      es: 'Suelta lo que tienes en la cabeza.',
      ptBr: 'Solte o que esta na sua cabeca.',
      ptPt: 'Larga o que tens na cabeca.',
      fr: 'Laisse sortir ce que tu as en tete.',
      it: 'Lascia uscire quello che hai in testa.',
      de: 'Lass raus, was dir im Kopf ist.',
      ja: 'Drop what is in your head.',
      zhHans: 'Drop what is in your head.',
      zhHant: 'Drop what is in your head.',
    );

String _capturePromptTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Capture first. Sort later.',
      es: 'Captura primero. Ordena después.',
      ptBr: 'Capture primeiro. Organize depois.',
      ptPt: 'Captura primeiro. Organiza depois.',
      fr: 'Capture d abord. Trie ensuite.',
      it: 'Cattura prima. Ordina dopo.',
      de: 'Erfassen zuerst. Spater sortieren.',
      ja: 'Capture first. Sort later.',
      zhHans: 'Capture first. Sort later.',
      zhHant: 'Capture first. Sort later.',
    );

String _capturePromptBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'One sentence is enough. GoLife will split it into drafts and keep privacy per item.',
      es: 'Una frase basta. GoLife la separa en borradores y mantiene la privacidad por ítem.',
      ptBr:
          'Uma frase basta. O GoLife a separa em rascunhos e mantém a privacidade por item.',
      ptPt:
          'Uma frase basta. O GoLife separa-a em rascunhos e mantem a privacidade por item.',
      fr: 'Une phrase suffit. GoLife la separe en brouillons et garde la confidentialite par element.',
      it: 'Basta una frase. GoLife la separa in bozze e mantiene la privacy per voce.',
      de: 'Ein Satz reicht. GoLife teilt ihn in Entwuerfe und behaelt Privatsphaere pro Eintrag.',
      ja: 'One sentence is enough. GoLife will split it into drafts and keep privacy per item.',
      zhHans:
          'One sentence is enough. GoLife will split it into drafts and keep privacy per item.',
      zhHant:
          'One sentence is enough. GoLife will split it into drafts and keep privacy per item.',
    );

String _understandLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Understand',
      es: 'Entender',
      ptBr: 'Entender',
      ptPt: 'Entender',
      fr: 'Comprendre',
      it: 'Capire',
      de: 'Verstehen',
      ja: 'Understand',
      zhHans: 'Understand',
      zhHant: 'Understand',
    );

String _savedLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Saved',
      es: 'Guardado',
      ptBr: 'Guardado',
      ptPt: 'Guardado',
      fr: 'Enregistre',
      it: 'Salvato',
      de: 'Gespeichert',
      ja: 'Saved',
      zhHans: 'Saved',
      zhHant: 'Saved',
    );

String _savedBody(int count, AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'GoLife will refresh your missions with $count new item(s).',
      es: 'GoLife actualizará tus misiones con $count ítem(s) nuevo(s).',
      ptBr: 'O GoLife atualizara suas missoes com $count novo(s) item(ns).',
      ptPt: 'O GoLife atualizara as tuas missoes com $count novo(s) item(ns).',
      fr: 'GoLife mettra a jour tes missions avec $count nouvel element.',
      it: 'GoLife aggiornera le tue missioni con $count nuovi elementi.',
      de: 'GoLife aktualisiert deine Missionen mit $count neuen Eintraegen.',
      ja: 'GoLife will refresh your missions with $count new item(s).',
      zhHans: 'GoLife will refresh your missions with $count new item(s).',
      zhHant: 'GoLife will refresh your missions with $count new item(s).',
    );

String _viewUpdatedTodayLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'View updated Today',
      es: 'Ver Today actualizado',
      ptBr: 'Ver Today atualizado',
      ptPt: 'Ver Today atualizado',
      fr: 'Voir Today mis a jour',
      it: 'Vedi Today aggiornato',
      de: 'Aktualisiertes Today ansehen',
      ja: 'View updated Today',
      zhHans: 'View updated Today',
      zhHant: 'View updated Today',
    );

String _captureAnotherLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Capture another thing',
      es: 'Capturar otra cosa',
      ptBr: 'Capturar outra coisa',
      ptPt: 'Capturar outra coisa',
      fr: 'Capturer autre chose',
      it: 'Cattura altro',
      de: 'Noch etwas erfassen',
      ja: 'Capture another thing',
      zhHans: 'Capture another thing',
      zhHant: 'Capture another thing',
    );

String _confirmCaptureTitle(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Confirm capture',
      es: 'Confirmar captura',
      ptBr: 'Confirmar captura',
      ptPt: 'Confirmar captura',
      fr: 'Confirmer la capture',
      it: 'Conferma acquisizione',
      de: 'Erfassung bestaetigen',
      ja: 'Confirm capture',
      zhHans: 'Confirm capture',
      zhHant: 'Confirm capture',
    );

String _detectedCountLabel(int count, AppLocalizations l10n) =>
    pickLocalizedValue(
      l10n.localeName,
      en: 'Detected $count thing(s).',
      es: 'Detecté $count cosa(s).',
      ptBr: 'Detectei $count coisa(s).',
      ptPt: 'Detetei $count coisa(s).',
      fr: '$count element(s) detecte(s).',
      it: 'Rilevate $count cose.',
      de: '$count Eintraege erkannt.',
      ja: 'Detected $count thing(s).',
      zhHans: 'Detected $count thing(s).',
      zhHant: 'Detected $count thing(s).',
    );

String _recentEventsBody(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Recent memory helps you sanity-check what was just captured.',
      es: 'La memoria reciente te ayuda a revisar lo que acabas de capturar.',
      ptBr: 'A memoria recente ajuda a revisar o que acabou de ser capturado.',
      ptPt: 'A memoria recente ajuda a rever o que acabaste de capturar.',
      fr: 'La memoire recente aide a verifier ce qui vient d etre capture.',
      it: 'La memoria recente aiuta a controllare cio che hai appena catturato.',
      de: 'Die letzte Erinnerung hilft dir zu pruefen, was gerade erfasst wurde.',
      ja: 'Recent memory helps you sanity-check what was just captured.',
      zhHans: 'Recent memory helps you sanity-check what was just captured.',
      zhHant: 'Recent memory helps you sanity-check what was just captured.',
    );

String _bulkPrivacyLocalLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'All local',
      es: 'Todo local',
      ptBr: 'Tudo local',
      ptPt: 'Tudo local',
      fr: 'Tout en local',
      it: 'Tutto locale',
      de: 'Alles lokal',
      ja: 'All local',
      zhHans: 'All local',
      zhHant: 'All local',
    );

String _bulkPrivacyAiLabel(AppLocalizations l10n) => pickLocalizedValue(
      l10n.localeName,
      en: 'Allow AI',
      es: 'Permitir IA',
      ptBr: 'Permitir IA',
      ptPt: 'Permitir IA',
      fr: 'Autoriser IA',
      it: 'Consenti IA',
      de: 'KI erlauben',
      ja: 'Allow AI',
      zhHans: 'Allow AI',
      zhHant: 'Allow AI',
    );

String _draftEventTypeLabel(AppLocalizations l10n, CaptureDraftItem draft) {
  switch (draft.eventType) {
    case 'task_captured':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Task',
        es: 'Tarea',
        ptBr: 'Tarefa',
        ptPt: 'Tarefa',
        fr: 'Tache',
        it: 'Attivita',
        de: 'Aufgabe',
        ja: 'Task',
        zhHans: 'Task',
        zhHant: 'Task',
      );
    case 'habit_logged':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Habit',
        es: 'Habito',
        ptBr: 'Habito',
        ptPt: 'Habito',
        fr: 'Habitude',
        it: 'Abitudine',
        de: 'Gewohnheit',
        ja: 'Habit',
        zhHans: 'Habit',
        zhHant: 'Habit',
      );
    case 'expense_logged':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Expense',
        es: 'Gasto',
        ptBr: 'Gasto',
        ptPt: 'Gasto',
        fr: 'Depense',
        it: 'Spesa',
        de: 'Ausgabe',
        ja: 'Expense',
        zhHans: 'Expense',
        zhHant: 'Expense',
      );
    case 'ingredient_flagged':
      return pickLocalizedValue(
        l10n.localeName,
        en: 'Pantry',
        es: 'Pantry',
        ptBr: 'Pantry',
        ptPt: 'Pantry',
        fr: 'Pantry',
        it: 'Pantry',
        de: 'Pantry',
        ja: 'Pantry',
        zhHans: 'Pantry',
        zhHant: 'Pantry',
      );
    default:
      return draft.domain.localizedLabel(l10n);
  }
}
