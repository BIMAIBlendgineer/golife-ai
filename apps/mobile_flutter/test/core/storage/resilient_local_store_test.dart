import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/privacy/privacy_models.dart';
import 'package:golife_flutter/core/storage/memory_local_store.dart';
import 'package:golife_flutter/core/storage/resilient_local_store.dart';

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
  });
}
