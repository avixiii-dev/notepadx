import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'settings_service.dart';
import 'file_service.dart';
import '../providers/editor_provider.dart';

class AutoSaveService {
  final EditorProvider _editorProvider;
  final SettingsService _settingsService;
  Timer? _debounceTimer;
  bool _isSaving = false;

  AutoSaveService(this._editorProvider, this._settingsService);

  void contentChanged() {
    if (!_settingsService.isAutoSaveEnabled) return;
    
    // Debounce auto-save to avoid saving too frequently
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (_editorProvider.isModified && _editorProvider.currentFilePath != null) {
        _performAutoSave();
      }
    });
  }

  Future<void> _performAutoSave() async {
    if (_isSaving || !_editorProvider.isModified || _editorProvider.currentFilePath == null) {
      return;
    }

    try {
      _isSaving = true;
      final filePath = _editorProvider.currentFilePath!;

      // If backup is enabled, create a backup before saving
      if (_settingsService.isAutoSaveBackupEnabled) {
        await _createBackup(filePath);
      }

      // Save the current file
      await FileService.writeFile(
        filePath,
        _editorProvider.content,
        _editorProvider.currentEncoding,
      );

      _editorProvider.markSaved();
      debugPrint('Auto-saved: $filePath');
    } catch (e) {
      debugPrint('Auto-save error: $e');
    } finally {
      _isSaving = false;
    }
  }

  Future<void> _createBackup(String filePath) async {
    try {
      final dir = path.dirname(filePath);
      final ext = path.extension(filePath);
      final name = path.basenameWithoutExtension(filePath);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = path.join(dir, '$name.backup-$timestamp$ext');

      final originalFile = File(filePath);
      if (await originalFile.exists()) {
        await originalFile.copy(backupPath);
        debugPrint('Created backup: $backupPath');
      }
    } catch (e) {
      debugPrint('Backup creation error: $e');
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
