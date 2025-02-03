import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../widgets/recent_files_menu.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/export_menu.dart';
import '../widgets/status_bar.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MenuBar(
            children: [
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      context.read<EditorProvider>().newFile();
                    },
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyN, control: true),
                    child: const Text('New'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      context.read<EditorProvider>().loadFile(context);
                    },
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyO, control: true),
                    child: const Text('Open'),
                  ),
                  const RecentFilesMenu(),
                  const Divider(),
                  MenuItemButton(
                    onPressed: () {
                      context.read<EditorProvider>().saveFile(context);
                    },
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
                    child: const Text('Save'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      context.read<EditorProvider>().saveFileAs(context);
                    },
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true),
                    child: const Text('Save As'),
                  ),
                ],
                child: const Text('File'),
              ),
              const ExportMenu(),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      final provider = context.read<EditorProvider>();
                      if (provider.canUndo) provider.undo();
                    },
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
                    child: const Text('Undo'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      final provider = context.read<EditorProvider>();
                      if (provider.canRedo) provider.redo();
                    },
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyY, control: true),
                    child: const Text('Redo'),
                  ),
                  const Divider(),
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const SettingsDialog(),
                      );
                    },
                    shortcut: const SingleActivator(LogicalKeyboardKey.comma, control: true),
                    child: const Text('Settings'),
                  ),
                ],
                child: const Text('Edit'),
              ),
            ],
          ),
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                // File operations
                const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
                  context.read<EditorProvider>().newFile();
                },
                const SingleActivator(LogicalKeyboardKey.keyO, control: true): () {
                  context.read<EditorProvider>().loadFile(context);
                },
                const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
                  context.read<EditorProvider>().saveFile(context);
                },
                const SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true): () {
                  context.read<EditorProvider>().saveFileAs(context);
                },
                
                // Edit operations
                const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
                  final provider = context.read<EditorProvider>();
                  if (provider.canUndo) provider.undo();
                },
                const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
                  final provider = context.read<EditorProvider>();
                  if (provider.canRedo) provider.redo();
                },
                
                // Settings
                const SingleActivator(LogicalKeyboardKey.comma, control: true): () {
                  showDialog(
                    context: context,
                    builder: (context) => const SettingsDialog(),
                  );
                },
              },
              child: Focus(
                autofocus: true,
                child: Consumer<EditorProvider>(
                  builder: (context, provider, child) {
                    return TextField(
                      controller: TextEditingController(text: provider.content)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: provider.content.length),
                        ),
                      maxLines: null,
                      expands: true,
                      onChanged: provider.updateContent,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const StatusBar(),
        ],
      ),
    );
  }
}
