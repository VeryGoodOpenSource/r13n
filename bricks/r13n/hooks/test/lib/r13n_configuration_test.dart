import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:r13n_hooks/hooks.dart';
import 'package:test/test.dart';

class _MockFile extends Mock implements File {}

void main() {
  group('$R13nConfiguration', () {
    group('read', () {
      late File configFile;

      setUp(() {
        configFile = _MockFile();
        const configFileContent = '''
arb-dir: ARB_DIR
template-arb-file: TEMPLATE_ARB_FILE
''';
        when(() => configFile.readAsString()).thenAnswer(
          (_) async => configFileContent,
        );
        when(() => configFile.existsSync()).thenReturn(true);
      });

      test('read yaml configuration', () async {
        await IOOverrides.runZoned(
          () async {
            final configuration = await R13nConfiguration.read();

            expect(configuration.arbDir, equals('ARB_DIR'));
            expect(configuration.templateArbFile, equals('TEMPLATE_ARB_FILE'));

            verify(() => configFile.readAsString()).called(1);
          },
          createFile: (path) => configFile,
        );
      });

      test('throws $R13nYamlParseException when something goes wrong',
          () async {
        await IOOverrides.runZoned(
          createFile: (path) => configFile,
          () async {
            when(() => configFile.readAsString()).thenAnswer(
              (_) async => throw const FileSystemException(),
            );
            await expectLater(
              R13nConfiguration.read,
              throwsA(isA<R13nYamlParseException>()),
            );
          },
        );
      });

      test('throws $R13nYamlParseException when "arb-dir" is not provided',
          () async {
        await IOOverrides.runZoned(
          createFile: (path) => configFile,
          () async {
            const configFileContent = '''
template-arb-file: TEMPLATE_ARB_FILE
''';
            when(() => configFile.readAsString()).thenAnswer(
              (_) async => configFileContent,
            );

            const errorMessage = 'Missing required field "arb-dir" in '
                '${R13nConfiguration.fileName}';
            await expectLater(
              R13nConfiguration.read,
              throwsA(
                isA<R13nYamlParseException>().having(
                  (exception) => exception.message,
                  'message',
                  equals(errorMessage),
                ),
              ),
            );
          },
        );
      });

      test(
          'throws $R13nYamlParseException when "template-arb-file" is not '
          'provided', () async {
        await IOOverrides.runZoned(
          createFile: (path) => configFile,
          () async {
            const configFileContent = '''
arb-dir: ARB_DIR
''';
            when(() => configFile.readAsString()).thenAnswer(
              (_) async => configFileContent,
            );

            const errorMessage =
                'Missing required field "template-arb-file" in '
                '${R13nConfiguration.fileName}';
            await expectLater(
              R13nConfiguration.read,
              throwsA(
                isA<R13nYamlParseException>().having(
                  (exception) => exception.message,
                  'message',
                  equals(errorMessage),
                ),
              ),
            );
          },
        );
      });
    });
  });
}
