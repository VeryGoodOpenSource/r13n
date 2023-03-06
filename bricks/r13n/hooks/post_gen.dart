import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:r13n_hooks/hooks.dart';

Future<void> run(HookContext context) async {
  final runProcess = ProcessOverrides.current?.runProcess ?? Process.run;
  final progress = context.logger.progress('Running "flutter format ."');
  final result = await runProcess(
    'flutter',
    ['format', '.'],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  progress.complete();

  if (result.exitCode != ExitCode.success.code) {
    throw Exception(result.stderr);
  }
}
