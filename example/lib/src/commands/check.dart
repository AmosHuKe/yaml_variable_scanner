import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

final class CheckCommand extends Command<int> {
  @override
  String get description => 'Check if YAML variables are used in the file.';

  @override
  String get name => 'check';

  @override
  Future<int> run() async {
    final List<CheckResult> checkResultAll = await YamlVariableScanner.run(
      './yaml_variable_scanner.yaml',
      stdout,
      prefix: (yamlKey) => 'site.$yamlKey',
    );
    if (checkResultAll.isNotEmpty) return 2;
    return 0;
  }
}
