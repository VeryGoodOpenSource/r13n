import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

/// Exit code indicating a command completed successfully.
///
/// [Source](https://www.freebsd.org/cgi/man.cgi?query=sysexits).
const _sucessfulExitCode = 0;

/// Objectives:
///
/// * Generate AppRegionalizations `mason make r13n` from arb files
/// * Ensure the code is formatted (`dart format .`)
/// * Ensure the code has no warnings/errors (`dart analyze .`)
/// * Ensure AppRegionalizations members are valid and accessible
void main() {
  test(
    'r13n brick generates successfully',
    timeout: const Timeout(Duration(minutes: 5)),
    () async {
      final tempDirectory = Directory.current.createTempSync();

      final arbPath = path.join(tempDirectory.path, 'lib', 'r13n', 'arb');
      Directory(arbPath).createSync(recursive: true);

      final arbUsPath = path.join(arbPath, 'app_us.arb');
      const arbUsFileContent = '''
{
    "@@region": "us",
    "supportEmail": "us@verygood.ventures"
}
''';

      File(arbUsPath)
        ..writeAsStringSync(arbUsFileContent)
        ..createSync();

      final arbGbPath = path.join(arbPath, 'app_gb.arb');
      const arbGbFileContent = '''
{
    "@@region": "gb",
    "supportEmail": "gb@verygood.ventures"
}
''';
      File(arbGbPath)
        ..writeAsStringSync(arbGbFileContent)
        ..createSync();

      final r13nYamlPath = path.join(tempDirectory.path, 'r13n.yaml');
      final r13nYamlFileContent = '''
arb-dir: ${path.relative(arbPath, from: tempDirectory.path)}
template-arb-file: ${path.basename(arbUsPath)}
''';
      File(r13nYamlPath)
        ..writeAsStringSync(r13nYamlFileContent)
        ..createSync();

      final pubspecYalPath = path.join(tempDirectory.path, 'pubspec.yaml');
      const pubsecYamlFileContent = '''
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
  very_good_analysis: ^3.1.0
''';
      File(pubspecYalPath)
        ..writeAsStringSync(pubsecYamlFileContent)
        ..createSync();

      final flutterPubGetResult = await Process.run(
        'flutter',
        ['pub', 'get'],
        runInShell: true,
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
      // Wait for the pubspec.lock file to be written.
      await Future<void>.delayed(const Duration(seconds: 5));

      final rootPath = Directory.current.parent.path;
      final r13nBrickPath = path.join(rootPath, 'bricks', 'r13n');
      final r13nBrick = Brick.path(r13nBrickPath);
      final r13nMasonGenerator = await MasonGenerator.fromBrick(r13nBrick);
      final directoryGeneratorTarget = DirectoryGeneratorTarget(tempDirectory);
      await r13nMasonGenerator.hooks
          .preGen(workingDirectory: tempDirectory.path);
      await r13nMasonGenerator.generate(directoryGeneratorTarget);
      await r13nMasonGenerator.hooks
          .postGen(workingDirectory: tempDirectory.path);

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
    },
  );
}
