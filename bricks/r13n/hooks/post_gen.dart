import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';

import 'process_overrides/process_overrides.dart';

Future<void> run(HookContext context) async {
  final runProcess = ProcessOverrides.current?.runProcess ?? Process.run;
  final arbDir = context.vars['arbDir'] as String;
  final progress = context.logger.progress('Running "dart format $arbDir"');
  final result = await runProcess(
    'dart',
    ['format', arbDir],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  progress.complete();

  if (result.exitCode != ExitCode.success.code) {
    throw Exception(result.stderr);
  }
}
