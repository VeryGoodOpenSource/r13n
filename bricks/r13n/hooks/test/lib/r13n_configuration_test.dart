import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:r13n_hooks/hooks.dart';
import 'package:test/test.dart';

class _MockFile extends Mock implements File {}

void main() {
  group('$R13nConfiguration', () {
    late File configFile;

    setUp(() {
      configFile = _MockFile();
      when(() => configFile.readAsString()).thenAnswer(
        (_) async => '''
arb-dir: ARB_DIR
template-arb-file: TEMPLATE_ARB_FILE
''',
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

    test('throws $R13nYamlNotFoundException when something goes wrong',
        () async {
      await IOOverrides.runZoned(
        () async {
          await expectLater(
            R13nConfiguration.read,
            throwsA(isA<R13nYamlNotFoundException>()),
          );

          verifyNever(() => configFile.readAsString());
        },
        createFile: (path) => throw const FileSystemException(),
      );
    });
  });
}