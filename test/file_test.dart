import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml_variable_scanner/src/file.dart';

void main() {
  group('FileLoad.getFileContent', () {
    late Directory tempDir;

    setUp(() => tempDir = Directory.systemTemp.createTempSync('yvs_file_test'));
    tearDown(() => tempDir.deleteSync(recursive: true));

    Future<String> writeAndRead(String content) {
      print('temp sample file: ${tempDir.path}/sample.txt');

      final File file = File('${tempDir.path}/sample.txt')
        ..writeAsBytesSync(utf8.encode(content));
      return FileLoad.getFileContent(file.path);
    }

    test('normalizes CRLF and CR to LF', () async {
      expect(await writeAndRead('a\r\nb\rc\n'), 'a\nb\nc\n');
    });

    test('appends a trailing newline for non-empty content', () async {
      expect(await writeAndRead('abc'), 'abc\n');
    });

    test('keeps empty file empty', () async {
      expect(await writeAndRead(''), '');
    });

    test('preserves blank lines', () async {
      expect(await writeAndRead('a\n\nb\n'), 'a\n\nb\n');
    });
  });
}
