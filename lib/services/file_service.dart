import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'encoding_service.dart';

class FileService {
  static const List<String> supportedExtensions = [
    'txt', 'md', 'json', 'xml', 'html', 'css', 'js', 'py', 'dart', 'log', 'csv', 'ini'
  ];

  static Future<String?> openFile(BuildContext context) async {
    try {
      final XTypeGroup typeGroup = XTypeGroup(
        label: 'Text files',
        extensions: supportedExtensions,
      );
      
      final XFile? file = await openFiles(acceptedTypeGroups: [typeGroup]).then((files) => files.isNotEmpty ? files.first : null);
      return file?.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
      return null;
    }
  }

  static Future<String?> saveFile(BuildContext context, {String? defaultPath}) async {
    try {
      String suggestedName = 'untitled.txt';
      if (defaultPath != null) {
        suggestedName = path.basename(defaultPath);
      }

      final String? savePath = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'Text files',
            extensions: supportedExtensions,
          ),
        ],
      ).then((location) => location?.path);

      return savePath;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
      return null;
    }
  }

  static Future<(String, FileEncoding)> readFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final encoding = EncodingService.detectEncoding(bytes);
    final content = EncodingService.decodeBytes(bytes, encoding);
    return (content, encoding);
  }

  static Future<void> writeFile(String filePath, String content, FileEncoding encoding) async {
    final file = File(filePath);
    final bytes = EncodingService.encodeString(content, encoding);
    await file.writeAsBytes(bytes);
  }
}
