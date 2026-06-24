import 'package:test/test.dart';
import 'package:yaml_variable_scanner/src/utils.dart';

void main() {
  group('StringExtensions.escapedPatternValue', () {
    test('escapes regex metacharacters', () {
      expect('[^0-9]+'.escapedPatternValue, r'\[\^0-9\]\+');
      expect(r'a.b*c?'.escapedPatternValue, r'a\.b\*c\?');
      expect(r'(x)|{y}'.escapedPatternValue, r'\(x\)\|\{y\}');
    });

    test('leaves plain text unchanged', () {
      expect('plain text 123'.escapedPatternValue, 'plain text 123');
    });

    test('escaped pattern matches the original literally', () {
      const String raw = '[^0-9]+=';
      final RegExp regExp = RegExp(raw.escapedPatternValue);
      expect(regExp.hasMatch(raw), isTrue);
      expect(regExp.hasMatch('123'), isFalse);
    });
  });
}
