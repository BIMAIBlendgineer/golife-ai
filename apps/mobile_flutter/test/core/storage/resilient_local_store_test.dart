import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/core/storage/resilient_local_store.dart';
import 'package:golife_flutter/domains/mindflow/mental_load_item.dart';

class _FailingLocalStore extends MemoryLocalStore {
  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    throw StateError('secure storage unavailable');
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    throw StateError('secure storage unavailable');
  }

  @override
  Future<bool> supportsSensitiveLocalEncryption() async {
    throw StateError('secure storage unavailable');
  }
}

void main() {
  test('falls back to in-memory storage when primary store fails', () async {
    final fallback = MemoryLocalStore();
    final store = ResilientLocalStore(
      primary: _FailingLocalStore(),
      fallback: fallback,
    );

    expect(await store.supportsSensitiveLocalEncryption(), isFalse);

    final defaults = await store.loadPrivacySettings();
    expect(
      defaults.permissionFor(DomainKey.finance),
      DataPermission.localOnly,
    );

    final updated = defaults.copyWithPermission(
      DomainKey.finance,
      DataPermission.aiAllowed,
    );
    await store.savePrivacySettings(updated);

    final reloaded = await store.loadPrivacySettings();
    expect(
      reloaded.permissionFor(DomainKey.finance),
      DataPermission.aiAllowed,
    );

    await store.upsertMentalLoadItem(
      const MentalLoadItem(
        id: 'mindflow-1',
        userId: 'local-user',
        sourceEventId: 'event-1',
        type: 'follow_up',
        domain: 'shopping',
        title: 'Replace detergent soon',
        summary: 'Supplies are nearly empty.',
        urgencyScore: 0.7,
        effortScore: 0.3,
        confidence: 0.8,
        state: 'inbox',
        dueHint: 'this_week',
        amountHint: null,
        currencyHint: null,
        evidenceRefs: <String>['event-1'],
        privacyLevel: 'local_only',
        requiresConfirmation: false,
        createdAtIso: '2026-05-01T08:00:00Z',
        updatedAtIso: '2026-05-01T08:00:00Z',
        trace: <String, Object?>{'provider': 'local'},
      ),
    );

    final mentalLoadItems = await store.loadMentalLoadItems();
    expect(mentalLoadItems, hasLength(1));
    expect(mentalLoadItems.single.title, 'Replace detergent soon');
  });
}
