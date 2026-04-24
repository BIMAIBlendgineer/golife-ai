import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';
import '../lifegraph/life_event.dart';
import '../privacy/privacy_models.dart';
import 'local_store.dart';

class SqliteLocalStore implements LocalStore {
  SqliteLocalStore();

  static const _databaseName = 'golife_ai.db';
  static const _databaseVersion = 1;
  static const _privacyKey = 'privacy_settings';

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, _databaseName);
    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {
          await _createSchema(db);
        }
      },
    );
    return _database!;
  }

  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    final db = await _db;
    final rows = await db.query(
      'key_value',
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: const [_privacyKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return PrivacySettings.defaults();
    }

    final rawJson = rows.first['value']?.toString();
    if (rawJson == null || rawJson.isEmpty) {
      return PrivacySettings.defaults();
    }
    return PrivacySettings.fromJson(
      Map<String, dynamic>.from(jsonDecode(rawJson) as Map),
    );
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    final db = await _db;
    await db.insert(
      'key_value',
      {
        'key': _privacyKey,
        'value': jsonEncode(settings.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<LifeEvent>> loadLifeEvents() async {
    final db = await _db;
    final rows = await db.query(
      'life_events',
      orderBy: 'timestamp_iso ASC',
    );
    return rows
        .map((row) => LifeEvent.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> saveLifeEvents(List<LifeEvent> events) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('life_events');
      for (final event in events) {
        await txn.insert(
          'life_events',
          {
            'event_id': event.eventId,
            'user_id': event.userId,
            'domain': event.domain,
            'event_type': event.eventType,
            'timestamp_iso': event.timestampIso,
            'privacy_level': event.privacyLevel,
            'json_blob': jsonEncode(event.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<MissionFeedback>> loadMissionFeedback() async {
    final db = await _db;
    final rows = await db.query(
      'mission_feedback',
      orderBy: 'created_at_iso ASC',
    );
    return rows
        .map(
          (row) => MissionFeedback.fromJson(_decodeJsonRow(row['json_blob'])),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveMissionFeedback(List<MissionFeedback> feedbackItems) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('mission_feedback');
      for (final feedback in feedbackItems) {
        await txn.insert(
          'mission_feedback',
          {
            'id': feedback.id,
            'mission_id': feedback.missionId,
            'status': feedback.status.storageKey,
            'created_at_iso': feedback.createdAtIso,
            'json_blob': jsonEncode(feedback.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<DailyMission>> loadDailyMissions() async {
    final db = await _db;
    final rows = await db.query(
      'missions',
      orderBy: 'rank_index ASC',
    );
    return rows
        .map((row) => DailyMission.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> saveDailyMissions(List<DailyMission> missions) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('missions');
      for (var index = 0; index < missions.length; index++) {
        final mission = missions[index];
        await txn.insert(
          'missions',
          {
            'id': mission.id,
            'rank_index': index,
            'confidence': mission.confidence,
            'recommendation_type': mission.recommendationType,
            'json_blob': jsonEncode(mission.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<DailyRisk>> loadDailyRisks() async {
    final db = await _db;
    final rows = await db.query(
      'daily_risks',
      orderBy: 'rank_index ASC',
    );
    return rows
        .map((row) => DailyRisk.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> saveDailyRisks(List<DailyRisk> risks) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('daily_risks');
      for (var index = 0; index < risks.length; index++) {
        final risk = risks[index];
        await txn.insert(
          'daily_risks',
          {
            'id': risk.id,
            'rank_index': index,
            'severity': risk.severity,
            'json_blob': jsonEncode(risk.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> upsertTask(GoTask task) async {
    final db = await _db;
    await db.insert(
      'tasks',
      {
        'id': task.id,
        'status': task.status.name,
        'priority': task.priority.name,
        'json_blob': jsonEncode(task.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<GoTask>> loadTasks() async {
    final db = await _db;
    final rows = await db.query(
      'tasks',
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => GoTask.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertHabit(Habit habit) async {
    final db = await _db;
    await db.insert(
      'habits',
      {
        'id': habit.id,
        'cadence': habit.cadence.name,
        'json_blob': jsonEncode(habit.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Habit>> loadHabits() async {
    final db = await _db;
    final rows = await db.query(
      'habits',
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => Habit.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertExpense(ExpenseRecord expense) async {
    final db = await _db;
    await db.insert(
      'expenses',
      {
        'id': expense.id,
        'amount': expense.amount,
        'category': expense.category,
        'json_blob': jsonEncode(expense.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ExpenseRecord>> loadExpenses() async {
    final db = await _db;
    final rows = await db.query(
      'expenses',
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => ExpenseRecord.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertPantryItem(PantryItem pantryItem) async {
    final db = await _db;
    await db.insert(
      'pantry_items',
      {
        'id': pantryItem.id,
        'json_blob': jsonEncode(pantryItem.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<PantryItem>> loadPantryItems() async {
    final db = await _db;
    final rows = await db.query(
      'pantry_items',
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => PantryItem.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertPurchaseIntention(
    PurchaseIntention purchaseIntention,
  ) async {
    final db = await _db;
    await db.insert(
      'purchase_intentions',
      {
        'id': purchaseIntention.id,
        'json_blob': jsonEncode(purchaseIntention.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<PurchaseIntention>> loadPurchaseIntentions() async {
    final db = await _db;
    final rows = await db.query(
      'purchase_intentions',
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => PurchaseIntention.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertWeekPlan(WeekPlan weekPlan) async {
    final db = await _db;
    await db.insert(
      'week_plans',
      {
        'id': weekPlan.id,
        'json_blob': jsonEncode(weekPlan.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<WeekPlan>> loadWeekPlans() async {
    final db = await _db;
    final rows = await db.query(
      'week_plans',
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => WeekPlan.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  Future<void> _createSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS key_value (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS life_events (event_id TEXT PRIMARY KEY, user_id TEXT NOT NULL, domain TEXT NOT NULL, event_type TEXT NOT NULL, timestamp_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_life_events_user_domain_time ON life_events(user_id, domain, timestamp_iso)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_life_events_privacy ON life_events(privacy_level)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS mission_feedback (id TEXT PRIMARY KEY, mission_id TEXT NOT NULL, status TEXT NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_feedback_mission_time ON mission_feedback(mission_id, created_at_iso)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS missions (id TEXT PRIMARY KEY, rank_index INTEGER NOT NULL, confidence REAL NOT NULL, recommendation_type TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS daily_risks (id TEXT PRIMARY KEY, rank_index INTEGER NOT NULL, severity TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS tasks (id TEXT PRIMARY KEY, status TEXT NOT NULL, priority TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS habits (id TEXT PRIMARY KEY, cadence TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS expenses (id TEXT PRIMARY KEY, amount REAL NOT NULL, category TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS pantry_items (id TEXT PRIMARY KEY, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS purchase_intentions (id TEXT PRIMARY KEY, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS week_plans (id TEXT PRIMARY KEY, json_blob TEXT NOT NULL)',
    );
  }

  Map<String, dynamic> _decodeJsonRow(Object? rawJson) {
    return Map<String, dynamic>.from(
      jsonDecode(rawJson?.toString() ?? '{}') as Map,
    );
  }
}
