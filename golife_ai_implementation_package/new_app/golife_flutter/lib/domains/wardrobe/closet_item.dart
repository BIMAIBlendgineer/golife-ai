// Rewritten for GoLife after auditing OpenWardrobe app (MIT, provenance pending verification).
// No source file copied verbatim.

import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class ClosetItem {
  const ClosetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.wearCount,
  });

  final String id;
  final String name;
  final String category;
  final int wearCount;

  LifeEvent toLifeEvent(String type) {
    return LifeEventFactory.create(
      domain: 'wardrobe',
      type: type,
      summary: name,
      payload: {
        'itemId': id,
        'category': category,
        'wearCount': wearCount,
      },
    );
  }
}
