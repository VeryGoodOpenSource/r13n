import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../pre_gen.dart' as pre_gen;

class _MockHookContext extends Mock implements HookContext {}

class _MockLogger extends Mock implements Logger {}

class _MockFile extends Mock implements File {}

class _MockDirectory extends Mock implements Directory {}

class _MockFileSystemEntity extends Mock implements FileSystemEntity {}

void main() {
  group('pre_gen', () {
    late HookContext hookContext;
    late Logger logger;
    late File configFile;
    late Directory arbDir;
    late File arbFile;

    setUp(() {
      configFile = _MockFile();
      when(() => configFile.readAsString()).thenAnswer((_) async => '''
arb-dir: ARB_DIR
template-arb-file: TEMPLATE_ARB_FILE
''');
      arbDir = _MockDirectory();

      final fileSystemEntity = _MockFileSystemEntity();
      when(() => fileSystemEntity.path).thenReturn('app_us.arb');
      when(() => arbDir.listSync()).thenReturn([fileSystemEntity]);

      arbFile = _MockFile();
      when(() => arbFile.readAsString()).thenAnswer((_) async => '''
{
    "@@region": "us",
    "aValue": "A Value"
}
''');

      logger = _MockLogger();
      hookContext = _MockHookContext();
      when(() => hookContext.logger).thenReturn(logger);
    });

    test('returns normally', () async {
      Map<String, dynamic> vars = {};

      when(() => hookContext.vars = any()).thenAnswer((invocation) {
        if (invocation.isGetter) return vars;
        return vars = invocation.positionalArguments.first;
      });

      await IOOverrides.runZoned(
        () async {
          await pre_gen.run(hookContext);

          expect(
            vars,
            equals({
              'currentYear': 2022,
              'regions': [
                {
                  'code': 'us',
                  'values': [
                    {'key': 'aValue', 'value': 'A Value'}
                  ]
                }
              ],
              'getters': [
                {'value': 'aValue'}
              ],
              'fallbackCode': 'us',
              'arbDir': 'ARB_DIR'
            }),
          );
        },
        createFile: (path) {
          if (path.endsWith('r13n.yaml')) {
            return configFile;
          } else if (path.endsWith('app_us.arb')) {
            return arbFile;
          } else {
            throw UnsupportedError('Unexpected path: $path');
          }
        },
        createDirectory: (path) => arbDir,
      );
    });

    test('when it fails, throws a R13nException', () async {
      try {
        await pre_gen.preGen(hookContext);
      } catch (err) {
        expect(err, isA<pre_gen.R13nException>());
      }
    });
  });
}
