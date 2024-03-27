import 'dart:io';

import 'package:test/test.dart';

import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

void main() {
  group('YamlVariableScanner Test', () {
    test('Check case1', () async {
      final List<CheckResult> checkResultAllExpect = [
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'description',
          yamlValue:
              'Dart is a client-optimized language for developing fast apps on any platform.',
          matchValue: {
            'Dart is a client-optimized language for developing fast apps on any platform.':
                [MatchPosition(line: 1, column: 5)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'repo.dart.lang',
          yamlValue: '<p>123</p>\n<p>456</p>\n',
          matchValue: {
            '<p>123</p>\n<p>456</p>\n': [MatchPosition(line: 6, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'repo.dart.reg-exp',
          yamlValue: '[^0-9]+',
          matchValue: {
            '[^0-9]+': [MatchPosition(line: 12, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'repo.reg-exp2',
          yamlValue: '[^0-9]+=',
          matchValue: {
            '{{ site.repo.dart.reg-exp }}=': [
              MatchPosition(line: 14, column: 1),
              MatchPosition(line: 15, column: 1)
            ],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'repo.reg-exp3',
          yamlValue: '[^0-9]+=+',
          matchValue: {
            '{{ site.repo.dart.reg-exp }}=+': [
              MatchPosition(line: 15, column: 1),
            ],
            '{{ site.repo.reg-exp2 }}+': [MatchPosition(line: 16, column: 1)],
            '{{site.repo.reg-exp2}}+': [MatchPosition(line: 17, column: 1)],
            '{{   site.repo.reg-exp2 | xxx }}+': [
              MatchPosition(line: 19, column: 1)
            ],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'description',
          yamlValue:
              'Dart is a client-optimized language for developing fast apps on any platform.',
          matchValue: {
            'Dart is a client-optimized language for developing fast apps on any platform.':
                [MatchPosition(line: 1, column: 5)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'repo.dart.lang',
          yamlValue: '<p>123</p>\n<p>456</p>\n',
          matchValue: {
            '<p>123</p>\n<p>456</p>\n': [MatchPosition(line: 6, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'repo.dart.reg-exp',
          yamlValue: '[^0-9]+',
          matchValue: {
            '[^0-9]+': [MatchPosition(line: 12, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'repo.reg-exp3',
          yamlValue: '[^0-9]+=+',
          matchValue: {
            '{{   site.repo.reg-exp2 | xxx }}+': [
              MatchPosition(line: 13, column: 1)
            ],
          },
        ),
      ];
      final List<CheckResult> checkResultAll = await YamlVariableScanner.run(
        './test/case1/yaml_variable_scanner.yaml',
        stdout,
        prefix: (yamlKey) => 'site.$yamlKey',
        enablePrint: true,
      );
      expect(checkResultAll, checkResultAllExpect);
    });
  });
}
