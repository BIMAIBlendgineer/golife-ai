import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/tasks/go_task.dart';

void main() {
  test('GoTask emits task life events', () {
    const task = GoTask(
      id: 'task-1',
      title: 'Submit receipt',
      priority: TaskPriority.critical,
      status: TaskStatus.active,
      estimatedMinutes: 10,
    );

    final event = task.toLifeEvent('task_progress_ping');

    expect(event.domain, 'task');
    expect(event.type, 'task_progress_ping');
    expect(event.payload['taskId'], 'task-1');
  });
}
