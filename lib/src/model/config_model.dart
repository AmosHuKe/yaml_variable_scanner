class YamlVariableScannerConfig {
  const YamlVariableScannerConfig({
    this.yamlFilePath,
    this.ignoreYamlFilePath,
    this.ignoreYamlKey,
    this.checkFilePath,
    this.ignoreCheckFilePath,
    this.ignoreCheckText,
  });

  /// File path for YAML variables
  final List<YamlFilePath>? yamlFilePath;

  /// Ignore Yaml file path
  ///
  /// (Glob Syntax)
  final List<String>? ignoreYamlFilePath;

  /// Ignore YAML Key
  ///
  /// e.g. "^a\.bb$"
  ///
  /// (RegExp Syntax)
  final List<String>? ignoreYamlKey;

  /// Check the file paths of the contents
  ///
  /// (Glob Syntax)
  final List<String>? checkFilePath;

  /// Ignore file paths to check
  ///
  /// (Glob Syntax)
  final List<String>? ignoreCheckFilePath;

  /// Ignore text that doesn't need to match
  ///
  /// e.g.
  /// - `r"^---([\s\S]*?)---$"`
  /// - `r"^{%\s*comment\s*%}([\s\S]*?){%\s*endcomment\s*%}$"`
  ///
  /// (RegExp Syntax)
  final List<String>? ignoreCheckText;

  @override
  String toString() =>
      '$runtimeType(yamlFilePath: $yamlFilePath, ignoreYamlFilePath: $ignoreYamlFilePath, ignoreYamlKey: $ignoreYamlKey, checkFilePath: $checkFilePath, ignoreCheckFilePath: $ignoreCheckFilePath, ignoreCheckText: $ignoreCheckText)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is YamlVariableScannerConfig &&
        _filePathListEquals(yamlFilePath, other.yamlFilePath) &&
        _stringListEquals(ignoreYamlFilePath, other.ignoreYamlFilePath) &&
        _stringListEquals(ignoreYamlKey, other.ignoreYamlKey) &&
        _stringListEquals(checkFilePath, other.checkFilePath) &&
        _stringListEquals(ignoreCheckFilePath, other.ignoreCheckFilePath) &&
        _stringListEquals(ignoreCheckText, other.ignoreCheckText);
  }

  @override
  int get hashCode => Object.hash(
        _nullableHashAll(yamlFilePath),
        _nullableHashAll(ignoreYamlFilePath),
        _nullableHashAll(ignoreYamlKey),
        _nullableHashAll(checkFilePath),
        _nullableHashAll(ignoreCheckFilePath),
        _nullableHashAll(ignoreCheckText),
      );
}

class YamlFilePath {
  const YamlFilePath({
    required this.path,
    required this.variablePrefix,
  });

  /// YAML path (Glob syntax)
  final String path;

  /// Variable prefix for deep variable checking.
  /// e.g. `site.` -> `site.x.xx`
  final String variablePrefix;

  @override
  String toString() =>
      '$runtimeType(path: $path, variablePrefix: $variablePrefix)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is YamlFilePath &&
        other.path == path &&
        other.variablePrefix == variablePrefix;
  }

  @override
  int get hashCode => Object.hash(path, variablePrefix);
}

/// Whether two nullable lists are equal element-by-element.
/// Two nulls are equal; a null and a non-null are not.
bool _stringListEquals(List<String>? a, List<String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Whether two nullable lists of [YamlFilePath] are equal element-by-element.
bool _filePathListEquals(List<YamlFilePath>? a, List<YamlFilePath>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Hash of a nullable list, consistent with the equality helpers above.
int _nullableHashAll(List<Object?>? list) =>
    list == null ? null.hashCode : Object.hashAll(list);
