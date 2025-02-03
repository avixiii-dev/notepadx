import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorProvider>(
      builder: (context, editorProvider, child) {
        final content = editorProvider.content;
        final lines = content.split('\n').length;
        final characters = content.length;
        final words = content.trim().split(RegExp(r'\s+')).length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Lines: $lines',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                'Words: $words',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                'Characters: $characters',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (editorProvider.currentFilePath != null)
                Text(
                  'Path: ${editorProvider.currentFilePath}',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        );
      },
    );
  }
}
