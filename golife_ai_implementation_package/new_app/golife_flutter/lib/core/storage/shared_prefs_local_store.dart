import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../privacy/privacy_models.dart';
import 'local_store.dart';

class SharedPrefsLocalStore implements LocalStore {
  const SharedPrefsLocalStore();

  static const _privacyKey = 'golife.privacy_settings';

  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_privacyKey);
    if (rawJson == null || rawJson.isEmpty) {
      return PrivacySettings.defaults();
    }

    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return PrivacySettings.fromJson(decoded);
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_privacyKey, jsonEncode(settings.toJson()));
  }
}
