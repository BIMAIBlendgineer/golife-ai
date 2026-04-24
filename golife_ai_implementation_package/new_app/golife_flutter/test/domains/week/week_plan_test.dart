import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/week/week_plan.dart';

void main() {
  test('WeekPlan emits week life events', () {
    const plan = WeekPlan(
      id: 'week-1',
      theme: 'Close the shell',
      colorToken: 'terra',
      days: [
        DayPlan(label: 'Friday', focus: 'Admin cleanup'),
      ],
    );

    final event = plan.toLifeEvent('week_plan_checked');

    expect(event.domain, 'week');
    expect(event.type, 'week_plan_checked');
    expect(event.payload['dayCount'], 1);
  });
}
