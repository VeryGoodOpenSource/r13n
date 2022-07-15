import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../post_gen.dart' as post_gen;

class _MockHookContext extends Mock implements HookContext {}

void main() {
  group('post_gen', () {
    late HookContext hookContext;

    setUp(() {
      hookContext = _MockHookContext();
    });

    test('returns normally', () {
      expect(() => post_gen.run(hookContext), returnsNormally);
    });
  });
}
