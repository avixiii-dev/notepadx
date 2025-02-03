import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;

class FileService {
  static const List<String> supportedExtensions = [
    'txt', 'md', 'json', 'xml', 'html', 'css', 'js', 'py', 'dart', 'log', 'csv', 'ini'
  ];

  static final List<XTypeGroup> _typeGroups = [
    XTypeGroup(
      label: 'Text files',
      extensions: supportedExtensions,
    ),
  ];

  /// Opens a file using the system file picker
  static Future<String?> openFile(BuildContext context) async {
    try {
      final List<XFile> files = await openFiles(
        acceptedTypeGroups: _typeGroups,
      );

      if (files.isNotEmpty) {
        return files.first.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Saves a file using the system file picker
  static Future<String?> saveFile(BuildContext context, {String? defaultPath}) async {
    try {
      String? suggestedName;
      
      if (defaultPath != null) {
        suggestedName = path.basename(defaultPath);
      }

      final FileSaveLocation? saveLocation = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: _typeGroups,
      );

      return saveLocation?.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  /// Reads the content of a file
  static Future<String> readFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }

  /// Writes content to a file
  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }
}
