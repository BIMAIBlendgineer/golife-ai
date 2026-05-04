import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golife_flutter/core/export/local_export_service.dart';

class _StaticExportDirectoryResolver implements ExportDirectoryResolver {
  const _StaticExportDirectoryResolver(this.path);

  final String path;

  @override
  Future<String> resolveProtectedExportDirectory() async => path;
}

void main() {
  test('writes the protected local export to the resolved directory', () async {
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

    final result = await service.saveJsonExport(
      baseFileName: 'golife_local_export',
      jsonPayload: '{\n  "ok": true\n}',
    );

    expect(
      result.fileName,
      'golife_local_export_20260504T103015Z.json',
    );
    expect(
      await File(result.filePath).readAsString(),
      '{\n  "ok": true\n}',
    );
    expect(result.byteCount, greaterThan(0));
  });
}
