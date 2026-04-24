// Rewritten for GoLife after auditing Wanna (MIT).
// No source file copied verbatim.

import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.quantityLabel,
    required this.rescueHint,
  });

  final String id;
  final String name;
  final String quantityLabel;
  final String rescueHint;

  LifeEvent toLifeEvent(String type, {String privacyLevel = 'local_only'}) {
    return LifeEventFactory.create(
      domain: 'pantry',
      type: type,
      summary: name,
      privacyLevel: privacyLevel,
      payload: {
        'itemId': id,
        'quantityLabel': quantityLabel,
        'rescueHint': rescueHint,
      },
    );
  }
}
