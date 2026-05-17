import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../domains/finance/expense_record.dart';
import '../../domains/habits/habit.dart';
import '../../domains/homememory/claim_draft.dart';
import '../../domains/homememory/evidence_attachment.dart';
import '../../domains/homememory/maintenance_reminder.dart';
import '../../domains/homememory/owned_item.dart';
import '../../domains/homememory/purchase_proof.dart';
import '../../domains/homememory/warranty_record.dart';
import '../../domains/analytics/analytics_event.dart';
import '../../domains/journal/journal_entry.dart';
import '../../domains/journal/quick_note.dart';
import '../../domains/calendar/calendar_item.dart';
import '../../domains/mindflow/decision_card.dart';
import '../../domains/mindflow/mental_load_item.dart';
import '../../domains/missions/daily_mission.dart';
import '../../domains/missions/mission_feedback.dart';
import '../../domains/missions/daily_risk.dart';
import '../../domains/missions/mission_set.dart';
import '../../domains/monetization/billing_audit_entry.dart';
import '../../domains/monetization/billing_subscription_state.dart';
import '../../domains/monetization/entitlement.dart';
import '../../domains/pantry/pantry_item.dart';
import '../../domains/privacy/evidence_item.dart';
import '../../domains/privacy/privacy_audit_entry.dart';
import '../../domains/recipes/recipe_rescue.dart';
import '../../domains/shopping/product_evidence_card.dart';
import '../../domains/shopping/shopping_need.dart';
import '../../domains/tasks/go_task.dart';
import '../../domains/wardrobe/purchase_intention.dart';
import '../../domains/week/week_plan.dart';
import '../lifegraph/life_event.dart';
import '../lifegraph/lifegraph_relation.dart';
import '../privacy/privacy_models.dart';
import '../runtime/app_runtime_config.dart';
import '../settings/app_profile_preferences.dart';
import 'local_store.dart';
import 'sensitive_data_cipher.dart';

class SqliteLocalStore implements LocalStore {
  SqliteLocalStore({
    String? databaseName,
    String? encryptionSecretOverride,
  })  : _databaseName = databaseName ?? _defaultDatabaseName,
        _sensitiveDataCipher = SensitiveDataCipher(
          secretOverride: encryptionSecretOverride,
        );

  static const _defaultDatabaseName = 'golife_ai.db';
  static const _databaseVersion = 9;
  static const _privacyKey = 'privacy_settings';
  static const _localePreferenceKey = 'locale_preference';
  static const _profilePreferencesKey = 'profile_preferences';
  static const _runtimeConfigKey = 'runtime_config';
  static const _demoSeedEnabledKey = 'demo_seed_enabled';

