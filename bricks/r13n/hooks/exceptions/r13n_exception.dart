abstract class R13nException implements Exception {
  const R13nException({required this.message});

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
