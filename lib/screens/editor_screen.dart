import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../widgets/recent_files_menu.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/export_menu.dart';
import '../widgets/status_bar.dart';
import '../widgets/search_dialog.dart';

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
                    child: const Text('New'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      context.read<EditorProvider>().loadFile(context);
                    },
                    child: const Text('Open'),
                  ),
                  const RecentFilesMenu(),
                  const Divider(),
                  MenuItemButton(
                    onPressed: () {
                      context.read<EditorProvider>().saveFile(context);
                    },
                    child: const Text('Save'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      context.read<EditorProvider>().saveFileAs(context);
                    },
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
                      showDialog(
                        context: context,
                        builder: (context) => const SearchDialog(),
                      );
                    },
                    child: const Text('Find and Replace'),
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyF, control: true),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const SettingsDialog(),
                      );
                    },
                    child: const Text('Settings'),
                  ),
                ],
                child: const Text('Edit'),
              ),
            ],
          ),
          Expanded(
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
          const StatusBar(),
        ],
      ),
    );
  }
}
