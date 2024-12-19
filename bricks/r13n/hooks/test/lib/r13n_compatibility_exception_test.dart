// Not needed for test files
// ignore_for_file: prefer_const_constructors

import 'package:r13n_hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  group('$R13nCompatibilityException', () {
    test('can be instantiated', () {
      final error = R13nCompatibilityException(message: '');
      expect(error, isA<R13nCompatibilityException>());
    });

    test('toString() ', () {
      const message = 'test message';
      final error = R13nCompatibilityException(message: message);
      expect(
        error.toString(),
        equals('R13nCompatibilityException: $message'),
      );
    });
  });
}
