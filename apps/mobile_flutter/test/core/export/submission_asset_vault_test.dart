import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/export/submission_asset_vault.dart';
import 'package:path/path.dart' as path;

class _StaticSubmissionAssetDirectoryResolver
    implements SubmissionAssetDirectoryResolver {
  const _StaticSubmissionAssetDirectoryResolver(this.path);

  final String path;

  @override
  Future<String> resolveProtectedSubmissionAssetDirectory() async => path;
}

void main() {
  test('stores assets in the protected vault and emits export manifest entries',
      () async {
    final vaultDirectory =
        await Directory.systemTemp.createTemp('golife_submission_vault_');
    final sourceDirectory =
        await Directory.systemTemp.createTemp('golife_submission_source_');
    addTearDown(() async {
      if (await vaultDirectory.exists()) {
        await vaultDirectory.delete(recursive: true);
      }
      if (await sourceDirectory.exists()) {
        await sourceDirectory.delete(recursive: true);
      }
    });

    final sourceFile = File(path.join(sourceDirectory.path, 'receipt.jpg'));
    await sourceFile.writeAsString('local proof bytes', flush: true);

    final vault = ProtectedSubmissionAssetVault(
      directoryResolver: _StaticSubmissionAssetDirectoryResolver(
        vaultDirectory.path,
      ),
    );

    final storedRef = await vault.persistSubmissionAsset(
      collection: 'evidence_attachments',
      entityId: 'evidence-1',
      sourcePath: sourceFile.path,
    );
    expect(
      storedRef,
      startsWith(ProtectedSubmissionAssetVault.managedRefPrefix),
    );
    expect(storedRef, isNot(sourceFile.path));

    final manifest = await vault.collectManifestEntries(<String?>[storedRef]);
    expect(manifest, hasLength(1));
    expect(manifest.single.available, isTrue);
    expect(
      manifest.single.bundleRelativePath,
      'assets/evidence_attachments/evidence-1/receipt.jpg',
    );
    expect(manifest.single.sourceKind, 'managed_vault');

    await vault.clearVault();
    expect(await Directory(vaultDirectory.path).exists(), isFalse);
  });
}
