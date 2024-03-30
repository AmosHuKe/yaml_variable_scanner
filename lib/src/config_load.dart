import 'package:yaml/yaml.dart';

import 'file.dart';

import 'model/config_model.dart';

/// Load yaml_variable_scanner.yaml config
class ConfigLoad with FileLoad {
  /// Load yaml_variable_scanner.yaml config
  ///
  /// - [filePath] `yaml_variable_scanner.yaml` config file path
  ConfigLoad(this.filePath);

  /// `yaml_variable_scanner.yaml` config file path
  final String filePath;

  /// Get yaml_variable_scanner.yaml config
  Future<YamlVariableScannerConfig> getConfig() async {
    final String configLines = await getFileContent(filePath);
    final yamlConfig = loadYaml(configLines)['yaml_variable_scanner'];
    final List<YamlFilePath>? yamlFilePath =
        (yamlConfig['yamlFilePath'] as List?)
            ?.map(
              (value) => YamlFilePath(
                path: value['path'].toString(),
                variablePrefix: value['variablePrefix'].toString(),
              ),
            )
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
    final List<String>? ignoreCheckFilePath =
        (yamlConfig['ignoreCheckFilePath'] as List?)
            ?.map((value) => value.toString())
            .toList();
    final List<String>? ignoreCheckText =
        (yamlConfig['ignoreCheckText'] as List?)
            ?.map((value) => value.toString())
            .toList();

    return YamlVariableScannerConfig(
      yamlFilePath: yamlFilePath,
      ignoreYamlFilePath: ignoreYamlFilePath,
      ignoreYamlKey: ignoreYamlKey,
      checkFilePath: checkFilePath,
      ignoreCheckFilePath: ignoreCheckFilePath,
      ignoreCheckText: ignoreCheckText,
    );
  }
}
