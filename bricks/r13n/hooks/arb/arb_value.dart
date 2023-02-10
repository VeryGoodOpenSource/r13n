class ArbValue {
  const ArbValue({
    required this.key,
    required this.value,
  });

  final String key;
  final String value;

  Map<String, dynamic> toMap() => {
        'key': key,
        'value': value,
      };
}
