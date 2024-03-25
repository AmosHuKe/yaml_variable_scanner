import 'dart:io';

import 'package:yaml/yaml.dart';

import 'file.dart';
import 'utils.dart';

import 'model/config_model.dart';
import 'model/check_model.dart';
import 'model/yaml_model.dart';

class YamlVariableScanner {
  const YamlVariableScanner._();

  /// Run scanning check
  ///
  /// - [configPath] `yaml_variable_scanner.yaml` config file path
  /// - [stdout] Stdout
  /// - [prefix] Variable prefixes for deep variable checking.
  ///            e.g. `(yamlKey) => 'site.$yamlKey'` -> `site.aa`
  /// - [enablePrint] Console Print
  static Future<List<CheckResult>> run(
    String configPath,
    Stdout stdout, {
    PrefixFunction? prefix,
    enablePrint = true,
  }) async {
    void print(Object message) => stdout.writeln(message);

    final List<CheckResult> checkResultList = [];

    /// Get configuration
    final YamlVariableScannerConfig scannerConfig =
        await ConfigLoad(configPath).getConfig();

    /// Get YAML variables
    final List<YamlVariable> yamlVariableAll = await YamlLoad(
      scannerConfig.yamlFilePath ?? [],
      ignoreGlobPathList: scannerConfig.ignoreYamlFilePath ?? [],
      ignoreYamlKeyList: scannerConfig.ignoreYamlKey ?? [],
      prefix: prefix,
    ).getVariable();

    /// Get directory files to scan
    final List<String> filePathAll = FilePath(
      scannerConfig.checkFilePath ?? [],
      ignoreGlobPathList: scannerConfig.ignoreFilePath ?? [],
    ).getPath();

    /// YAML all results
    // final Map<String, YamlCheckResult> yamlCheckResultAll = {};

    /// Start check
    for (final String filePath in filePathAll) {
      final List<CheckResult> checkResultAll =
          await VariableCheck(yamlVariableAll, filePath).run();

      if (checkResultAll.isNotEmpty) {
        checkResultList.addAll(checkResultAll);

        if (enablePrint) {
          print('');
          for (final CheckResult checkResult in checkResultAll) {
            print('[File Path]: ${checkResult.filePath}');
            print('├── [YAML Key]: ${checkResult.yamlKey}');
            print('└── [YAML Value]: ${checkResult.yamlValue}');
            for (final matchValue in checkResult.matchValue.entries) {
              print('    ├── [Match Value]: ${matchValue.key}');
              print('    └── [Total Matches]: ${matchValue.value}');
            }
            print('');
          }
        }
      }
    }

    // if (enablePrint && yamlCheckResultAll.isNotEmpty) {
    //   print('------------------------------------------------');
    //   print('[YAML Total Matches]:');
    //   for (final yamlCheckResult in yamlCheckResultAll.entries) {
    //     print('''
    // │
    // ├── [YAML Key]: ${yamlCheckResult.key}
    // └── [YAML Value]: ${yamlCheckResult.value.yamlValue}''');

    //     for (final matchValue in yamlCheckResult.value.matchValue.entries) {
    //       print('''
    //     ├── [Match Value]: ${matchValue.key}
    //     └── [Total Matches]: ${matchValue.value}''');
    //     }
    //   }
    //   print('------------------------------------------------');
    // }

    return checkResultList;
  }
}

class ConfigLoad with FileLoad {
  /// Load yaml_variable_scanner.yaml config
  ///
  /// - [filePath] `yaml_variable_scanner.yaml` config file path
  ConfigLoad(this.filePath);

  /// `yaml_variable_scanner.yaml` config file path
  final String filePath;

  Future<YamlVariableScannerConfig> getConfig() async {
    final String configLines = await getFileContent(filePath);
    final yamlConfig = loadYaml(configLines)['yaml_variable_scanner'];
    final List<String>? yamlFilePath = (yamlConfig['yamlFilePath'] as List?)
        ?.map((value) => value.toString())
        .toList();
    final List<String>? ignoreYamlFilePath =
        (yamlConfig['ignoreYamlFilePath'] as List?)
            ?.map((value) => value.toString())
            .toList();
    final List<String>? ignoreYamlKey = (yamlConfig['ignoreYamlKey'] as List?)
        ?.map((value) => value.toString())
        .toList();
    final List<String>? checkFilePath = (yamlConfig['checkFilePath'] as List?)
        ?.map((value) => value.toString())
        .toList();
    final List<String>? ignoreFilePath = (yamlConfig['ignoreFilePath'] as List?)
        ?.map((value) => value.toString())
        .toList();

    return YamlVariableScannerConfig(
      yamlFilePath: yamlFilePath,
      ignoreYamlFilePath: ignoreYamlFilePath,
      ignoreYamlKey: ignoreYamlKey,
      checkFilePath: checkFilePath,
      ignoreFilePath: ignoreFilePath,
    );
  }
}

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
          yamlMatchAll.add(
            yamlVariable.value.escapedPatternValue.replaceAll(
              regExp.pattern,
              '{{\\s*${prefixValue.escapedPatternValue}.*?}}',
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
          _flattenCollection(
            entry.value,
            '$prefix${entry.key}.',
            result,
          );
        }
        break;
      case List _:
        for (int i = 0; i < collections.length; i++) {
          _flattenCollection(
            collections[i],
            '$prefix[${i.toString()}].',
            result,
          );
        }
        break;
      default:
        result[prefix.substring(0, prefix.length - 1)] = collections.toString();
        break;
    }
  }
}

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
