import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/export/local_export_service.dart';
import 'package:path/path.dart' as path;

class _StaticExportDirectoryResolver implements ExportDirectoryResolver {
  const _StaticExportDirectoryResolver(this.path);

  final String path;

  @override
  Future<String> resolveProtectedExportDirectory() async => path;
}

void main() {
  test('writes the protected local export bundle to the resolved directory',
      () async {
    final tempDirectory =
        await Directory.systemTemp.createTemp('golife_local_export_test_');
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final service = ProtectedLocalExportService(
      directoryResolver: _StaticExportDirectoryResolver(tempDirectory.path),
      now: () => DateTime.utc(2026, 5, 4, 10, 30, 15),
    );

    final result = await service.saveExportBundle(
      baseFileName: 'golife_local_export',
      jsonPayload: '{\n  "ok": true\n}',
    );

    expect(
      result.fileName,
      'golife_local_export_20260504T103015Z',
    );
    expect(
      await File(result.dataFilePath).readAsString(),
      '{\n  "ok": true\n}',
    );
    expect(result.byteCount, greaterThan(0));
    expect(result.assetCount, 0);
  });

  test('copies assets into the protected local export bundle', () async {
    final exportDirectory =
        await Directory.systemTemp.createTemp('golife_local_bundle_test_');
    final sourceDirectory =
        await Directory.systemTemp.createTemp('golife_local_asset_test_');
    addTearDown(() async {
      if (await exportDirectory.exists()) {
        await exportDirectory.delete(recursive: true);
      }
      if (await sourceDirectory.exists()) {
        await sourceDirectory.delete(recursive: true);
      }
    });

    final sourceFile = File(path.join(sourceDirectory.path, 'receipt.txt'));
    await sourceFile.writeAsString('receipt image bytes', flush: true);

    final service = ProtectedLocalExportService(
      directoryResolver: _StaticExportDirectoryResolver(exportDirectory.path),
      now: () => DateTime.utc(2026, 5, 4, 10, 30, 15),
    );

    final result = await service.saveExportBundle(
      baseFileName: 'golife_local_export',
      jsonPayload: '{\n  "ok": true\n}',
      assets: <LocalExportAsset>[
        LocalExportAsset(
          sourcePath: sourceFile.path,
          bundleRelativePath:
              'assets/evidence_attachments/evidence-1/receipt.txt',
          byteCount: 19,
        ),
      ],
    );

    final copiedFile = File(path.join(
      result.filePath,
      'assets',
      'evidence_attachments',
      'evidence-1',
      'receipt.txt',
    ));
    expect(await copiedFile.exists(), isTrue);
    expect(await copiedFile.readAsString(), 'receipt image bytes');
    expect(result.assetCount, 1);
  });
}
