import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class SubmissionAssetManifestEntry {
  const SubmissionAssetManifestEntry({
    required this.storedRef,
    required this.sourcePath,
    required this.bundleRelativePath,
    required this.byteCount,
    required this.available,
    required this.sourceKind,
  });

  final String storedRef;
  final String sourcePath;
  final String bundleRelativePath;
  final int byteCount;
  final bool available;
  final String sourceKind;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'stored_ref': storedRef,
      'bundle_path': bundleRelativePath,
      'byte_count': byteCount,
      'available': available,
      'source_kind': sourceKind,
    };
  }
}

abstract class SubmissionAssetVault {
  Future<String?> persistSubmissionAsset({
    required String collection,
    required String entityId,
    String? sourcePath,
  });

  Future<List<SubmissionAssetManifestEntry>> collectManifestEntries(
    Iterable<String?> storedRefs,
  );

  Future<void> deleteStoredAsset(String? storedRef);

  Future<void> clearVault();
}

abstract class SubmissionAssetDirectoryResolver {
  Future<String> resolveProtectedSubmissionAssetDirectory();
}

class DatabaseSubmissionAssetDirectoryResolver
    implements SubmissionAssetDirectoryResolver {
  @override
  Future<String> resolveProtectedSubmissionAssetDirectory() async {
    final databasePath = await getDatabasesPath();
    return path.join(databasePath, 'submission_assets');
  }
}

class ProtectedSubmissionAssetVault implements SubmissionAssetVault {
  ProtectedSubmissionAssetVault({
    SubmissionAssetDirectoryResolver? directoryResolver,
  }) : _directoryResolver =
            directoryResolver ?? DatabaseSubmissionAssetDirectoryResolver();

  static const managedRefPrefix = 'vault://submission-assets/';

  final SubmissionAssetDirectoryResolver _directoryResolver;

  @override
  Future<String?> persistSubmissionAsset({
    required String collection,
    required String entityId,
    String? sourcePath,
  }) async {
    final trimmedSourcePath = sourcePath?.trim();
    if (trimmedSourcePath == null || trimmedSourcePath.isEmpty) {
      return null;
    }
    if (_isManagedRef(trimmedSourcePath)) {
      return trimmedSourcePath;
    }

    final sourceFile = File(trimmedSourcePath);
    if (!await sourceFile.exists()) {
      return trimmedSourcePath;
    }

    final vaultDirectoryPath =
        await _directoryResolver.resolveProtectedSubmissionAssetDirectory();
    final safeCollection = _sanitizePathSegment(collection);
    final safeEntityId = _sanitizePathSegment(entityId);
    final safeFileName = _sanitizeFileName(
      path.basename(trimmedSourcePath),
    );
    final relativePath = path.join(
      safeCollection,
      safeEntityId,
      safeFileName,
    );
    final destinationFile = File(path.join(vaultDirectoryPath, relativePath));
    await destinationFile.parent.create(recursive: true);
    await sourceFile.copy(destinationFile.path);
    return '$managedRefPrefix${_toPosix(relativePath)}';
  }

  @override
  Future<List<SubmissionAssetManifestEntry>> collectManifestEntries(
    Iterable<String?> storedRefs,
  ) async {
    final uniqueRefs = <String>{};
    final entries = <SubmissionAssetManifestEntry>[];

    for (final rawRef in storedRefs) {
      final trimmedRef = rawRef?.trim();
      if (trimmedRef == null ||
          trimmedRef.isEmpty ||
          !uniqueRefs.add(trimmedRef)) {
        continue;
      }

      final resolved = await _resolveEntry(trimmedRef);
      if (resolved != null) {
        entries.add(resolved);
      }
    }

    return entries;
  }

  @override
  Future<void> deleteStoredAsset(String? storedRef) async {
    final absolutePath = await _resolveAbsolutePath(storedRef);
    if (absolutePath == null) {
      return;
    }
    final file = File(absolutePath);
    if (!await file.exists()) {
      return;
    }
    await file.delete();
    await _deleteEmptyParents(file.parent);
  }

  @override
  Future<void> clearVault() async {
    final vaultDirectoryPath =
        await _directoryResolver.resolveProtectedSubmissionAssetDirectory();
    final vaultDirectory = Directory(vaultDirectoryPath);
    if (await vaultDirectory.exists()) {
      await vaultDirectory.delete(recursive: true);
    }
  }

  Future<SubmissionAssetManifestEntry?> _resolveEntry(String storedRef) async {
    if (_isManagedRef(storedRef)) {
      final relativePath = _managedRelativePath(storedRef);
      final absolutePath = await _resolveAbsolutePath(storedRef);
      if (absolutePath == null) {
        return null;
      }
      final file = File(absolutePath);
      final exists = await file.exists();
      return SubmissionAssetManifestEntry(
        storedRef: storedRef,
        sourcePath: absolutePath,
        bundleRelativePath: 'assets/$relativePath',
        byteCount: exists ? await file.length() : 0,
        available: exists,
        sourceKind: 'managed_vault',
      );
    }

    final sourceFile = File(storedRef);
    final exists = await sourceFile.exists();
    final safeFileName = _sanitizeFileName(path.basename(storedRef));
    return SubmissionAssetManifestEntry(
      storedRef: storedRef,
      sourcePath: storedRef,
      bundleRelativePath: 'assets/legacy/$safeFileName',
      byteCount: exists ? await sourceFile.length() : 0,
      available: exists,
      sourceKind: 'legacy_metadata_ref',
    );
  }

  Future<String?> _resolveAbsolutePath(String? storedRef) async {
    if (storedRef == null || !_isManagedRef(storedRef)) {
      return null;
    }
    final vaultDirectoryPath =
        await _directoryResolver.resolveProtectedSubmissionAssetDirectory();
    return path.join(vaultDirectoryPath, _managedRelativePath(storedRef));
  }

  bool _isManagedRef(String value) {
    return value.startsWith(managedRefPrefix);
  }

  String _managedRelativePath(String storedRef) {
    return storedRef.substring(managedRefPrefix.length);
  }

  Future<void> _deleteEmptyParents(Directory directory) async {
    final rootPath =
        await _directoryResolver.resolveProtectedSubmissionAssetDirectory();
    var current = directory;
    while (path.normalize(current.path) != path.normalize(rootPath)) {
      if (!await current.exists()) {
        current = current.parent;
        continue;
      }
      if (current.listSync().isNotEmpty) {
        return;
      }
      await current.delete();
      current = current.parent;
    }
  }

  String _sanitizePathSegment(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
  }

  String _sanitizeFileName(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return sanitized.isEmpty ? 'asset.bin' : sanitized;
  }

  String _toPosix(String value) {
    return value.replaceAll('\\', '/');
  }
}
