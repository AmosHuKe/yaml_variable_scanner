import 'package:yaml/yaml.dart';

import 'file.dart';

import 'model/config_model.dart';

/// Load yaml_variable_scanner.yaml config
class ConfigLoad {
  /// Load yaml_variable_scanner.yaml config
  ///
  /// - [filePath] `yaml_variable_scanner.yaml` config file path
  ConfigLoad(this.filePath);

  /// `yaml_variable_scanner.yaml` config file path
  final String filePath;

  /// Get yaml_variable_scanner.yaml config
  Future<YamlVariableScannerConfig> getConfig() async {
    final String configLines = await FileLoad.getFileContent(filePath);

    final dynamic configDoc = loadYaml(configLines);
    if (configDoc is! Map || configDoc['yaml_variable_scanner'] == null) {
      throw FormatException(
        'Invalid config "$filePath": '
        'missing top-level "yaml_variable_scanner" key.',
      );
    }
    final dynamic yamlConfig = configDoc['yaml_variable_scanner'];
    if (yamlConfig is! Map) {
      throw FormatException(
        'Invalid config "$filePath": '
        '"yaml_variable_scanner" must be a mapping.',
      );
    }

    final List<YamlFilePath>? yamlFilePath =
        (yamlConfig['yamlFilePath'] as List?)?.map((value) {
      if (value is! Map || value['path'] == null) {
        throw FormatException(
          'Invalid config "$filePath": '
          'each "yamlFilePath" item requires a "path".',
        );
      }
      if (value['variablePrefix'] == null) {
        throw FormatException(
          'Invalid config "$filePath": "yamlFilePath" item '
          '"${value['path']}" requires a "variablePrefix".',
        );
      }
      return YamlFilePath(
        path: value['path'].toString(),
        variablePrefix: value['variablePrefix'].toString(),
      );
    }).toList();

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
