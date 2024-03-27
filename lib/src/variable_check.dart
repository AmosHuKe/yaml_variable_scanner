import 'file.dart';

import 'model/check_model.dart';
import 'model/yaml_model.dart';

class VariableCheck with FileLoad {
  /// Check file contents with YAML variables
  ///
  /// - [yamlVariable] Flattened YAML variables
  /// - [filePath] File path
  VariableCheck(
    this.yamlVariable,
    this.filePath,
  );

  /// Flattened YAML variables
  final List<YamlVariable> yamlVariable;

  /// File path
  final String filePath;

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

  MatchPosition _matchPosition(String text, int matchIndex) {
    final List<String> lines = text.split('\n');
    int lineNumber = 0;
    int currentIndex = 0;
    for (final String line in lines) {
      currentIndex += line.length + 1;
      if (currentIndex > matchIndex) break;
      lineNumber++;
    }
    final int line = lineNumber + 1;

    final int lineStartIndex = text.lastIndexOf('\n', matchIndex) + 1;
    final int column = matchIndex - lineStartIndex + 1;

    return MatchPosition(line: line, column: column);
  }
}
