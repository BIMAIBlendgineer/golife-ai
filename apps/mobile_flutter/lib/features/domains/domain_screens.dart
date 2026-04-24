import 'package:flutter/material.dart';

import '../../domains/tasks/go_task.dart';
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
          'TaskDoctor starts as a local-first execution list that can be updated by capture and missions.',
      accent: const Color(0xFF1F4C5B),
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
                : () async {
                    final message = await controller.completeTaskById(task.id);
                    return message ?? 'Task updated.';
                  },
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
          'LifeQuest keeps habit momentum local first and lets a mission turn into a concrete check-in.',
      accent: const Color(0xFF5D7A68),
      child: _EntityList(
        emptyLabel: 'No habits captured yet.',
        children: controller.habits.map((habit) {
          return _EntityCard(
            title: habit.title,
            subtitle: '${habit.cue} · ${habit.streakLabel}',
            chips: <String>[habit.cadence.name],
            actionLabel: 'Check in',
            onAction: () async {
              final message = await controller.checkInHabitById(habit.id);
              return message ?? 'Habit checked in.';
            },
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
          'MoneyMirror stays reflective and conservative: review local spend, never regulated advice.',
      accent: const Color(0xFF8A6C2F),
      child: _EntityList(
        emptyLabel: 'No expenses captured yet.',
        children: controller.expenses.map((expense) {
          return _EntityCard(
            title: expense.label,
            subtitle: expense.reflectionLabel,
            chips: <String>[expense.category],
            actionLabel: 'Reflect',
            onAction: () async {
              final message = await controller.logExpenseTouchById(expense.id);
              return message ?? 'Expense revisited.';
            },
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
          'FridgeZero is now a real local collection: captured food can be marked used directly from the board.',
      accent: const Color(0xFF4C6A4F),
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
                : () async {
                    final message =
                        await controller.markPantryItemUsedById(item.id);
                    return message ?? 'Pantry item updated.';
                  },
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
          'ClosetLess starts as an intention board: pause a purchase and turn wardrobe friction into a visible decision.',
      accent: const Color(0xFF7A5167),
      child: _EntityList(
        emptyLabel: 'No purchase intentions captured yet.',
        children: controller.purchaseIntentions.map((item) {
          return _EntityCard(
            title: item.label,
            subtitle: item.reason,
            chips: const <String>['purchase_intention'],
            actionLabel: 'Pause 24h',
            onAction: () async {
              final message =
                  await controller.pausePurchaseIntentionById(item.id);
              return message ?? 'Purchase intention paused.';
            },
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
          'WeekPilot remains intentionally light: local load, current focus, and quick replanning.',
      accent: const Color(0xFF5D7A68),
      child: _EntityList(
        emptyLabel: 'No week plans captured yet.',
        children: controller.weekPlans.map((plan) {
          return _EntityCard(
            title: plan.theme,
            subtitle: plan.energyNote,
            chips: plan.days.map((day) => day.label).toList(growable: false),
            actionLabel: 'Replan',
            onAction: () async {
              final message = await controller.refreshWeekPlanById(plan.id);
              return message ?? 'Week plan updated.';
            },
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
  });

  final String title;
  final String eyebrow;
  final String description;
  final Color accent;
  final Widget child;

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
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodyLarge),
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
  });

  final String title;
  final String subtitle;
  final List<String> chips;
  final String actionLabel;
  final Future<String> Function()? onAction;

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
            children: chips.map((chip) => Chip(label: Text(chip))).toList(),
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}
