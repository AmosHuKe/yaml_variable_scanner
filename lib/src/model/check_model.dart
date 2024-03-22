class CheckResult {
  const CheckResult({
    required this.filePath,
    required this.yamlKey,
    required this.yamlValue,
    required this.totalMatches,
  });

  final String filePath;
  final String yamlKey;
  final String yamlValue;
  final int totalMatches;

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
        other.totalMatches == totalMatches;
  }

  @override
  int get hashCode => Object.hash(
        filePath.hashCode,
        yamlKey.hashCode,
        yamlValue.hashCode,
        totalMatches.hashCode,
      );
}

class YamlCheckResult extends CheckResult {
  YamlCheckResult({
    required super.filePath,
    required super.yamlKey,
    required super.yamlValue,
    required super.totalMatches,
  });
}
