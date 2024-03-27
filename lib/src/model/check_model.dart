class MatchPosition {
  const MatchPosition({
    required this.line,
    required this.column,
  });

  final int line;
  final int column;

  @override
  String toString() => '$runtimeType(line: $line, column: $column)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MatchPosition &&
        other.line == line &&
        other.column == column;
  }

  @override
  int get hashCode => Object.hash(
        line.hashCode,
        column.hashCode,
      );
}

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
  final Map<String, List<MatchPosition>> matchValue;

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
