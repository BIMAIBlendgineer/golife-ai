import '../storage/local_store.dart';
import 'life_event.dart';

class LifeGraphRepository {
  LifeGraphRepository({
    LocalStore? localStore,
    List<LifeEvent>? seedEvents,
  })  : _localStore = localStore,
        _seedEvents = List<LifeEvent>.from(seedEvents ?? const <LifeEvent>[]);

  factory LifeGraphRepository.seeded({LocalStore? localStore}) {
    return LifeGraphRepository(
      localStore: localStore,
      seedEvents: const [
        LifeEvent(
          eventId: 'evt-task-1',
          userId: 'local-user',
          domain: 'task',
          eventType: 'task_created',
          timestampIso: '2026-04-24T08:00:00Z',
          payload: {'summary': 'Submit rent receipt'},
          source: 'manual',
          privacyLevel: 'local_only',
        ),
        LifeEvent(
          eventId: 'evt-habit-1',
          userId: 'local-user',
          domain: 'habit',
          eventType: 'habit_checked',
          timestampIso: '2026-04-24T08:20:00Z',
          payload: {'summary': 'Night reset kept for 4 days'},
          source: 'manual',
          privacyLevel: 'local_only',
        ),
        LifeEvent(
          eventId: 'evt-finance-1',
          userId: 'local-user',
          domain: 'finance',
          eventType: 'expense_logged',
          timestampIso: '2026-04-24T09:00:00Z',
          payload: {'summary': 'Coffee and sandwich purchase recorded'},
          source: 'manual',
          privacyLevel: 'local_only',
        ),
        LifeEvent(
          eventId: 'evt-pantry-1',
          userId: 'local-user',
          domain: 'pantry',
          eventType: 'ingredient_flagged',
          timestampIso: '2026-04-24T09:20:00Z',
          payload: {'summary': 'Spinach should be used tonight'},
          source: 'manual',
          privacyLevel: 'local_only',
        ),
        LifeEvent(
          eventId: 'evt-wardrobe-1',
          userId: 'local-user',
          domain: 'wardrobe',
          eventType: 'purchase_intention',
          timestampIso: '2026-04-24T09:40:00Z',
          payload: {'summary': 'Thinking about another black jacket'},
          source: 'manual',
          privacyLevel: 'local_only',
        ),
      ],
    );
  }

  final LocalStore? _localStore;
  final List<LifeEvent> _seedEvents;
  final List<LifeEvent> _events = <LifeEvent>[];
  bool _bootstrapped = false;

  Future<void> bootstrap() async {
    if (_bootstrapped) {
      return;
    }

    final storedEvents = await _localStore?.loadLifeEvents() ?? const <LifeEvent>[];
    final demoSeedEnabled = await _localStore?.loadDemoSeedEnabled() ?? true;
    _events
      ..clear()
      ..addAll(
        storedEvents.isNotEmpty
            ? storedEvents
            : demoSeedEnabled
                ? _seedEvents
                : const <LifeEvent>[],
      );

    _bootstrapped = true;

    if (storedEvents.isEmpty && _localStore != null && _events.isNotEmpty) {
      await _localStore.saveLifeEvents(_events);
    }
  }

  List<LifeEvent> allEvents() {
    final current = _events.isEmpty && !_bootstrapped ? _seedEvents : _events;
    return List<LifeEvent>.unmodifiable(current.reversed.toList(growable: false));
  }

  List<LifeEvent> eventsForDomain(String domain) {
    return allEvents()
        .where((event) => event.domain == domain)
        .toList(growable: false);
  }

  Future<void> addEvent(LifeEvent event) async {
    if (!_bootstrapped) {
      await bootstrap();
    }
    _events.add(event);
    await _localStore?.saveLifeEvents(_events);
  }

  Future<void> replaceAll(List<LifeEvent> events) async {
    _events
      ..clear()
      ..addAll(events);
    _bootstrapped = true;
    await _localStore?.saveLifeEvents(_events);
  }

  Future<void> clear() async {
    await replaceAll(const <LifeEvent>[]);
  }
}
