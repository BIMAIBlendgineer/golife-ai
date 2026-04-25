import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/lifegraph/life_event.dart';
import 'package:golife_flutter/core/storage/sqlite_local_store.dart';
import 'package:golife_flutter/domains/calendar/calendar_item.dart';
import 'package:golife_flutter/domains/journal/journal_entry.dart';
import 'package:golife_flutter/domains/recipes/recipe_rescue.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('persists entities and deletes all local data', () async {
    final databaseName =
        'golife_test_${DateTime.now().microsecondsSinceEpoch}.db';
    final store = SqliteLocalStore(databaseName: databaseName);

    await store.saveLifeEvents(
      const <LifeEvent>[
        LifeEvent(
          eventId: 'evt-1',
          userId: 'local-user',
          domain: 'task',
          eventType: 'task_captured',
          timestampIso: '2026-04-25T08:00:00Z',
          payload: {'summary': 'Test'},
          source: 'manual',
          privacyLevel: 'local_only',
        ),
      ],
    );

    expect(await store.loadLifeEvents(), hasLength(1));
    expect(await store.loadDemoSeedEnabled(), isTrue);

    await store.upsertJournalEntry(
      const JournalEntry(
        id: 'journal-1',
        title: 'Today felt heavy',
        body: 'Need a clearer afternoon reset.',
        mood: 'tired',
        createdAtIso: '2026-04-25T09:00:00Z',
      ),
    );
    await store.upsertCalendarItem(
      const CalendarItem(
        id: 'cal-1',
        title: 'Focus block',
        startIso: '2026-04-25T10:00:00Z',
        endIso: '2026-04-25T11:00:00Z',
      ),
    );
    await store.upsertRecipeRescue(
      const RecipeRescue(
        id: 'recipe-1',
        title: 'Spinach bowl',
        summary: 'Use spinach and rice.',
        ingredientNames: <String>['spinach', 'rice'],
        estimatedMinutes: 15,
      ),
    );

    expect(await store.loadJournalEntries(), hasLength(1));
    expect(await store.loadCalendarItems(), hasLength(1));
    expect(await store.loadRecipeRescues(), hasLength(1));

    await store.deleteAllData();

    expect(await store.loadLifeEvents(), isEmpty);
    expect(await store.loadMissionFeedback(), isEmpty);
    expect(await store.loadJournalEntries(), isEmpty);
    expect(await store.loadCalendarItems(), isEmpty);
    expect(await store.loadRecipeRescues(), isEmpty);
    expect(await store.loadDemoSeedEnabled(), isFalse);

    final databasePath = path.join(await getDatabasesPath(), databaseName);
    await deleteDatabase(databasePath);
  });
}
