import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Consumer<EditorProvider>(
        builder: (context, provider, child) {
          final fileName = provider.currentFilePath != null
              ? File(provider.currentFilePath!).uri.pathSegments.last
              : 'Untitled';
          final charCount = provider.content.length;
          final lineCount = provider.content.split('\n').length;
          
          return Row(
            children: [
              Text(
                fileName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                'Characters: $charCount  Lines: $lineCount',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                'Encoding: ${provider.currentEncodingName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
