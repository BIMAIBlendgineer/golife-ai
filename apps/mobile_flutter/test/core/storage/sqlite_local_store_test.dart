import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/lifegraph/life_event.dart';
import 'package:golife_flutter/core/storage/sqlite_local_store.dart';
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

    await store.deleteAllData();

    expect(await store.loadLifeEvents(), isEmpty);
    expect(await store.loadMissionFeedback(), isEmpty);
    expect(await store.loadDemoSeedEnabled(), isFalse);

    final databasePath = path.join(await getDatabasesPath(), databaseName);
    await deleteDatabase(databasePath);
  });
}
