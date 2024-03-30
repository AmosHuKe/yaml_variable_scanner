import 'dart:io';
import 'dart:convert';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

mixin class FileLoad {
  /// Get File Path
  ///
  /// - [globPathList] File paths (Glob syntax)
  /// - [ignoreGlobPathList] Ignore file paths (Glob syntax)
  List<String> getFilePath(
    List<String> globPathList,
    List<String> ignoreGlobPathList,
  ) {
    final List<String> pathList = [];
    for (final String globPath in globPathList) {
      final Glob globFile = Glob(
        globPath,
        recursive: true,
        caseSensitive: true,
      );
      final globFileList = globFile.listSync(followLinks: false);
      for (final FileSystemEntity entity in globFileList) {
        bool isIgnoreMatch = false;
        final String entityPath = entity.path;

        /// Ignore match
        for (final String ignoreGlobPath in ignoreGlobPathList) {
          final Glob ignoreGlobFile = Glob(
            ignoreGlobPath,
            recursive: true,
            caseSensitive: true,
          );
          if (ignoreGlobFile.matches(entityPath)) {
            isIgnoreMatch = true;
            break;
          }
        }
        if (!isIgnoreMatch) pathList.add(entity.path);
      }
    }

    return pathList.toSet().toList();
  }

  /// Get File Content
  Future<String> getFileContent(String path) async {
    String lineAll = '';
    final Stream<String> lines = utf8.decoder
        .bind(File(path).openRead())
        .transform(const LineSplitter());
    try {
      await for (final line in lines) {
        lineAll += '$line\n';
      }
    } catch (_) {
      await handleFileError(path);
    }
    return lineAll;
  }

  Future<void> handleFileError(String path) async {
    if (await FileSystemEntity.isDirectory(path)) {
      stderr.writeln('error: $path is a directory');
    } else {
      exitCode = 2;
    }
  }
}
