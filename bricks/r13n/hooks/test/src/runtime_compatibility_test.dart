// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../pre_gen.dart';

void main() {
  group('R13nCompatibilityException', () {
    test('toString override is correct', () {
      const message = 'test message';
      expect(
        R13nCompatibilityException(message: message).toString(),
        equals(message),
      );
    });
  });

  group('isCompatibleWithR13n', () {
    test('returns true when the package:r13n version is compatible', () {
      final compatibleVersions = [
        VersionConstraint.parse('0.1.0-dev.1'),
        VersionConstraint.parse('0.1.0-dev.2'),
        VersionConstraint.parse('>=0.1.0-dev.1 <0.1.0-dev.2'),
        VersionConstraint.parse('>=0.1.0-dev.1 <0.1.0-dev.3'),
      ];
      for (final version in compatibleVersions) {
        expect(isCompatibleWithR13n(version), isTrue);
      }
    });

    test('returns false when the package:r13n version is incompatible', () {
      final incompatibleVersions = [
        VersionConstraint.parse('any'),
        VersionConstraint.parse('^0.1.0-dev'),
        VersionConstraint.parse('^0.1.0-dev.1'),
        VersionConstraint.parse('^0.1.0-dev.2'),
        VersionConstraint.parse('0.1.0'),
        VersionConstraint.parse('^0.1.0'),
        VersionConstraint.parse('>=0.1.0 <0.2.0'),
        VersionConstraint.parse('>=0.2.0 <=0.3.0'),
        VersionConstraint.parse('>=1.0.0 <2.0.0'),
      ];
      for (final version in incompatibleVersions) {
        expect(isCompatibleWithR13n(version), isFalse);
      }
    });
  });

  group('ensureRuntimeCompatibility', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync();
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('throws when a pubspec.yaml does not exist', () {
      final expected = 'Expected to find a pubspec.yaml in ${tempDir.path}.';
      expect(
        () => ensureRuntimeCompatibility(tempDir),
        throwsA(
          isA<R13nCompatibilityException>().having(
            (e) => e.message,
            'message',
            expected,
          ),
        ),
      );
    });

    test(
        'throws when the pubspec.yaml does '
        'not contain a package:r13n dependency', () {
      const expected =
          'Expected to find a dependency on "r13n" in the pubspec.yaml';
      File(path.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(
        '''
name: example
version: 0.1.0+1
environment:
  sdk: ">=2.17.0 <3.0.0"
''',
      );
      expect(
        () => ensureRuntimeCompatibility(tempDir),
        throwsA(
          isA<R13nCompatibilityException>().having(
            (e) => e.message,
            'message',
            expected,
          ),
        ),
      );
    });

    test('throws when the version of package:r13n is incompatible', () {
      const incompatibleVersion = '^99.99.99';
      const expected =
          '''The current version of "brick:r13n" requires "package:r13n" $compatibleR13nVersion.\nBecause the current version of "package:r13n" is $incompatibleVersion, version solving failed.''';
      File(path.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(
        '''
name: example
version: 0.1.0+1
environment:
  sdk: ">=2.17.0 <3.0.0"
dependencies:
  r13n: $incompatibleVersion
''',
      );
      expect(
        () => ensureRuntimeCompatibility(tempDir),
        throwsA(
          isA<R13nCompatibilityException>().having(
            (e) => e.message,
            'message',
            expected,
          ),
        ),
      );
    });

    test('completes when the version is compatible.', () {
      File(path.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(
        '''
name: example
version: 0.1.0+1
environment:
  sdk: ">=2.17.0 <3.0.0"
dependencies:
  r13n: "$compatibleR13nVersion"
''',
      );
      expect(() => ensureRuntimeCompatibility(tempDir), returnsNormally);
    });
  });
}
