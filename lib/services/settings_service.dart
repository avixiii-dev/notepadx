import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _autoSaveEnabledKey = 'auto_save_enabled';
  static const String _autoSaveBackupKey = 'auto_save_backup';

  static const bool defaultAutoSaveEnabled = true;
  static const bool defaultAutoSaveBackup = true;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isAutoSaveEnabled {
    return _prefs?.getBool(_autoSaveEnabledKey) ?? defaultAutoSaveEnabled;
  }

  Future<void> setAutoSaveEnabled(bool value) async {
    await _prefs?.setBool(_autoSaveEnabledKey, value);
  }

  bool get isAutoSaveBackupEnabled {
    return _prefs?.getBool(_autoSaveBackupKey) ?? defaultAutoSaveBackup;
  }

  Future<void> setAutoSaveBackupEnabled(bool value) async {
    await _prefs?.setBool(_autoSaveBackupKey, value);
  }
}
