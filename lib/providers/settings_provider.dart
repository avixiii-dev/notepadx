import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  bool _initialized = false;

  // Default values
  bool _autoSaveEnabled = false;
  bool _autoSaveBackupEnabled = false;

  bool get isAutoSaveEnabled => _autoSaveEnabled;
  bool get isAutoSaveBackupEnabled => _autoSaveBackupEnabled;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    await _settingsService.init();
    
    // Load saved settings
    _autoSaveEnabled = _settingsService.isAutoSaveEnabled;
    _autoSaveBackupEnabled = _settingsService.isAutoSaveBackupEnabled;
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> setAutoSaveEnabled(bool value) async {
    await _settingsService.setAutoSaveEnabled(value);
    _autoSaveEnabled = value;
    notifyListeners();
  }

  Future<void> setAutoSaveBackupEnabled(bool value) async {
    await _settingsService.setAutoSaveBackupEnabled(value);
    _autoSaveBackupEnabled = value;
    notifyListeners();
  }
}
