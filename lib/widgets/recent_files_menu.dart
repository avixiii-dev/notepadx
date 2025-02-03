import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';

class RecentFilesMenu extends StatelessWidget {
  const RecentFilesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Files',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: Consumer<EditorProvider>(
                  builder: (context, editorProvider, child) {
                    if (editorProvider.recentFiles.isEmpty) {
                      return const Center(
                        child: Text('No recent files'),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: editorProvider.recentFiles.length,
                      itemBuilder: (context, index) {
                        final filePath = editorProvider.recentFiles[index];
                        final file = File(filePath);
                        
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(
                            file.uri.pathSegments.last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            filePath,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            // Check for unsaved changes
                            if (editorProvider.isModified) {
                              final save = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Unsaved Changes'),
                                  content: const Text(
                                    'Do you want to save the changes before opening another file?'
                                  ),
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

                            final success = await editorProvider.loadRecentFile(filePath);
                            if (success) {
                              Navigator.pop(context); // Close recent files dialog
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to open file'),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
                  context.read<EditorProvider>().clearRecentFiles();
                },
                child: const Text('Clear Recent Files'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
