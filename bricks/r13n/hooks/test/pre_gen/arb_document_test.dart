import 'package:test/test.dart';

import '../../pre_gen.dart';

void main() {
  group('ArbDocument', () {
    group('reads', () {
      test('throws AssertionError when reading a non arb file', () {
        expect(
          () => ArbDocument.read('foo.png'),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });

  group('ArbValue', () {
    const arbValue = ArbValue(key: '', value: '');

    test('can be instantiated', () {
      expect(
        arbValue,
        isA<ArbValue>(),
      );
    });

    group('toMap', () {
      test('returns normally', () {
        expect(() => arbValue.toMap(), returnsNormally);
      });

      test('converts successfuly', () {
        final map = {
          'key': arbValue.key,
          'value': arbValue.value,
        };

        expect(arbValue.toMap(), equals(map));
      });
    });
  });
}
