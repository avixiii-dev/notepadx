import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import 'package:path/path.dart' as path;

class RecentFilesMenu extends StatelessWidget {
  const RecentFilesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        if (provider.recentFiles.isEmpty) {
          return MenuItemButton(
            onPressed: null,
            child: const Text('No recent files'),
          );
        }

        return SubmenuButton(
          menuChildren: [
            ...provider.recentFiles.map(
              (filePath) => MenuItemButton(
                onPressed: () => provider.openRecentFile(context, filePath),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            path.basename(filePath),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            filePath,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!File(filePath).existsSync())
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
            const Divider(),
            MenuItemButton(
              onPressed: () {
                provider.recentFiles.clear();
                provider.notifyListeners();
              },
              child: const Text('Clear Recent Files'),
            ),
          ],
          child: const Text('Open Recent'),
        );
      },
    );
  }
}
