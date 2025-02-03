import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:markdown/markdown.dart' as md;
import 'package:html/parser.dart' as html;
import 'package:printing/printing.dart';
import 'package:path/path.dart' as path;

enum ExportFormat {
  pdf,
  markdown,
  html
}

class ExportService {
  static Future<void> exportToPdf(BuildContext context, String content, {String? defaultPath}) async {
    try {
      final pdf = pw.Document();
      
      // Add content to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(content),
            );
          },
        ),
      );

      // Get save location
      String? filePath = defaultPath;
      if (filePath == null) {
        final FileSaveLocation? saveLocation = await getSaveLocation(
          suggestedName: 'document.pdf',
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'PDF',
              extensions: ['pdf'],
            ),
          ],
        );
        if (saveLocation == null) return;
        filePath = saveLocation.path;
      }

      // Save PDF file
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show preview
      if (context.mounted) {
        await Printing.layoutPdf(
          onLayout: (format) async => pdf.save(),
          name: path.basename(filePath),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting to PDF: $e')),
        );
      }
      rethrow;
    }
  }

  static Future<void> exportToMarkdown(BuildContext context, String content, {String? defaultPath}) async {
    try {
      // Get save location
      String? filePath = defaultPath;
      if (filePath == null) {
        final FileSaveLocation? saveLocation = await getSaveLocation(
          suggestedName: 'document.md',
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'Markdown',
              extensions: ['md', 'markdown'],
            ),
          ],
        );
        if (saveLocation == null) return;
        filePath = saveLocation.path;
      }

      // Save Markdown file
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting to Markdown: $e')),
        );
      }
      rethrow;
    }
  }

  static Future<void> exportToHtml(BuildContext context, String content, {String? defaultPath}) async {
    try {
      // Convert Markdown to HTML if content appears to be Markdown
      final htmlContent = md.markdownToHtml(content);
      
      // Create a complete HTML document
      final document = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exported Document</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        pre {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        code {
            font-family: monospace;
        }
    </style>
</head>
<body>
$htmlContent
</body>
</html>
''';

      // Get save location
      String? filePath = defaultPath;
      if (filePath == null) {
        final FileSaveLocation? saveLocation = await getSaveLocation(
          suggestedName: 'document.html',
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'HTML',
              extensions: ['html', 'htm'],
            ),
          ],
        );
        if (saveLocation == null) return;
        filePath = saveLocation.path;
      }

      // Save HTML file
      final file = File(filePath);
      await file.writeAsString(document);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting to HTML: $e')),
        );
      }
      rethrow;
    }
  }
}
