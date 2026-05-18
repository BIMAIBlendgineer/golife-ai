import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localized_values.dart';
import '../../domains/calendar/calendar_item.dart';
import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/journal/journal_entry.dart';
import '../../domains/journal/quick_note.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/recipes/recipe_rescue.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';
import '../../l10n/app_localizations.dart';
import '../app_state/golife_controller.dart';
import '../shared/premium_ui.dart';

String _joinSegments(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' | ');
}

String _taskPriorityLabel(AppLocalizations l10n, TaskPriority priority) {
  switch (priority) {
    case TaskPriority.gentle:
      return l10n.priorityGentle;
    case TaskPriority.standard:
      return l10n.priorityStandard;
    case TaskPriority.critical:
      return l10n.priorityCritical;
  }
}

String _taskStatusLabel(AppLocalizations l10n, TaskStatus status) {
  switch (status) {
    case TaskStatus.inbox:
      return l10n.statusTaskInbox;
    case TaskStatus.active:
      return l10n.statusTaskActive;
    case TaskStatus.done:
      return l10n.statusTaskDone;
  }
}

String _habitCadenceLabel(AppLocalizations l10n, HabitCadence cadence) {
  switch (cadence) {
    case HabitCadence.daily:
      return l10n.cadenceDaily;
    case HabitCadence.weekdays:
      return l10n.cadenceWeekdays;
    case HabitCadence.weekly:
      return l10n.cadenceWeekly;
  }
}

String _recipeStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'cooked':
      return l10n.recipeStatusCooked;
    case 'draft':
    default:
      return l10n.recipeStatusDraft;
  }
}

