extension StringExtensions on String {
  /// Escape special characters
  ///
  /// This is useful for creating a regex pattern that matches the string literally.
  ///
  /// e.g. ```[^0-9]+``` -> ```\[\^0-9\]\+```
  String get escapedPatternValue => replaceAllMapped(
        RegExp(r'[\\^$.*+?()\[\]{}|=]'),
        (match) => '\\${match.group(0)}',
      );
}
