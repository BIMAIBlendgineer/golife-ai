import '../../domains/analytics/analytics_event.dart';
import '../storage/local_store.dart';

class LocalAnalyticsRepository {
  const LocalAnalyticsRepository({
    required LocalStore localStore,
    this.maxEvents = 500,
  }) : _localStore = localStore;

  final LocalStore _localStore;
  final int maxEvents;

  Future<List<AnalyticsEvent>> loadEvents() {
    return _localStore.loadAnalyticsEvents();
  }

  Future<List<AnalyticsEvent>> appendEvent(
    List<AnalyticsEvent> currentEvents,
    AnalyticsEvent event,
  ) async {
    final nextEvents = <AnalyticsEvent>[
      event.sanitized(),
      ...currentEvents,
    ].take(maxEvents).toList(growable: false);
    await _localStore.saveAnalyticsEvents(nextEvents);
    return nextEvents;
  }

  Map<String, int> countByType(Iterable<AnalyticsEvent> events) {
    final counts = <String, int>{};
    for (final event in events) {
      counts.update(event.eventName, (value) => value + 1,
          ifAbsent: () => 1);
    }
    return counts;
  }

  Map<String, Object?> buildSummary(Iterable<AnalyticsEvent> events) {
    final list = events.toList(growable: false);
    final counts = countByType(list);
    return <String, Object?>{
      'total_events': list.length,
      'event_counts': counts,
      'latest_event_at': list.isEmpty ? null : list.first.timestampIso,
      'fallback_event_count': counts['fallback_used'] ?? 0,
      'mission_event_count': list
          .where((event) => event.eventName.startsWith('mission_'))
          .length,
      'privacy_event_count': list
          .where(
            (event) =>
                event.eventName == 'privacy_setting_changed' ||
                event.eventName == 'event_privacy_changed',
          )
          .length,
      'lifegraph_event_count': list
          .where((event) => event.eventName.startsWith('lifegraph_'))
          .length,
    };
  }
}
