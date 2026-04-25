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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity_label': quantityLabel,
      'rescue_hint': rescueHint,
    };
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      quantityLabel:
          (json['quantity_label'] ?? json['quantityLabel'] ?? '').toString(),
      rescueHint: (json['rescue_hint'] ?? json['rescueHint'] ?? '').toString(),
    );
  }

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
