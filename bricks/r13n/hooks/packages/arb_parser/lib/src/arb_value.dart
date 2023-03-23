/// {@template arb_value}
/// A value in an arb file.
/// {@endtemplate}
class ArbValue {
  /// {@macro arb_value}
  const ArbValue({
    required this.key,
    required this.value,
  });

  /// The key of the value.
  final String key;

  /// The value.
  ///
  /// This is the translated string.
  final String value;

  /// Converts the [ArbValue] to a [Map].
  ///
  /// Useful for converting to JSON.
  Map<String, dynamic> toMap() => {
        'key': key,
        'value': value,
      };
}
