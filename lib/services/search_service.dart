import 'package:flutter/material.dart';

class SearchMatch {
  final int start;
  final int end;
  final String text;
  final String replacement;

  SearchMatch({
    required this.start,
    required this.end,
    required this.text,
    this.replacement = '',
  });
}

class SearchOptions {
  final bool caseSensitive;
  final bool useRegex;
  final bool wholeWord;
  final bool multiline;

  const SearchOptions({
    this.caseSensitive = false,
    this.useRegex = false,
    this.wholeWord = false,
    this.multiline = true,
  });
}

class SearchService {
  static List<SearchMatch> findMatches(
    String content,
    String query, {
    SearchOptions options = const SearchOptions(),
  }) {
    if (query.isEmpty) return [];

    final matches = <SearchMatch>[];
    RegExp regex;

    try {
      if (options.useRegex) {
        // Use the query directly as a regex pattern
        final flags = '${options.caseSensitive ? '' : 'i'}${options.multiline ? 'm' : ''}';
        regex = RegExp(query, multiLine: options.multiline, caseSensitive: options.caseSensitive);
      } else {
        // Escape special regex characters for plain text search
        final escapedQuery = RegExp.escape(query);
        final pattern = options.wholeWord ? '\\b$escapedQuery\\b' : escapedQuery;
        regex = RegExp(
          pattern,
          multiLine: options.multiline,
          caseSensitive: options.caseSensitive,
        );
      }

      for (final match in regex.allMatches(content)) {
        matches.add(SearchMatch(
          start: match.start,
          end: match.end,
          text: match.group(0) ?? '',
        ));
      }
    } catch (e) {
      debugPrint('Search error: $e');
      // Return empty list for invalid regex
      return [];
    }

    return matches;
  }

  static String replaceMatches(
    String content,
    List<SearchMatch> matches,
    String replacement, {
    bool useRegex = false,
  }) {
    if (matches.isEmpty) return content;

    // Sort matches in reverse order to avoid offset issues
    final sortedMatches = List<SearchMatch>.from(matches)
      ..sort((a, b) => b.start.compareTo(a.start));

    var result = content;
    for (final match in sortedMatches) {
      final actualReplacement = useRegex
          ? match.text.replaceAllMapped(
              RegExp(match.text),
              (m) => replacement,
            )
          : replacement;

      result = result.replaceRange(match.start, match.end, actualReplacement);
    }

    return result;
  }

  static int countMatches(String content, String query, SearchOptions options) {
    return findMatches(content, query, options: options).length;
  }
}
