import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/editor_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/editor_area.dart';
import '../widgets/status_bar.dart';
import '../widgets/recent_files_menu.dart';
import '../services/encoding_service.dart';
import '../widgets/settings_dialog.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  Future<void> _openFile(BuildContext context) async {
    final editorProvider = context.read<EditorProvider>();
    
    // Check for unsaved changes
    if (editorProvider.isModified) {
      final save = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save the changes before opening a new file?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, null),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (save == null) return; // User cancelled
      if (save) {
        final saved = await editorProvider.saveFile(context);
        if (!saved) return; // Save failed or cancelled
      }
    }

    final success = await editorProvider.loadFile(context);
    if (!success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open file')),
        );
      }
    }
  }

  Future<void> _saveFile(BuildContext context) async {
    final editorProvider = context.read<EditorProvider>();
    final success = await editorProvider.saveFile(context);
    
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save file')),
        );
      }
    }
  }

  Future<void> _saveFileAs(BuildContext context) async {
    final editorProvider = context.read<EditorProvider>();
    final success = await editorProvider.saveFileAs(context);
    
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save file')),
        );
      }
    }
  }

  Future<void> _newFile(BuildContext context) async {
    final editorProvider = context.read<EditorProvider>();
    
    // Check for unsaved changes
    if (editorProvider.isModified) {
      final save = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save the changes before creating a new file?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, null),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (save == null) return; // User cancelled
      if (save) {
        final saved = await editorProvider.saveFile(context);
        if (!saved) return; // Save failed or cancelled
      }
    }

    editorProvider.newFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<EditorProvider>(
          builder: (context, editorProvider, child) {
            final fileName = editorProvider.currentFilePath != null
                ? File(editorProvider.currentFilePath!).uri.pathSegments.last
                : 'Untitled';
            return Text('NotepadX - ${editorProvider.isModified ? "*" : ""}$fileName');
          },
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'File Menu',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('New'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open),
                    SizedBox(width: 8),
                    Text('Open...'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'saveAs',
                child: Row(
                  children: [
                    Icon(Icons.save_as),
                    SizedBox(width: 8),
                    Text('Save As...'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('Recent Files'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'new':
                  await _newFile(context);
                  break;
                case 'open':
                  await _openFile(context);
                  break;
                case 'save':
                  await _saveFile(context);
                  break;
                case 'saveAs':
                  await _saveFileAs(context);
                  break;
                case 'recent':
                  await showDialog(
                    context: context,
                    builder: (context) => const RecentFilesMenu(),
                  );
                  break;
              }
            },
          ),
          const SizedBox(width: 8),
          Consumer<EditorProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<FileEncoding>(
                tooltip: 'Encoding',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.text_fields, size: 20),
                      const SizedBox(width: 4),
                      Text(provider.currentEncodingName),
                    ],
                  ),
                ),
                itemBuilder: (context) => provider.supportedEncodings
                    .map(
                      (encoding) => PopupMenuItem(
                        value: encoding,
                        child: Text(EncodingService.getEncodingName(encoding)),
                      ),
                    )
                    .toList(),
                onSelected: (encoding) {
                  provider.setEncoding(encoding);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Changed encoding to ${EncodingService.getEncodingName(encoding)}'),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final themeProvider = context.read<ThemeProvider>();
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: EditorArea(),
          ),
          StatusBar(),
        ],
      ),
    );
  }
}
