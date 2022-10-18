import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../post_gen.dart' as post_gen;

class _TestProcess {
  Future<ProcessResult> run(
    String command,
    List<String> args, {
    bool runInShell = false,
    String? workingDirectory,
  }) {
    throw UnimplementedError();
  }
}

class _MockHookContext extends Mock implements HookContext {}

class _MockProcess extends Mock implements _TestProcess {}

class _MockProcessResult extends Mock implements ProcessResult {}

void main() {
  group('post_gen', () {
    late HookContext hookContext;
    late _TestProcess process;
    late ProcessResult processResult;

    setUp(() {
      hookContext = _MockHookContext();
      process = _MockProcess();
      processResult = _MockProcessResult();
      when(() => processResult.exitCode).thenReturn(ExitCode.success.code);
      when(
        () => process.run(
          any(),
          any(),
          runInShell: any(named: 'runInShell'),
          workingDirectory: any(named: 'workingDirectory'),
        ),
      ).thenAnswer((_) async => processResult);
    });

    test('returns normally', () {
      post_gen.ProcessOverrides.runZoned(
        () {
          expect(() => post_gen.run(hookContext), returnsNormally);
        },
        runProcess: process.run,
      );
    });

    test('throws exception if format fails', () {
      when(() => processResult.exitCode).thenReturn(ExitCode.osError.code);

      post_gen.ProcessOverrides.runZoned(
        () {
          expectLater(
            () => post_gen.run(hookContext),
            throwsException,
          );
        },
        runProcess: process.run,
      );
    });
  });
}
