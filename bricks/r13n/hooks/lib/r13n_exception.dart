/// {@template r13n_exception}
/// Base class for all r13n exceptions.
///
/// All r13n exceptions should extend this class.
/// {@endtemplate}
abstract class R13nException implements Exception {
  /// {@macro r13n_exception}
  const R13nException({required this.message});

  /// The message of the exception.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}
