import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/editor_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/editor_area.dart';
import '../widgets/status_bar.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  Future<void> _openFile(BuildContext context) async {
    try {
      final editorProvider = context.read<EditorProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File open feature coming soon. We are working on implementing a native file picker.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _saveFile(BuildContext context) async {
    try {
      final editorProvider = context.read<EditorProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File save feature coming soon. We are working on implementing a native file picker.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NotepadX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New File',
            onPressed: () {
              context.read<EditorProvider>().newFile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Open File',
            onPressed: () => _openFile(context),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () => _saveFile(context),
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              final themeProvider = context.read<ThemeProvider>();
              themeProvider.setThemeMode(
                themeProvider.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark
              );
            },
          ),
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: EditorArea(),
          ),
          StatusBar(),
        ],
      ),
    );
  }
}
