import 'dart:io';

import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:r13n_hooks/hooks.dart';
import 'package:yaml/yaml.dart';

/// The version range of package:r13n supported by the current version of the
/// r13n brick.
@visibleForTesting
const compatibleR13nVersion = '>=0.1.0-dev.1 <0.1.0-dev.3';

/// {@template r13n_compatibility_exception}
/// An exception thrown when the current version of the r13n brick
/// is incompatible with the r13n runtime being used.
/// {@endtemplate}
class R13nCompatibilityException extends R13nException {
  /// {@macro r13n_compatibility_exception}
  const R13nCompatibilityException({required super.message});
}

/// Ensures that the current version of `brick:r13n` is compatible
/// with the version of `package:r13n` used in the [workingDirectory].
void ensureRuntimeCompatibility(Directory workingDirectory) {
  final version = _r13nPackageVersion(workingDirectory);
  final isCompatible =
      VersionConstraint.parse(compatibleR13nVersion).allows(version);

  if (!isCompatible) {
    throw R13nCompatibilityException(
      message: '''
The current version of "brick:r13n" requires "package:r13n" $compatibleR13nVersion.
Because the current version of "package:r13n" is $version}, version solving failed.''',
    );
  }
}

/// Retrieves the version of package:r13n from the pubspec.lock at the
/// [workingDirectory].
Version _r13nPackageVersion(Directory workingDirectory) {
  final lockFile = File(path.join(workingDirectory.path, 'pubspec.lock'));
  if (!lockFile.existsSync()) {
    throw R13nCompatibilityException(
      message: 'Expected to find a pubspec.lock in ${workingDirectory.path}.',
    );
  }

  final content = lockFile.readAsStringSync();
  final packages = (loadYaml(content) as YamlMap)['packages'] as YamlMap;
  final dependencyEntry = packages.entries.where(
    (package) => package.key == 'r13n',
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
  return Version.parse(dependency['version'] as String);
}
