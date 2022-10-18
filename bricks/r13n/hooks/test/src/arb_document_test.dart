import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../pre_gen.dart';

class _MockFile extends Mock implements File {}

void main() {
  group('ArbDocument', () {
    group('reads', () {
      late File arbFile;

      setUp(() {
        arbFile = _MockFile();
        when(() => arbFile.readAsString()).thenAnswer(
          (_) async => '''
{
    "@@region": "us",
    "aValue": "A Value"
}
''',
        );
      });

      test('throws AssertionError when reading a non arb file', () {
        expect(
          () => ArbDocument.read('foo.png'),
          throwsA(isA<AssertionError>()),
        );
      });

      test('into a document', () async {
        await IOOverrides.runZoned(
          () async {
            final document = await ArbDocument.read('test.arb');

            verify(() => arbFile.readAsString()).called(1);

            expect(document.path, equals('test.arb'));
            expect(document.region, equals('us'));

            expect(document.regionalizedValues.length, equals(1));
            expect(document.regionalizedValues.first.key, equals('aValue'));
            expect(document.regionalizedValues.first.value, equals('A Value'));

            expect(document.values.length, equals(2));
          },
          createFile: (path) => arbFile,
        );
      });

      test('fails to parse region', () async {
        await IOOverrides.runZoned(
          () async {
            when(() => arbFile.readAsString()).thenAnswer(
              (_) async => '''
{
    "aValue": "A Value"
}
''',
            );
            final document = await ArbDocument.read('test.arb');

            verify(() => arbFile.readAsString()).called(1);

            expect(
              () => document.region,
              throwsA(isA<ArbMissingRegionTagException>()),
            );
          },
          createFile: (path) => arbFile,
        );
      });
    });
  });
}
