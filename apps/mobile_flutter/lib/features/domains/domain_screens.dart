import 'package:flutter/material.dart';

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
import '../app_state/golife_controller.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Tasks',
      eyebrow: 'Execution',
      description:
          'TaskDoctor is now a local-first task board with direct create, edit, and complete flows.',
      accent: const Color(0xFF1F4C5B),
      actions: [
        FilledButton.icon(
          onPressed: () => _showTaskEditor(context, controller),
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('New task'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No tasks captured yet.',
        children: controller.tasks.map((task) {
          return _EntityCard(
            title: task.title,
            subtitle: '${task.priorityLabel} · ${task.timeboxLabel}',
            chips: <String>[task.status.name, task.priority.name],
            actionLabel: task.status == TaskStatus.done ? 'Done' : 'Complete',
            onAction: task.status == TaskStatus.done
                ? null
                : () async =>
                    (await controller.completeTaskById(task.id)) ??
                    'Task updated.',
            secondaryLabel: 'Edit',
            onSecondaryAction: () => _showTaskEditor(context, controller, task),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Habits',
      eyebrow: 'Continuity',
      description:
          'LifeQuest now supports direct habit creation and recovery-friendly check-ins.',
      accent: const Color(0xFF5D7A68),
      actions: [
        FilledButton.icon(
          onPressed: () => _showHabitEditor(context, controller),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New habit'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No habits captured yet.',
        children: controller.habits.map((habit) {
          return _EntityCard(
            title: habit.title,
            subtitle: '${habit.cue} · ${habit.streakLabel}',
            chips: <String>[habit.cadence.name],
            actionLabel: 'Check in',
            onAction: () async =>
                (await controller.checkInHabitById(habit.id)) ??
                'Habit checked in.',
            secondaryLabel: 'Edit',
            onSecondaryAction: () =>
                _showHabitEditor(context, controller, habit),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Money',
      eyebrow: 'Awareness',
      description:
          'MoneyMirror stays conservative: log, edit, and reflect locally without crossing into regulated advice.',
      accent: const Color(0xFF8A6C2F),
      actions: [
        FilledButton.icon(
          onPressed: () => _showExpenseEditor(context, controller),
          icon: const Icon(Icons.add_card_rounded),
          label: const Text('New expense'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No expenses captured yet.',
        children: controller.expenses.map((expense) {
          return _EntityCard(
            title: expense.label,
            subtitle: expense.reflectionLabel,
            chips: <String>[expense.category],
            actionLabel: 'Reflect',
            onAction: () async =>
                (await controller.logExpenseTouchById(expense.id)) ??
                'Expense revisited.',
            secondaryLabel: 'Edit',
            onSecondaryAction: () =>
                _showExpenseEditor(context, controller, expense),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Pantry',
      eyebrow: 'Rescue',
      description:
          'FridgeZero now keeps a rescue board where ingredients can be created, edited, and marked used.',
      accent: const Color(0xFF4C6A4F),
      actions: [
        FilledButton.icon(
          onPressed: () => _showPantryEditor(context, controller),
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: const Text('New item'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No pantry items captured yet.',
        children: controller.pantryItems.map((item) {
          return _EntityCard(
            title: item.name,
            subtitle: '${item.quantityLabel} · ${item.rescueHint}',
            chips: const <String>['rescue'],
            actionLabel: item.quantityLabel == 'used' ? 'Used' : 'Mark used',
            onAction: item.quantityLabel == 'used'
                ? null
                : () async =>
                    (await controller.markPantryItemUsedById(item.id)) ??
                    'Pantry item updated.',
            secondaryLabel: 'Edit',
            onSecondaryAction: () =>
                _showPantryEditor(context, controller, item),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class ClosetScreen extends StatelessWidget {
  const ClosetScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Closet',
      eyebrow: 'Anti-consumption',
      description:
          'ClosetLess remains an intention-first board, now with editable pauses and purchase reasons.',
      accent: const Color(0xFF7A5167),
      actions: [
        FilledButton.icon(
          onPressed: () => _showClosetEditor(context, controller),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('New intention'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No purchase intentions captured yet.',
        children: controller.purchaseIntentions.map((item) {
          return _EntityCard(
            title: item.label,
            subtitle: item.reason,
            chips: const <String>['purchase_intention'],
            actionLabel: 'Pause 24h',
            onAction: () async =>
                (await controller.pausePurchaseIntentionById(item.id)) ??
                'Purchase intention paused.',
            secondaryLabel: 'Edit',
            onSecondaryAction: () =>
                _showClosetEditor(context, controller, item),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Week',
      eyebrow: 'Planner',
      description:
          'WeekPilot stays intentionally light, but now supports quick creation and direct replanning.',
      accent: const Color(0xFF5D7A68),
      actions: [
        FilledButton.icon(
          onPressed: () => _showWeekEditor(context, controller),
          icon: const Icon(Icons.edit_calendar_rounded),
          label: const Text('New plan'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No week plans captured yet.',
        children: controller.weekPlans.map((plan) {
          return _EntityCard(
            title: plan.theme,
            subtitle: plan.energyNote,
            chips: plan.days.map((day) => day.label).toList(growable: false),
            actionLabel: 'Replan',
            onAction: () async =>
                (await controller.refreshWeekPlanById(plan.id)) ??
                'Week plan updated.',
            secondaryLabel: 'Edit',
            onSecondaryAction: () => _showWeekEditor(context, controller, plan),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Journal',
      eyebrow: 'Private by default',
      description:
          'Journal and notes stay local-first so the app can learn from your day without turning into therapy.',
      accent: const Color(0xFF6A5A4B),
      actions: [
        FilledButton.icon(
          onPressed: () => _showJournalEditor(context, controller),
          icon: const Icon(Icons.menu_book_rounded),
          label: const Text('New entry'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => _showQuickNoteEditor(context, controller),
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('Quick note'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EntityList(
            emptyLabel: 'No journal entries yet.',
            children: controller.journalEntries.map((entry) {
              return _EntityCard(
                title: entry.title,
                subtitle: '${entry.mood} · ${entry.body}',
                chips: const <String>['journal', 'local_only'],
                actionLabel: 'Review',
                onAction: () async => 'Journal stays local on this device.',
                secondaryLabel: 'Edit',
                onSecondaryAction: () =>
                    _showJournalEditor(context, controller, entry),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 20),
          Text(
            'Quick notes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _EntityList(
            emptyLabel: 'No quick notes yet.',
            children: controller.quickNotes.map((note) {
              return _EntityCard(
                title: note.text,
                subtitle: note.createdAtIso,
                chips: const <String>['note', 'local_only'],
                actionLabel: 'Keep local',
                onAction: () async => 'Note stays local on this device.',
                secondaryLabel: 'Edit',
                onSecondaryAction: () =>
                    _showQuickNoteEditor(context, controller, note),
              );
            }).toList(growable: false),
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
    return _DomainScreen(
      title: 'Calendar',
      eyebrow: 'QuickCal',
      description:
          'QuickCal starts as a fast local layer for time blocks and overload detection, not a full sync engine.',
      accent: const Color(0xFF406A7C),
      topPanel: controller.hasOverloadedCalendarDay
          ? const _InfoPanel(
              title: 'Overload detected',
              body:
                  'There are already four or more local calendar items. Protect the smallest non-critical block first.',
            )
          : const _InfoPanel(
              title: 'Calm calendar',
              body:
                  'Use QuickCal for fast local blocks before adding full calendar sync.',
            ),
      actions: [
        FilledButton.icon(
          onPressed: () => _showCalendarEditor(context, controller),
          icon: const Icon(Icons.add_alarm_rounded),
          label: const Text('New block'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No calendar items yet.',
        children: controller.calendarItems.map((item) {
          return _EntityCard(
            title: item.title,
            subtitle: '${item.startIso} → ${item.endIso}',
            chips: <String>[
              item.energy,
              if (item.location.isNotEmpty) item.location
            ],
            actionLabel: 'Edit',
            onAction: () async {
              _showCalendarEditor(context, controller, item);
              return 'Opening editor.';
            },
            secondaryLabel: 'Time block',
            onSecondaryAction: () =>
                _showCalendarEditor(context, controller, item),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key, required this.controller});

  final GoLifeController controller;

  @override
  Widget build(BuildContext context) {
    return _DomainScreen(
      title: 'Recipes',
      eyebrow: 'Recipe Rescue',
      description:
          'Recipe Rescue turns pantry context into simple local meal plans that can mark ingredients as used.',
      accent: const Color(0xFF855A2B),
      actions: [
        FilledButton.icon(
          onPressed: () => _showRecipeEditor(context, controller),
          icon: const Icon(Icons.restaurant_menu_rounded),
          label: const Text('New recipe'),
        ),
      ],
      child: _EntityList(
        emptyLabel: 'No recipe rescues yet.',
        children: controller.recipeRescues.map((recipe) {
          return _EntityCard(
            title: recipe.title,
            subtitle:
                '${recipe.summary} · ${recipe.estimatedMinutes} min · ${recipe.ingredientNames.join(', ')}',
            chips: <String>[recipe.status],
            actionLabel: recipe.status == 'cooked' ? 'Cooked' : 'Cook now',
            onAction: recipe.status == 'cooked'
                ? null
                : () async =>
                    (await controller.markRecipeRescueCookedById(recipe.id)) ??
                    'Recipe rescue updated.',
            secondaryLabel: 'Edit',
            onSecondaryAction: () =>
                _showRecipeEditor(context, controller, recipe),
          );
        }).toList(growable: false),
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
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(description, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              if (actions.isNotEmpty) const SizedBox(width: 16),
              if (actions.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: actions,
                ),
            ],
          ),
          if (topPanel != null) ...[
            const SizedBox(height: 20),
            topPanel!,
          ],
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _EntityList extends StatelessWidget {
  const _EntityList({
    required this.emptyLabel,
    required this.children,
  });

  final String emptyLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Text(emptyLabel, style: Theme.of(context).textTheme.bodyLarge);
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
      ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
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
  const _InfoPanel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

Future<void> _showTaskEditor(
  BuildContext context,
  GoLifeController controller, [
  GoTask? existing,
]) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final minutesController = TextEditingController(
    text: (existing?.estimatedMinutes ?? 15).toString(),
  );
  final notesController = TextEditingController(text: existing?.notes ?? '');
  TaskPriority priority = existing?.priority ?? TaskPriority.standard;
  return _showEditorDialog(
    context,
    title: existing == null ? 'New task' : 'Edit task',
    builder: (setState) => [
      TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title')),
      const SizedBox(height: 12),
      TextField(
        controller: minutesController,
        decoration: const InputDecoration(labelText: 'Estimated minutes'),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<TaskPriority>(
        initialValue: priority,
        decoration: const InputDecoration(labelText: 'Priority'),
        items: TaskPriority.values
            .map((value) =>
                DropdownMenuItem(value: value, child: Text(value.name)))
            .toList(growable: false),
        onChanged: (value) =>
            setState(() => priority = value ?? TaskPriority.standard),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: notesController,
        decoration: const InputDecoration(labelText: 'Notes'),
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
      return message ?? 'Task saved.';
    },
  );
}

Future<void> _showHabitEditor(
  BuildContext context,
  GoLifeController controller, [
  Habit? existing,
]) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final cueController = TextEditingController(text: existing?.cue ?? '');
  HabitCadence cadence = existing?.cadence ?? HabitCadence.daily;
  return _showEditorDialog(
    context,
    title: existing == null ? 'New habit' : 'Edit habit',
    builder: (setState) => [
      TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title')),
      const SizedBox(height: 12),
      TextField(
          controller: cueController,
          decoration: const InputDecoration(labelText: 'Cue')),
      const SizedBox(height: 12),
      DropdownButtonFormField<HabitCadence>(
        initialValue: cadence,
        decoration: const InputDecoration(labelText: 'Cadence'),
        items: HabitCadence.values
            .map((value) =>
                DropdownMenuItem(value: value, child: Text(value.name)))
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
      return message ?? 'Habit saved.';
    },
  );
}

Future<void> _showExpenseEditor(
  BuildContext context,
  GoLifeController controller, [
  ExpenseRecord? existing,
]) {
  final labelController = TextEditingController(text: existing?.label ?? '');
  final amountController = TextEditingController(
    text: (existing?.amount ?? 0).toString(),
  );
  final categoryController =
      TextEditingController(text: existing?.category ?? 'general');
  return _showEditorDialog(
    context,
    title: existing == null ? 'New expense' : 'Edit expense',
    builder: (_) => [
      TextField(
          controller: labelController,
          decoration: const InputDecoration(labelText: 'Label')),
      const SizedBox(height: 12),
      TextField(
        controller: amountController,
        decoration: const InputDecoration(labelText: 'Amount'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: categoryController,
        decoration: const InputDecoration(labelText: 'Category'),
      ),
    ],
    onSave: () async {
      final message = await controller.saveExpense(
        id: existing?.id,
        label: labelController.text.trim(),
        amount: double.tryParse(
                amountController.text.trim().replaceAll(',', '.')) ??
            0,
        category: categoryController.text.trim(),
      );
      return message ?? 'Expense saved.';
    },
  );
}

Future<void> _showPantryEditor(
  BuildContext context,
  GoLifeController controller, [
  PantryItem? existing,
]) {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final quantityController = TextEditingController(
    text: existing?.quantityLabel ?? '1 captured item',
  );
  final hintController =
      TextEditingController(text: existing?.rescueHint ?? '');
  return _showEditorDialog(
    context,
    title: existing == null ? 'New pantry item' : 'Edit pantry item',
    builder: (_) => [
      TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name')),
      const SizedBox(height: 12),
      TextField(
        controller: quantityController,
        decoration: const InputDecoration(labelText: 'Quantity'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: hintController,
        decoration: const InputDecoration(labelText: 'Rescue hint'),
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
      return message ?? 'Pantry item saved.';
    },
  );
}

Future<void> _showClosetEditor(
  BuildContext context,
  GoLifeController controller, [
  PurchaseIntention? existing,
]) {
  final labelController = TextEditingController(text: existing?.label ?? '');
  final reasonController = TextEditingController(text: existing?.reason ?? '');
  return _showEditorDialog(
    context,
    title:
        existing == null ? 'New purchase intention' : 'Edit purchase intention',
    builder: (_) => [
      TextField(
          controller: labelController,
          decoration: const InputDecoration(labelText: 'Label')),
      const SizedBox(height: 12),
      TextField(
        controller: reasonController,
        decoration: const InputDecoration(labelText: 'Reason'),
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
      return message ?? 'Purchase intention saved.';
    },
  );
}

Future<void> _showWeekEditor(
  BuildContext context,
  GoLifeController controller, [
  WeekPlan? existing,
]) {
  final themeController = TextEditingController(text: existing?.theme ?? '');
  final focusController =
      TextEditingController(text: existing?.energyNote ?? '');
  return _showEditorDialog(
    context,
    title: existing == null ? 'New week plan' : 'Edit week plan',
    builder: (_) => [
      TextField(
          controller: themeController,
          decoration: const InputDecoration(labelText: 'Theme')),
      const SizedBox(height: 12),
      TextField(
        controller: focusController,
        decoration: const InputDecoration(labelText: 'Focus'),
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
      return message ?? 'Week plan saved.';
    },
  );
}

Future<void> _showJournalEditor(
  BuildContext context,
  GoLifeController controller, [
  JournalEntry? existing,
]) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final bodyController = TextEditingController(text: existing?.body ?? '');
  final moodController =
      TextEditingController(text: existing?.mood ?? 'steady');
  return _showEditorDialog(
    context,
    title: existing == null ? 'New journal entry' : 'Edit journal entry',
    builder: (_) => [
      TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title')),
      const SizedBox(height: 12),
      TextField(
          controller: moodController,
          decoration: const InputDecoration(labelText: 'Mood')),
      const SizedBox(height: 12),
      TextField(
        controller: bodyController,
        decoration: const InputDecoration(labelText: 'Body'),
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
      return message ?? 'Journal entry saved.';
    },
  );
}

Future<void> _showQuickNoteEditor(
  BuildContext context,
  GoLifeController controller, [
  QuickNote? existing,
]) {
  final textController = TextEditingController(text: existing?.text ?? '');
  return _showEditorDialog(
    context,
    title: existing == null ? 'New quick note' : 'Edit quick note',
    builder: (_) => [
      TextField(
        controller: textController,
        decoration: const InputDecoration(labelText: 'Note'),
        minLines: 3,
        maxLines: 5,
      ),
    ],
    onSave: () async {
      final message = await controller.saveQuickNote(
        id: existing?.id,
        text: textController.text.trim(),
      );
      return message ?? 'Quick note saved.';
    },
  );
}

Future<void> _showCalendarEditor(
  BuildContext context,
  GoLifeController controller, [
  CalendarItem? existing,
]) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final startController = TextEditingController(
    text: existing?.startIso ?? DateTime.now().toUtc().toIso8601String(),
  );
  final endController = TextEditingController(
    text: existing?.endIso ??
        DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
  );
  final locationController =
      TextEditingController(text: existing?.location ?? '');
  final energyController =
      TextEditingController(text: existing?.energy ?? 'steady');
  return _showEditorDialog(
    context,
    title: existing == null ? 'New calendar item' : 'Edit calendar item',
    builder: (_) => [
      TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title')),
      const SizedBox(height: 12),
      TextField(
          controller: startController,
          decoration: const InputDecoration(labelText: 'Start ISO')),
      const SizedBox(height: 12),
      TextField(
          controller: endController,
          decoration: const InputDecoration(labelText: 'End ISO')),
      const SizedBox(height: 12),
      TextField(
          controller: locationController,
          decoration: const InputDecoration(labelText: 'Location')),
      const SizedBox(height: 12),
      TextField(
          controller: energyController,
          decoration: const InputDecoration(labelText: 'Energy')),
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
      return message ?? 'Calendar item saved.';
    },
  );
}

Future<void> _showRecipeEditor(
  BuildContext context,
  GoLifeController controller, [
  RecipeRescue? existing,
]) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final summaryController =
      TextEditingController(text: existing?.summary ?? '');
  final ingredientsController = TextEditingController(
    text: existing?.ingredientNames.join(', ') ?? '',
  );
  final minutesController = TextEditingController(
    text: (existing?.estimatedMinutes ?? 15).toString(),
  );
  return _showEditorDialog(
    context,
    title: existing == null ? 'New recipe rescue' : 'Edit recipe rescue',
    builder: (_) => [
      TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title')),
      const SizedBox(height: 12),
      TextField(
        controller: summaryController,
        decoration: const InputDecoration(labelText: 'Summary'),
        minLines: 2,
        maxLines: 4,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: ingredientsController,
        decoration:
            const InputDecoration(labelText: 'Ingredients (comma separated)'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: minutesController,
        decoration: const InputDecoration(labelText: 'Estimated minutes'),
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
      return message ?? 'Recipe rescue saved.';
    },
  );
}

Future<void> _showEditorDialog(
  BuildContext context, {
  required String title,
  required List<Widget> Function(void Function(VoidCallback fn) setState)
      builder,
  required Future<String> Function() onSave,
}) {
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
              TextButton(
                onPressed:
                    saving ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(() => saving = true);
                        final message = await onSave();
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                child: Text(saving ? 'Saving...' : 'Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
