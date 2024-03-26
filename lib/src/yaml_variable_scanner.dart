import 'dart:io';

import 'package:console/console.dart';

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

    Console.init();
    final ProgressBar consoleProgressBar = ProgressBar();
    final LoadingBar consoleLoadingBar = LoadingBar()..start();

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
    for (final filePath in filePathAll.asMap().entries) {
      final List<CheckResult> checkResultAll =
          await VariableCheck(yamlVariableAll, filePath.value).run();

      if (checkResultAll.isNotEmpty) {
        checkResultList.addAll(checkResultAll);

        Console.eraseLine(1);
        if (enablePrint) {
          _consolePrintCheckResult(checkResultAll);
        }
        consoleProgressBar.update(
          (filePath.key / (filePathAll.length - 1) * 100).toInt(),
        );
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

    consoleLoadingBar.stop();
    return checkResultList;
  }

  /// Console Print Results
  static void _consolePrintCheckResult(List<CheckResult> checkResultAll) {
    Console.init();
    for (final CheckResult checkResult in checkResultAll) {
      print('');
      TextPen()
          .lightMagenta()
          .text('📂 [File Path]: ')
          .normal()
          .text(checkResult.filePath)
          .print();
      TextPen()
          .gray()
          .text('├── ')
          .normal()
          .text('🔍 [YAML Key]: ')
          .normal()
          .text(checkResult.yamlKey)
          .print();
      TextPen()
          .gray()
          .text('└── ')
          .normal()
          .text('🔍 [YAML Value]: ')
          .normal()
          .text(checkResult.yamlValue)
          .print();
      for (final matchValue in checkResult.matchValue.entries) {
        TextPen().gray().text('    │   ').print();
        TextPen()
            .gray()
            .text('    └── ')
            .normal()
            .text('📄 [Match content ')
            .blue()
            .text('(total ${matchValue.value})')
            .normal()
            .text(']: ')
            .normal()
            .text(matchValue.key)
            .print();
      }
      print('');
    }
  }
}
