import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

typedef Exit = void Function(int);

Future<void> run(HookContext context) async => preGen(context);

Future<void> preGen(
  HookContext context, {
  void Function(io.Directory) ensureRuntimeCompatibility =
      ensureRuntimeCompatibility,
  Exit exit = io.exit,
}) async {
  try {
    ensureRuntimeCompatibility(Directory.current);
  } on R13nCompatibilityException catch (error) {
    context.logger.err(error.message);
    return exit(1);
  }

  final configuration = await R13nConfiguration.read();
  final regions = <Map<String, dynamic>>[];
  String? fallbackRegion;

  final documents = await readArbDocuments(configuration);
  for (final document in documents) {
    final region = document.region;

    final regionMap = {
      'code': region,
      'values':
          document.regionalizedValues.map((value) => value.toMap()).toList(),
    };
    regions.add(regionMap);

    final isTemplate = document.path.endsWith(configuration.templateArbFile);
    if (fallbackRegion == null || isTemplate) {
      fallbackRegion = region;
    }
  }

  final getters = documents.first.regionalizedValues
      .map((entry) => {'value': entry.key})
      .toList();

  context.vars = {
    'currentYear': DateTime.now().year,
    'regions': regions,
    'getters': getters,
    'fallbackCode': fallbackRegion,
    'arbDir': configuration.arbDir,
  };
}

Future<List<ArbDocument>> readArbDocuments(
  R13nConfiguration configuration,
) async {
  final arbPath = path.join(Directory.current.path, configuration.arbDir);
  final arbDirectory = Directory(arbPath);
  final arbPaths = arbDirectory
      .listSync()
      .where(
        (fileSystemEntity) =>
            fileSystemEntity.path.endsWith(ArbDocument.extension),
      )
      .map((fileSystemEntity) => fileSystemEntity.path);

  return Future.wait(arbPaths.map(ArbDocument.read));
}

/// The classes below should be part of their own library, but Mason
/// does not yet support that, so for now they are here.
///
/// Enjoy.

class R13nConfiguration {
  const R13nConfiguration._({
    required this.arbDir,
    required this.templateArbFile,
  });

  R13nConfiguration._fromYamlMap(YamlMap map)
      : this._(
          arbDir: map['arb-dir'] as String,
          templateArbFile: map['template-arb-file'] as String,
        );

  static const _fileName = 'r13n.yaml';

  static Future<R13nConfiguration> read() async {
    try {
      final file = File(path.join(Directory.current.path, _fileName));
      final content = await file.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return R13nConfiguration._fromYamlMap(yaml);
    } on FileSystemException catch (_) {
      throw YamlNotFoundException();
    }
  }

  final String arbDir;
  final String templateArbFile;
}

class ArbValue {
  const ArbValue({
    required this.key,
    required this.value,
  });

  final String key;
  final String value;

  Map<String, dynamic> toMap() => {
        'key': key,
        'value': value,
      };
}

class ArbDocument {
  const ArbDocument._({
    required this.path,
    required this.values,
  });

  static const extension = '.arb';

  static Future<ArbDocument> read(String path) async {
    assert(path.endsWith(extension), 'File is not a valid arb file: $path');

    final file = File(path);
    final json = await file.readAsString();
    final content = jsonDecode(json) as Map<String, dynamic>;

    final values = content.entries
        .map((e) => ArbValue(key: e.key, value: e.value as String))
        .toList();

    return ArbDocument._(path: path, values: values);
  }

  String get region {
    try {
      return values.firstWhere((value) => value.key == '@@region').value;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        const ArbMissingRegionTagException(),
        stackTrace,
      );
    }
  }

  Iterable<ArbValue> get regionalizedValues =>
      values.where((value) => !value.key.startsWith('@@'));

  final String path;
  final List<ArbValue> values;
}

abstract class R13nException implements Exception {
  const R13nException({required this.message});

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class YamlNotFoundException extends R13nException {
  YamlNotFoundException()
      : super(
          message: 'No r13n.yaml found.',
        );
}

class ArbMissingRegionTagException extends R13nException {
  const ArbMissingRegionTagException()
      : super(
          message:
              'Missing region tag in arb file, make sure to include @@region',
        );
}

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

/// The version range of package:r13n
/// supported by the current version of the r13n brick.
const compatibleR13nVersion = '>=0.1.0-dev.1 <0.1.0-dev.3';

/// Whether current version of the r13n brick is compatible
/// with the provided [version] of package:r13n.
bool isCompatibleWithR13n(Version version) {
  return VersionConstraint.parse(compatibleR13nVersion).allows(version);
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
