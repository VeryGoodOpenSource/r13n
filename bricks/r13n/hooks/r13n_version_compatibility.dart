import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

import 'package:yaml/yaml.dart';
import 'hooks.dart';
import 'pre_gen.dart';

/// {@template r13n_compatibility_exception}
/// An exception thrown when the current version of the r13n brick
/// is incompatible with the r13n runtime being used.
/// {@endtemplate}
class R13nCompatibilityException extends R13nException {
  /// {@macro r13n_compatibility_exception}
  const R13nCompatibilityException({required super.message});

  @override
  String toString() => message;
}

/// Ensures that the current version of `brick:r13n` is compatible
/// with the version of `package:r13n` used in the [cwd].
void ensureRuntimeCompatibility(Directory cwd) {
  final lockFile = File(path.join(cwd.path, 'pubspec.lock'));
  if (!lockFile.existsSync()) {
    throw R13nCompatibilityException(
      message: 'Expected to find a pubspec.lock in ${cwd.path}.',
    );
  }

  final content = lockFile.readAsStringSync();
  final packages = (loadYaml(content) as YamlMap)['packages'] as YamlMap;
  final dependencyEntry = packages.entries.where(
        (e) => e.key == 'r13n',
  );

  if (dependencyEntry.isEmpty) {
    throw const R13nCompatibilityException(
      message: '''
Expected to find a dependency on "r13n" in the pubspec.lock

Ensure the "r13n" package is added to your pubspec.yaml and run "flutter pub get" before running "mason make r13n".
''',
    );
  }

  final dependency = dependencyEntry.first.value as YamlMap;
  if (!isCompatibleWithR13n(Version.parse(dependency['version'] as String))) {
    throw R13nCompatibilityException(
      message: '''
The current version of "brick:r13n" requires "package:r13n" $compatibleR13nVersion.
Because the current version of "package:r13n" is ${dependency['version']}, version solving failed.''',
    );
  }
}
