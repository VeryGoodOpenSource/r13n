import 'package:r13n_hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  group('$R13nYamlNotFoundException', () {
    test('can be instantiated', () {
      final error = R13nYamlNotFoundException();
      expect(error, isA<R13nYamlNotFoundException>());
      expect(error.message, equals('No r13n.yaml found.'));
    });

    test('toString() ', () {
      final error = R13nYamlNotFoundException();
      expect(
        error.toString(),
        equals('R13nYamlNotFoundException: No r13n.yaml found.'),
      );
    });
  });
}
