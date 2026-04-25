import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class QuickNote {
  const QuickNote({
    required this.id,
    required this.text,
    required this.createdAtIso,
    this.privacyLevel = 'local_only',
  });

  final String id;
  final String text;
  final String createdAtIso;
  final String privacyLevel;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'text': text,
      'created_at_iso': createdAtIso,
      'privacy_level': privacyLevel,
    };
  }

  factory QuickNote.fromJson(Map<String, dynamic> json) {
    return QuickNote(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAtIso:
          (json['created_at_iso'] ?? json['createdAtIso'] ?? '').toString(),
      privacyLevel:
          (json['privacy_level'] ?? json['privacyLevel'] ?? 'local_only')
              .toString(),
    );
  }

  LifeEvent toLifeEvent(String type) {
    return LifeEventFactory.create(
      domain: 'system',
      type: type,
      summary: text,
      privacyLevel: privacyLevel,
      payload: {
        'quickNoteId': id,
        'summary': text,
      },
    );
  }
}
