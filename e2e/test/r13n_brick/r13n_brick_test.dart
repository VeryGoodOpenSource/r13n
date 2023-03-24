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
/// * Generate AppRegionalizations from arb files (`mason make r13n`)
/// * Ensure the code is formatted (`dart format . --set-exit-if-changed`)
/// * Ensure the code has no warnings/errors (`dart analyze .`)
/// * Ensure generated AppRegionalizations have valid members
void main() {
  test(
    'r13n brick generates successfully',
    timeout: const Timeout(Duration(minutes: 5)),
    () async {
      final tempDirectory = Directory.systemTemp.createTempSync();
      final setUpPath =
          path.join(Directory.current.path, 'test', 'r13n_brick', 'set_up');
      await Process.run(
        'cp',
        ['-R', '$setUpPath/', tempDirectory.path],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );

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

      final dartFormatResult = await Process.run(
        'dart',
        ['format', '.', '--set-exit-if-changed'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        dartFormatResult.exitCode,
        equals(_sucessfulExitCode),
        reason:
            '''`dart format . --set-exit-if-changed` failed with exit code ${dartFormatResult.exitCode} and stderr ${dartFormatResult.stderr}''',
      );
      expect(
        dartFormatResult.stderr,
        isEmpty,
        reason:
            '''`dart format . --set-exit-if-changed` failed with exit code ${dartFormatResult.exitCode} and stderr ${dartFormatResult.stderr}''',
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

      final flutterTestResult = await Process.run(
        'flutter',
        ['test'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        flutterTestResult.exitCode,
        equals(_sucessfulExitCode),
        reason:
            '''`flutter test` failed with exit code ${flutterTestResult.exitCode} and stderr ${flutterTestResult.stderr}''',
      );
      expect(
        flutterTestResult.stderr,
        isEmpty,
        reason:
            '''`flutter test` failed with exit code ${flutterTestResult.exitCode} and stderr ${flutterTestResult.stderr}''',
      );

      tempDirectory.deleteSync(recursive: true);
    },
  );
}
