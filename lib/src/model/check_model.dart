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
  int get hashCode => Object.hash(line, column);
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

  /// {
  /// "matchValue1": [MatchPosition(line, column), ...],
  /// "matchValue2": [MatchPosition(line, column), ...],
  /// }
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
        _matchValueEquals(matchValue, other.matchValue);
  }

  @override
  int get hashCode => Object.hash(
        filePath,
        yamlKey,
        yamlValue,
        _matchValueDeepHash(matchValue),
      );
}

/// Whether two lists of [MatchPosition] are equal element-by-element.
bool _positionListEquals(List<MatchPosition> a, List<MatchPosition> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Whether two [CheckResult.matchValue] maps are deeply equal:
/// order-independent across keys, order-sensitive within each position list.
bool _matchValueEquals(
  Map<String, List<MatchPosition>> a,
  Map<String, List<MatchPosition>> b,
) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final MapEntry<String, List<MatchPosition>> entry in a.entries) {
    final List<MatchPosition>? other = b[entry.key];
    if (other == null || !_positionListEquals(entry.value, other)) return false;
  }
  return true;
}

/// Order-independent hash of a [CheckResult.matchValue] map,
/// consistent with [_matchValueEquals].
int _matchValueDeepHash(Map<String, List<MatchPosition>> map) {
  int hash = 0;
  for (final MapEntry<String, List<MatchPosition>> entry in map.entries) {
    hash ^= Object.hash(entry.key, Object.hashAll(entry.value));
  }
  return hash;
}
