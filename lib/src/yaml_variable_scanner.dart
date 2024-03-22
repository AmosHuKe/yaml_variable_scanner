import 'dart:io';

import 'package:yaml/yaml.dart';

import 'file.dart';
import 'utils.dart';

import 'model/check_model.dart';
import 'model/config_model.dart';

class YamlVariableScanner {
  const YamlVariableScanner._();

  /// Run scanning check
  ///
  /// - [configPath] `yaml_variable_scanner.yaml` config file path
  /// - [stdout] Stdout
  /// - [enablePrint] Console Print
  static Future<List<CheckResult>> run(
    String configPath,
    Stdout stdout, {
    enablePrint = true,
  }) async {
    void print(Object message) => stdout.writeln(message);

    final List<CheckResult> checkResultList = [];

    /// Get configuration
    final YamlVariableScannerConfig scannerConfig =
        await ConfigLoad(configPath).getConfig();

    /// Get YAML variables
    final Map<String, String> yamlConfigAll = await YamlLoad(
      scannerConfig.yamlFilePath ?? [],
      ignoreGlobPathList: scannerConfig.ignoreYamlFilePath ?? [],
      ignoreYamlKeyList: scannerConfig.ignoreYamlKey ?? [],
    ).getConfig();

    /// Get directory files to scan
    final List<String> filePathAll = FilePath(
      scannerConfig.checkFilePath ?? [],
      ignoreGlobPathList: scannerConfig.ignoreFilePath ?? [],
    ).getPath();

    /// YAML all results
    final Map<String, YamlCheckResult> yamlCheckResultAll = {};

    /// Start check
    for (final String filePath in filePathAll) {
      final List<CheckResult> checkResultAll =
          await VariableCheck(yamlConfigAll, filePath).run();

      if (checkResultAll.isNotEmpty) {
        checkResultList.addAll(checkResultAll);
        for (final CheckResult checkResult in checkResultAll) {
          yamlCheckResultAll.addAll({
            checkResult.yamlKey: YamlCheckResult(
              filePath: '',
              yamlKey: checkResult.yamlKey,
              yamlValue: checkResult.yamlValue,
              totalMatches: checkResult.totalMatches +
                  (yamlCheckResultAll[checkResult.yamlKey]?.totalMatches ?? 0),
            ),
          });
          if (enablePrint) {
            print('''
[File Path]: ${checkResult.filePath}
  ├── [YAML Key]: ${checkResult.yamlKey}
  ├── [YAML Value]: ${checkResult.yamlValue}
  └── [Total Matches]: ${checkResult.totalMatches}''');
            print('');
          }
        }
      }
    }

    if (enablePrint && yamlCheckResultAll.isNotEmpty) {
      print('------------------------------------------------');
      print('[YAML Total Matches]:');
      for (final yamlCheckResult in yamlCheckResultAll.entries) {
        print('''
  │
  ├── [YAML Key]: ${yamlCheckResult.key}
  │   ├── [YAML Value]: ${yamlCheckResult.value.yamlValue}
  │   └── [Total]: ${yamlCheckResult.value.totalMatches}''');
      }
      print('------------------------------------------------');
    }

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

class YamlLoad extends FilePath with FileLoad {
  /// Load YAML variables
  ///
  /// - [globPathList] YAML paths (Glob syntax)
  /// - [ignoreGlobPathList] Ignore YAML paths (Glob syntax)
  /// - [ignoreYamlKeyList] Ignore YAML keys (RegExp syntax)
  const YamlLoad(
    super.globPathList, {
    super.ignoreGlobPathList,
    this.ignoreYamlKeyList = const [],
  });

  /// Ignore YAML keys (RegExp syntax)
  final List<String> ignoreYamlKeyList;

  Future<Map<String, String>> getConfig() async {
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
      final RegExp regExp = RegExp(
        ignoreYamlKey,
        multiLine: true,
        dotAll: true,
      );
      yamlAll.removeWhere((key, value) => regExp.hasMatch(key));
    }

    return yamlAll;
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
  /// - [yamlConfig] Flattened YAML variables
  /// - [filePath] File path
  VariableCheck(
    this.yamlConfig,
    this.filePath,
  );

  /// Flattened YAML variables
  final Map<String, String> yamlConfig;

  /// File path
  final String filePath;

  Future<List<CheckResult>> run() async {
    final List<CheckResult> checkResultAll = [];

    for (final MapEntry<String, String> matchConfig in yamlConfig.entries) {
      final String fileContent = await getFileContent(filePath);
      final String escapedPatternValue = matchConfig.value.escapedPatternValue;
      final RegExp regExp = RegExp(
        r'\\?' + escapedPatternValue,
        multiLine: true,
        dotAll: true,
      );
      final Iterable<RegExpMatch> matches = regExp.allMatches(fileContent);
      if (matches.isNotEmpty) {
        checkResultAll.add(
          CheckResult(
            filePath: filePath,
            yamlKey: matchConfig.key,
            yamlValue: matchConfig.value,
            totalMatches: matches.length,
          ),
        );
      }
    }
    return checkResultAll;
  }
}
