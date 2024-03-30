import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

final class CheckCommand extends Command<int> {
  @override
  String get description =>
      'Scans multiple files for text that can use YAML variables.';

  @override
  String get name => 'check';

  @override
  Future<int> run() async {
    final List<CheckResult> checkResultAll = await YamlVariableScanner.run(
      './yaml_variable_scanner.yaml',
      stdout,
    );
    if (checkResultAll.isNotEmpty) return 2;
    return 0;
  }
}
