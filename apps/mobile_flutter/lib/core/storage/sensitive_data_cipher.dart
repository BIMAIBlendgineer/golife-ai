import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SensitiveDataCipher {
  SensitiveDataCipher({
    String? secretOverride,
    FlutterSecureStorage? secureStorage,
  })  : _secretOverride = secretOverride,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _secretStorageKey = 'golife.sensitive_data_key.v1';
  static const String _scheme = 'aes_gcm_256_v1';
  static const String _aad = 'golife_sensitive_local_payload';

  final String? _secretOverride;
  final FlutterSecureStorage _secureStorage;

  encrypt.Encrypter? _encrypter;
  bool _ready = false;

  Future<void> ensureReady() async {
    if (_ready) {
      return;
    }

    final keyBytes = await _resolveKeyBytes();
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    _encrypter = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.gcm,
      ),
    );
    _ready = true;
  }

  bool looksEncrypted(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      return decoded is Map && decoded['_scheme'] == _scheme;
    } catch (_) {
      return false;
    }
  }

  String encryptJsonMap(Map<String, Object?> value) {
    _ensureInitialized();

    final iv = encrypt.IV.fromSecureRandom(12);
    final ciphertext = _encrypter!.encrypt(
      jsonEncode(value),
      iv: iv,
      associatedData: utf8.encode(_aad),
    );
    return jsonEncode(
      <String, Object?>{
        '_scheme': _scheme,
        'iv': iv.base64,
        'ciphertext': ciphertext.base64,
      },
    );
  }

  Map<String, dynamic> decryptJsonString(String rawJson) {
    _ensureInitialized();

    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      return <String, dynamic>{};
    }

    final map = Map<String, dynamic>.from(decoded);
    if (map['_scheme'] != _scheme) {
      return map;
    }

    final iv = encrypt.IV.fromBase64((map['iv'] ?? '').toString());
    final ciphertext = encrypt.Encrypted.fromBase64(
      (map['ciphertext'] ?? '').toString(),
    );
    final decrypted = _encrypter!.decrypt(
      ciphertext,
      iv: iv,
      associatedData: utf8.encode(_aad),
    );
    return Map<String, dynamic>.from(jsonDecode(decrypted) as Map);
  }

  Future<List<int>> _resolveKeyBytes() async {
    final override = _secretOverride;
    if (override != null && override.isNotEmpty) {
      return _hashKeyMaterial(override);
    }

    final existing = await _secureStorage.read(key: _secretStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }

    final generated = _randomBytes(32);
    await _secureStorage.write(
      key: _secretStorageKey,
      value: base64Encode(generated),
    );
    return generated;
  }

  List<int> _hashKeyMaterial(String value) {
    return crypto.sha256.convert(utf8.encode(value)).bytes;
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  void _ensureInitialized() {
    if (!_ready || _encrypter == null) {
      throw StateError(
        'SensitiveDataCipher must be initialized with ensureReady() before use.',
      );
    }
  }
}
