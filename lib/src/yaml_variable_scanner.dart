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
      ignoreGlobPathList: scannerConfig.ignoreCheckFilePath ?? [],
    ).getPath();

    /// YAML all results
    // final Map<String, YamlCheckResult> yamlCheckResultAll = {};

    /// Start check
    for (final MapEntry<int, String>(
          key: index,
          value: filePath,
        ) in filePathAll.asMap().entries) {
      final List<CheckResult> checkResultAll = await VariableCheck(
        yamlVariableAll,
        filePath,
        ignoreCheckText: scannerConfig.ignoreCheckText ?? [],
      ).run();

      if (checkResultAll.isNotEmpty) {
        checkResultList.addAll(checkResultAll);

        Console.eraseLine(1);
        if (enablePrint) {
          _consolePrintCheckResult(checkResultAll);
        }
        consoleProgressBar.update(
          (index / (filePathAll.length - 1) * 100).toInt(),
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
        bool isMatchValueLast = false;
        if (checkResult.matchValue.entries.last.key == matchValue.key) {
          isMatchValueLast = true;
        }

        TextPen().gray().text('    │   ').print();
        final TextPen matchValuePen = TextPen();
        matchValuePen.gray();
        switch ([isMatchValueLast]) {
          case [false]:
            matchValuePen.text('    ├── ');
            break;
          case [true]:
            matchValuePen.text('    └── ');
            break;
        }
        matchValuePen
            .normal()
            .text('📄 [Match Content ')
            .blue()
            .text('(total ${matchValue.value.length})')
            .normal()
            .text(']: ')
            .normal()
            .text(matchValue.key)
            .print();

        for (final MapEntry<int, MatchPosition>(
              key: index,
              value: matchPosition,
            ) in matchValue.value.asMap().entries) {
          bool isMatchPositionLast = false;
          if (index + 1 == matchValue.value.length) {
            isMatchPositionLast = true;
          }

          final TextPen matchPositionPen = TextPen();
          matchPositionPen.gray();
          switch ([isMatchValueLast, isMatchPositionLast]) {
            case [false, true]:
              matchPositionPen.text('    │   └── ');
              break;
            case [false, false]:
              matchPositionPen.text('    │   ├── ');
              break;
            case [true, false]:
              matchPositionPen.text('        ├── ');
              break;
            case [true, true]:
              matchPositionPen.text('        └── ');
              break;
            default:
              matchPositionPen.text('        └── ');
              break;
          }

          matchPositionPen
              .normal()
              .text(checkResult.filePath)
              .blue()
              .text(':${matchPosition.line}:${matchPosition.column}')
              .print();
        }
      }
      print('');
    }
  }
}
