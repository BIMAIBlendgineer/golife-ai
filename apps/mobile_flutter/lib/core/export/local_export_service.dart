import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class LocalExportAsset {
  const LocalExportAsset({
    required this.sourcePath,
    required this.bundleRelativePath,
    required this.byteCount,
  });

  final String sourcePath;
  final String bundleRelativePath;
  final int byteCount;
}

class LocalExportResult {
  const LocalExportResult({
    required this.fileName,
    required this.filePath,
    required this.dataFilePath,
    required this.byteCount,
    required this.assetCount,
  });

  final String fileName;
  final String filePath;
  final String dataFilePath;
  final int byteCount;
  final int assetCount;
}

abstract class LocalExportService {
  Future<LocalExportResult> saveExportBundle({
    required String baseFileName,
    required String jsonPayload,
    List<LocalExportAsset> assets = const <LocalExportAsset>[],
  });
}

abstract class ExportDirectoryResolver {
  Future<String> resolveProtectedExportDirectory();
}

class DatabaseExportDirectoryResolver implements ExportDirectoryResolver {
  @override
  Future<String> resolveProtectedExportDirectory() async {
    final databasePath = await getDatabasesPath();
    return path.join(databasePath, 'exports');
  }
}

class ProtectedLocalExportService implements LocalExportService {
  ProtectedLocalExportService({
    ExportDirectoryResolver? directoryResolver,
    DateTime Function()? now,
  })  : _directoryResolver =
            directoryResolver ?? DatabaseExportDirectoryResolver(),
        _now = now ?? DateTime.now;

  final ExportDirectoryResolver _directoryResolver;
  final DateTime Function() _now;

  @override
  Future<LocalExportResult> saveExportBundle({
    required String baseFileName,
    required String jsonPayload,
    List<LocalExportAsset> assets = const <LocalExportAsset>[],
  }) async {
    final exportDirectoryPath =
        await _directoryResolver.resolveProtectedExportDirectory();
    final exportDirectory = Directory(exportDirectoryPath);
    await exportDirectory.create(recursive: true);

    final timestamp = _formatTimestamp(_now().toUtc());
    final fileName = '${baseFileName}_$timestamp';
    final bundleDirectory =
        Directory(path.join(exportDirectory.path, fileName));
    await bundleDirectory.create(recursive: true);

    final dataFilePath = path.join(bundleDirectory.path, 'data.json');
    final exportFile = File(dataFilePath);
    await exportFile.writeAsString(jsonPayload, flush: true);
    await _copyAssetFiles(bundleDirectory, assets);

    return LocalExportResult(
      fileName: fileName,
      filePath: bundleDirectory.path,
      dataFilePath: dataFilePath,
      byteCount: utf8.encode(jsonPayload).length,
      assetCount: assets.length,
    );
  }

  Future<void> _copyAssetFiles(
    Directory bundleDirectory,
    List<LocalExportAsset> assets,
  ) async {
    for (final asset in assets) {
      final normalizedRelativePath =
          path.normalize(asset.bundleRelativePath).replaceAll('\\', '/');
      if (normalizedRelativePath.isEmpty ||
          normalizedRelativePath.startsWith('..') ||
          path.isAbsolute(normalizedRelativePath)) {
        throw ArgumentError.value(
          asset.bundleRelativePath,
          'bundleRelativePath',
          'Asset path must stay inside the export bundle.',
        );
      }
      final destinationPath = path.joinAll(
        <String>[bundleDirectory.path, ...path.split(normalizedRelativePath)],
      );
      final destinationFile = File(destinationPath);
      await destinationFile.parent.create(recursive: true);
      await File(asset.sourcePath).copy(destinationFile.path);
    }
  }

  static String _formatTimestamp(DateTime timestamp) {
    final year = timestamp.year.toString().padLeft(4, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$year$month${day}T$hour$minute${second}Z';
  }
}
