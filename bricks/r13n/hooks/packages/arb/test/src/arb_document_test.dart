import 'dart:io';

import 'package:arb/arb.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFile extends Mock implements File {}

void main() {
  group('$ArbDocument', () {
    const testPath = 'test.arb';

    group('unnamed constructor', () {
      test('returns normally', () {
        expect(() => ArbDocument(path: testPath), returnsNormally);
      });

      test('sets path without alteration', () {
        final document = ArbDocument(path: testPath);
        expect(document.path, equals(testPath));
      });

      test('throws AssertionError when reading a non arb file', () {
        expect(
          () => ArbDocument(path: 'not-arb.png'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

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

      test('returns normally $ArbDocument', () async {
        await IOOverrides.runZoned(
          createFile: (path) => arbFile,
          () async {
            final document = ArbDocument(path: testPath);
            await expectLater(document.read, returnsNormally);
          },
        );
      });

      test('keys follow file order', () async {
        await IOOverrides.runZoned(
          createFile: (path) => arbFile,
          () async {
            final document = ArbDocument(path: testPath);
            await document.read();

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
