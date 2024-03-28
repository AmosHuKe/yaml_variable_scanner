import 'package:yaml/yaml.dart';

import 'utils.dart';
import 'file.dart';

import 'model/yaml_model.dart';

typedef PrefixFunction = String Function(String yamlKey);

class YamlLoad extends FilePath with FileLoad {
  /// Load YAML variables
  ///
  /// - [globPathList] YAML paths (Glob syntax)
  /// - [ignoreGlobPathList] Ignore YAML paths (Glob syntax)
  /// - [ignoreYamlKeyList] Ignore YAML keys (RegExp syntax)
  /// - [prefix] Variable prefixes for deep variable checking.
  ///            e.g. `(yamlKey) => 'site.$yamlKey'` -> `site.aa`
  const YamlLoad(
    super.globPathList, {
    super.ignoreGlobPathList,
    this.ignoreYamlKeyList = const [],
    this.prefix,
  });

  /// Ignore YAML keys (RegExp syntax)
  final List<String> ignoreYamlKeyList;

  /// Variable prefixes for deep variable checking.
  /// e.g. `(yamlKey) => 'site.$yamlKey'` -> `site.aa`
  final PrefixFunction? prefix;

  Future<List<YamlVariable>> getVariable() async {
    final List<YamlVariable> yamlVariableAll = [];
    final Map<String, String> yamlAll = {};

    final List<String> pathList = getPath();
    for (final String path in pathList) {
      final String lines = await getFileContent(path);
      final yamlDoc = loadYaml(lines);
      final Map<String, String> yamlCollections = _flattenYaml(yamlDoc);
      yamlAll.addAll(yamlCollections);
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
          final String prefixValue =
              prefix != null ? prefix!(yamlMatch.key) : yamlMatch.key;

          /// {{ prefix }}
          yamlMatchAll.add(
            yamlVariable.value.escapedPatternValue.replaceAll(
              regExp.pattern,
              r'{{\s*' + prefixValue.escapedPatternValue + r'.*?}}',
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
