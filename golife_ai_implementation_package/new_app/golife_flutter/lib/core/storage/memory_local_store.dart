import '../privacy/privacy_models.dart';
import 'local_store.dart';

class MemoryLocalStore implements LocalStore {
  PrivacySettings _settings = PrivacySettings.defaults();

  @override
  Future<PrivacySettings> loadPrivacySettings() async {
    return _settings;
  }

  @override
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    _settings = settings;
  }
}
