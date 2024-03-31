import 'dart:io';

import 'package:console/console.dart';

import 'file.dart';
import 'config_load.dart';
import 'yaml_load.dart';
import 'variable_check.dart';

import 'model/config_model.dart';
import 'model/yaml_model.dart';
import 'model/check_model.dart';

enum PrintMode {
  /// No content
  none,

  /// Detail to file lines and columns
  detail,

  /// Total statistics
  stats,

  /// Detail & Stats
  detailAndStats,
}

/// YAML Variable Scanner
class YamlVariableScanner {
  const YamlVariableScanner._();

  /// Run scanning check
  ///
  /// - [configPath] `yaml_variable_scanner.yaml` config file path
  /// - [stdout] stdout from dart:io
  /// - [printMode] Console Print Mode [PrintMode]
  ///
  static Future<List<CheckResult>> run(
    String configPath,
    Stdout stdout, {
    PrintMode printMode = PrintMode.detail,
  }) async {
    void print(Object message) => stdout.writeln(message);

    final List<CheckResult> checkResultList = [];
    int replaceableContentsTotal = 0;
    int relatedFilesTotal = 0;

    /// Console
    Console.init();
    // final LoadingBar consoleLoadingBar = LoadingBar();

    /// Get configuration
    final YamlVariableScannerConfig scannerConfig =
        await ConfigLoad(configPath).getConfig();

    /// Get YAML variables
    final List<YamlVariable> yamlVariableAll = await YamlLoad(
      scannerConfig.yamlFilePath ?? [],
      ignoreGlobPathList: scannerConfig.ignoreYamlFilePath ?? [],
      ignoreYamlKeyList: scannerConfig.ignoreYamlKey ?? [],
    ).getVariable();

    /// Get directory files to scan
    final List<String> filePathAll = FileLoad().getFilePath(
      scannerConfig.checkFilePath ?? [],
      scannerConfig.ignoreCheckFilePath ?? [],
    );

    /// Start check
    for (final String filePath in filePathAll) {
      final List<CheckResult> checkResultAll = await VariableCheck(
        yamlVariableAll,
        filePath,
        ignoreCheckText: scannerConfig.ignoreCheckText ?? [],
      ).run();

      if (checkResultAll.isNotEmpty) {
        checkResultList.addAll(checkResultAll);

        relatedFilesTotal++;
        for (final checkResult in checkResultAll) {
          for (final matchValue in checkResult.matchValue.entries) {
            replaceableContentsTotal += matchValue.value.length;
          }
        }

        if (printMode == PrintMode.detail ||
            printMode == PrintMode.detailAndStats) {
          /// Results per file
          _consolePrintCheckResult(print, checkResultAll);
        }
      }
    }

    if (printMode == PrintMode.stats || printMode == PrintMode.detailAndStats) {
      /// Total statistics
      _consolePrintStatisticCheckResult(print, checkResultList);
    }

    /// Done
    _consolePrintDoneStats(
      print,
      allVariables: yamlVariableAll.length,
      allFiles: filePathAll.length,
      replaceableContents: replaceableContentsTotal,
      relatedFiles: relatedFilesTotal,
    );

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
          .normal()
          .text('├── ')
          .normal()
          .text('🔍 [Variable Key]: ')
          .normal()
          .text(checkResult.yamlKey)
          .print();
      TextPen()
          .normal()
          .text('└── ')
          .normal()
          .text('🔍 [Variable Value]: ')
          .normal()
          .text(checkResult.yamlValue)
          .print();

      for (final matchValue in checkResult.matchValue.entries) {
        bool isMatchValueLast = false;
        if (checkResult.matchValue.entries.last.key == matchValue.key) {
          isMatchValueLast = true;
        }

        TextPen().normal().text('    │   ').print();

        /// Replaceable content
        TextPen()
            .normal()
            .text('    ├── ')
            .normal()
            .text('📄 [Replaceable content ')
            .blue()
            .text('(total ${matchValue.value.length})')
            .normal()
            .text(']: ')
            .normal()
            .text(matchValue.key)
            .print();

        /// Suggestion
        final TextPen suggestionPen = TextPen();
        suggestionPen.normal();
        switch ([isMatchValueLast]) {
          case [false]:
            suggestionPen.text('    ├── ');
            break;
          case [true]:
            suggestionPen.text('    └── ');
            break;
        }
        suggestionPen
            .yellow()
            .text('💡 [Suggestion]: ')
            .normal()
            .text('Replace all "')
            .yellow()
            .text(matchValue.key)
            .normal()
            .text('" with "')
            .yellow()
            .text('{{${checkResult.yamlKey}}}')
            .normal()
            .text('"')
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
          matchPositionPen.normal();
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
      final TextPen divider = TextPen().lightMagenta().text(
            '[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]',
          );
      print('');
      TextPen().lightMagenta().text('🌏 [Total statistics]:').print();
      divider.print();
      for (final statisticCheckResult in statisticCheckResultAll.entries) {
        print('');
        TextPen()
            .normal()
            .text('  🔍 [Variable Key]: ')
            .normal()
            .text(statisticCheckResult.key.key)
            .print();
        TextPen()
            .normal()
            .text('  🔍 [Variable Value]: ')
            .normal()
            .text(statisticCheckResult.key.value)
            .print();

        for (final matchValue in statisticCheckResult.value.entries) {
          bool isMatchValueLast = false;
          if (statisticCheckResult.value.entries.last.key == matchValue.key) {
            isMatchValueLast = true;
          }

          TextPen().normal().text('    │   ').print();

          /// Replaceable content
          TextPen()
              .normal()
              .text('    ├── ')
              .normal()
              .text('📄 [Replaceable content ')
              .blue()
              .text('(total ${matchValue.value})')
              .normal()
              .text(']: ')
              .normal()
              .text(matchValue.key)
              .print();

          /// Suggestion
          final TextPen suggestionPen = TextPen();
          suggestionPen.normal();
          switch ([isMatchValueLast]) {
            case [false]:
              suggestionPen.text('    ├── ');
              break;
            case [true]:
              suggestionPen.text('    └── ');
              break;
          }
          suggestionPen
              .yellow()
              .text('💡 [Suggestion]: ')
              .normal()
              .text('Replace all "')
              .yellow()
              .text(matchValue.key)
              .normal()
              .text('" with "')
              .yellow()
              .text('{{${statisticCheckResult.key.key}}}')
              .normal()
              .text('"')
              .print();
        }
        print('');
      }
      print('');
      divider.print();
    }
  }

  /// Console Print Done Stats
  static void _consolePrintDoneStats(
    void Function(Object message) print, {
    required int allVariables,
    required int allFiles,
    required int replaceableContents,
    required int relatedFiles,
  }) {
    Console.init();

    print('');
    TextPen().lightMagenta().text('🌏  Done! ').print();

    /// Total scanned
    TextPen().blue().text('    Total scanned: ').print();
    TextPen()
        .normal()
        .text('    ├── All variables: $allVariables (YAML Key)')
        .print();
    TextPen().normal().text('    └── All files: $allFiles').print();
    print('');

    /// Issues
    TextPen().yellow().text('    Issues: ').print();
    TextPen()
        .normal()
        .text(
            '    └── Replaceable contents: $replaceableContents (Related files: $relatedFiles)')
        .print();
    print('');
  }
}
