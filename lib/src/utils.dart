extension StringExtensions on String {
  /// Escape special characters
  ///
  /// e.g. ```[^0-9]+``` -> ```\[\^0-9\]\+```
  String get escapedPatternValue => replaceAllMapped(
        RegExp(r'[\\^$.*+?()\[\]{}|=]'),
        (match) => '\\${match.group(0)}',
      );
}
