class YamlVariableScannerConfig {
  const YamlVariableScannerConfig({
    this.yamlFilePath,
    this.ignoreYamlFilePath,
    this.ignoreYamlKey,
    this.checkFilePath,
    this.ignoreFilePath,
  });
  final List<String>? yamlFilePath;
  final List<String>? ignoreYamlFilePath;
  final List<String>? ignoreYamlKey;
  final List<String>? checkFilePath;
  final List<String>? ignoreFilePath;
}
