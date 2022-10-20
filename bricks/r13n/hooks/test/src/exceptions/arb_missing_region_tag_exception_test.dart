// ignore_for_file: prefer_const_constructors

import 'package:test/test.dart';

import '../../../pre_gen.dart';

void main() {
  group('ArbMissingRegionTagException', () {
    test('can be instantiated', () {
      final error = ArbMissingRegionTagException();
      expect(error, isA<ArbMissingRegionTagException>());
      expect(
        error.message,
        equals('Missing region tag in arb file, make sure to include @@region'),
      );
    });

    test('toString() ', () {
      final error = ArbMissingRegionTagException();
      expect(
        error.toString(),
        equals(
          '''ArbMissingRegionTagException: Missing region tag in arb file, make sure to include @@region''',
        ),
      );
    });
  });
}
