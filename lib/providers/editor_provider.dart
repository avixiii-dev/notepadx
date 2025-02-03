import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/file_service.dart';
import '../services/encoding_service.dart';
import '../services/auto_save_service.dart';
import '../services/settings_service.dart';
import '../services/history_service.dart';
import 'package:path/path.dart' as path;

class EditorProvider with ChangeNotifier {
  String _content = '';
  String? _currentFilePath;
  bool _isModified = false;
  List<String> _recentFiles = [];
  FileEncoding _currentEncoding = FileEncoding.utf8;
  final String _recentFilesKey = 'recent_files';
  late SharedPreferences _prefs;
  late AutoSaveService _autoSaveService;
  late SettingsService _settingsService;
  final _historyService = HistoryService();
  int _cursorPosition = 0;

  EditorProvider() {
    _loadRecentFiles();
    _initServices();
  }

  String get content => _content;
  String? get currentFilePath => _currentFilePath;
  bool get isModified => _isModified;
  List<String> get recentFiles => _recentFiles;
  FileEncoding get currentEncoding => _currentEncoding;
  String get currentEncodingName => EncodingService.getEncodingName(_currentEncoding);
  List<FileEncoding> get supportedEncodings => EncodingService.supportedEncodings;
  bool get canUndo => _historyService.canUndo;
  bool get canRedo => _historyService.canRedo;

  Future<void> _initServices() async {
    _settingsService = SettingsService();
    await _settingsService.init();
    _autoSaveService = AutoSaveService(this, _settingsService);
  }

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
      // Save current state before updating
      _historyService.pushState(HistoryState(
        content: _content,
        cursorPosition: _cursorPosition,
      ));

      _content = newContent;
      _isModified = true;
      _autoSaveService.contentChanged();
      notifyListeners();
    }
  }

  void setCursorPosition(int position) {
    _cursorPosition = position;
  }

  void undo() {
    final currentState = HistoryState(
      content: _content,
      cursorPosition: _cursorPosition,
    );

    final previousState = _historyService.undo(currentState);
    if (previousState != null) {
      _content = previousState.content;
      _cursorPosition = previousState.cursorPosition;
      _isModified = true;
      notifyListeners();
    }
  }

  void redo() {
    final currentState = HistoryState(
      content: _content,
      cursorPosition: _cursorPosition,
    );

    final nextState = _historyService.redo(currentState);
    if (nextState != null) {
      _content = nextState.content;
      _cursorPosition = nextState.cursorPosition;
      _isModified = true;
      notifyListeners();
    }
  }

  void markSaved() {
    _isModified = false;
    notifyListeners();
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
        _updateRecentFiles(filePath);
        _historyService.clear(); // Clear history when loading new file
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading file: $e')),
        );
      }
    }
    return false;
  }

  Future<bool> saveFile(BuildContext context) async {
    if (_currentFilePath == null) {
      return saveFileAs(context);
    }

    try {
      await FileService.writeFile(_currentFilePath!, _content, _currentEncoding);
      _isModified = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
      return false;
    }
  }

  Future<bool> saveFileAs(BuildContext context) async {
    try {
      final filePath = await FileService.saveFile(context, defaultPath: _currentFilePath);
      if (filePath != null) {
        await FileService.writeFile(filePath, _content, _currentEncoding);
        _currentFilePath = filePath;
        _isModified = false;
        _updateRecentFiles(filePath);
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
    return false;
  }

  void _updateRecentFiles(String filePath) {
    _recentFiles.remove(filePath);
    _recentFiles.insert(0, filePath);
    if (_recentFiles.length > 10) {
      _recentFiles = _recentFiles.sublist(0, 10);
    }
    _saveRecentFiles();
  }

  void newFile() {
    _content = '';
    _currentFilePath = null;
    _isModified = false;
    _currentEncoding = FileEncoding.utf8;
    _historyService.clear(); // Clear history for new file
    notifyListeners();
  }

  Future<void> openRecentFile(BuildContext context, String filePath) async {
    if (!File(filePath).existsSync()) {
      _recentFiles.remove(filePath);
      _saveRecentFiles();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File not found: $filePath')),
        );
      }
      return;
    }

    try {
      final (content, encoding) = await FileService.readFile(filePath);
      _content = content;
      _currentFilePath = filePath;
      _currentEncoding = encoding;
      _isModified = false;
      _updateRecentFiles(filePath);
      _historyService.clear(); // Clear history when opening recent file
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  void setEncoding(FileEncoding encoding) {
    if (_currentEncoding != encoding) {
      _currentEncoding = encoding;
      _isModified = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _autoSaveService.dispose();
    super.dispose();
  }
}
