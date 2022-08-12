import 'package:test/test.dart';

import '../../../pre_gen.dart';

void main() {
  group('ArbMissingRegionTagException', () {
    test('can be instantiated', () {
      final error = ArbMissingRegionTagException(Object());
      expect(error, isA<ArbMissingRegionTagException>());
      expect(
        error.message,
        equals('Missing region tag in arb file, make sure to include @@region'),
      );
    });
  });
}
