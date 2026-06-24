class YamlVariable {
  const YamlVariable({
    required this.key,
    required this.value,
    required this.matchValue,
  });

  /// YAML Key
  ///
  /// e.g. `aa.bb.cc`, `aa.bb[0]`, `aa.bb[1]`
  final String key;

  /// YAML Value
  final String value;

  /// All matches
  /// (RegExp Syntax)
  final List<String> matchValue;

  @override
  String toString() =>
      '$runtimeType(key: $key, value: $value, matchValue: $matchValue)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is YamlVariable &&
        other.key == key &&
        other.value == value &&
        _stringListEquals(matchValue, other.matchValue);
  }

  @override
  int get hashCode => Object.hash(key, value, Object.hashAll(matchValue));
}

/// Whether two lists of strings are equal element-by-element.
bool _stringListEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