  final String _databaseName;
  final SensitiveDataCipher _sensitiveDataCipher;
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    await _sensitiveDataCipher.ensureReady();
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
        if (oldVersion < 2) {
          await _createAdditionalSchema(db);
        }
        if (oldVersion < 3) {
          await _migrateSensitiveRows(db);
        }
        if (oldVersion < 4) {
          await _createHomeMemorySchema(db);
        }
        if (oldVersion < 5) {
          await _createMindFlowSchema(db);
        }
        if (oldVersion < 6) {
          await _createCommercialSnapshotSchema(db);
        }
        if (oldVersion < 7) {
          await _createAnalyticsSchema(db);
        }
        if (oldVersion < 8) {
          await _createEntitlementSchema(db);
        }
        if (oldVersion < 9) {
          await _createBillingRuntimeSchema(db);
        }
      },
    );
    return _database!;
  }

  @override
  Future<bool> supportsSensitiveLocalEncryption() async {
    await _sensitiveDataCipher.ensureReady();
    return true;
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
  Future<String?> loadLocalePreference() async {
    final db = await _db;
    final rows = await db.query(
      'key_value',
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: const [_localePreferenceKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final rawValue = rows.first['value']?.toString();
    if (rawValue == null || rawValue.isEmpty || rawValue == 'system') {
      return null;
    }
    return rawValue;
  }

  @override
  Future<void> saveLocalePreference(String? localeTag) async {
    final db = await _db;
    await db.insert(
      'key_value',
      {
        'key': _localePreferenceKey,
        'value': localeTag ?? 'system',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<AppProfilePreferences> loadProfilePreferences() async {
    final db = await _db;
    final rows = await db.query(
      'key_value',
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: const [_profilePreferencesKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return AppProfilePreferences.defaults();
    }
    final rawJson = rows.first['value']?.toString();
    if (rawJson == null || rawJson.isEmpty) {
      return AppProfilePreferences.defaults();
    }
    return AppProfilePreferences.fromJson(
      Map<String, dynamic>.from(jsonDecode(rawJson) as Map),
    );
  }

  @override
  Future<void> saveProfilePreferences(AppProfilePreferences preferences) async {
    final db = await _db;
    await db.insert(
      'key_value',
      {
        'key': _profilePreferencesKey,
        'value': jsonEncode(preferences.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> loadDemoSeedEnabled() async {
    final db = await _db;
    final rows = await db.query(
      'key_value',
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: const [_demoSeedEnabledKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return true;
    }
    return rows.first['value']?.toString() != 'false';
  }

  @override
  Future<void> saveDemoSeedEnabled(bool enabled) async {
    final db = await _db;
    await db.insert(
      'key_value',
      {
        'key': _demoSeedEnabledKey,
        'value': enabled ? 'true' : 'false',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<AppRuntimeConfig?> loadRuntimeConfig() async {
    final db = await _db;
    final rows = await db.query(
      'key_value',
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: const [_runtimeConfigKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final rawJson = rows.first['value']?.toString();
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }
    return AppRuntimeConfig.fromJson(
      Map<String, dynamic>.from(jsonDecode(rawJson) as Map),
    );
  }

  @override
  Future<void> saveRuntimeConfig(AppRuntimeConfig config) async {
    final db = await _db;
    await db.insert(
      'key_value',
      {
        'key': _runtimeConfigKey,
        'value': jsonEncode(config.toJson()),
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
        .map(
          (row) => LifeEvent.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
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
            'json_blob': _encodeSensitiveJsonBlob(event.toJson()),
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
        .map(
          (row) => DailyMission.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
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
            'json_blob': _encodeSensitiveJsonBlob(mission.toJson()),
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
        .map(
          (row) => DailyRisk.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
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
            'json_blob': _encodeSensitiveJsonBlob(risk.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<MissionSet>> loadMissionSets() async {
    final db = await _db;
    final rows = await db.query(
      'mission_sets',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => MissionSet.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveMissionSets(List<MissionSet> missionSets) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('mission_sets');
      for (final missionSet in missionSets) {
        await txn.insert(
          'mission_sets',
          {
            'mission_set_id': missionSet.missionSetId,
            'date': missionSet.date,
            'source_state': missionSet.sourceState.storageKey,
            'created_at_iso': missionSet.createdAt,
            'json_blob': _encodeSensitiveJsonBlob(missionSet.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<EvidenceItem>> loadEvidenceItems() async {
    final db = await _db;
    final rows = await db.query(
      'evidence_items',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => EvidenceItem.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveEvidenceItems(List<EvidenceItem> evidenceItems) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('evidence_items');
      for (final item in evidenceItems) {
        await txn.insert(
          'evidence_items',
          {
            'evidence_id': item.evidenceId,
            'source_type': item.sourceType,
            'privacy_class': item.privacyClass.storageKey,
            'allowed_for_ai': item.allowedForAi ? 1 : 0,
            'created_at_iso': item.createdAt,
            'hash': item.hash,
            'json_blob': _encodeSensitiveJsonBlob(item.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<LifeGraphRelation>> loadLifeGraphRelations() async {
    final db = await _db;
    final rows = await db.query(
      'lifegraph_relations',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => LifeGraphRelation.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveLifeGraphRelations(List<LifeGraphRelation> relations) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('lifegraph_relations');
      for (final relation in relations) {
        await txn.insert(
          'lifegraph_relations',
          {
            'relation_id': relation.relationId,
            'from_event_id': relation.fromEventId,
            'to_event_id': relation.toEventId,
            'relation_type': relation.relationType,
            'confidence': relation.confidence,
            'created_at_iso': relation.createdAt,
            'json_blob': _encodeSensitiveJsonBlob(relation.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<PrivacyAuditEntry>> loadPrivacyAuditEntries() async {
    final db = await _db;
    final rows = await db.query(
      'privacy_audit_entries',
      orderBy: 'changed_at_iso DESC',
    );
    return rows
        .map(
          (row) => PrivacyAuditEntry.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> savePrivacyAuditEntries(List<PrivacyAuditEntry> entries) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('privacy_audit_entries');
      for (final entry in entries) {
        await txn.insert(
          'privacy_audit_entries',
          {
            'audit_id': entry.auditId,
            'event_id': entry.eventId,
            'old_privacy_level': entry.oldPrivacyLevel,
            'new_privacy_level': entry.newPrivacyLevel,
            'changed_at_iso': entry.changedAt,
            'json_blob': _encodeSensitiveJsonBlob(entry.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<AnalyticsEvent>> loadAnalyticsEvents() async {
    final db = await _db;
    final rows = await db.query(
      'analytics_events',
      orderBy: 'timestamp_iso DESC',
    );
    return rows
        .map(
          (row) => AnalyticsEvent.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveAnalyticsEvents(List<AnalyticsEvent> events) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('analytics_events');
      for (final event in events) {
        await txn.insert(
          'analytics_events',
          {
            'event_id': event.eventId,
            'event_name': event.eventName,
            'timestamp_iso': event.timestampIso,
            'source': event.source,
            'json_blob': _encodeSensitiveJsonBlob(event.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<Entitlement> loadEntitlement() async {
    final db = await _db;
    final rows = await db.query(
      'entitlement_state',
      orderBy: 'updated_at_iso DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return Entitlement.disabledSafeDefault();
    }
    return Entitlement.fromJson(
      _decodeSensitiveJsonRow(rows.first['json_blob']),
    );
  }

  @override
  Future<void> saveEntitlement(Entitlement entitlement) async {
    final db = await _db;
    await db.insert(
      'entitlement_state',
      <String, Object?>{
        'singleton_id': 1,
        'plan': entitlement.plan.storageKey,
        'billing_provider': entitlement.billingProvider,
        'renewal_state': entitlement.renewalState,
        'updated_at_iso': DateTime.now().toUtc().toIso8601String(),
        'json_blob': _encodeSensitiveJsonBlob(entitlement.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<BillingSubscriptionState?> loadBillingSubscriptionState() async {
    final db = await _db;
    final rows = await db.query(
      'billing_subscription_state',
      orderBy: 'updated_at_iso DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return BillingSubscriptionState.fromJson(
      _decodeSensitiveJsonRow(rows.first['json_blob']),
    );
  }

  @override
  Future<void> saveBillingSubscriptionState(
    BillingSubscriptionState? state,
  ) async {
    final db = await _db;
    if (state == null) {
      await db.delete('billing_subscription_state');
      return;
    }
    await db.insert(
      'billing_subscription_state',
      <String, Object?>{
        'singleton_id': 1,
        'provider': state.provider,
        'mode': state.mode,
        'product_id': state.productId,
        'renewal_state': state.renewalState,
        'purchase_token_hash': state.purchaseTokenHash,
        'verified': state.verified ? 1 : 0,
        'updated_at_iso': DateTime.now().toUtc().toIso8601String(),
        'json_blob': _encodeSensitiveJsonBlob(state.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<BillingAuditEntry>> loadBillingAuditEntries() async {
    final db = await _db;
    final rows = await db.query(
      'billing_audit_entries',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => BillingAuditEntry.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveBillingAuditEntries(List<BillingAuditEntry> entries) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('billing_audit_entries');
      for (final entry in entries) {
        await txn.insert(
          'billing_audit_entries',
          <String, Object?>{
            'audit_id': entry.auditId,
            'event_type': entry.eventType,
            'status_code': entry.statusCode,
            'provider': entry.provider,
            'product_id': entry.productId,
            'renewal_state': entry.renewalState,
            'created_at_iso': entry.createdAtIso,
            'json_blob': _encodeSensitiveJsonBlob(entry.toJson()),
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
        'json_blob': _encodeSensitiveJsonBlob(expense.toJson()),
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
        .map(
          (row) => ExpenseRecord.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
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
        .map((row) =>
            PurchaseIntention.fromJson(_decodeJsonRow(row['json_blob'])))
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

  @override
  Future<void> upsertJournalEntry(JournalEntry journalEntry) async {
    final db = await _db;
    await db.insert(
      'journal_entries',
      {
        'id': journalEntry.id,
        'created_at_iso': journalEntry.createdAtIso,
        'privacy_level': journalEntry.privacyLevel,
        'json_blob': _encodeSensitiveJsonBlob(journalEntry.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<JournalEntry>> loadJournalEntries() async {
    final db = await _db;
    final rows = await db.query(
      'journal_entries',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => JournalEntry.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertQuickNote(QuickNote quickNote) async {
    final db = await _db;
    await db.insert(
      'quick_notes',
      {
        'id': quickNote.id,
        'created_at_iso': quickNote.createdAtIso,
        'privacy_level': quickNote.privacyLevel,
        'json_blob': _encodeSensitiveJsonBlob(quickNote.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<QuickNote>> loadQuickNotes() async {
    final db = await _db;
    final rows = await db.query(
      'quick_notes',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => QuickNote.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertCalendarItem(CalendarItem calendarItem) async {
    final db = await _db;
    await db.insert(
      'calendar_items',
      {
        'id': calendarItem.id,
        'start_iso': calendarItem.startIso,
        'end_iso': calendarItem.endIso,
        'json_blob': _encodeSensitiveJsonBlob(calendarItem.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<CalendarItem>> loadCalendarItems() async {
    final db = await _db;
    final rows = await db.query(
      'calendar_items',
      orderBy: 'start_iso ASC',
    );
    return rows
        .map(
          (row) => CalendarItem.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertRecipeRescue(RecipeRescue recipeRescue) async {
    final db = await _db;
    await db.insert(
      'recipe_rescues',
      {
        'id': recipeRescue.id,
        'status': recipeRescue.status,
        'estimated_minutes': recipeRescue.estimatedMinutes,
        'json_blob': jsonEncode(recipeRescue.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<RecipeRescue>> loadRecipeRescues() async {
    final db = await _db;
    final rows = await db.query(
      'recipe_rescues',
      orderBy: 'id ASC',
    );
    return rows
        .map((row) => RecipeRescue.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertOwnedItem(OwnedItem ownedItem) async {
    final db = await _db;
    await db.insert(
      'owned_items',
      {
        'id': ownedItem.id,
        'user_id': ownedItem.userId,
        'category': ownedItem.category,
        'warranty_until': ownedItem.warrantyUntil,
        'privacy_level': ownedItem.privacyLevel,
        'updated_at_iso': ownedItem.updatedAt,
        'json_blob': _encodeSensitiveJsonBlob(ownedItem.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<OwnedItem>> loadOwnedItems() async {
    final db = await _db;
    final rows = await db.query(
      'owned_items',
      orderBy: 'updated_at_iso DESC',
    );
    return rows
        .map(
          (row) => OwnedItem.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertPurchaseProof(PurchaseProof purchaseProof) async {
    final db = await _db;
    await db.insert(
      'purchase_proofs',
      {
        'id': purchaseProof.id,
        'user_id': purchaseProof.userId,
        'owned_item_id': purchaseProof.ownedItemId,
        'merchant_name': purchaseProof.merchantName,
        'purchase_date': purchaseProof.purchaseDate,
        'privacy_level': purchaseProof.privacyLevel,
        'created_at_iso': purchaseProof.createdAt,
        'json_blob': _encodeSensitiveJsonBlob(purchaseProof.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<PurchaseProof>> loadPurchaseProofs() async {
    final db = await _db;
    final rows = await db.query(
      'purchase_proofs',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => PurchaseProof.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertWarrantyRecord(WarrantyRecord warrantyRecord) async {
    final db = await _db;
    await db.insert(
      'warranty_records',
      {
        'id': warrantyRecord.id,
        'user_id': warrantyRecord.userId,
        'owned_item_id': warrantyRecord.ownedItemId,
        'warranty_until': warrantyRecord.warrantyUntil,
        'json_blob': jsonEncode(warrantyRecord.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<WarrantyRecord>> loadWarrantyRecords() async {
    final db = await _db;
    final rows = await db.query(
      'warranty_records',
      orderBy: 'warranty_until ASC',
    );
    return rows
        .map((row) => WarrantyRecord.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertMaintenanceReminder(
    MaintenanceReminder maintenanceReminder,
  ) async {
    final db = await _db;
    await db.insert(
      'maintenance_reminders',
      {
        'id': maintenanceReminder.id,
        'user_id': maintenanceReminder.userId,
        'owned_item_id': maintenanceReminder.ownedItemId,
        'due_date': maintenanceReminder.dueDate,
        'status': maintenanceReminder.status,
        'json_blob': jsonEncode(maintenanceReminder.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<MaintenanceReminder>> loadMaintenanceReminders() async {
    final db = await _db;
    final rows = await db.query(
      'maintenance_reminders',
      orderBy: 'due_date ASC',
    );
    return rows
        .map((row) =>
            MaintenanceReminder.fromJson(_decodeJsonRow(row['json_blob'])))
        .toList(growable: false);
  }

  @override
  Future<void> upsertClaimDraft(ClaimDraft claimDraft) async {
    final db = await _db;
    await db.insert(
      'claim_drafts',
      {
        'id': claimDraft.id,
        'user_id': claimDraft.userId,
        'owned_item_id': claimDraft.ownedItemId,
        'status': claimDraft.status,
        'privacy_level': claimDraft.privacyLevel,
        'created_at_iso': claimDraft.createdAt,
        'json_blob': _encodeSensitiveJsonBlob(claimDraft.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ClaimDraft>> loadClaimDrafts() async {
    final db = await _db;
    final rows = await db.query(
      'claim_drafts',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => ClaimDraft.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> upsertEvidenceAttachment(
    EvidenceAttachment evidenceAttachment,
  ) async {
    final db = await _db;
    await db.insert(
      'evidence_attachments',
      {
        'id': evidenceAttachment.id,
        'user_id': evidenceAttachment.userId,
        'owned_item_id': evidenceAttachment.ownedItemId,
        'proof_id': evidenceAttachment.proofId,
        'type': evidenceAttachment.type,
        'privacy_level': evidenceAttachment.privacyLevel,
        'created_at_iso': evidenceAttachment.createdAt,
        'json_blob': _encodeSensitiveJsonBlob(evidenceAttachment.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<EvidenceAttachment>> loadEvidenceAttachments() async {
    final db = await _db;
    final rows = await db.query(
      'evidence_attachments',
      orderBy: 'created_at_iso DESC',
    );
    return rows
        .map(
          (row) => EvidenceAttachment.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<MentalLoadItem>> loadMentalLoadItems() async {
    final db = await _db;
    final rows = await db.query(
      'mental_load_items',
      orderBy:
          'state ASC, urgency_score DESC, effort_score ASC, updated_at_iso DESC',
    );
    return rows
        .map(
          (row) => MentalLoadItem.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveMentalLoadItems(List<MentalLoadItem> items) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('mental_load_items');
      for (final item in items) {
        await _insertMentalLoadItem(txn, item);
      }
    });
  }

  @override
  Future<void> upsertMentalLoadItem(MentalLoadItem item) async {
    final db = await _db;
    await _insertMentalLoadItem(db, item);
  }

  @override
  Future<List<DecisionCard>> loadDecisionCards() async {
    final db = await _db;
    final rows = await db.query(
      'decision_cards',
      orderBy: 'status ASC, final_score DESC, updated_at_iso DESC',
    );
    return rows
        .map(
          (row) => DecisionCard.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveDecisionCards(List<DecisionCard> cards) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('decision_cards');
      for (final card in cards) {
        await _insertDecisionCard(txn, card);
      }
    });
  }

  @override
  Future<void> upsertDecisionCard(DecisionCard card) async {
    final db = await _db;
    await _insertDecisionCard(db, card);
  }

  @override
  Future<List<ShoppingNeed>> loadShoppingNeeds() async {
    final db = await _db;
    final rows = await db.query(
      'shopping_needs',
      orderBy: 'state ASC, urgency_score DESC, updated_at_iso DESC',
    );
    return rows
        .map(
          (row) => ShoppingNeed.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveShoppingNeeds(List<ShoppingNeed> needs) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('shopping_needs');
      for (final need in needs) {
        await _insertShoppingNeed(txn, need);
      }
    });
  }

  @override
  Future<void> upsertShoppingNeed(ShoppingNeed need) async {
    final db = await _db;
    await _insertShoppingNeed(db, need);
  }

  @override
  Future<List<ProductEvidenceCard>> loadProductEvidenceCards() async {
    final db = await _db;
    final rows = await db.query(
      'product_evidence_cards',
      orderBy: 'confidence DESC, checked_at_iso DESC, product_name ASC',
    );
    return rows
        .map(
          (row) => ProductEvidenceCard.fromJson(
            _decodeSensitiveJsonRow(row['json_blob']),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveProductEvidenceCards(List<ProductEvidenceCard> cards) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('product_evidence_cards');
      for (final card in cards) {
        await _insertProductEvidenceCard(txn, card);
      }
    });
  }

  @override
  Future<void> upsertProductEvidenceCard(ProductEvidenceCard card) async {
    final db = await _db;
    await _insertProductEvidenceCard(db, card);
  }

  @override
  Future<void> deleteTask(String id) => _deleteEntityRow('tasks', id);

  @override
  Future<void> deleteHabit(String id) => _deleteEntityRow('habits', id);

  @override
  Future<void> deleteExpense(String id) => _deleteEntityRow('expenses', id);

  @override
  Future<void> deletePantryItem(String id) =>
      _deleteEntityRow('pantry_items', id);

  @override
  Future<void> deletePurchaseIntention(String id) =>
      _deleteEntityRow('purchase_intentions', id);

  @override
  Future<void> deleteWeekPlan(String id) => _deleteEntityRow('week_plans', id);

  @override
  Future<void> deleteJournalEntry(String id) =>
      _deleteEntityRow('journal_entries', id);

  @override
  Future<void> deleteQuickNote(String id) =>
      _deleteEntityRow('quick_notes', id);

  @override
  Future<void> deleteCalendarItem(String id) =>
      _deleteEntityRow('calendar_items', id);

  @override
  Future<void> deleteRecipeRescue(String id) =>
      _deleteEntityRow('recipe_rescues', id);

  @override
  Future<void> deleteMentalLoadItem(String id) =>
      _deleteEntityRow('mental_load_items', id);

  @override
  Future<void> deleteDecisionCard(String id) =>
      _deleteEntityRow('decision_cards', id);

  @override
  Future<void> deleteShoppingNeed(String id) =>
      _deleteEntityRow('shopping_needs', id);

  @override
  Future<void> deleteProductEvidenceCard(String id) =>
      _deleteEntityRow('product_evidence_cards', id);

  @override
  Future<void> deleteAllData() async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('key_value');
      await txn.delete('life_events');
      await txn.delete('mission_feedback');
      await txn.delete('missions');
      await txn.delete('daily_risks');
      await txn.delete('mission_sets');
      await txn.delete('evidence_items');
      await txn.delete('lifegraph_relations');
      await txn.delete('privacy_audit_entries');
      await txn.delete('analytics_events');
      await txn.delete('entitlement_state');
      await txn.delete('billing_subscription_state');
      await txn.delete('billing_audit_entries');
      await txn.delete('tasks');
      await txn.delete('habits');
      await txn.delete('expenses');
      await txn.delete('pantry_items');
      await txn.delete('purchase_intentions');
      await txn.delete('week_plans');
      await txn.delete('journal_entries');
      await txn.delete('quick_notes');
      await txn.delete('calendar_items');
      await txn.delete('recipe_rescues');
      await txn.delete('owned_items');
      await txn.delete('purchase_proofs');
      await txn.delete('warranty_records');
      await txn.delete('maintenance_reminders');
      await txn.delete('claim_drafts');
      await txn.delete('evidence_attachments');
      await txn.delete('mental_load_items');
      await txn.delete('decision_cards');
      await txn.delete('shopping_needs');
      await txn.delete('product_evidence_cards');
      await txn.insert(
        'key_value',
        {
          'key': _demoSeedEnabledKey,
          'value': 'false',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
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
    await _createAdditionalSchema(db);
  }

  Future<void> _createAdditionalSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS journal_entries (id TEXT PRIMARY KEY, created_at_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_journal_created ON journal_entries(created_at_iso)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS quick_notes (id TEXT PRIMARY KEY, created_at_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_quick_notes_created ON quick_notes(created_at_iso)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS calendar_items (id TEXT PRIMARY KEY, start_iso TEXT NOT NULL, end_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_calendar_start ON calendar_items(start_iso)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS recipe_rescues (id TEXT PRIMARY KEY, status TEXT NOT NULL, estimated_minutes INTEGER NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_recipe_status ON recipe_rescues(status)',
    );
    await _createHomeMemorySchema(db);
  }

  Future<void> _createHomeMemorySchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS owned_items (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, category TEXT NOT NULL, warranty_until TEXT, privacy_level TEXT NOT NULL, updated_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_owned_items_user ON owned_items(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_owned_items_category ON owned_items(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_owned_items_warranty_until ON owned_items(warranty_until)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS purchase_proofs (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, owned_item_id TEXT NOT NULL, merchant_name TEXT NOT NULL, purchase_date TEXT, privacy_level TEXT NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchase_proofs_user ON purchase_proofs(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_purchase_proofs_item ON purchase_proofs(owned_item_id)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS warranty_records (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, owned_item_id TEXT NOT NULL, warranty_until TEXT, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_warranty_records_until ON warranty_records(warranty_until)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS maintenance_reminders (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, owned_item_id TEXT NOT NULL, due_date TEXT NOT NULL, status TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_maintenance_reminders_due ON maintenance_reminders(due_date)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS claim_drafts (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, owned_item_id TEXT NOT NULL, status TEXT NOT NULL, privacy_level TEXT NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_claim_drafts_status ON claim_drafts(status)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS evidence_attachments (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, owned_item_id TEXT NOT NULL, proof_id TEXT, type TEXT NOT NULL, privacy_level TEXT NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_evidence_attachments_item ON evidence_attachments(owned_item_id)',
    );
    await _createMindFlowSchema(db);
  }

  Future<void> _createMindFlowSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS mental_load_items (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, type TEXT NOT NULL, domain TEXT NOT NULL, state TEXT NOT NULL, urgency_score REAL NOT NULL, effort_score REAL NOT NULL, confidence REAL NOT NULL, privacy_level TEXT NOT NULL, created_at_iso TEXT NOT NULL, updated_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mental_load_user_state ON mental_load_items(user_id, state)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mental_load_domain ON mental_load_items(domain)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mental_load_priority ON mental_load_items(state, urgency_score, effort_score)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS decision_cards (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, status TEXT NOT NULL, final_score REAL NOT NULL, confidence REAL NOT NULL, created_at_iso TEXT NOT NULL, updated_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_decision_cards_user_status ON decision_cards(user_id, status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_decision_cards_score ON decision_cards(status, final_score)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS shopping_needs (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, need_type TEXT NOT NULL, state TEXT NOT NULL, urgency_score REAL NOT NULL, currency TEXT, created_at_iso TEXT NOT NULL, updated_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shopping_needs_user_state ON shopping_needs(user_id, state)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_shopping_needs_type ON shopping_needs(need_type)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS product_evidence_cards (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, product_name TEXT NOT NULL, brand TEXT, sustainability_status TEXT NOT NULL, checked_at_iso TEXT, confidence REAL NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_evidence_user_product ON product_evidence_cards(user_id, product_name)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_product_evidence_status ON product_evidence_cards(sustainability_status)',
    );
    await _createCommercialSnapshotSchema(db);
  }

  Future<void> _createCommercialSnapshotSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS mission_sets (mission_set_id TEXT PRIMARY KEY, date TEXT NOT NULL, source_state TEXT NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mission_sets_date_created ON mission_sets(date, created_at_iso DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mission_sets_source_state ON mission_sets(source_state)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS evidence_items (evidence_id TEXT PRIMARY KEY, source_type TEXT NOT NULL, privacy_class TEXT NOT NULL, allowed_for_ai INTEGER NOT NULL, created_at_iso TEXT NOT NULL, hash TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_evidence_items_source_type ON evidence_items(source_type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_evidence_items_privacy_class ON evidence_items(privacy_class)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_evidence_items_allowed_created ON evidence_items(allowed_for_ai, created_at_iso DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_evidence_items_hash ON evidence_items(hash)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS lifegraph_relations (relation_id TEXT PRIMARY KEY, from_event_id TEXT NOT NULL, to_event_id TEXT NOT NULL, relation_type TEXT NOT NULL, confidence REAL NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lifegraph_relations_from_to ON lifegraph_relations(from_event_id, to_event_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lifegraph_relations_type ON lifegraph_relations(relation_type)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS privacy_audit_entries (audit_id TEXT PRIMARY KEY, event_id TEXT NOT NULL, old_privacy_level TEXT NOT NULL, new_privacy_level TEXT NOT NULL, changed_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_privacy_audit_event_time ON privacy_audit_entries(event_id, changed_at_iso DESC)',
    );
    await _createAnalyticsSchema(db);
  }

  Future<void> _createAnalyticsSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS analytics_events (event_id TEXT PRIMARY KEY, event_name TEXT NOT NULL, timestamp_iso TEXT NOT NULL, source TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_analytics_events_name_time ON analytics_events(event_name, timestamp_iso DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_analytics_events_source_time ON analytics_events(source, timestamp_iso DESC)',
    );
    await _createEntitlementSchema(db);
  }

  Future<void> _createEntitlementSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS entitlement_state (singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1), plan TEXT NOT NULL, billing_provider TEXT NOT NULL, renewal_state TEXT NOT NULL, updated_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_entitlement_state_updated ON entitlement_state(updated_at_iso DESC)',
    );
    await _createBillingRuntimeSchema(db);
  }

  Future<void> _createBillingRuntimeSchema(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS billing_subscription_state (singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1), provider TEXT NOT NULL, mode TEXT NOT NULL, product_id TEXT NOT NULL, renewal_state TEXT NOT NULL, purchase_token_hash TEXT NOT NULL, verified INTEGER NOT NULL, updated_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_billing_subscription_state_updated ON billing_subscription_state(updated_at_iso DESC)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS billing_audit_entries (audit_id TEXT PRIMARY KEY, event_type TEXT NOT NULL, status_code TEXT NOT NULL, provider TEXT NOT NULL, product_id TEXT, renewal_state TEXT NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_billing_audit_created ON billing_audit_entries(created_at_iso DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_billing_audit_status ON billing_audit_entries(status_code)',
    );
  }

  Map<String, dynamic> _decodeJsonRow(Object? rawJson) {
    return Map<String, dynamic>.from(
      jsonDecode(rawJson?.toString() ?? '{}') as Map,
    );
  }

  Map<String, dynamic> _decodeSensitiveJsonRow(Object? rawJson) {
    final raw = rawJson?.toString() ?? '{}';
    return _sensitiveDataCipher.decryptJsonString(raw);
  }

  String _encodeSensitiveJsonBlob(Map<String, Object?> value) {
    return _sensitiveDataCipher.encryptJsonMap(value);
  }

  Future<void> _deleteEntityRow(String table, String id) async {
    final db = await _db;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> _insertMentalLoadItem(
    DatabaseExecutor db,
    MentalLoadItem item,
  ) async {
    await db.insert(
      'mental_load_items',
      {
        'id': item.id,
        'user_id': item.userId,
        'type': item.type,
        'domain': item.domain,
        'state': item.state,
        'urgency_score': item.urgencyScore,
        'effort_score': item.effortScore,
        'confidence': item.confidence,
        'privacy_level': item.privacyLevel,
        'created_at_iso': item.createdAtIso,
        'updated_at_iso': item.updatedAtIso,
        'json_blob': _encodeSensitiveJsonBlob(item.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _insertDecisionCard(
    DatabaseExecutor db,
    DecisionCard card,
  ) async {
    await db.insert(
      'decision_cards',
      {
        'id': card.id,
        'user_id': card.userId,
        'status': card.status,
        'final_score': card.rankingScore,
        'confidence': card.confidence,
        'created_at_iso': card.createdAtIso,
        'updated_at_iso': card.updatedAtIso,
        'json_blob': _encodeSensitiveJsonBlob(card.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _insertShoppingNeed(
    DatabaseExecutor db,
    ShoppingNeed need,
  ) async {
    await db.insert(
      'shopping_needs',
      {
        'id': need.id,
        'user_id': need.userId,
        'need_type': need.needType,
        'state': need.state,
        'urgency_score': need.urgencyScore,
        'currency': need.currency,
        'created_at_iso': need.createdAtIso,
        'updated_at_iso': need.updatedAtIso,
        'json_blob': _encodeSensitiveJsonBlob(need.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _insertProductEvidenceCard(
    DatabaseExecutor db,
    ProductEvidenceCard card,
  ) async {
    await db.insert(
      'product_evidence_cards',
      {
        'id': card.id,
        'user_id': card.userId,
        'product_name': card.productName,
        'brand': card.brand,
        'sustainability_status': card.sustainabilityStatus,
        'checked_at_iso': card.checkedAtIso,
        'confidence': card.confidence,
        'json_blob': _encodeSensitiveJsonBlob(card.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _migrateSensitiveRows(Database db) async {
    await _migrateSensitiveTable(db, 'life_events', 'event_id');
    await _migrateSensitiveTable(db, 'missions', 'id');
    await _migrateSensitiveTable(db, 'daily_risks', 'id');
    await _migrateSensitiveTable(db, 'expenses', 'id');
    await _migrateSensitiveTable(db, 'journal_entries', 'id');
    await _migrateSensitiveTable(db, 'quick_notes', 'id');
    await _migrateSensitiveTable(db, 'calendar_items', 'id');
  }

  Future<void> _migrateSensitiveTable(
    Database db,
    String table,
    String idColumn,
  ) async {
    final rows =
        await db.query(table, columns: <String>[idColumn, 'json_blob']);
    for (final row in rows) {
      final raw = row['json_blob']?.toString();
      if (raw == null ||
          raw.isEmpty ||
          _sensitiveDataCipher.looksEncrypted(raw)) {
        continue;
      }
      final decoded = _decodeJsonRow(raw);
      await db.update(
        table,
        <String, Object?>{
          'json_blob': _encodeSensitiveJsonBlob(
            Map<String, Object?>.from(decoded),
          ),
        },
        where: '$idColumn = ?',
        whereArgs: <Object?>[row[idColumn]],
      );
    }
  }
}
