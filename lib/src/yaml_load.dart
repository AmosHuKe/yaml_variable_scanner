import 'package:yaml/yaml.dart';

import 'utils.dart';
import 'file.dart';

import 'model/config_model.dart';
import 'model/yaml_model.dart';

/// Load YAML variables
class YamlLoad with FileLoad {
  /// Load YAML variables
  ///
  /// - [yamlFilePathList] List [YamlFilePath]
  /// - [ignoreGlobPathList] Ignore YAML paths (Glob syntax)
  /// - [ignoreYamlKeyList] Ignore YAML keys (RegExp syntax)
  ///
  const YamlLoad(
    this.yamlFilePathList, {
    this.ignoreGlobPathList = const [],
    this.ignoreYamlKeyList = const [],
  });

  /// File path for YAML variables
  final List<YamlFilePath> yamlFilePathList;

  /// Ignore file paths (Glob syntax)
  final List<String> ignoreGlobPathList;

  /// Ignore YAML keys (RegExp syntax)
  final List<String> ignoreYamlKeyList;

  Future<List<YamlVariable>> getVariable() async {
    final List<YamlVariable> yamlVariableAll = [];
    final Map<String, String> yamlAll = {};

    for (final YamlFilePath yamlFilePath in yamlFilePathList) {
      final List<String> pathList = getFilePath(
        [yamlFilePath.path],
        ignoreGlobPathList,
      );
      for (final String path in pathList) {
        final String lines = await getFileContent(path);
        final yamlDoc = loadYaml(lines);
        final Map<String, String> yamlCollections = _flattenYaml(yamlDoc);
        yamlAll.addAll(
          /// prefix
          yamlCollections.map(
            (key, value) =>
                MapEntry('${yamlFilePath.variablePrefix}$key', value),
          ),
        );
      }
    }

    /// Ignore YAML keys
    for (final String ignoreYamlKey in ignoreYamlKeyList) {
      final RegExp regExp = RegExp(ignoreYamlKey);
      yamlAll.removeWhere((key, value) => regExp.hasMatch(key));
    }

    /// Deep variable
    for (final yamlVariable in yamlAll.entries) {
      final List<String> yamlMatchAll = [];

      for (final yamlMatch in yamlAll.entries) {
        if (yamlVariable.key == yamlMatch.key ||
            yamlVariable.value == yamlMatch.value) continue;

        final String yamlMatchValue = yamlMatch.value.escapedPatternValue;
        final RegExp regExp = RegExp(r'' + yamlMatchValue);
        final bool hasMatch = regExp.hasMatch(yamlVariable.value);
        if (hasMatch) {
          /// {{ prefix }}
          yamlMatchAll.add(
            yamlVariable.value.escapedPatternValue.replaceAll(
              regExp.pattern,
              r'{{\s*' + yamlMatch.key.escapedPatternValue + r'.*?}}',
            ),
          );
        }
      }

      yamlVariableAll.add(
        YamlVariable(
          key: yamlVariable.key,
          value: yamlVariable.value,
          matchValue: [yamlVariable.value.escapedPatternValue, ...yamlMatchAll],
        ),
      );
    }

    return yamlVariableAll;
  }

  /// Flatten YAML collection result
  ///
  /// - [collections] e.g. Map, List
  Map<String, String> _flattenYaml(dynamic collections) {
    final Map<String, String> result = {};
    _flattenCollection(collections, '', result);
    return result;
  }

  /// Flatten Collection
  ///
  /// - [collections] e.g. Map, List
  /// - [prefix] prefix. e.g. aa.bb
  /// - [result] result
  ///
  /// e.g.
  /// ```
  /// {
  ///   a: {b: 123},
  ///   b: [a, c],
  /// }
  /// ```
  ///
  /// Flatten:
  /// ```
  /// {
  ///   a.b: 123,
  ///   b.[0]: a,
  ///   b.[1]: c,
  /// }
  /// ```
  ///
  void _flattenCollection(
    dynamic collections,
    String prefix,
    Map<String, String> result,
  ) {
    switch (collections) {
      case Map _:
        for (final entry in collections.entries) {
          _flattenCollection(entry.value, '$prefix${entry.key}.', result);
        }
        break;
      case List _:
        for (int i = 0; i < collections.length; i++) {
          final listPrefix = '${prefix.replaceFirst(RegExp(r'\.$'), '')}[$i].';
          _flattenCollection(collections[i], listPrefix, result);
        }
        break;
      default:
        if (collections != null) {
          result[prefix.substring(0, prefix.length - 1)] =
              collections.toString();
        }
        break;
    }
  }
}
