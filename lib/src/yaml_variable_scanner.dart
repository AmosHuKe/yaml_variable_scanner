import 'dart:io';

import 'package:console/console.dart';

import 'file.dart';
import 'config_load.dart';
import 'yaml_load.dart';
import 'variable_check.dart';

import 'model/config_model.dart';
import 'model/yaml_model.dart';
import 'model/check_model.dart';

/// YAML Variable Scanner
class YamlVariableScanner {
  const YamlVariableScanner._();

  /// Run scanning check
  ///
  /// - [configPath] `yaml_variable_scanner.yaml` config file path
  /// - [stdout] stdout from dart:io
  /// - [prefix] Prefix used for YAML variables.
  ///            e.g. `(yamlKey) => 'site.$yamlKey'` -> `site.aa`
  /// - [enablePrint] Enable console printing of results
  static Future<List<CheckResult>> run(
    String configPath,
    Stdout stdout, {
    PrefixFunction? prefix,
    enablePrint = true,
  }) async {
    void print(Object message) => stdout.writeln(message);

    final List<CheckResult> checkResultList = [];

    /// Console
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
          _consolePrintCheckResult(print, checkResultAll);
        }
        consoleProgressBar.update(
          (index / (filePathAll.length - 1) * 100).toInt(),
        );
      }
    }

    if (enablePrint) {
      Console.eraseLine(1);
      _consolePrintStatisticCheckResult(print, checkResultList);
    }

    consoleLoadingBar.stop();
    return checkResultList;
  }

  /// Console Print Results
  static void _consolePrintCheckResult(
    void Function(Object message) print,
    List<CheckResult> checkResultAll,
  ) {
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

  /// Console Print Results (Statistic)
  static void _consolePrintStatisticCheckResult(
    void Function(Object message) print,
    List<CheckResult> checkResultAll,
  ) {
    Console.init();
    final Map<YamlVariable, Map<String, int>> statisticCheckResultAll = {};

    for (final CheckResult checkResult in checkResultAll) {
      for (final matchValue in checkResult.matchValue.entries) {
        final YamlVariable yamlVariable = YamlVariable(
          key: checkResult.yamlKey,
          value: checkResult.yamlValue,
          matchValue: [],
        );
        final Map<String, int> preMatchMap =
            statisticCheckResultAll[yamlVariable] ?? {};
        final int preMatchLength =
            statisticCheckResultAll[yamlVariable]?[matchValue.key] ?? 0;
        final int matchLength = matchValue.value.length;
        final matchMap = preMatchMap
          ..addAll({matchValue.key: matchLength + preMatchLength});
        statisticCheckResultAll.addAll({yamlVariable: matchMap});
      }
    }

    if (statisticCheckResultAll.isNotEmpty) {
      final TextPen divider = TextPen()
          .lightMagenta()
          .text('========================================');

      TextPen().lightMagenta().text('🌏 [Total statistics]:').print();
      divider.print();
      for (final statisticCheckResult in statisticCheckResultAll.entries) {
        print('');
        TextPen()
            .normal()
            .text('  🔍 [YAML Key]: ')
            .normal()
            .text(statisticCheckResult.key.key)
            .print();
        TextPen()
            .normal()
            .text('  🔍 [YAML Value]: ')
            .normal()
            .text(statisticCheckResult.key.value)
            .print();

        for (final matchValue in statisticCheckResult.value.entries) {
          bool isMatchValueLast = false;
          if (statisticCheckResult.value.entries.last.key == matchValue.key) {
            isMatchValueLast = true;
          }

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
              .text('(total ${matchValue.value})')
              .normal()
              .text(']: ')
              .normal()
              .text(matchValue.key)
              .print();
        }
      }
      print('');
      divider.print();
    }
  }
}
