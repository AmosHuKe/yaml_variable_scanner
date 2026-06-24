import 'package:yaml/yaml.dart';

import 'utils.dart';
import 'file.dart';

import 'model/config_model.dart';
import 'model/yaml_model.dart';

/// Load YAML variables
class YamlLoad {
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
      final List<String> pathList = FileLoad.getFilePath(
        [yamlFilePath.path],
        ignoreGlobPathList,
      );
      for (final String path in pathList) {
        final String lines = await FileLoad.getFileContent(path);
        final yamlDoc = loadYaml(lines);
        final Map<String, String> yamlCollections = _flattenYaml(yamlDoc);
        yamlAll.addAll(
          /// prefix
          yamlCollections.map(
            (key, value) => MapEntry(
              '${yamlFilePath.variablePrefix}$key',
              value,
            ),
          ),
        );
      }
    }

    /// Ignore YAML keys
    for (final String ignoreYamlKey in ignoreYamlKeyList) {
      final RegExp regExp = RegExp(ignoreYamlKey);
      yamlAll.removeWhere((key, value) => regExp.hasMatch(key));
    }

    /// Pre-compute per-entry escaped key/value and the value RegExp once,
    final List<MapEntry<String, String>> entries = yamlAll.entries.toList();
    final Map<String, String> escapedValue = {};
    final Map<String, String> escapedKey = {};
    final Map<String, RegExp> valueRegExp = {};
    for (final MapEntry<String, String> entry in entries) {
      final String escaped = entry.value.escapedPatternValue;
      escapedValue[entry.key] = escaped;
      escapedKey[entry.key] = entry.key.escapedPatternValue;
      valueRegExp[entry.key] = RegExp(escaped);
    }

    /// Deep variable
    for (final MapEntry<String, String> yamlVariable in entries) {
      final List<String> yamlMatchAll = [];

      /// Check if the value of the current variable matches any other variable's value,
      /// and if so, add `{{ other_variable }}` to the match list for the current variable.
      ///
      /// e.g. If we have two variables:
      /// - var1: "Hello"
      /// - var2: "Hello, World!"
      ///
      /// Then `var2`'s value contains `var1`'s value, so we replace it with `{{ var1 }}` in the match.
      ///
      /// This allows `{{ var1 }}, World!` to be recognized as a match for `var2`'s value.
      ///
      for (final MapEntry<String, String> yamlMatch in entries) {
        /// Skip self-match
        if (yamlVariable.key == yamlMatch.key ||
            yamlVariable.value == yamlMatch.value) {
          continue;
        }

        final RegExp regExp = valueRegExp[yamlMatch.key]!;
        if (regExp.hasMatch(yamlVariable.value)) {
          /// {{ prefix }}
          yamlMatchAll.add(
            escapedValue[yamlVariable.key]!.replaceAll(
              regExp.pattern,
              r'{{\s*' + escapedKey[yamlMatch.key]! + r'.*?}}',
            ),
          );
        }
      }

      yamlVariableAll.add(
        YamlVariable(
          key: yamlVariable.key,
          value: yamlVariable.value,
          matchValue: [escapedValue[yamlVariable.key]!, ...yamlMatchAll],
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
      case List _:
        for (int i = 0; i < collections.length; i++) {
          final listPrefix = '${prefix.replaceFirst(RegExp(r'\.$'), '')}[$i].';
          _flattenCollection(collections[i], listPrefix, result);
        }
      default:
        if (collections != null) {
          result[prefix.substring(0, prefix.length - 1)] =
              collections.toString();
        }
    }
  }
}
