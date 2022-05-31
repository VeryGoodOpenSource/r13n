import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final result = await Process.run(
    'flutter',
    ['format', '.'],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );

  if (result.exitCode != 0) {
    throw Exception(result.stderr);
  }
}
