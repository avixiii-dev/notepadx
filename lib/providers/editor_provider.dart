import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/file_service.dart';
import '../services/encoding_service.dart';

class EditorProvider with ChangeNotifier {
  String _content = '';
  String? _currentFilePath;
  bool _isModified = false;
  List<String> _recentFiles = [];
  FileEncoding _currentEncoding = FileEncoding.utf8;
  final String _recentFilesKey = 'recent_files';
  late SharedPreferences _prefs;

  EditorProvider() {
    _loadRecentFiles();
  }

  String get content => _content;
  String? get currentFilePath => _currentFilePath;
  bool get isModified => _isModified;
  List<String> get recentFiles => _recentFiles;
  FileEncoding get currentEncoding => _currentEncoding;
  String get currentEncodingName => EncodingService.getEncodingName(_currentEncoding);
  List<FileEncoding> get supportedEncodings => EncodingService.supportedEncodings;

  Future<void> _loadRecentFiles() async {
    _prefs = await SharedPreferences.getInstance();
    _recentFiles = _prefs.getStringList(_recentFilesKey) ?? [];
    notifyListeners();
  }

  Future<void> _saveRecentFiles() async {
    await _prefs.setStringList(_recentFilesKey, _recentFiles);
  }

  void updateContent(String newContent) {
    if (_content != newContent) {
      _content = newContent;
      _isModified = true;
      notifyListeners();
    }
  }

  Future<bool> loadFile(BuildContext context) async {
    try {
      final filePath = await FileService.openFile(context);
      if (filePath != null) {
        final (content, encoding) = await FileService.readFile(filePath);
        _content = content;
        _currentFilePath = filePath;
        _currentEncoding = encoding;
        _isModified = false;
        
        // Update recent files
        _recentFiles.remove(filePath);
        _recentFiles.insert(0, filePath);
        if (_recentFiles.length > 10) {
          _recentFiles = _recentFiles.sublist(0, 10);
        }
        await _saveRecentFiles();
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error loading file: $e');
      return false;
    }
  }

  Future<bool> saveFile(BuildContext context) async {
    try {
      if (_currentFilePath != null) {
        // If we have a current file, save directly to it
        await FileService.writeFile(_currentFilePath!, _content, _currentEncoding);
        _isModified = false;
        notifyListeners();
        return true;
      }

      // If no current file, ask for save location
      final filePath = await FileService.saveFile(
        context,
        defaultPath: _currentFilePath,
      );

      if (filePath != null) {
        await FileService.writeFile(filePath, _content, _currentEncoding);
        _currentFilePath = filePath;
        _isModified = false;

        // Update recent files
        if (!_recentFiles.contains(filePath)) {
          _recentFiles.insert(0, filePath);
          if (_recentFiles.length > 10) {
            _recentFiles = _recentFiles.sublist(0, 10);
          }
          await _saveRecentFiles();
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return false;
    }
  }

  Future<bool> saveFileAs(BuildContext context) async {
    try {
      final filePath = await FileService.saveFile(
        context,
        defaultPath: _currentFilePath,
      );

      if (filePath != null) {
        await FileService.writeFile(filePath, _content, _currentEncoding);
        _currentFilePath = filePath;
        _isModified = false;

        // Update recent files
        if (!_recentFiles.contains(filePath)) {
          _recentFiles.insert(0, filePath);
          if (_recentFiles.length > 10) {
            _recentFiles = _recentFiles.sublist(0, 10);
          }
          await _saveRecentFiles();
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return false;
    }
  }

  Future<void> newFile() async {
    _content = '';
    _currentFilePath = null;
    _currentEncoding = FileEncoding.utf8;
    _isModified = false;
    notifyListeners();
  }

  void clearRecentFiles() {
    _recentFiles.clear();
    _saveRecentFiles();
    notifyListeners();
  }

  Future<bool> loadRecentFile(String filePath) async {
    try {
      if (await File(filePath).exists()) {
        final (content, encoding) = await FileService.readFile(filePath);
        _content = content;
        _currentFilePath = filePath;
        _currentEncoding = encoding;
        _isModified = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error loading recent file: $e');
      return false;
    }
  }

  void setEncoding(FileEncoding encoding) {
    if (_currentEncoding != encoding) {
      _currentEncoding = encoding;
      _isModified = true;
      notifyListeners();
    }
  }
}
