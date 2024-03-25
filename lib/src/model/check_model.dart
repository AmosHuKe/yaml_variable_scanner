class CheckResult {
  const CheckResult({
    required this.filePath,
    required this.yamlKey,
    required this.yamlValue,
    required this.matchValue,
  });

  final String filePath;
  final String yamlKey;
  final String yamlValue;
  final Map<String, int> matchValue;

  @override
  String toString() =>
      '$runtimeType(filePath: $filePath, yamlKey: $yamlKey, yamlValue: $yamlValue, matchValue: $matchValue)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CheckResult &&
        other.filePath == filePath &&
        other.yamlKey == yamlKey &&
        other.yamlValue == yamlValue &&
        other.matchValue.toString().hashCode == matchValue.toString().hashCode;
  }

  @override
  int get hashCode => Object.hash(
        filePath.hashCode,
        yamlKey.hashCode,
        yamlValue.hashCode,
        matchValue.toString().hashCode,
      );
}

class YamlCheckResult extends CheckResult {
  YamlCheckResult({
    required super.filePath,
    required super.yamlKey,
    required super.yamlValue,
    required super.matchValue,
  });
}
