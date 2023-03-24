import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

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
      final copyResult = await Process.run(
        'cp',
        ['-R', '$setUpPath/', tempDirectory.path],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        copyResult,
        _isSuccessful,
        reason: '`cp -R $setUpPath/ ${tempDirectory.path}` failed.',
      );

      final flutterPubGetResult = await Process.run(
        'flutter',
        ['pub', 'get'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        flutterPubGetResult,
        _isSuccessful,
        reason: '`flutter pub get` failed.',
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
        dartFormatResult,
        _isSuccessful,
        reason: '`dart format . --set-exit-if-changed` failed.',
      );

      final dartAnalyzeResult = await Process.run(
        'dart',
        ['analyze', '.'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        dartAnalyzeResult,
        _isSuccessful,
        reason: '`dart analyze .` failed.',
      );

      final flutterTestResult = await Process.run(
        'flutter',
        ['test'],
        runInShell: true,
        workingDirectory: tempDirectory.path,
      );
      expect(
        flutterTestResult,
        _isSuccessful,
        reason: '`flutter test` failed.',
      );

      tempDirectory.deleteSync(recursive: true);
    },
  );
}

const _isSuccessful = _ProcessResultSuccessfulMatcher();

class _ProcessResultSuccessfulMatcher extends Matcher {
  const _ProcessResultSuccessfulMatcher();

  /// Exit code indicating a command completed successfully.
  ///
  /// [Source](https://www.freebsd.org/cgi/man.cgi?query=sysexits).
  static const _sucessfulExitCode = 0;

  @override
  bool matches(covariant ProcessResult item, Map<dynamic, dynamic> matchState) {
    final hasEmptyStderr = (item.stderr as String).isEmpty;
    final hasSuccessfulExitCode = item.exitCode == _sucessfulExitCode;
    return hasSuccessfulExitCode && hasEmptyStderr;
  }

  @override
  Description describeMismatch(
    covariant ProcessResult item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    return describe(
      mismatchDescription.add(
        '''Failed with exit code ${item.exitCode} and stderr:\n`${item.stderr}`''',
      ),
    );
  }

  @override
  Description describe(Description description) =>
      description.add('Process to run succesfully');
}
