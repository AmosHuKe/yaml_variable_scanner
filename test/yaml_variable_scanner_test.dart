import 'dart:io';

import 'package:test/test.dart';

import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

void main() {
  group('YamlVariableScanner Test', () {
    test('Check case1', () async {
      final List<CheckResult> checkResultAllExpect = [
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'a.description',
          yamlValue:
              'Dart is a client-optimized language for developing fast apps on any platform.',
          matchValue: {
            'Dart is a client-optimized language for developing fast apps on any platform.':
                [MatchPosition(line: 1, column: 5)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'a.repo.dart.lang',
          yamlValue: '<p>123</p>\n<p>456</p>\n',
          matchValue: {
            '<p>123</p>\n<p>456</p>\n': [MatchPosition(line: 6, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'a.repo.dart.reg-exp',
          yamlValue: '[^0-9]+',
          matchValue: {
            '[^0-9]+': [MatchPosition(line: 12, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'a.repo.reg-exp2',
          yamlValue: '[^0-9]+=',
          matchValue: {
            '{{ a.repo.dart.reg-exp }}=': [
              MatchPosition(line: 14, column: 1),
              MatchPosition(line: 15, column: 1)
            ],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'a.repo.reg-exp3',
          yamlValue: '[^0-9]+=+',
          matchValue: {
            '{{ a.repo.dart.reg-exp }}=+': [
              MatchPosition(line: 15, column: 1),
            ],
            '{{ a.repo.reg-exp2 }}+': [MatchPosition(line: 16, column: 1)],
            '{{a.repo.reg-exp2}}+': [MatchPosition(line: 17, column: 1)],
            '{{   a.repo.reg-exp2 | xxx }}+': [
              MatchPosition(line: 19, column: 1)
            ],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'b.reg-exp2',
          yamlValue: '[^0-9]+=',
          matchValue: {
            '{{ a.repo.dart.reg-exp }}=': [
              MatchPosition(line: 14, column: 1),
              MatchPosition(line: 15, column: 1)
            ],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\1.md',
          yamlKey: 'b.reg-exp3',
          yamlValue: '[^0-9]+=+',
          matchValue: {
            '{{ a.repo.dart.reg-exp }}=+': [
              MatchPosition(line: 15, column: 1),
            ],
            '{{ a.repo.reg-exp2 }}+': [MatchPosition(line: 16, column: 1)],
            '{{a.repo.reg-exp2}}+': [MatchPosition(line: 17, column: 1)],
            '{{   a.repo.reg-exp2 | xxx }}+': [
              MatchPosition(line: 19, column: 1)
            ],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'a.description',
          yamlValue:
              'Dart is a client-optimized language for developing fast apps on any platform.',
          matchValue: {
            'Dart is a client-optimized language for developing fast apps on any platform.':
                [MatchPosition(line: 5, column: 5)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'a.repo.dart.lang',
          yamlValue: '<p>123</p>\n<p>456</p>\n',
          matchValue: {
            '<p>123</p>\n<p>456</p>\n': [MatchPosition(line: 16, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'a.repo.dart.reg-exp',
          yamlValue: '[^0-9]+',
          matchValue: {
            '[^0-9]+': [MatchPosition(line: 22, column: 1)],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'a.repo.reg-exp3',
          yamlValue: '[^0-9]+=+',
          matchValue: {
            '{{   a.repo.reg-exp2 | xxx }}+': [
              MatchPosition(line: 23, column: 1)
            ],
          },
        ),
        CheckResult(
          filePath: r'.\test\case1\posts\2.md',
          yamlKey: 'b.reg-exp3',
          yamlValue: '[^0-9]+=+',
          matchValue: {
            '{{   a.repo.reg-exp2 | xxx }}+': [
              MatchPosition(line: 23, column: 1)
            ],
          },
        ),
      ];
      final List<CheckResult> checkResultAll = await YamlVariableScanner.run(
        './test/case1/yaml_variable_scanner.yaml',
        stdout,
        enablePrint: true,
      );
      expect(
        checkResultAll
            .map(
              (value) => CheckResult(
                filePath: value.filePath.replaceAll(r'\', '/'),
                yamlKey: value.yamlKey,
                yamlValue: value.yamlValue,
                matchValue: value.matchValue,
              ),
            )
            .toList()
          ..sort((a, b) => a.hashCode.compareTo(b.hashCode)),
        checkResultAllExpect
            .map(
              (value) => CheckResult(
                filePath: value.filePath.replaceAll(r'\', '/'),
                yamlKey: value.yamlKey,
                yamlValue: value.yamlValue,
                matchValue: value.matchValue,
              ),
            )
            .toList()
          ..sort((a, b) => a.hashCode.compareTo(b.hashCode)),
      );
    });
  });
}
