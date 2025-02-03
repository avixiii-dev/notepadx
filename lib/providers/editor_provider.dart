import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditorProvider with ChangeNotifier {
  String _content = '';
  String? _currentFilePath;
  bool _isModified = false;
  List<String> _recentFiles = [];
  final String _recentFilesKey = 'recent_files';
  late SharedPreferences _prefs;

  EditorProvider() {
    _loadRecentFiles();
  }

  String get content => _content;
  String? get currentFilePath => _currentFilePath;
  bool get isModified => _isModified;
  List<String> get recentFiles => _recentFiles;

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

  Future<void> loadFile(String filePath) async {
    try {
      final file = File(filePath);
      _content = await file.readAsString();
      _currentFilePath = filePath;
      _isModified = false;
      
      // Update recent files
      _recentFiles.remove(filePath);
      _recentFiles.insert(0, filePath);
      if (_recentFiles.length > 10) {
        _recentFiles = _recentFiles.sublist(0, 10);
      }
      await _saveRecentFiles();
      
      notifyListeners();
    } catch (e) {
      throw Exception('Error loading file: $e');
    }
  }

  Future<void> saveFile([String? filePath]) async {
    try {
      final targetPath = filePath ?? _currentFilePath;
      if (targetPath == null) {
        throw Exception('No file path specified');
      }

      final file = File(targetPath);
      await file.writeAsString(_content);
      _currentFilePath = targetPath;
      _isModified = false;

      // Update recent files
      if (!_recentFiles.contains(targetPath)) {
        _recentFiles.insert(0, targetPath);
        if (_recentFiles.length > 10) {
          _recentFiles = _recentFiles.sublist(0, 10);
        }
        await _saveRecentFiles();
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Error saving file: $e');
    }
  }

  Future<void> newFile() async {
    _content = '';
    _currentFilePath = null;
    _isModified = false;
    notifyListeners();
  }

  void clearRecentFiles() {
    _recentFiles.clear();
    _saveRecentFiles();
    notifyListeners();
  }
}
