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
    return other is YamlVariableScannerConfig && other.toString() == toString();
  }

  @override
  int get hashCode => toString().hashCode;
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
    return other is YamlFilePath && other.toString() == toString();
  }

  @override
  int get hashCode => toString().hashCode;
}
