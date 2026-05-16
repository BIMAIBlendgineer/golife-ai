import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/lifegraph/life_event.dart';
import 'package:golife_flutter/core/storage/sqlite_local_store.dart';
import 'package:golife_flutter/domains/analytics/analytics_event.dart';
import 'package:golife_flutter/domains/pantry/pantry_item.dart';
import 'package:golife_flutter/domains/tasks/go_task.dart';
import 'package:golife_flutter/domains/finance/expense_record.dart';
import 'package:golife_flutter/domains/homememory/claim_draft.dart';
import 'package:golife_flutter/domains/homememory/evidence_attachment.dart';
import 'package:golife_flutter/domains/homememory/maintenance_reminder.dart';
import 'package:golife_flutter/domains/homememory/owned_item.dart';
import 'package:golife_flutter/domains/homememory/purchase_proof.dart';
import 'package:golife_flutter/domains/homememory/warranty_record.dart';
import 'package:golife_flutter/domains/calendar/calendar_item.dart';
import 'package:golife_flutter/domains/journal/journal_entry.dart';
import 'package:golife_flutter/domains/journal/quick_note.dart';
import 'package:golife_flutter/domains/mindflow/action_contract.dart';
import 'package:golife_flutter/domains/mindflow/decision_card.dart';
import 'package:golife_flutter/domains/mindflow/mental_load_item.dart';
import 'package:golife_flutter/domains/mindflow/privacy_summary.dart';
import 'package:golife_flutter/domains/missions/daily_mission.dart';
import 'package:golife_flutter/domains/missions/daily_risk.dart';
import 'package:golife_flutter/domains/missions/mission_set.dart';
import 'package:golife_flutter/domains/privacy/evidence_item.dart';
import 'package:golife_flutter/domains/privacy/privacy_audit_entry.dart';
import 'package:golife_flutter/domains/recipes/recipe_rescue.dart';
import 'package:golife_flutter/domains/shopping/product_evidence_card.dart';
import 'package:golife_flutter/domains/shopping/shopping_need.dart';
import 'package:golife_flutter/core/lifegraph/lifegraph_relation.dart';
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
    await store.saveDailyMissions(
      const <DailyMission>[
        DailyMission(
          id: 'mission-1',
          title: 'Protect one focus block',
          body: 'Block 30 minutes for the next critical task.',
          evidence: <String>['Calendar is fragmented'],
          uncertainty: 'Review final timing before starting.',
          requiresConfirmation: true,
          domainTargets: <String>['task'],
          recommendationType: 'mission',
          confidence: 0.88,
          ranking: null,
          trace: <String, Object?>{'provider': 'mock'},
        ),
      ],
    );
    await store.saveDailyRisks(
      const <DailyRisk>[
        DailyRisk(
          id: 'risk-1',
          title: 'Calendar overload',
          summary: 'Too many context switches are scheduled this afternoon.',
          severity: 'medium',
          domainTargets: <String>['week'],
        ),
      ],
    );
    await store.saveMissionSets(
      const <MissionSet>[
        MissionSet(
          missionSetId: 'set-1',
          date: '2026-04-25',
          sourceState: MissionSourceState.live,
          missions: <DailyMission>[
            DailyMission(
              id: 'mission-1',
              title: 'Protect one focus block',
              body: 'Block 30 minutes for the next critical task.',
              evidence: <String>['Calendar is fragmented'],
              uncertainty: 'Review final timing before starting.',
              requiresConfirmation: true,
              domainTargets: <String>['task'],
              recommendationType: 'mission',
              confidence: 0.88,
              ranking: null,
              trace: <String, Object?>{'provider': 'mock'},
            ),
          ],
          rankingTrace: <String, Object?>{'sourceState': 'live'},
          createdAt: '2026-04-25T08:05:00Z',
        ),
      ],
    );
    await store.saveEvidenceItems(
      const <EvidenceItem>[
        EvidenceItem(
          evidenceId: 'evidence-1',
          sourceType: 'purchase_proof',
          localPayloadRef: 'vault://submission-assets/proof.txt',
          privacyClass: EvidencePrivacyClass.localOnly,
          allowedForAi: false,
          createdAt: '2026-04-25T08:10:00Z',
          hash: 'proof-1',
        ),
      ],
    );
    await store.saveLifeGraphRelations(
      const <LifeGraphRelation>[
        LifeGraphRelation(
          relationId: 'rel-1',
          fromEventId: 'evt-1',
          toEventId: 'evt-2',
          relationType: 'homememory.proof',
          confidence: 0.95,
          createdAt: '2026-04-25T08:15:00Z',
        ),
      ],
    );
    await store.savePrivacyAuditEntries(
      const <PrivacyAuditEntry>[
        PrivacyAuditEntry(
          auditId: 'audit-1',
          eventId: 'evt-1',
          oldPrivacyLevel: 'local_only',
          newPrivacyLevel: 'ai_allowed',
          changedAt: '2026-04-25T08:20:00Z',
        ),
      ],
    );
    await store.saveAnalyticsEvents(
      const <AnalyticsEvent>[
        AnalyticsEvent(
          eventId: 'analytics-1',
          eventName: 'mission_set_generated',
          timestampIso: '2026-04-25T08:25:00Z',
          locale: 'en',
          source: 'mission_planner',
          metadata: <String, Object?>{
            'mission_set_id': 'set-1',
            'summary': 'This should be stripped from analytics metadata.',
          },
        ),
      ],
    );

    expect(await store.loadLifeEvents(), hasLength(1));
    expect(await store.loadDailyMissions(), hasLength(1));
    expect(await store.loadDailyRisks(), hasLength(1));
    expect(await store.loadMissionSets(), hasLength(1));
    expect(await store.loadEvidenceItems(), hasLength(1));
    expect(await store.loadLifeGraphRelations(), hasLength(1));
    expect(await store.loadPrivacyAuditEntries(), hasLength(1));
    expect(await store.loadAnalyticsEvents(), hasLength(1));
    expect(
      (await store.loadAnalyticsEvents()).single.metadata.containsKey('summary'),
      isFalse,
    );
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
    final eventBlob = (await db.query(
      'life_events',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final missionBlob = (await db.query(
      'missions',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final riskBlob = (await db.query(
      'daily_risks',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final missionSetBlob = (await db.query(
      'mission_sets',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final evidenceItemBlob = (await db.query(
      'evidence_items',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final relationBlob = (await db.query(
      'lifegraph_relations',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final privacyAuditBlob = (await db.query(
      'privacy_audit_entries',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final analyticsBlob = (await db.query(
      'analytics_events',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final calendarBlob = (await db.query(
      'calendar_items',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    expect(journalBlob, isNot(contains('Today felt heavy')));
    expect(noteBlob, isNot(contains('Call landlord tomorrow morning')));
    expect(expenseBlob, isNot(contains('Coffee before commute')));
    expect(eventBlob, isNot(contains('task_captured')));
    expect(missionBlob, isNot(contains('Protect one focus block')));
    expect(riskBlob, isNot(contains('Calendar overload')));
    expect(missionSetBlob, isNot(contains('"mission_set_id":"set-1"')));
    expect(evidenceItemBlob, isNot(contains('vault://submission-assets')));
    expect(relationBlob, isNot(contains('homememory.proof')));
    expect(
        privacyAuditBlob, isNot(contains('"new_privacy_level":"ai_allowed"')));
    expect(analyticsBlob, isNot(contains('mission_set_generated')));
    expect(calendarBlob, isNot(contains('Focus block')));
    await db.close();

    await store.deleteAllData();

    expect(await store.loadLifeEvents(), isEmpty);
    expect(await store.loadDailyMissions(), isEmpty);
    expect(await store.loadDailyRisks(), isEmpty);
    expect(await store.loadMissionSets(), isEmpty);
    expect(await store.loadEvidenceItems(), isEmpty);
    expect(await store.loadLifeGraphRelations(), isEmpty);
    expect(await store.loadPrivacyAuditEntries(), isEmpty);
    expect(await store.loadAnalyticsEvents(), isEmpty);
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
          'CREATE TABLE IF NOT EXISTS life_events (event_id TEXT PRIMARY KEY, user_id TEXT NOT NULL, domain TEXT NOT NULL, event_type TEXT NOT NULL, timestamp_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS missions (id TEXT PRIMARY KEY, rank_index INTEGER NOT NULL, confidence REAL NOT NULL, recommendation_type TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS daily_risks (id TEXT PRIMARY KEY, rank_index INTEGER NOT NULL, severity TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS journal_entries (id TEXT PRIMARY KEY, created_at_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS quick_notes (id TEXT PRIMARY KEY, created_at_iso TEXT NOT NULL, privacy_level TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS calendar_items (id TEXT PRIMARY KEY, start_iso TEXT NOT NULL, end_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
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
      'life_events',
      <String, Object?>{
        'event_id': 'event-legacy',
        'user_id': 'local-user',
        'domain': 'task',
        'event_type': 'task_captured',
        'timestamp_iso': '2026-04-25T08:00:00Z',
        'privacy_level': 'local_only',
        'json_blob':
            '{"event_id":"event-legacy","user_id":"local-user","domain":"task","event_type":"task_captured","timestamp_iso":"2026-04-25T08:00:00Z","payload":{"summary":"Legacy event"},"source":"manual","privacy_level":"local_only"}',
      },
    );
    await legacyDb.insert(
      'missions',
      <String, Object?>{
        'id': 'mission-legacy',
        'rank_index': 0,
        'confidence': 0.85,
        'recommendation_type': 'mission',
        'json_blob':
            '{"id":"mission-legacy","title":"Legacy mission","body":"Legacy mission body","evidence":["Legacy evidence"],"uncertainty":"Legacy uncertainty","requires_confirmation":true,"domain_targets":["task"],"recommendation_type":"mission","confidence":0.85,"trace":{"provider":"mock"}}',
      },
    );
    await legacyDb.insert(
      'daily_risks',
      <String, Object?>{
        'id': 'risk-legacy',
        'rank_index': 0,
        'severity': 'medium',
        'json_blob':
            '{"id":"risk-legacy","title":"Legacy risk","summary":"Legacy risk summary","severity":"medium","domain_targets":["week"]}',
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
    await legacyDb.insert(
      'calendar_items',
      <String, Object?>{
        'id': 'calendar-legacy',
        'start_iso': '2026-04-25T11:00:00Z',
        'end_iso': '2026-04-25T12:00:00Z',
        'json_blob':
            '{"id":"calendar-legacy","title":"Legacy calendar block","start_iso":"2026-04-25T11:00:00Z","end_iso":"2026-04-25T12:00:00Z","notes":"Legacy calendar note"}',
      },
    );
    await legacyDb.close();

    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

    final lifeEvents = await store.loadLifeEvents();
    final missions = await store.loadDailyMissions();
    final risks = await store.loadDailyRisks();
    final journalEntries = await store.loadJournalEntries();
    final quickNotes = await store.loadQuickNotes();
    final expenses = await store.loadExpenses();
    final calendarItems = await store.loadCalendarItems();
    expect(lifeEvents.single.payload['summary'], 'Legacy event');
    expect(missions.single.title, 'Legacy mission');
    expect(risks.single.summary, 'Legacy risk summary');
    expect(journalEntries.single.body, 'This should become encrypted.');
    expect(quickNotes.single.text, 'Legacy quick note');
    expect(expenses.single.label, 'Lunch near office');
    expect(calendarItems.single.title, 'Legacy calendar block');

    final migratedDb = await openDatabase(
      databasePath,
      singleInstance: false,
    );
    final migratedEventBlob = (await migratedDb.query(
      'life_events',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final migratedMissionBlob = (await migratedDb.query(
      'missions',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final migratedRiskBlob = (await migratedDb.query(
      'daily_risks',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
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
    final migratedCalendarBlob = (await migratedDb.query(
      'calendar_items',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    expect(migratedEventBlob, isNot(contains('Legacy event')));
    expect(migratedMissionBlob, isNot(contains('Legacy mission body')));
    expect(migratedRiskBlob, isNot(contains('Legacy risk summary')));
    expect(
        migratedJournalBlob, isNot(contains('This should become encrypted.')));
    expect(migratedNoteBlob, isNot(contains('Legacy quick note')));
    expect(migratedExpenseBlob, isNot(contains('Lunch near office')));
    expect(migratedCalendarBlob, isNot(contains('Legacy calendar block')));
    await migratedDb.close();

    await deleteDatabase(databasePath);
  });

  test('persists homememory entities and encrypts sensitive blobs', () async {
    final databaseName =
        'golife_homememory_${DateTime.now().microsecondsSinceEpoch}.db';
    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

    await store.upsertOwnedItem(
      const OwnedItem(
        id: 'item-1',
        userId: 'local-user',
        name: 'Dyson V8',
        brand: 'Dyson',
        model: 'V8',
        category: 'appliance',
        purchaseDate: '2026-04-10',
        purchasePrice: 249.99,
        currency: 'USD',
        store: 'Amazon',
        warrantyUntil: '2028-04-10',
        warrantySource: WarrantySource.explicit,
        notes: 'Keep receipt local.',
        privacyLevel: 'local_only',
        createdAt: '2026-04-10T10:00:00Z',
        updatedAt: '2026-04-10T10:00:00Z',
      ),
    );
    await store.upsertPurchaseProof(
      const PurchaseProof(
        id: 'proof-1',
        userId: 'local-user',
        ownedItemId: 'item-1',
        sourceType: PurchaseProofSourceType.manualEntry,
        merchantName: 'Amazon',
        purchaseDate: '2026-04-10',
        totalAmount: 249.99,
        currency: 'USD',
        rawText: 'Bought Dyson V8 from Amazon on 2026-04-10 for 249.99 USD.',
        fileRef: 'proofs/receipt-1.txt',
        extractedFields: <String, Object?>{'product_name': 'Dyson V8'},
        privacyLevel: 'local_only',
        createdAt: '2026-04-10T10:00:00Z',
      ),
    );
    await store.upsertWarrantyRecord(
      const WarrantyRecord(
        id: 'warranty-1',
        userId: 'local-user',
        ownedItemId: 'item-1',
        warrantyUntil: '2028-04-10',
        warrantySource: WarrantySource.explicit,
        warrantyMonths: 24,
        disclaimer: 'Verify with seller.',
        createdAt: '2026-04-10T10:00:00Z',
      ),
    );
    await store.upsertMaintenanceReminder(
      const MaintenanceReminder(
        id: 'reminder-1',
        userId: 'local-user',
        ownedItemId: 'item-1',
        title: 'Review warranty before expiration',
        dueDate: '2028-03-27',
        recurrence: 'none',
        status: MaintenanceReminderStatus.scheduled,
        createdAt: '2026-04-10T10:00:00Z',
      ),
    );
    await store.upsertClaimDraft(
      const ClaimDraft(
        id: 'claim-1',
        userId: 'local-user',
        ownedItemId: 'item-1',
        title: 'Warranty claim for Dyson V8',
        issueDescription: 'Battery stopped charging.',
        generatedMessage: 'Hello, I need support with my Dyson V8.',
        recipientHint: 'Amazon support',
        status: ClaimDraftStatus.draft,
        disclaimer: 'No legal advice.',
        privacyLevel: 'local_only',
        createdAt: '2026-04-10T10:00:00Z',
      ),
    );
    await store.upsertEvidenceAttachment(
      const EvidenceAttachment(
        id: 'evidence-1',
        userId: 'local-user',
        ownedItemId: 'item-1',
        proofId: 'proof-1',
        type: EvidenceAttachmentType.receipt,
        fileRef: 'files/receipt-1.jpg',
        description: 'Front receipt photo',
        privacyLevel: 'local_only',
        createdAt: '2026-04-10T10:00:00Z',
      ),
    );

    expect(await store.loadOwnedItems(), hasLength(1));
    expect(await store.loadPurchaseProofs(), hasLength(1));
    expect(await store.loadWarrantyRecords(), hasLength(1));
    expect(await store.loadMaintenanceReminders(), hasLength(1));
    expect(await store.loadClaimDrafts(), hasLength(1));
    expect(await store.loadEvidenceAttachments(), hasLength(1));

    final databasePath = path.join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(databasePath, singleInstance: false);
    final ownedItemBlob =
        (await db.query('owned_items', columns: const ['json_blob'], limit: 1))
            .first['json_blob']
            .toString();
    final proofBlob = (await db.query(
      'purchase_proofs',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final claimBlob =
        (await db.query('claim_drafts', columns: const ['json_blob'], limit: 1))
            .first['json_blob']
            .toString();
    final evidenceBlob = (await db.query(
      'evidence_attachments',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();

    expect(ownedItemBlob, isNot(contains('Keep receipt local.')));
    expect(proofBlob, isNot(contains('Bought Dyson V8 from Amazon')));
    expect(claimBlob, isNot(contains('Battery stopped charging.')));
    expect(evidenceBlob, isNot(contains('Front receipt photo')));

    await db.close();
    await store.deleteAllData();
    expect(await store.loadOwnedItems(), isEmpty);
    expect(await store.loadPurchaseProofs(), isEmpty);
    expect(await store.loadClaimDrafts(), isEmpty);
    expect(await store.loadEvidenceAttachments(), isEmpty);

    await deleteDatabase(databasePath);
  });

  test('persists mindflow entities, encrypts blobs, and clears v5 tables',
      () async {
    final databaseName =
        'golife_mindflow_${DateTime.now().microsecondsSinceEpoch}.db';
    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

    await store.upsertMentalLoadItem(
      const MentalLoadItem(
        id: 'mental-1',
        userId: 'local-user',
        sourceEventId: 'event-1',
        type: 'renewal',
        domain: 'homememory',
        title: 'Review vacuum warranty',
        summary: 'The warranty window closes soon.',
        urgencyScore: 0.92,
        effortScore: 0.35,
        confidence: 0.88,
        state: 'inbox',
        dueHint: '2026-06-01',
        amountHint: null,
        currencyHint: null,
        evidenceRefs: <String>['warranty-1'],
        privacyLevel: 'local_only',
        requiresConfirmation: false,
        createdAtIso: '2026-05-01T08:00:00Z',
        updatedAtIso: '2026-05-01T08:00:00Z',
        trace: <String, Object?>{'provider': 'local'},
      ),
    );
    await store.upsertDecisionCard(
      const DecisionCard(
        id: 'decision-1',
        userId: 'local-user',
        title: 'Handle the warranty before it expires',
        recommendedAction: 'Create a reminder and gather the receipt.',
        alternatives: <String>['Ignore it', 'Wait until next week'],
        domainTargets: <String>['homememory', 'shopping'],
        sourceItems: <String>['mental-1'],
        evidence: <String>['Warranty ends in 30 days'],
        confidence: 0.84,
        uncertainty: 'Exact merchant process is unknown.',
        privacySummary: PrivacySummary(
          aiEnabled: false,
          sentEventCount: 0,
          blockedEventCount: 1,
          allowedDomains: <String>[],
          blockedDomains: <String>['homememory'],
          localOnlyCollections: <String>['purchase_proofs'],
          trace: <String, Object?>{'mode': 'local_only'},
        ),
        confirmationRequired: true,
        actionContract: ActionContract(
          actionType: 'review',
          requiresConfirmation: true,
          destructive: false,
          external: false,
          payloadPreview: <String, Object?>{'item_id': 'item-1'},
          forbiddenActions: <String>['external_purchase'],
        ),
        status: 'proposed',
        evidenceStatus: 'local_only',
        rankingScore: 0.91,
        createdAtIso: '2026-05-01T08:05:00Z',
        updatedAtIso: '2026-05-01T08:05:00Z',
        trace: <String, Object?>{'provider': 'local'},
      ),
    );
    await store.upsertShoppingNeed(
      const ShoppingNeed(
        id: 'need-1',
        userId: 'local-user',
        needType: 'restock',
        title: 'Replace dishwasher tablets',
        sourceDomain: 'shopping',
        sourceEventIds: <String>['event-2'],
        urgencyScore: 0.74,
        budgetHint: 18.5,
        currency: 'EUR',
        sustainabilityPreference: 'lower_packaging',
        state: 'planned',
        createdAtIso: '2026-05-01T08:10:00Z',
        updatedAtIso: '2026-05-01T08:10:00Z',
        trace: <String, Object?>{'provider': 'local'},
      ),
    );
    await store.upsertProductEvidenceCard(
      const ProductEvidenceCard(
        id: 'evidence-1',
        userId: 'local-user',
        productName: 'Dishwasher tablets',
        brand: 'EcoTabs',
        merchantName: 'Local shop',
        price: 13.99,
        currency: 'EUR',
        source: 'local_catalog',
        checkedAtIso: '2026-05-01T08:12:00Z',
        reviewSummary: 'Packaging appears recyclable.',
        sustainabilityStatus: 'insufficient_verified_data',
        confidence: 0.42,
        disclaimer: 'No external sustainability verification available.',
        trace: <String, Object?>{'provider': 'local'},
      ),
    );

    expect(await store.loadMentalLoadItems(), hasLength(1));
    expect(await store.loadDecisionCards(), hasLength(1));
    expect(await store.loadShoppingNeeds(), hasLength(1));
    expect(await store.loadProductEvidenceCards(), hasLength(1));

    final databasePath = path.join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(databasePath, singleInstance: false);
    final mentalBlob = (await db.query(
      'mental_load_items',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final decisionBlob = (await db.query(
      'decision_cards',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final needBlob = (await db.query(
      'shopping_needs',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();
    final evidenceBlob = (await db.query(
      'product_evidence_cards',
      columns: const ['json_blob'],
      limit: 1,
    ))
        .first['json_blob']
        .toString();

    expect(mentalBlob, isNot(contains('Review vacuum warranty')));
    expect(decisionBlob, isNot(contains('gather the receipt')));
    expect(needBlob, isNot(contains('Replace dishwasher tablets')));
    expect(evidenceBlob, isNot(contains('Packaging appears recyclable')));

    await db.close();
    await store.deleteAllData();

    expect(await store.loadMentalLoadItems(), isEmpty);
    expect(await store.loadDecisionCards(), isEmpty);
    expect(await store.loadShoppingNeeds(), isEmpty);
    expect(await store.loadProductEvidenceCards(), isEmpty);

    await deleteDatabase(databasePath);
  });

  test('upgrades v4 databases to v7 without losing existing rows', () async {
    final databaseName =
        'golife_v4_upgrade_${DateTime.now().microsecondsSinceEpoch}.db';
    final databasePath = path.join(await getDatabasesPath(), databaseName);

    final legacyDb = await openDatabase(
      databasePath,
      version: 4,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS key_value (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS tasks (id TEXT PRIMARY KEY, status TEXT NOT NULL, priority TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS owned_items (id TEXT PRIMARY KEY, user_id TEXT NOT NULL, category TEXT NOT NULL, warranty_until TEXT, privacy_level TEXT NOT NULL, updated_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
      },
    );
    await legacyDb.insert(
      'tasks',
      <String, Object?>{
        'id': 'task-legacy',
        'status': 'inbox',
        'priority': 'standard',
        'json_blob':
            '{"id":"task-legacy","title":"Legacy task","priority":"standard","status":"inbox","estimated_minutes":15}',
      },
    );
    await legacyDb.insert(
      'owned_items',
      <String, Object?>{
        'id': 'item-legacy',
        'user_id': 'local-user',
        'category': 'appliance',
        'warranty_until': '2028-04-10',
        'privacy_level': 'local_only',
        'updated_at_iso': '2026-04-10T10:00:00Z',
        'json_blob': 'encrypted:placeholder',
      },
    );
    await legacyDb.close();

    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

    final tasks = await store.loadTasks();
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Legacy task');

    final migratedDb = await openDatabase(databasePath, singleInstance: false);
    final tables = (await migratedDb.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('mental_load_items', 'decision_cards', 'shopping_needs', 'product_evidence_cards', 'mission_sets', 'evidence_items', 'lifegraph_relations', 'privacy_audit_entries', 'analytics_events')",
    ))
        .map((row) => row['name'].toString())
        .toSet();
    expect(
      tables,
      containsAll(<String>[
        'mental_load_items',
        'decision_cards',
        'shopping_needs',
        'product_evidence_cards',
        'mission_sets',
        'evidence_items',
        'lifegraph_relations',
        'privacy_audit_entries',
        'analytics_events',
      ]),
    );
    await migratedDb.close();

    await deleteDatabase(databasePath);
  });

  test('upgrades v6 databases to v7 and adds analytics_events', () async {
    final databaseName =
        'golife_v6_upgrade_${DateTime.now().microsecondsSinceEpoch}.db';
    final databasePath = path.join(await getDatabasesPath(), databaseName);

    final legacyDb = await openDatabase(
      databasePath,
      version: 6,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS key_value (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS mission_sets (mission_set_id TEXT PRIMARY KEY, date TEXT NOT NULL, source_state TEXT NOT NULL, created_at_iso TEXT NOT NULL, json_blob TEXT NOT NULL)',
        );
      },
    );
    await legacyDb.insert(
      'mission_sets',
      <String, Object?>{
        'mission_set_id': 'set-legacy',
        'date': '2026-05-16',
        'source_state': 'live',
        'created_at_iso': '2026-05-16T08:00:00Z',
        'json_blob':
            '{"mission_set_id":"set-legacy","date":"2026-05-16","source_state":"live","missions":[],"ranking_trace":{"sourceState":"live"},"created_at":"2026-05-16T08:00:00Z"}',
      },
    );
    await legacyDb.close();

    final store = SqliteLocalStore(
      databaseName: databaseName,
      encryptionSecretOverride: 'test-secret',
    );

    final missionSets = await store.loadMissionSets();
    expect(missionSets, hasLength(1));
    expect(missionSets.single.missionSetId, 'set-legacy');

    final upgradedDb = await openDatabase(databasePath, singleInstance: false);
    final tables = (await upgradedDb.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'analytics_events'",
    ))
        .map((row) => row['name'].toString())
        .toSet();
    expect(tables, contains('analytics_events'));
    await upgradedDb.close();

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
    await store.upsertMentalLoadItem(
      const MentalLoadItem(
        id: 'mental-1',
        userId: 'local-user',
        sourceEventId: 'event-1',
        type: 'todo',
        domain: 'shopping',
        title: 'Replace soap',
        summary: 'Soap is almost gone.',
        urgencyScore: 0.7,
        effortScore: 0.2,
        confidence: 0.8,
        state: 'inbox',
        dueHint: null,
        amountHint: null,
        currencyHint: null,
        evidenceRefs: <String>['event-1'],
        privacyLevel: 'local_only',
        requiresConfirmation: false,
        createdAtIso: '2026-05-01T08:00:00Z',
        updatedAtIso: '2026-05-01T08:00:00Z',
        trace: <String, Object?>{},
      ),
    );

    expect(await store.loadTasks(), hasLength(1));
    expect(await store.loadExpenses(), hasLength(1));
    expect(await store.loadPantryItems(), hasLength(1));
    expect(await store.loadMentalLoadItems(), hasLength(1));

    await store.deleteTask('task-1');
    await store.deleteExpense('expense-1');
    await store.deleteMentalLoadItem('mental-1');

    expect(await store.loadTasks(), isEmpty);
    expect(await store.loadExpenses(), isEmpty);
    expect(await store.loadPantryItems(), hasLength(1));
    expect(await store.loadMentalLoadItems(), isEmpty);

    await store.deletePantryItem('pantry-1');
    expect(await store.loadPantryItems(), isEmpty);

    final databasePath = path.join(await getDatabasesPath(), databaseName);
    await deleteDatabase(databasePath);
  });
}
