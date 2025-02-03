import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final editorProvider = context.watch<EditorProvider>();
    final fileName = editorProvider.currentFilePath?.split('\\').last ?? 'Untitled';
    final isModified = editorProvider.isModified;

    return WindowTitleBarBox(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'NotepadX - ${isModified ? "*" : ""}$fileName',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            WindowButtons(),
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: Theme.of(context).colorScheme.onSurface,
      mouseOver: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      mouseDown: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      iconMouseOver: Theme.of(context).colorScheme.primary,
      iconMouseDown: Theme.of(context).colorScheme.primary,
    );

    final closeButtonColors = WindowButtonColors(
      mouseOver: Colors.red,
      mouseDown: Colors.red.shade800,
      iconNormal: Theme.of(context).colorScheme.onSurface,
      iconMouseOver: Colors.white,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
