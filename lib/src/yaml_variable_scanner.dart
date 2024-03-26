import 'dart:io';

import 'file.dart';
import 'config_load.dart';
import 'yaml_load.dart';
import 'variable_check.dart';

import 'model/config_model.dart';
import 'model/yaml_model.dart';
import 'model/check_model.dart';

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
