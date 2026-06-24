import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml_variable_scanner/src/config_load.dart';

import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

void main() {
  group('ConfigLoad validation', () {
    late Directory tempDir;

    setUp(() => tempDir = Directory.systemTemp.createTempSync('yvs_cfg_test'));
    tearDown(() => tempDir.deleteSync(recursive: true));

    Future<YamlVariableScannerConfig> load(String yaml) {
      print('Temp config file: ${tempDir.path}/config.yaml');

      final File file = File('${tempDir.path}/config.yaml')
        ..writeAsStringSync(yaml);
      return ConfigLoad(file.path).getConfig();
    }

    test('throws when the top-level key is missing', () async {
      await expectLater(load('foo: bar'), throwsFormatException);
    });

    test('throws when a yamlFilePath item lacks variablePrefix', () async {
      await expectLater(
        load(
          'yaml_variable_scanner:\n'
          '  yamlFilePath:\n'
          '    - path: "a.yaml"\n',
        ),
        throwsFormatException,
      );
    });

    test('parses a valid config', () async {
      final YamlVariableScannerConfig config = await load(
        'yaml_variable_scanner:\n'
        '  yamlFilePath:\n'
        '    - path: "a.yaml"\n'
        '      variablePrefix: "a."\n'
        '  checkFilePath:\n'
        '    - "**/*.md"\n',
      );
      expect(config.yamlFilePath, [
        const YamlFilePath(path: 'a.yaml', variablePrefix: 'a.'),
      ]);
      expect(config.checkFilePath, ['**/*.md']);
    });
  });
}
