import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/lifegraph/life_event.dart';
import 'package:golife_flutter/core/storage/sqlite_local_store.dart';
import 'package:golife_flutter/domains/pantry/pantry_item.dart';
import 'package:golife_flutter/domains/tasks/go_task.dart';
import 'package:golife_flutter/domains/finance/expense_record.dart';
import 'package:golife_flutter/domains/calendar/calendar_item.dart';
import 'package:golife_flutter/domains/journal/journal_entry.dart';
import 'package:golife_flutter/domains/journal/quick_note.dart';
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
    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

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
    await store.upsertQuickNote(
      const QuickNote(
        id: 'note-1',
        text: 'Call landlord tomorrow morning.',
        createdAtIso: '2026-04-25T09:30:00Z',
      ),
    );
    await store.upsertExpense(
      const ExpenseRecord(
        id: 'expense-1',
        label: 'Coffee before commute',
        amount: 4.5,
        category: 'food',
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
    expect(await store.loadQuickNotes(), hasLength(1));
    expect(await store.loadExpenses(), hasLength(1));
    expect(await store.loadCalendarItems(), hasLength(1));
    expect(await store.loadRecipeRescues(), hasLength(1));

    final databasePath = path.join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(
      databasePath,
      singleInstance: false,
    );
    final journalBlob = (await db.query(
      'journal_entries',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final noteBlob = (await db.query(
      'quick_notes',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final expenseBlob = (await db.query(
      'expenses',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    expect(journalBlob, isNot(contains('Today felt heavy')));
    expect(noteBlob, isNot(contains('Call landlord tomorrow morning')));
    expect(expenseBlob, isNot(contains('Coffee before commute')));
    await db.close();

    await store.deleteAllData();

    expect(await store.loadLifeEvents(), isEmpty);
    expect(await store.loadMissionFeedback(), isEmpty);
    expect(await store.loadJournalEntries(), isEmpty);
    expect(await store.loadCalendarItems(), isEmpty);
    expect(await store.loadRecipeRescues(), isEmpty);
    expect(await store.loadDemoSeedEnabled(), isFalse);

    await deleteDatabase(databasePath);
  });

  test('migrates legacy plaintext sensitive rows into encrypted blobs',
      () async {
    final databaseName =
        'golife_migration_${DateTime.now().microsecondsSinceEpoch}.db';
    final databasePath = path.join(await getDatabasesPath(), databaseName);

    final legacyDb = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS key_value (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS expenses (id TEXT PRIMARY KEY, amount REAL NOT NULL, category TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS journal_entries (id TEXT PRIMARY KEY, created_at_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS quick_notes (id TEXT PRIMARY KEY, created_at_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
      },
    );

    await legacyDb.insert(
      'expenses',
      <String, Object?>{
        'id': 'expense-legacy',
        'amount': 18.2,
        'category': 'food',
        'json_blob':
            '{"id":"expense-legacy","label":"Lunch near office","amount":18.2,"category":"food"}',
      },
    );
    await legacyDb.insert(
      'journal_entries',
      <String, Object?>{
        'id': 'journal-legacy',
        'created_at_iso': '2026-04-25T09:00:00Z',
        'privacy_level': 'local_only',
        'json_blob':
            '{"id":"journal-legacy","title":"Legacy note","body":"This should become encrypted.","mood":"steady","created_at_iso":"2026-04-25T09:00:00Z","privacy_level":"local_only"}',
      },
    );
    await legacyDb.insert(
      'quick_notes',
      <String, Object?>{
        'id': 'note-legacy',
        'created_at_iso': '2026-04-25T09:15:00Z',
        'privacy_level': 'local_only',
        'json_blob':
            '{"id":"note-legacy","text":"Legacy quick note","created_at_iso":"2026-04-25T09:15:00Z","privacy_level":"local_only"}',
      },
    );
    await legacyDb.close();

    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

    final journalEntries = await store.loadJournalEntries();
    final quickNotes = await store.loadQuickNotes();
    final expenses = await store.loadExpenses();
    expect(journalEntries.single.body, 'This should become encrypted.');
    expect(quickNotes.single.text, 'Legacy quick note');
    expect(expenses.single.label, 'Lunch near office');

    final migratedDb = await openDatabase(
      databasePath,
      singleInstance: false,
    );
    final migratedJournalBlob = (await migratedDb.query(
      'journal_entries',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final migratedNoteBlob = (await migratedDb.query(
      'quick_notes',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final migratedExpenseBlob = (await migratedDb.query(
      'expenses',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    expect(
        migratedJournalBlob, isNot(contains('This should become encrypted.')));
    expect(migratedNoteBlob, isNot(contains('Legacy quick note')));
    expect(migratedExpenseBlob, isNot(contains('Lunch near office')));
    await migratedDb.close();

    await deleteDatabase(databasePath);
  });

  test('deletes individual entities without clearing unrelated tables',
      () async {
    final databaseName =
        'golife_delete_${DateTime.now().microsecondsSinceEpoch}.db';
    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

    await store.upsertTask(
      const GoTask(
        id: 'task-1',
        title: 'Prepare receipts',
        priority: TaskPriority.standard,
        status: TaskStatus.inbox,
        estimatedMinutes: 20,
      ),
    );
    await store.upsertExpense(
      const ExpenseRecord(
        id: 'expense-1',
        label: 'Groceries',
        amount: 21.3,
        category: 'food',
      ),
    );
    await store.upsertPantryItem(
      const PantryItem(
        id: 'pantry-1',
        name: 'Spinach',
        quantityLabel: '1 bag',
        rescueHint: 'Use tonight.',
      ),
    );

    expect(await store.loadTasks(), hasLength(1));
    expect(await store.loadExpenses(), hasLength(1));
    expect(await store.loadPantryItems(), hasLength(1));

    await store.deleteTask('task-1');
    await store.deleteExpense('expense-1');

    expect(await store.loadTasks(), isEmpty);
    expect(await store.loadExpenses(), isEmpty);
    expect(await store.loadPantryItems(), hasLength(1));

    await store.deletePantryItem('pantry-1');
    expect(await store.loadPantryItems(), isEmpty);

    final databasePath = path.join(await getDatabasesPath(), databaseName);
    await deleteDatabase(databasePath);
  });
}
