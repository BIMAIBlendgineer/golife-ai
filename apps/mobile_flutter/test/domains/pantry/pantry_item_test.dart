import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/pantry/pantry_item.dart';

void main() {
  test('PantryItem emits pantry life events', () {
    const item = PantryItem(
      id: 'pantry-1',
      name: 'Spinach',
      quantityLabel: '1 bag',
      rescueHint: 'Use tonight',
    );

    final event = item.toLifeEvent('ingredient_flagged');

    expect(event.domain, 'pantry');
    expect(event.type, 'ingredient_flagged');
    expect(event.payload['itemId'], 'pantry-1');
  });
}
