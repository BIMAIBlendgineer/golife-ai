// Rewritten for GoLife while Flow source is unavailable locally.
// This is a placeholder domain model, not a migration from a verified local repo.

import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.label,
    required this.amount,
    required this.category,
  });

  final String id;
  final String label;
  final double amount;
  final String category;

  String get reflectionLabel => '$label (\$$amount)';

  LifeEvent toLifeEvent() {
    return LifeEventFactory.create(
      domain: 'finance',
      type: 'expense_logged',
      summary: label,
      payload: {
        'expenseId': id,
        'amount': amount,
        'category': category,
      },
    );
  }
}
