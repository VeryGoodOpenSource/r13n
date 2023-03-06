import 'package:test/test.dart';

import '../../../pre_gen.dart';

void main() {
  group('YamlNotFoundException', () {
    test('can be instantiated', () {
      final error = YamlNotFoundException();
      expect(error, isA<YamlNotFoundException>());
      expect(error.message, equals('No r13n.yaml found.'));
    });

    test('toString() ', () {
      final error = YamlNotFoundException();
      expect(
        error.toString(),
        equals('YamlNotFoundException: No r13n.yaml found.'),
      );
    });
  });
}
