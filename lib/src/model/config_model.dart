class YamlVariableScannerConfig {
  const YamlVariableScannerConfig({
    this.yamlFilePath,
    this.ignoreYamlFilePath,
    this.ignoreYamlKey,
    this.checkFilePath,
    this.ignoreCheckFilePath,
    this.ignoreCheckText,
  });
  final List<String>? yamlFilePath;
  final List<String>? ignoreYamlFilePath;
  final List<String>? ignoreYamlKey;
  final List<String>? checkFilePath;
  final List<String>? ignoreCheckFilePath;
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
        other.yamlFilePath == yamlFilePath &&
        other.ignoreYamlFilePath == ignoreYamlFilePath &&
        other.ignoreYamlKey == ignoreYamlKey &&
        other.checkFilePath == checkFilePath &&
        other.ignoreCheckFilePath == ignoreCheckFilePath &&
        other.ignoreCheckText == ignoreCheckText;
  }

  @override
  int get hashCode => Object.hash(
        yamlFilePath.hashCode,
        ignoreYamlFilePath.hashCode,
        ignoreYamlKey.hashCode,
        checkFilePath.hashCode,
        ignoreCheckFilePath.hashCode,
        ignoreCheckText.hashCode,
      );
}
