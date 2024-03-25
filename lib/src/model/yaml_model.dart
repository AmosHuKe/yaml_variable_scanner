class YamlVariable {
  const YamlVariable({
    required this.key,
    required this.value,
    required this.matchValue,
  });
  final String key;
  final String value;

  /// RegExp Syntax
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
        other.matchValue == matchValue;
  }

  @override
  int get hashCode => Object.hash(
        key.hashCode,
        value.hashCode,
        matchValue.hashCode,
      );
}
