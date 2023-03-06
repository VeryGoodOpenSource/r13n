import 'dart:io';

import 'package:arb/arb.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFile extends Mock implements File {}

void main() {
  group('$ArbDocument', () {
    group('reads', () {
      late File arbFile;

      setUp(() {
        arbFile = _MockFile();
        const arbFileContent = '''
{
    "first_key": "first value.",
    "second_key": "second value."
}
''';
        when(() => arbFile.readAsString())
            .thenAnswer((_) async => arbFileContent);
      });

      test('throws AssertionError when reading a non arb file', () {
        expect(
          () => ArbDocument.read('foo.png'),
          throwsA(isA<AssertionError>()),
        );
      });

      test('returns normally $ArbDocument', () async {
        await IOOverrides.runZoned(
          createFile: (path) => arbFile,
          () async {
            await expectLater(
              () => ArbDocument.read('test.arb'),
              returnsNormally,
            );
          },
        );
      });

      test('path remains unchanged', () async {
        await IOOverrides.runZoned(
          createFile: (path) => arbFile,
          () async {
            const path = 'test.arb';
            final document = await ArbDocument.read(path);
            expect(document.path, equals(path));
          },
        );
      });

      test('keys follow file order', () async {
        await IOOverrides.runZoned(
          createFile: (path) => arbFile,
          () async {
            final document = await ArbDocument.read('test.arb');

            expect(document.values.length, equals(2));

            final firstValue = document.values[0];
            expect(firstValue.key, equals('first_key'));
            expect(firstValue.value, equals('first value.'));

            final secondValue = document.values[1];
            expect(secondValue.key, equals('second_key'));
            expect(secondValue.value, equals('second value.'));
          },
        );
      });
    });
  });
}
