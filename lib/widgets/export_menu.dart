import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../services/export_service.dart';

class ExportMenu extends StatelessWidget {
  const ExportMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        return SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () => _exportFile(context, provider, ExportFormat.pdf),
              child: const Text('Export as PDF'),
            ),
            MenuItemButton(
              onPressed: () => _exportFile(context, provider, ExportFormat.markdown),
              child: const Text('Export as Markdown'),
            ),
            MenuItemButton(
              onPressed: () => _exportFile(context, provider, ExportFormat.html),
              child: const Text('Export as HTML'),
            ),
          ],
          child: const Text('Export'),
        );
      },
    );
  }

  Future<void> _exportFile(BuildContext context, EditorProvider provider, ExportFormat format) async {
    try {
      switch (format) {
        case ExportFormat.pdf:
          await ExportService.exportToPdf(context, provider.content);
          break;
        case ExportFormat.markdown:
          await ExportService.exportToMarkdown(context, provider.content);
          break;
        case ExportFormat.html:
          await ExportService.exportToHtml(context, provider.content);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export file: $e')),
        );
      }
    }
  }
}
