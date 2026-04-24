import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/domains/wardrobe/purchase_intention.dart';

void main() {
  test('PurchaseIntention emits wardrobe purchase signal', () {
    const intention = PurchaseIntention(
      id: 'purchase-1',
      label: 'Black jacket',
      reason: 'Looks redundant with current closet',
    );

    final event = intention.toLifeEvent();

    expect(event.domain, 'wardrobe');
    expect(event.type, 'purchase_intention');
    expect(event.payload['purchaseIntentionId'], 'purchase-1');
  });
}
