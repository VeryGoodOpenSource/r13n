// ignore_for_file: prefer_const_constructors

import 'package:arb_parser/arb_parser.dart';
import 'package:test/test.dart';

void main() {
  group('$ArbValue', () {
    test('can be instantiated', () {
      final arbValue = ArbValue(key: 'key', value: 'value');

      expect(arbValue.key, 'key');
      expect(arbValue.value, 'value');
    });

    group('toMap', () {
      test('returns normally', () {
        final arbValue = ArbValue(key: 'key', value: 'value');

        expect(arbValue.toMap, returnsNormally);
      });

      test('converts successfuly', () {
        final arbValue = ArbValue(key: 'key', value: 'value');
        final map = {
          'key': arbValue.key,
          'value': arbValue.value,
        };

        expect(arbValue.toMap(), equals(map));
      });
    });
  });
}
