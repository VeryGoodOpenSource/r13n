import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

/// Exit code indicating a command completed successfully.
///
/// [Source](https://www.freebsd.org/cgi/man.cgi?query=sysexits).
const _sucessfulExitCode = 0;

/// Objectives:
///
/// * Generate AppRegionalizations from arb files (`mason make r13n`)
/// * Ensure the code is formatted (`dart format .`)
/// * Ensure the code has no warnings/errors (`dart analyze .`)
/// * Ensure generated AppRegionalizations match the expected output (fixtures/gen/)
void main() {
  test(
    'r13n brick generates successfully',
    timeout: const Timeout(Duration(minutes: 5)),
    () async {
      final tempDirectory = Directory.systemTemp.createTempSync();

      final arbPath = path.join(tempDirectory.path, 'lib', 'r13n', 'arb');
      Directory(arbPath).createSync(recursive: true);
      final usArbFile = File(path.join(arbPath, 'app_us.arb'))
        ..writeAsStringSync('''
{
    "@@region": "us",
    "supportEmail": "us@verygood.ventures"
}
''');
      final gbArbFile = File(path.join(arbPath, 'app_gb.arb'))
        ..writeAsStringSync('''
{
    "@@region": "gb",
    "supportEmail": "gb@verygood.ventures"
}
''');

      final arbDirectory = path.relative(arbPath, from: tempDirectory.path);
      final templateArbFile = path.basename(usArbFile.path);
      final r13nYamlFile = File(path.join(tempDirectory.path, 'r13n.yaml'))
        ..writeAsStringSync('''
arb-dir: $arbDirectory
template-arb-file: $templateArbFile
''');

      final pubspecYamlFile =
          File(path.join(tempDirectory.path, 'pubspec.yaml'))
            ..writeAsStringSync('''
name: r13n_e2e_test
description: An r13n e2e test.
publish_to: "none"

environment:
  sdk: ">=2.18.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  r13n: 0.1.0-dev.2

dev_dependencies:
  flutter_test:
    sdk: flutter
''');

      await Future.wait([
        usArbFile.create(),
        gbArbFile.create(),
        r13nYamlFile.create(),
        pubspecYamlFile.create(),
      ]);

      final flutterPubGetResult = await Process.run(
        'flutter',
        ['pub', 'get'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        flutterPubGetResult.exitCode,
        equals(_sucessfulExitCode),
        reason:
            '''`flutter pub get` failed with exit code ${flutterPubGetResult.exitCode} and stderr ${flutterPubGetResult.stderr}''',
      );
      expect(
        flutterPubGetResult.stderr,
        isEmpty,
        reason:
            '''`flutter pub get` failed with exit code ${flutterPubGetResult.exitCode} and stderr ${flutterPubGetResult.stderr}''',
      );

      final rootPath = Directory.current.parent.path;
      final r13nBrickPath = path.join(rootPath, 'bricks', 'r13n');
      final r13nBrick = Brick.path(r13nBrickPath);
      final r13nMasonGenerator = await MasonGenerator.fromBrick(r13nBrick);
      final directoryGeneratorTarget = DirectoryGeneratorTarget(tempDirectory);

      var vars = <String, dynamic>{};
      await r13nMasonGenerator.hooks.preGen(
        workingDirectory: tempDirectory.path,
        onVarsChanged: (newVars) => vars = newVars,
      );
      await r13nMasonGenerator.generate(
        directoryGeneratorTarget,
        vars: vars,
      );
      await r13nMasonGenerator.hooks.postGen(
        workingDirectory: tempDirectory.path,
        vars: vars,
      );

      final fixturesPath =
          path.join(Directory.current.path, 'test', 'r13n_brick', 'fixtures');
      final genFixturesPath = path.join(fixturesPath, 'gen');
      expect(
        Directory(path.join(tempDirectory.path, arbDirectory, 'gen')),
        _DirectoryContentMatcher(Directory(genFixturesPath)),
        reason:
            '''Generated files content do not match the expected the generated files.''',
      );

      final dartFormatResult = await Process.run(
        'dart',
        ['format', '.'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        dartFormatResult.exitCode,
        equals(_sucessfulExitCode),
        reason:
            '''`dart format .` failed with exit code ${dartFormatResult.exitCode} and stderr ${dartFormatResult.stderr}''',
      );
      expect(
        dartFormatResult.stderr,
        isEmpty,
        reason:
            '''`dart format .` failed with exit code ${dartFormatResult.exitCode} and stderr ${dartFormatResult.stderr}''',
      );

      final dartAnalyzeResult = await Process.run(
        'dart',
        ['analyze', '.'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        dartAnalyzeResult.exitCode,
        equals(_sucessfulExitCode),
        reason:
            '''`dart analyze .` failed with exit code ${dartAnalyzeResult.exitCode} and stderr ${dartAnalyzeResult.stderr}''',
      );
      expect(
        dartAnalyzeResult.stderr,
        isEmpty,
        reason:
            '''`dart analyze .` failed with exit code ${dartAnalyzeResult.exitCode} and stderr ${dartAnalyzeResult.stderr}''',
      );

      tempDirectory.deleteSync(recursive: true);
    },
  );
}

class _DirectoryContentMatcher extends Matcher {
  _DirectoryContentMatcher(this._expected);

  final Directory _expected;

  final _reason = StringBuffer();

  @override
  Description describe(Description description) {
    return description.add(_reason.toString());
  }

  @override
  bool matches(covariant Directory item, Map<dynamic, dynamic> matchState) {
    _reason.clear();

    if (!_expected.existsSync()) {
      _reason.write('Expected directory (${_expected.path}) does not exist.');
      return false;
    }
    if (!item.existsSync()) {
      _reason.write('Directory (${item.path}) does not exist.');
      return false;
    }

    final dirAContents = _expected.listSync(recursive: true).whereType<File>();
    final dirBContents = item.listSync(recursive: true).whereType<File>();

    if (dirAContents.length != dirBContents.length) {
      _reason.write(
        '''Directory contents do not match, expected ${dirAContents.length} files, found ${dirBContents.length} files.''',
      );
      return false;
    }

    final files = <String, Digest>{};
    for (final file in dirAContents) {
      final relativePath = path.relative(file.path, from: _expected.path);
      final bytes = file.readAsBytesSync();
      final digest = sha1.convert(bytes);
      files[relativePath] = digest;
    }
    for (final file in dirBContents) {
      final relativePath = path.relative(file.path, from: item.path);
      final bytes = file.readAsBytesSync();
      final digest = sha1.convert(bytes);
      if (files[relativePath] != digest) {
        _reason.writeln('Contents of file `$relativePath` do not match.');
      }
    }

    return _reason.isEmpty;
  }
}
