import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class LocalExportResult {
  const LocalExportResult({
    required this.fileName,
    required this.filePath,
    required this.byteCount,
  });

  final String fileName;
  final String filePath;
  final int byteCount;
}

abstract class LocalExportService {
  Future<LocalExportResult> saveJsonExport({
    required String baseFileName,
    required String jsonPayload,
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
  Future<LocalExportResult> saveJsonExport({
    required String baseFileName,
    required String jsonPayload,
  }) async {
    final exportDirectoryPath =
        await _directoryResolver.resolveProtectedExportDirectory();
    final exportDirectory = Directory(exportDirectoryPath);
    await exportDirectory.create(recursive: true);

    final timestamp = _formatTimestamp(_now().toUtc());
    final fileName = '${baseFileName}_$timestamp.json';
    final filePath = path.join(exportDirectory.path, fileName);
    final exportFile = File(filePath);
    await exportFile.writeAsString(jsonPayload, flush: true);

    return LocalExportResult(
      fileName: fileName,
      filePath: filePath,
      byteCount: utf8.encode(jsonPayload).length,
    );
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
