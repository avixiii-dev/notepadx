import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';

class EditorArea extends StatefulWidget {
  const EditorArea({super.key});

  @override
  State<EditorArea> createState() => _EditorAreaState();
}

class _EditorAreaState extends State<EditorArea> {
  late TextEditingController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editorProvider = context.read<EditorProvider>();
      _controller.text = editorProvider.content;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorProvider>(
      builder: (context, editorProvider, child) {
        if (_controller.text != editorProvider.content) {
          _controller.text = editorProvider.content;
        }

        return Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: TextField(
            controller: _controller,
            scrollController: _scrollController,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'Consolas',
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(16.0),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
            onChanged: (value) {
              editorProvider.updateContent(value);
            },
          ),
        );
      },
    );
  }
}
