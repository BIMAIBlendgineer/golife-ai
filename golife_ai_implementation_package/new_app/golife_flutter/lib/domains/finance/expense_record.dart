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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'label': label,
      'amount': amount,
      'category': category,
    };
  }

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) {
    return ExpenseRecord(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: (json['category'] ?? 'general').toString(),
    );
  }

  String get reflectionLabel => '$label (\$$amount)';

  LifeEvent toLifeEvent({String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'finance',
      type: 'expense_logged',
      summary: label,
      privacyLevel: privacyLevel,
      payload: {
        'expenseId': id,
        'amount': amount,
        'category': category,
      },
    );
  }
}