String _dayPlanLabel(AppLocalizations l10n, String label) {
  if (label == 'Today') {
    return l10n.labelToday;
  }
  return label;
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navTasks,
      eyebrow: l10n.domainTasksEyebrow,
      description: l10n.domainTasksDescription,
      accent: const Color(0xFF1F4C5B),
      actions: [
        FilledButton.icon(
          onPressed: () => _showTaskEditor(context, controller),
          icon: const Icon(Icons.add_task_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityTask)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.tasksEmpty,
        children: controller.tasks
            .map((task) {
              return _EntityCard(
                title: task.title,
                subtitle: _joinSegments(<String>[
                  _taskPriorityLabel(l10n, task.priority),
                  l10n.taskTimeboxFirstBlock(task.estimatedMinutes),
                ]),
                chips: <String>[
                  _taskStatusLabel(l10n, task.status),
                  _taskPriorityLabel(l10n, task.priority),
                ],
                actionLabel: task.status == TaskStatus.done
                    ? l10n.actionDone
                    : l10n.actionComplete,
                onAction: task.status == TaskStatus.done
                    ? null
                    : () async =>
                          (await controller.completeTaskById(task.id)) ??
                          l10n.messageTaskUpdated,
                secondaryLabel: l10n.actionEdit,
                onSecondaryAction: () =>
                    _showTaskEditor(context, controller, task),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navHabits,
      eyebrow: l10n.domainHabitsEyebrow,
      description: l10n.domainHabitsDescription,
      accent: const Color(0xFF5D7A68),
      actions: [
        FilledButton.icon(
          onPressed: () => _showHabitEditor(context, controller),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityHabit)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.habitsEmpty,
        children: controller.habits
            .map((habit) {
              return _EntityCard(
                title: habit.title,
                subtitle: _joinSegments(<String>[
                  habit.cue,
                  l10n.habitStreakDays(habit.streak),
                ]),
                chips: <String>[_habitCadenceLabel(l10n, habit.cadence)],
                actionLabel: l10n.actionCheckIn,
                onAction: () async =>
                    (await controller.checkInHabitById(habit.id)) ??
                    l10n.messageHabitCheckedIn,
                secondaryLabel: l10n.actionEdit,
                onSecondaryAction: () =>
                    _showHabitEditor(context, controller, habit),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navMoney,
      eyebrow: l10n.domainMoneyEyebrow,
      description: l10n.domainMoneyDescription,
      accent: const Color(0xFF8A6C2F),
      actions: [
        FilledButton.icon(
          onPressed: () => _showExpenseEditor(context, controller),
          icon: const Icon(Icons.add_card_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityExpense)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.moneyEmpty,
        children: controller.expenses
            .map((expense) {
              return _EntityCard(
                title: expense.label,
                subtitle: expense.reflectionLabel,
                chips: <String>[expense.category],
                actionLabel: l10n.actionReflect,
                onAction: () async =>
                    (await controller.logExpenseTouchById(expense.id)) ??
                    l10n.messageExpenseRevisited,
                secondaryLabel: l10n.actionEdit,
                onSecondaryAction: () =>
                    _showExpenseEditor(context, controller, expense),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navPantry,
      eyebrow: l10n.domainPantryEyebrow,
      description: l10n.domainPantryDescription,
      accent: const Color(0xFF4C6A4F),
      actions: [
        FilledButton.icon(
          onPressed: () => _showPantryEditor(context, controller),
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityPantryItem)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.pantryEmpty,
        children: controller.pantryItems
            .map((item) {
              return _EntityCard(
                title: item.name,
                subtitle: _joinSegments(<String>[
                  item.quantityLabel,
                  item.rescueHint,
                ]),
                chips: <String>[l10n.chipRescue],
                actionLabel: item.quantityLabel == 'used'
                    ? l10n.actionUsed
                    : l10n.actionMarkUsed,
                onAction: item.quantityLabel == 'used'
                    ? null
                    : () async =>
                          (await controller.markPantryItemUsedById(item.id)) ??
                          l10n.messagePantryItemUpdated,
                secondaryLabel: l10n.actionEdit,
                onSecondaryAction: () =>
                    _showPantryEditor(context, controller, item),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class ClosetScreen extends StatelessWidget {
  const ClosetScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navCloset,
      eyebrow: l10n.domainClosetEyebrow,
      description: l10n.domainClosetDescription,
      accent: const Color(0xFF7A5167),
      actions: [
        FilledButton.icon(
          onPressed: () => _showClosetEditor(context, controller),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityPurchaseIntention)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.closetEmpty,
        children: controller.purchaseIntentions
            .map((item) {
              return _EntityCard(
                title: item.label,
                subtitle: item.reason,
                chips: <String>[l10n.chipPurchaseIntention],
                actionLabel: l10n.actionPause24h,
                onAction: () async =>
                    (await controller.pausePurchaseIntentionById(item.id)) ??
                    l10n.messagePurchaseIntentionPaused,
                secondaryLabel: l10n.actionEdit,
                onSecondaryAction: () =>
                    _showClosetEditor(context, controller, item),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navWeek,
      eyebrow: l10n.domainWeekEyebrow,
      description: l10n.domainWeekDescription,
      accent: const Color(0xFF5D7A68),
      actions: [
        FilledButton.icon(
          onPressed: () => _showWeekEditor(context, controller),
          icon: const Icon(Icons.edit_calendar_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityWeekPlan)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.weekEmpty,
        children: controller.weekPlans
            .map((plan) {
              return _EntityCard(
                title: plan.theme,
                subtitle: plan.energyNote,
                chips: plan.days
                    .map((day) => _dayPlanLabel(l10n, day.label))
                    .toList(growable: false),
                actionLabel: l10n.actionReplan,
                onAction: () async =>
                    (await controller.refreshWeekPlanById(plan.id)) ??
                    l10n.messageWeekPlanUpdated,
                secondaryLabel: l10n.actionEdit,
                onSecondaryAction: () =>
                    _showWeekEditor(context, controller, plan),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navJournal,
      eyebrow: l10n.domainJournalEyebrow,
      description: l10n.domainJournalDescription,
      accent: const Color(0xFF6A5A4B),
      actions: [
        FilledButton.icon(
          onPressed: () => _showJournalEditor(context, controller),
          icon: const Icon(Icons.menu_book_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityJournalEntry)),
        ),
        FilledButton.tonalIcon(
          onPressed: () => _showQuickNoteEditor(context, controller),
          icon: const Icon(Icons.note_add_outlined),
          label: Text(l10n.actionNewEntity(l10n.entityQuickNote)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EntityList(
            emptyLabel: l10n.journalEmpty,
            children: controller.journalEntries
                .map((entry) {
                  return _EntityCard(
                    title: entry.title,
                    subtitle: _joinSegments(<String>[entry.mood, entry.body]),
                    chips: <String>[l10n.chipJournal, l10n.chipLocalOnly],
                    actionLabel: l10n.actionReview,
                    onAction: () async => l10n.messageJournalLocalOnly,
                    secondaryLabel: l10n.actionEdit,
                    onSecondaryAction: () =>
                        _showJournalEditor(context, controller, entry),
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.journalQuickNotesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _EntityList(
            emptyLabel: l10n.quickNotesEmpty,
            children: controller.quickNotes
                .map((note) {
                  return _EntityCard(
                    title: note.text,
                    subtitle: note.createdAtIso,
                    chips: <String>[l10n.chipNote, l10n.chipLocalOnly],
                    actionLabel: l10n.actionKeepLocal,
                    onAction: () async => l10n.messageNoteLocalOnly,
                    secondaryLabel: l10n.actionEdit,
                    onSecondaryAction: () =>
                        _showQuickNoteEditor(context, controller, note),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navCalendar,
      eyebrow: l10n.domainCalendarEyebrow,
      description: l10n.domainCalendarDescription,
      accent: const Color(0xFF406A7C),
      topPanel: controller.hasOverloadedCalendarDay
          ? _InfoPanel(
              title: l10n.calendarOverloadTitle,
              body: l10n.calendarOverloadBody,
            )
          : _InfoPanel(
              title: l10n.calendarCalmTitle,
              body: l10n.calendarCalmBody,
            ),
      actions: [
        FilledButton.icon(
          onPressed: () => _showCalendarEditor(context, controller),
          icon: const Icon(Icons.add_alarm_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityCalendarItem)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.calendarEmpty,
        children: controller.calendarItems
            .map((item) {
              return _EntityCard(
                title: item.title,
                subtitle: _joinSegments(<String>[item.startIso, item.endIso]),
                chips: <String>[
                  item.energy,
                  if (item.location.isNotEmpty) item.location,
                ],
                actionLabel: l10n.actionEdit,
                onAction: () async {
                  _showCalendarEditor(context, controller, item);
                  return l10n.messageOpeningEditor;
                },
                secondaryLabel: l10n.actionTimeBlock,
                onSecondaryAction: () =>
                    _showCalendarEditor(context, controller, item),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navRecipes,
      eyebrow: l10n.domainRecipesEyebrow,
      description: l10n.domainRecipesDescription,
      accent: const Color(0xFF855A2B),
      actions: [
        FilledButton.icon(
          onPressed: () => _showRecipeEditor(context, controller),
          icon: const Icon(Icons.restaurant_menu_rounded),
          label: Text(l10n.actionNewEntity(l10n.entityRecipeRescue)),
        ),
      ],
      child: _EntityList(
        emptyLabel: l10n.recipesEmpty,
        children: controller.recipeRescues
            .map((recipe) {
              return _EntityCard(
                title: recipe.title,
                subtitle: _joinSegments(<String>[
                  recipe.summary,
                  '${recipe.estimatedMinutes} ${l10n.unitMinutesShort}',
                  recipe.ingredientNames.join(', '),
                ]),
                chips: <String>[_recipeStatusLabel(l10n, recipe.status)],
                actionLabel: recipe.status == 'cooked'
                    ? l10n.actionCooked
                    : l10n.actionCookNow,
                onAction: recipe.status == 'cooked'
                    ? null
                    : () async =>
                          (await controller.markRecipeRescueCookedById(
                            recipe.id,
                          )) ??
                          l10n.messageRecipeUpdated,
                secondaryLabel: l10n.actionEdit,
                onSecondaryAction: () =>
                    _showRecipeEditor(context, controller, recipe),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class EverydayScreen extends StatelessWidget {
  const EverydayScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _DomainScreen(
      title: l10n.navEveryday,
      eyebrow: l10n.domainEverydayEyebrow,
      description: l10n.domainEverydayDescription,
      accent: const Color(0xFF6A5A4B),
      topPanel: _InfoPanel(
        title: l10n.everydayContextTitle,
        body: l10n.everydayContextBody,
      ),
      child: Column(
        children: [
          _NavigationCard(
            title: l10n.navJournal,
            subtitle: l10n.everydayJournalSubtitle(
              controller.journalEntries.length,
              controller.quickNotes.length,
            ),
            body: l10n.everydayJournalBody,
            actionLabel: l10n.actionOpenJournal,
            onTap: () => context.go('/journal'),
          ),
          _NavigationCard(
            title: l10n.navCalendar,
            subtitle: l10n.everydayCalendarSubtitle(
              controller.calendarItems.length,
              controller.hasOverloadedCalendarDay
                  ? l10n.overloadDetected
                  : l10n.overloadNotDetected,
            ),
            body: l10n.everydayCalendarBody,
            actionLabel: l10n.actionOpenCalendar,
            onTap: () => context.go('/calendar'),
          ),
          _NavigationCard(
            title: l10n.navRecipes,
            subtitle: l10n.everydayRecipesSubtitle(
              controller.recipeRescues.length,
            ),
            body: l10n.everydayRecipesBody,
            actionLabel: l10n.actionOpenRecipes,
            onTap: () => context.go('/recipes'),
          ),
          _NavigationCard(
            title: l10n.homeMemoryTitle,
            subtitle: l10n.homeMemoryEverydaySubtitle(
              controller.ownedItems.length,
              controller.warrantyEndingSoonItems.length,
            ),
            body: l10n.homeMemoryEverydayBody,
            actionLabel: l10n.homeMemoryActionOpen,
            onTap: () => context.go('/homememory'),
          ),
        ],
      ),
    );
  }
}

class _DomainScreen extends StatelessWidget {
  const _DomainScreen({
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.accent,
    required this.child,
    this.actions = const <Widget>[],
    this.topPanel,
  });

  final String title;
  final String eyebrow;
  final String description;
  final Color accent;
  final Widget child;
  final List<Widget> actions;
  final Widget? topPanel;

  @override
  Widget build(BuildContext context) {
    return GoLifeScreen(
      title: title,
      subtitle: description,
      badge: GoLifeStatusPill(
        label: eyebrow,
        icon: Icons.auto_awesome_motion_rounded,
        accent: _toneForAccent(accent),
      ),
      children: [
        if (actions.isNotEmpty)
          GoLifeCard(
            accent: _toneForAccent(accent),
            child: Wrap(spacing: 10, runSpacing: 10, children: actions),
          ),
        if (actions.isNotEmpty) const SizedBox(height: 16),
        if (topPanel != null) ...[topPanel!, const SizedBox(height: 16)],
        GoLifeCard(accent: _toneForAccent(accent), child: child),
      ],
    );
  }
}

class _EntityList extends StatelessWidget {
  const _EntityList({required this.emptyLabel, required this.children});

  final String emptyLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return GoLifeEmptyState(
        title: emptyLabel,
        body: _emptyBody(AppLocalizations.of(context)!),
        icon: Icons.inbox_outlined,
      );
    }
    return Column(children: children);
  }
}

class _EntityCard extends StatelessWidget {
  const _EntityCard({
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String subtitle;
  final List<String> chips;
  final String actionLabel;
  final Future<String> Function()? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GoLifeCard(
      accent: GoLifeAccent.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .where((chip) => chip.trim().isNotEmpty)
                .map((chip) => Chip(label: Text(chip)))
                .toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonal(
                onPressed: onAction == null
                    ? null
                    : () async {
                        final message = await onAction!.call();
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                child: Text(actionLabel),
              ),
              if (secondaryLabel != null)
                OutlinedButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GoLifeCard(
      accent: GoLifeAccent.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String body;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GoLifeCard(
      accent: GoLifeAccent.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

GoLifeAccent _toneForAccent(Color accent) {
  if (accent == const Color(0xFF4C6A4F) || accent == const Color(0xFF5D7A68)) {
    return GoLifeAccent.emerald;
  }
  if (accent == const Color(0xFF8A6C2F) || accent == const Color(0xFF855A2B)) {
    return GoLifeAccent.amber;
  }
  if (accent == const Color(0xFF7A5167)) {
    return GoLifeAccent.danger;
  }
  return GoLifeAccent.blue;
}

String _emptyBody(AppLocalizations l10n) => pickLocalizedValue(
  l10n.localeName,
  en: 'This domain stays available here, but does not need to dominate navigation.',
  es: 'Este dominio sigue disponible aqui, pero no necesita dominar la navegacion.',
  ptBr:
      'Este dominio continua disponivel aqui, mas nao precisa dominar a navegacao.',
  ptPt:
      'Este dominio continua disponivel aqui, mas nao precisa dominar a navegacao.',
  fr: 'Ce domaine reste disponible ici, mais n a pas besoin de dominer la navigation.',
  it: 'Questo dominio resta disponibile qui, ma non deve dominare la navigazione.',
  de: 'Dieser Bereich bleibt hier verfuegbar, muss aber die Navigation nicht dominieren.',
  ja: 'This domain stays available here, but does not need to dominate navigation.',
  zhHans:
      'This domain stays available here, but does not need to dominate navigation.',
  zhHant:
      'This domain stays available here, but does not need to dominate navigation.',
);

Future<void> _showTaskEditor(
  BuildContext context,
  GoLifeController controller, [
  GoTask? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final titleController = TextEditingController(text: existing?.title ?? '');
  final minutesController = TextEditingController(
    text: (existing?.estimatedMinutes ?? 15).toString(),
  );
  final notesController = TextEditingController(text: existing?.notes ?? '');
  TaskPriority priority = existing?.priority ?? TaskPriority.standard;
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityTask)
        : l10n.actionEditEntity(l10n.entityTask),
    builder: (setState) => [
      TextField(
        controller: titleController,
        decoration: InputDecoration(labelText: l10n.fieldTitle),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: minutesController,
        decoration: InputDecoration(labelText: l10n.fieldEstimatedMinutes),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<TaskPriority>(
        initialValue: priority,
        decoration: InputDecoration(labelText: l10n.fieldPriority),
        items: TaskPriority.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(_taskPriorityLabel(l10n, value)),
              ),
            )
            .toList(growable: false),
        onChanged: (value) =>
            setState(() => priority = value ?? TaskPriority.standard),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: notesController,
        decoration: InputDecoration(labelText: l10n.fieldNotes),
        minLines: 2,
        maxLines: 3,
      ),
    ],
    onSave: () async {
      final message = await controller.saveTask(
        id: existing?.id,
        title: titleController.text.trim(),
        priority: priority,
        estimatedMinutes: int.tryParse(minutesController.text.trim()) ?? 15,
        notes: notesController.text.trim(),
        status: existing?.status ?? TaskStatus.inbox,
      );
      return message ?? l10n.messageEntitySaved(l10n.entityTask);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteTaskById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityTask);
          },
  );
}

Future<void> _showHabitEditor(
  BuildContext context,
  GoLifeController controller, [
  Habit? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final titleController = TextEditingController(text: existing?.title ?? '');
  final cueController = TextEditingController(text: existing?.cue ?? '');
  HabitCadence cadence = existing?.cadence ?? HabitCadence.daily;
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityHabit)
        : l10n.actionEditEntity(l10n.entityHabit),
    builder: (setState) => [
      TextField(
        controller: titleController,
        decoration: InputDecoration(labelText: l10n.fieldTitle),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: cueController,
        decoration: InputDecoration(labelText: l10n.fieldCue),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<HabitCadence>(
        initialValue: cadence,
        decoration: InputDecoration(labelText: l10n.fieldCadence),
        items: HabitCadence.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(_habitCadenceLabel(l10n, value)),
              ),
            )
            .toList(growable: false),
        onChanged: (value) =>
            setState(() => cadence = value ?? HabitCadence.daily),
      ),
    ],
    onSave: () async {
      final message = await controller.saveHabit(
        id: existing?.id,
        title: titleController.text.trim(),
        cue: cueController.text.trim(),
        cadence: cadence,
        streak: existing?.streak ?? 0,
      );
      return message ?? l10n.messageEntitySaved(l10n.entityHabit);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteHabitById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityHabit);
          },
  );
}

Future<void> _showExpenseEditor(
  BuildContext context,
  GoLifeController controller, [
  ExpenseRecord? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final labelController = TextEditingController(text: existing?.label ?? '');
  final amountController = TextEditingController(
    text: (existing?.amount ?? 0).toString(),
  );
  final categoryController = TextEditingController(
    text: existing?.category ?? 'general',
  );
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityExpense)
        : l10n.actionEditEntity(l10n.entityExpense),
    builder: (_) => [
      TextField(
        controller: labelController,
        decoration: InputDecoration(labelText: l10n.fieldLabel),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: amountController,
        decoration: InputDecoration(labelText: l10n.fieldAmount),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: categoryController,
        decoration: InputDecoration(labelText: l10n.fieldCategory),
      ),
    ],
    onSave: () async {
      final message = await controller.saveExpense(
        id: existing?.id,
        label: labelController.text.trim(),
        amount:
            double.tryParse(
              amountController.text.trim().replaceAll(',', '.'),
            ) ??
            0,
        category: categoryController.text.trim(),
      );
      return message ?? l10n.messageEntitySaved(l10n.entityExpense);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteExpenseById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityExpense);
          },
  );
}

Future<void> _showPantryEditor(
  BuildContext context,
  GoLifeController controller, [
  PantryItem? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final nameController = TextEditingController(text: existing?.name ?? '');
  final quantityController = TextEditingController(
    text: existing?.quantityLabel ?? '1 captured item',
  );
  final hintController = TextEditingController(
    text: existing?.rescueHint ?? '',
  );
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityPantryItem)
        : l10n.actionEditEntity(l10n.entityPantryItem),
    builder: (_) => [
      TextField(
        controller: nameController,
        decoration: InputDecoration(labelText: l10n.fieldName),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: quantityController,
        decoration: InputDecoration(labelText: l10n.fieldQuantity),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: hintController,
        decoration: InputDecoration(labelText: l10n.fieldRescueHint),
        minLines: 2,
        maxLines: 3,
      ),
    ],
    onSave: () async {
      final message = await controller.savePantryItem(
        id: existing?.id,
        name: nameController.text.trim(),
        quantityLabel: quantityController.text.trim(),
        rescueHint: hintController.text.trim(),
      );
      return message ?? l10n.messageEntitySaved(l10n.entityPantryItem);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deletePantryItemById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityPantryItem);
          },
  );
}

Future<void> _showClosetEditor(
  BuildContext context,
  GoLifeController controller, [
  PurchaseIntention? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final labelController = TextEditingController(text: existing?.label ?? '');
  final reasonController = TextEditingController(text: existing?.reason ?? '');
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityPurchaseIntention)
        : l10n.actionEditEntity(l10n.entityPurchaseIntention),
    builder: (_) => [
      TextField(
        controller: labelController,
        decoration: InputDecoration(labelText: l10n.fieldLabel),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: reasonController,
        decoration: InputDecoration(labelText: l10n.fieldReason),
        minLines: 2,
        maxLines: 3,
      ),
    ],
    onSave: () async {
      final message = await controller.savePurchaseIntention(
        id: existing?.id,
        label: labelController.text.trim(),
        reason: reasonController.text.trim(),
      );
      return message ?? l10n.messageEntitySaved(l10n.entityPurchaseIntention);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deletePurchaseIntentionById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityPurchaseIntention);
          },
  );
}

Future<void> _showWeekEditor(
  BuildContext context,
  GoLifeController controller, [
  WeekPlan? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final themeController = TextEditingController(text: existing?.theme ?? '');
  final focusController = TextEditingController(
    text: existing?.energyNote ?? '',
  );
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityWeekPlan)
        : l10n.actionEditEntity(l10n.entityWeekPlan),
    builder: (_) => [
      TextField(
        controller: themeController,
        decoration: InputDecoration(labelText: l10n.fieldTheme),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: focusController,
        decoration: InputDecoration(labelText: l10n.fieldFocus),
        minLines: 2,
        maxLines: 3,
      ),
    ],
    onSave: () async {
      final message = await controller.saveWeekPlan(
        id: existing?.id,
        theme: themeController.text.trim(),
        focus: focusController.text.trim(),
        colorToken: existing?.colorToken ?? 'terra',
      );
      return message ?? l10n.messageEntitySaved(l10n.entityWeekPlan);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteWeekPlanById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityWeekPlan);
          },
  );
}

Future<void> _showJournalEditor(
  BuildContext context,
  GoLifeController controller, [
  JournalEntry? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final titleController = TextEditingController(text: existing?.title ?? '');
  final bodyController = TextEditingController(text: existing?.body ?? '');
  final moodController = TextEditingController(
    text: existing?.mood ?? 'steady',
  );
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityJournalEntry)
        : l10n.actionEditEntity(l10n.entityJournalEntry),
    builder: (_) => [
      TextField(
        controller: titleController,
        decoration: InputDecoration(labelText: l10n.fieldTitle),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: moodController,
        decoration: InputDecoration(labelText: l10n.fieldMood),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: bodyController,
        decoration: InputDecoration(labelText: l10n.fieldBody),
        minLines: 4,
        maxLines: 6,
      ),
    ],
    onSave: () async {
      final message = await controller.saveJournalEntry(
        id: existing?.id,
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        mood: moodController.text.trim(),
      );
      return message ?? l10n.messageEntitySaved(l10n.entityJournalEntry);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteJournalEntryById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityJournalEntry);
          },
  );
}

Future<void> _showQuickNoteEditor(
  BuildContext context,
  GoLifeController controller, [
  QuickNote? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final textController = TextEditingController(text: existing?.text ?? '');
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityQuickNote)
        : l10n.actionEditEntity(l10n.entityQuickNote),
    builder: (_) => [
      TextField(
        controller: textController,
        decoration: InputDecoration(labelText: l10n.fieldNote),
        minLines: 3,
        maxLines: 5,
      ),
    ],
    onSave: () async {
      final message = await controller.saveQuickNote(
        id: existing?.id,
        text: textController.text.trim(),
      );
      return message ?? l10n.messageEntitySaved(l10n.entityQuickNote);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteQuickNoteById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityQuickNote);
          },
  );
}

Future<void> _showCalendarEditor(
  BuildContext context,
  GoLifeController controller, [
  CalendarItem? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final titleController = TextEditingController(text: existing?.title ?? '');
  final startController = TextEditingController(
    text: existing?.startIso ?? DateTime.now().toUtc().toIso8601String(),
  );
  final endController = TextEditingController(
    text:
        existing?.endIso ??
        DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
  );
  final locationController = TextEditingController(
    text: existing?.location ?? '',
  );
  final energyController = TextEditingController(
    text: existing?.energy ?? 'steady',
  );
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityCalendarItem)
        : l10n.actionEditEntity(l10n.entityCalendarItem),
    builder: (_) => [
      TextField(
        controller: titleController,
        decoration: InputDecoration(labelText: l10n.fieldTitle),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: startController,
        decoration: InputDecoration(labelText: l10n.fieldStartIso),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: endController,
        decoration: InputDecoration(labelText: l10n.fieldEndIso),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: locationController,
        decoration: InputDecoration(labelText: l10n.fieldLocation),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: energyController,
        decoration: InputDecoration(labelText: l10n.fieldEnergy),
      ),
    ],
    onSave: () async {
      final message = await controller.saveCalendarItem(
        id: existing?.id,
        title: titleController.text.trim(),
        startIso: startController.text.trim(),
        endIso: endController.text.trim(),
        location: locationController.text.trim(),
        energy: energyController.text.trim(),
      );
      return message ?? l10n.messageEntitySaved(l10n.entityCalendarItem);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteCalendarItemById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityCalendarItem);
          },
  );
}

Future<void> _showRecipeEditor(
  BuildContext context,
  GoLifeController controller, [
  RecipeRescue? existing,
]) {
  final l10n = AppLocalizations.of(context)!;
  final titleController = TextEditingController(text: existing?.title ?? '');
  final summaryController = TextEditingController(
    text: existing?.summary ?? '',
  );
  final ingredientsController = TextEditingController(
    text: existing?.ingredientNames.join(', ') ?? '',
  );
  final minutesController = TextEditingController(
    text: (existing?.estimatedMinutes ?? 15).toString(),
  );
  return _showEditorDialog(
    context,
    title: existing == null
        ? l10n.actionNewEntity(l10n.entityRecipeRescue)
        : l10n.actionEditEntity(l10n.entityRecipeRescue),
    builder: (_) => [
      TextField(
        controller: titleController,
        decoration: InputDecoration(labelText: l10n.fieldTitle),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: summaryController,
        decoration: InputDecoration(labelText: l10n.fieldSummary),
        minLines: 2,
        maxLines: 4,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: ingredientsController,
        decoration: InputDecoration(
          labelText: l10n.fieldIngredientsCommaSeparated,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: minutesController,
        decoration: InputDecoration(labelText: l10n.fieldEstimatedMinutes),
        keyboardType: TextInputType.number,
      ),
    ],
    onSave: () async {
      final message = await controller.saveRecipeRescue(
        id: existing?.id,
        title: titleController.text.trim(),
        summary: summaryController.text.trim(),
        ingredientNames: ingredientsController.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false),
        estimatedMinutes: int.tryParse(minutesController.text.trim()) ?? 15,
        status: existing?.status ?? 'draft',
      );
      return message ?? l10n.messageEntitySaved(l10n.entityRecipeRescue);
    },
    deleteLabel: existing == null ? null : l10n.actionDelete,
    onDelete: existing == null
        ? null
        : () async {
            await controller.deleteRecipeRescueById(existing.id);
            return l10n.messageEntityDeleted(l10n.entityRecipeRescue);
          },
  );
}

Future<void> _showEditorDialog(
  BuildContext context, {
  required String title,
  required List<Widget> Function(void Function(VoidCallback fn) setState)
  builder,
  required Future<String> Function() onSave,
  String? deleteLabel,
  Future<String> Function()? onDelete,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      bool saving = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: builder(setState),
                ),
              ),
            ),
            actions: [
              if (deleteLabel != null && onDelete != null)
                TextButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          final message = await onDelete();
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(dialogContext).colorScheme.error,
                  ),
                  child: Text(deleteLabel),
                ),
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(() => saving = true);
                        final message = await onSave();
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(
                            dialogContext,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                child: Text(saving ? l10n.actionSaving : l10n.actionSave),
              ),
            ],
          );
        },
      );
    },
  );
}
