// Rewritten for GoLife after auditing Taskly (MIT).
// No source file copied verbatim.

import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

enum TaskPriority { gentle, standard, critical }

enum TaskStatus { inbox, active, done }

class GoSubtask {
  const GoSubtask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  final String id;
  final String title;
  final bool isDone;
}

class GoTask {
  const GoTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
    required this.estimatedMinutes,
    this.notes = '',
    this.subtasks = const <GoSubtask>[],
  });

  final String id;
  final String title;
  final TaskPriority priority;
  final TaskStatus status;
  final int estimatedMinutes;
  final String notes;
  final List<GoSubtask> subtasks;

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.gentle:
        return 'Gentle';
      case TaskPriority.standard:
        return 'Standard';
      case TaskPriority.critical:
        return 'Critical';
    }
  }

  String get timeboxLabel => '$estimatedMinutes min first block';

  LifeEvent toLifeEvent(String type) {
    return LifeEventFactory.create(
      domain: 'task',
      type: type,
      summary: title,
      payload: {
        'taskId': id,
        'priority': priority.name,
        'status': status.name,
        'estimatedMinutes': estimatedMinutes,
        'subtaskCount': subtasks.length,
      },
    );
  }
}
