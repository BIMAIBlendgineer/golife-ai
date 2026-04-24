import 'life_event.dart';

class LifeGraphRepository {
  LifeGraphRepository({List<LifeEvent>? seedEvents})
      : _events = List<LifeEvent>.from(seedEvents ?? const []);

  factory LifeGraphRepository.seeded() {
    return LifeGraphRepository(
      seedEvents: const [
        LifeEvent(
          id: 'evt-task-1',
          domain: 'task',
          type: 'task_created',
          occurredAtIso: '2026-04-24T08:00:00Z',
          summary: 'Submit rent receipt',
        ),
        LifeEvent(
          id: 'evt-habit-1',
          domain: 'habit',
          type: 'habit_checked',
          occurredAtIso: '2026-04-24T08:20:00Z',
          summary: 'Night reset kept for 4 days',
        ),
        LifeEvent(
          id: 'evt-finance-1',
          domain: 'finance',
          type: 'expense_logged',
          occurredAtIso: '2026-04-24T09:00:00Z',
          summary: 'Coffee and sandwich purchase recorded',
        ),
        LifeEvent(
          id: 'evt-pantry-1',
          domain: 'pantry',
          type: 'ingredient_flagged',
          occurredAtIso: '2026-04-24T09:20:00Z',
          summary: 'Spinach should be used tonight',
        ),
        LifeEvent(
          id: 'evt-wardrobe-1',
          domain: 'wardrobe',
          type: 'purchase_intention',
          occurredAtIso: '2026-04-24T09:40:00Z',
          summary: 'Thinking about another black jacket',
        ),
      ],
    );
  }

  final List<LifeEvent> _events;

  List<LifeEvent> allEvents() {
    return List<LifeEvent>.unmodifiable(_events.reversed);
  }

  List<LifeEvent> eventsForDomain(String domain) {
    return allEvents().where((event) => event.domain == domain).toList(growable: false);
  }

  Future<void> addEvent(LifeEvent event) async {
    _events.add(event);
  }
}
