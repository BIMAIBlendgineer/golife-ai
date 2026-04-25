import '../../core/lifegraph/life_event.dart';
import '../../core/lifegraph/life_event_factory.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.createdAtIso,
    this.privacyLevel = 'local_only',
  });

  final String id;
  final String title;
  final String body;
  final String mood;
  final String createdAtIso;
  final String privacyLevel;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'mood': mood,
      'created_at_iso': createdAtIso,
      'privacy_level': privacyLevel,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      mood: (json['mood'] ?? 'steady').toString(),
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
      summary: title,
      privacyLevel: privacyLevel,
      payload: {
        'journalEntryId': id,
        'summary': title,
        'mood': mood,
      },
    );
  }
}
