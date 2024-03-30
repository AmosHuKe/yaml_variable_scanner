import 'file.dart';

import 'model/check_model.dart';
import 'model/yaml_model.dart';

/// Check file contents with YAML variables
class VariableCheck with FileLoad {
  /// Check file contents with YAML variables
  ///
  /// - [yamlVariable] Flattened YAML variables
  /// - [filePath] File path
  /// - [ignoreCheckText] Ignore text that doesn't need to match (RegExp Syntax)
  VariableCheck(
    this.yamlVariable,
    this.filePath, {
    this.ignoreCheckText = const [],
  });

  /// Flattened YAML variables
  final List<YamlVariable> yamlVariable;

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

  Future<List<CheckResult>> run() async {
    final List<CheckResult> checkResultAll = [];

    for (final YamlVariable matchVariable in yamlVariable) {
      final String fileContent = await getFileContent(filePath);

      final Map<String, List<MatchPosition>> matchValueMap = {};
      for (final String matchValue in matchVariable.matchValue) {
        final RegExp regExp = RegExp(r'' + matchValue);
        final Iterable<RegExpMatch> matches = regExp.allMatches(fileContent);
        if (matches.isNotEmpty) {
          for (final RegExpMatch match in matches) {
            /// Ignore
            if (_ignoreMatch(fileContent, match.start, match.end)) continue;

            /// Add
            final String matchContent = match.group(0)!;
            final MatchPosition matchPosition = _matchPosition(
              fileContent,
              match.start,
            );
            matchValueMap.addAll({
              matchContent: [
                ...(matchValueMap[matchContent] ?? []),
                matchPosition,
              ],
            });
          }
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

  /// Ignore Match
  ///
  /// - [text] Text content
  /// - [matchStart] The index in the string where the match starts
  /// - [matchEnd] The index in the string after the last character of the match
  ///
  bool _ignoreMatch(String text, int matchStart, int matchEnd) {
    bool isIgnore = false;
    for (final String regExpIgnoreText in ignoreCheckText) {
      final RegExp regExp = RegExp(regExpIgnoreText, multiLine: true);
      Iterable<Match> matches = regExp.allMatches(text);
      for (final Match match in matches) {
        if (matchStart >= match.start && matchEnd <= match.end) {
          isIgnore = true;
          break;
        }
      }
    }
    return isIgnore;
  }

  /// Match Position
  ///
  /// - [text] Text content
  /// - [matchStart] The index in the string where the match starts
  ///
  /// e.g. line: 1, column: 1
  ///
  /// @return [MatchPosition]
  MatchPosition _matchPosition(String text, int matchStart) {
    /// line
    final List<String> lines = text.split('\n');
    int lineNumber = 0;
    int currentIndex = 0;
    for (final String line in lines) {
      currentIndex += line.length + 1;
      if (currentIndex > matchStart) break;
      lineNumber++;
    }
    final int line = lineNumber + 1;

    /// column
    final int lineStartIndex = text.lastIndexOf('\n', matchStart) + 1;
    final int column = matchStart - lineStartIndex + 1;

    return MatchPosition(line: line, column: column);
  }
}
