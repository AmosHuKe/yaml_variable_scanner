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

      final Map<String, int> matchValueMap = {};
      for (final String matchValue in matchVariable.matchValue) {
        final RegExp regExp = RegExp(r'' + matchValue);
        final Iterable<RegExpMatch> matches = regExp.allMatches(fileContent);
        if (matches.isNotEmpty) {
          for (final RegExpMatch match in matches) {
            matchValueMap.addAll({
              match.group(0)!: (matchValueMap[match.group(0)] ?? 0) + 1,
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
}
