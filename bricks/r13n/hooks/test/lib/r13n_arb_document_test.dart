import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../lib/hooks.dart';

class _MockFile extends Mock implements File {}

void main() {
  group('$R13nArbDocument', () {
    group('read', () {
      late File arbFile;

      setUp(() {
        arbFile = _MockFile();
        const arbFileContent = '''
{
    "@@region": "us",
    "aValue": "A Value"
}
''';
        when(() => arbFile.readAsString())
            .thenAnswer((_) async => arbFileContent);
      });

      test('sets region to last @@region tag', () async {
        await IOOverrides.runZoned(createFile: (path) => arbFile, () async {
          const lastRegion = 'es';
          const arbFileContent = '''
{
    "@@region": "us",
    "@@region": "uk",
    "@@region": "$lastRegion"
}
''';
          when(() => arbFile.readAsString()).thenAnswer(
            (_) async => arbFileContent,
          );

          final document = R13nArbDocument(path: 'test.arb');
          await document.read();

          expect(document.region, equals(lastRegion));
        });
      });

      test('sets regionalizedValues to values not prefixed with @@', () async {
        await IOOverrides.runZoned(createFile: (path) => arbFile, () async {
          const arbFileContent = '''
{
    "@@region": "us",
    "@@test": "test",
    "first" : "first value",
    "second" : "second value"
}
''';
          when(() => arbFile.readAsString()).thenAnswer(
            (_) async => arbFileContent,
          );

          final document = R13nArbDocument(path: 'test.arb');
          await document.read();

          expect(document.regionalizedValues.length, equals(2));

          final firstValue = document.regionalizedValues.first;
          expect(firstValue.key, equals('first'));
          expect(firstValue.value, equals('first value'));

          final secondValue = document.regionalizedValues.last;
          expect(secondValue.key, equals('second'));
          expect(secondValue.value, equals('second value'));
        });
      });

      test(
          'throws an $R13nArbDocumentMissingRegionTagException when missing '
          'a region tag', () async {
        await IOOverrides.runZoned(
          createFile: (path) => arbFile,
          () async {
            const arbFileContent = '''
{
    "first_value": "A value."
}
''';
            when(() => arbFile.readAsString()).thenAnswer(
              (_) async => arbFileContent,
            );

            final document = R13nArbDocument(path: 'test.arb');
            await expectLater(
              document.read,
              throwsA(isA<R13nArbDocumentMissingRegionTagException>()),
            );
          },
        );
      });
    });
  });
}
