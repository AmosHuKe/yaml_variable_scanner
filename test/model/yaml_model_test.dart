import 'package:test/test.dart';

import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

void main() {
  group('YamlVariable', () {
    test('equals by fields', () {
      const YamlVariable a = YamlVariable(
        key: 'a.b',
        value: 'v',
        matchValue: ['v'],
      );
      const YamlVariable b = YamlVariable(
        key: 'a.b',
        value: 'v',
        matchValue: ['v'],
      );
      const YamlVariable c = YamlVariable(
        key: 'a.b',
        value: 'v',
        matchValue: ['v', 'extra'],
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
