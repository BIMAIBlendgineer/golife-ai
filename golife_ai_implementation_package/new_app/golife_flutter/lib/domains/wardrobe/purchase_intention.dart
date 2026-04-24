// Rewritten for GoLife after auditing OpenWardrobe app (MIT, provenance pending verification).
// No source file copied verbatim.

import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class PurchaseIntention {
  const PurchaseIntention({
    required this.id,
    required this.label,
    required this.reason,
  });

  final String id;
  final String label;
  final String reason;

  LifeEvent toLifeEvent({String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'wardrobe',
      type: 'purchase_intention',
      summary: label,
      privacyLevel: privacyLevel,
      payload: {
        'purchaseIntentionId': id,
        'reason': reason,
      },
    );
  }
}
