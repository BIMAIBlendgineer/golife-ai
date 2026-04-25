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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'is_done': isDone,
    };
  }

  factory GoSubtask.fromJson(Map<String, dynamic> json) {
    return GoSubtask(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      isDone: (json['is_done'] ?? json['isDone'] ?? false) == true,
    );
  }
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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'status': status.name,
      'estimated_minutes': estimatedMinutes,
      'notes': notes,
      'subtasks': subtasks.map((item) => item.toJson()).toList(growable: false),
    };
  }

  factory GoTask.fromJson(Map<String, dynamic> json) {
    return GoTask(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      priority:
          _taskPriorityFromKey((json['priority'] ?? 'standard').toString()),
      status: _taskStatusFromKey((json['status'] ?? 'inbox').toString()),
      estimatedMinutes:
          ((json['estimated_minutes'] ?? json['estimatedMinutes']) as num?)
                  ?.toInt() ??
              15,
      notes: (json['notes'] ?? '').toString(),
      subtasks: ((json['subtasks'] ?? const <Object?>[]) as List)
          .whereType<Map>()
          .map((item) => GoSubtask.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }

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

  LifeEvent toLifeEvent(String type, {String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'task',
      type: type,
      summary: title,
      privacyLevel: privacyLevel,
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

TaskPriority _taskPriorityFromKey(String rawValue) {
  return TaskPriority.values.firstWhere(
    (value) => value.name == rawValue,
    orElse: () => TaskPriority.standard,
  );
}

TaskStatus _taskStatusFromKey(String rawValue) {
  return TaskStatus.values.firstWhere(
    (value) => value.name == rawValue,
    orElse: () => TaskStatus.inbox,
  );
}
