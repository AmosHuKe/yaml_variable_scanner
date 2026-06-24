import 'file.dart';

import 'model/check_model.dart';
import 'model/yaml_model.dart';

/// Check file contents with YAML variables
class VariableCheck {
  /// Check file contents with YAML variables
  ///
  /// - [yamlVariables] Flattened YAML variables
  /// - [filePath] File path
  /// - [ignoreCheckText] Ignore text that doesn't need to match (RegExp Syntax)
  /// - [regExpCache] Optional shared cache of compiled regular expressions.
  ///   Passing the same map for every file compiles each pattern only once.
  VariableCheck(
    this.yamlVariables,
    this.filePath, {
    this.ignoreCheckText = const [],
    Map<String, RegExp>? regExpCache,
  }) : _regExpCache = regExpCache ?? {};

  /// Flattened YAML variables
  final List<YamlVariable> yamlVariables;

  /// File path
  final String filePath;

  /// Ignore text that doesn't need to match
  ///
  /// e.g.
  /// - `r"^\s*---([\s\S]*?)---$"`
  /// - `r"^\s*{%-?\s*comment\s*-?%}([\s\S]*?){%-?\s*endcomment\s*-?%}$"`
  /// - `r"^\s*<!---?\s*([\s\S]*?)\s*-?-->$"`
  ///
  /// (RegExp Syntax)
  final List<String> ignoreCheckText;

  /// Shared cache of compiled regular expressions, keyed by match mode + pattern.
  /// Compiling each pattern once (instead of once per file/variable/match).
  final Map<String, RegExp> _regExpCache;

  Future<List<CheckResult>> run() async {
    final List<CheckResult> checkResultAll = [];
    final String fileContent = await FileLoad.getFileContent(filePath);

    /// Pre-compute ignored ranges once per file
    final List<({int start, int end})> ignoreRanges =
        _computeIgnoreRanges(fileContent);

    for (final YamlVariable matchVariable in yamlVariables) {
      final Map<String, List<MatchPosition>> matchValueMap = {};
      for (final String matchValue in matchVariable.matchValue) {
        final RegExp regExp = _cachedRegExp(matchValue);
        for (final RegExpMatch match in regExp.allMatches(fileContent)) {
          /// Ignore
          if (_isIgnored(ignoreRanges, match.start, match.end)) continue;

          /// Add
          final String matchContent = match.group(0)!;
          final MatchPosition matchPosition = _matchPosition(
            fileContent,
            match.start,
          );
          matchValueMap.addAll({
            matchContent: [
              ...matchValueMap[matchContent] ?? [],
              matchPosition,
            ],
          });
        }
      }
      if (matchValueMap.isNotEmpty) {
        checkResultAll.add(
          CheckResult(
            filePath: filePath,
            yamlKey: matchVariable.key,
            yamlValue: matchVariable.value,
            matchValue: matchValueMap,
          ),
        );
      }
    }
    return checkResultAll;
  }

  /// Returns a compiled [RegExp] for [pattern], reusing [_regExpCache].
  ///
  /// The cache key includes [multiLine] so the single-line and multi-line
  /// compilations of the same pattern never collide.
  RegExp _cachedRegExp(String pattern, {bool multiLine = false}) {
    final String key = '${multiLine ? 'multi-line-' : 'single-line-'}$pattern';
    return _regExpCache[key] ??= RegExp(pattern, multiLine: multiLine);
  }

  /// Compute ignored ranges for [text].
  ///
  /// Each entry of [ignoreCheckText] is matched against the whole text once and
  /// every matched `(start, end)` span is collected.
  /// A match position is later ignored when it is fully contained in any of these spans.
  ///
  /// - [text] Text content
  List<({int start, int end})> _computeIgnoreRanges(String text) {
    final List<({int start, int end})> ranges = [];
    for (final String regExpIgnoreText in ignoreCheckText) {
      final RegExp regExp = _cachedRegExp(regExpIgnoreText, multiLine: true);
      for (final Match match in regExp.allMatches(text)) {
        ranges.add((start: match.start, end: match.end));
      }
    }
    return ranges;
  }

  /// Whether `(matchStart, matchEnd)` is fully contained in any ignored range.
  ///
  /// - [ignoreRanges] Pre-computed ignored ranges
  /// - [matchStart] The index in the string where the match starts
  /// - [matchEnd] The index in the string after the last character of the match
  bool _isIgnored(
    List<({int start, int end})> ignoreRanges,
    int matchStart,
    int matchEnd,
  ) {
    for (final range in ignoreRanges) {
      if (matchStart >= range.start && matchEnd <= range.end) return true;
    }
    return false;
  }

  /// Match Position
  ///
  /// e.g. line: 1, column: 1
  ///
  /// - [text] Text content
  /// - [matchStart] The index in the string where the match starts
  ///
  /// @return [MatchPosition]
  MatchPosition _matchPosition(String text, int matchStart) {
    /// line: count the newlines before [matchStart]
    int line = 1;
    for (int i = 0; i < matchStart; i++) {
      // 0x0A is the ASCII code for '\n'
      if (text.codeUnitAt(i) == 0x0A) line++;
    }

    /// column
    final int lineStartIndex = text.lastIndexOf('\n', matchStart) + 1;
    final int column = matchStart - lineStartIndex + 1;

    return MatchPosition(line: line, column: column);
  }
}
