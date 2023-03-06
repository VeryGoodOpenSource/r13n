// ignore_for_file: prefer_const_constructors

import 'package:r13n_hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  group('$R13nArbDocumentMissingRegionTagException', () {
    test('can be instantiated', () {
      final error = R13nArbDocumentMissingRegionTagException();
      expect(error, isA<R13nArbDocumentMissingRegionTagException>());
      expect(
        error.message,
        equals('Missing region tag in arb file, make sure to include @@region'),
      );
    });

    test('toString() ', () {
      final error = R13nArbDocumentMissingRegionTagException();
      expect(
        error.toString(),
        equals(
          '''R13nArbDocumentMissingRegionTagException: Missing region tag in arb file, make sure to include @@region''',
        ),
      );
    });
  });
}
