import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/finance/expense_record.dart';

void main() {
  test('ExpenseRecord emits finance life events', () {
    const record = ExpenseRecord(
      id: 'expense-1',
      label: 'Lunch',
      amount: 14.5,
      category: 'food',
    );

    final event = record.toLifeEvent();

    expect(event.domain, 'finance');
    expect(event.type, 'expense_logged');
    expect(event.payload['amount'], 14.5);
  });
}
