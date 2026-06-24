import 'dart:convert' show Utf8Codec;
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

abstract final class FileLoad {
  /// Get File Path
  ///
  /// - [globPathList] File paths (Glob syntax)
  /// - [ignoreGlobPathList] Ignore file paths (Glob syntax)
  ///
  /// @return [List<String>] File paths
  static List<String> getFilePath(
    List<String> globPathList,
    List<String> ignoreGlobPathList,
  ) {
    final List<String> pathList = [];

    /// Pre-compile the ignore globs
    final List<Glob> ignoreGlobList = [
      for (final String ignoreGlobPath in ignoreGlobPathList)
        Glob(ignoreGlobPath, recursive: true, caseSensitive: true),
    ];

    for (final String globPath in globPathList) {
      final Glob globFile = Glob(
        globPath,
        recursive: true,
        caseSensitive: true,
      );
      final globFileList = globFile.listSync(followLinks: false);
      for (final FileSystemEntity entity in globFileList) {
        final String entityPath = entity.path;

        /// Ignore match
        bool isIgnoreMatch = false;
        for (final Glob ignoreGlob in ignoreGlobList) {
          if (ignoreGlob.matches(entityPath)) {
            isIgnoreMatch = true;
            break;
          }
        }
        if (!isIgnoreMatch) pathList.add(entityPath);
      }
    }

    return pathList.toSet().toList();
  }

  /// Get File Content
  ///
  /// Reads the whole file as a UTF-8 string in one shot,
  /// then normalises line endings to preserve the exact semantics.
  ///
  /// On a read/decode error the file is skipped (returns an empty string)
  /// instead of returning partially-decoded content,
  /// while keeping the same observable side effects via [handleFileError].
  ///
  /// - [path] File path
  ///
  /// @return [String] File content
  static Future<String> getFileContent(String path) async {
    try {
      final String raw =
          await File(path).readAsString(encoding: const Utf8Codec());
      final String normalized =
          raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      if (normalized.isEmpty) return '';
      return normalized.endsWith('\n') ? normalized : '$normalized\n';
    } catch (_) {
      await handleFileError(path);
      return '';
    }
  }

  static Future<void> handleFileError(String path) async {
    if (await FileSystemEntity.isDirectory(path)) {
      stderr.writeln('error: $path is a directory');
    } else {
      exitCode = 2;
    }
  }
}
