import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'encoding_service.dart';

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

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: _typeGroups,
      );

      return location?.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  /// Reads the content of a file with encoding detection
  static Future<(String, FileEncoding)> readFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final encoding = EncodingService.detectEncoding(bytes);
    final content = EncodingService.decodeBytes(bytes, encoding);
    return (content, encoding);
  }

  /// Writes content to a file with specified encoding
  static Future<void> writeFile(String filePath, String content, FileEncoding encoding) async {
    final file = File(filePath);
    final bytes = EncodingService.encodeString(content, encoding);
    await file.writeAsBytes(bytes);
  }
}
