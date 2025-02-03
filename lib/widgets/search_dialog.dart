import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../services/search_service.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _searchController = TextEditingController();
  final _replaceController = TextEditingController();
  bool _caseSensitive = false;
  bool _useRegex = false;
  bool _wholeWord = false;
  List<SearchMatch> _matches = [];
  int _currentMatchIndex = -1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final content = context.read<EditorProvider>().content;
    final query = _searchController.text;

    setState(() {
      _matches = SearchService.findMatches(
        content,
        query,
        options: SearchOptions(
          caseSensitive: _caseSensitive,
          useRegex: _useRegex,
          wholeWord: _wholeWord,
        ),
      );
      _currentMatchIndex = _matches.isEmpty ? -1 : 0;
    });
  }

  void _findNext() {
    if (_matches.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matches.length;
    });
    _scrollToMatch(_matches[_currentMatchIndex]);
  }

  void _findPrevious() {
    if (_matches.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _matches.length) % _matches.length;
    });
    _scrollToMatch(_matches[_currentMatchIndex]);
  }

  void _scrollToMatch(SearchMatch match) {
    // TODO: Implement scrolling to match
  }

  void _replace() {
    if (_currentMatchIndex == -1) return;
    
    final provider = context.read<EditorProvider>();
    final match = _matches[_currentMatchIndex];
    final replacement = _replaceController.text;
    
    final newContent = SearchService.replaceMatches(
      provider.content,
      [match],
      replacement,
      useRegex: _useRegex,
    );
    
    provider.updateContent(newContent);
    _onSearchChanged(); // Refresh matches
  }

  void _replaceAll() {
    if (_matches.isEmpty) return;
    
    final provider = context.read<EditorProvider>();
    final replacement = _replaceController.text;
    
    final newContent = SearchService.replaceMatches(
      provider.content,
      _matches,
      replacement,
      useRegex: _useRegex,
    );
    
    provider.updateContent(newContent);
    _onSearchChanged(); // Refresh matches
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Find',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: _findPrevious,
                      tooltip: 'Find Previous',
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: _findNext,
                      tooltip: 'Find Next',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _replaceController,
              decoration: const InputDecoration(
                labelText: 'Replace with',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Case Sensitive'),
                  selected: _caseSensitive,
                  onSelected: (value) => setState(() {
                    _caseSensitive = value;
                    _onSearchChanged();
                  }),
                ),
                FilterChip(
                  label: const Text('Regex'),
                  selected: _useRegex,
                  onSelected: (value) => setState(() {
                    _useRegex = value;
                    _onSearchChanged();
                  }),
                ),
                FilterChip(
                  label: const Text('Whole Word'),
                  selected: _wholeWord,
                  onSelected: (value) => setState(() {
                    _wholeWord = value;
                    _onSearchChanged();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _matches.isEmpty
                      ? 'No matches'
                      : 'Match ${_currentMatchIndex + 1} of ${_matches.length}',
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _matches.isEmpty ? null : _replace,
                      child: const Text('Replace'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _matches.isEmpty ? null : _replaceAll,
                      child: const Text('Replace All'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
