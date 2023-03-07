// ignore_for_file: prefer_const_constructors

import 'package:r13n_hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  group('$R13nYamlParseException', () {
    test('can be instantiated', () {
      final error = R13nYamlParseException('');
      expect(error, isA<R13nYamlParseException>());
    });

    test('toString() ', () {
      const message = 'test message';
      final error = R13nYamlParseException(message);
      expect(
        error.toString(),
        equals('R13nYamlParseException: $message'),
      );
    });
  });
}
