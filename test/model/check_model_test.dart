import 'package:test/test.dart';

import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

void main() {
  group('MatchPosition', () {
    test('equals by fields', () {
      const MatchPosition a = MatchPosition(line: 1, column: 2);
      const MatchPosition b = MatchPosition(line: 1, column: 2);
      const MatchPosition c = MatchPosition(line: 1, column: 3);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('CheckResult', () {
    test('deep-equals on matchValue', () {
      const CheckResult a = CheckResult(
        filePath: 'f',
        yamlKey: 'k',
        yamlValue: 'v',
        matchValue: {
          'm': [MatchPosition(line: 1, column: 1)],
        },
      );
      const CheckResult b = CheckResult(
        filePath: 'f',
        yamlKey: 'k',
        yamlValue: 'v',
        matchValue: {
          'm': [MatchPosition(line: 1, column: 1)],
        },
      );
      const CheckResult c = CheckResult(
        filePath: 'f',
        yamlKey: 'k',
        yamlValue: 'v',
        matchValue: {
          'm': [MatchPosition(line: 2, column: 1)],
        },
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });
}
