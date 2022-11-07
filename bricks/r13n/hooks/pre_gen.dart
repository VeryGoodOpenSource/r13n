import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';
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
      'values': document.regionalizedValues.map((value) {
        return value.toMap();
      }).toList(),
    };
    regions.add(regionMap);

    final isTemplate = document.path.endsWith(configuration.templateArbFile);
    if (fallbackRegion == null || isTemplate) {
      fallbackRegion = region;
    }
  }

  final getters = documents.first.regionalizedValues.map((entry) {
    return {
      'value': entry.key,
      'source': entry.source,
    };
  }).toList();

  context.vars = {
    'currentYear': DateTime.now().year,
    'regions': regions,
    'getters': getters,
    'fallbackCode': fallbackRegion,
    'arbDir': configuration.arbDir,
    'multipleArbFiles': configuration.multipleArbFiles,
    'outputDirectory': configuration.outputDirectory,
  };
}

Future<List<ArbDocument>> readArbDocuments(
  R13nConfiguration configuration,
) async {
  final multipleArbFiles = configuration.multipleArbFiles;

  if (multipleArbFiles) {
    return readMultiArbDocuments(
      configuration,
    );
  }

  final arbPath = path.join(
    Directory.current.path,
    configuration.arbDir,
  );
  final arbDirectory = Directory(arbPath);

  final arbPathsSync = arbDirectory.listSync();

  final arbPaths = arbPathsSync.where(
    (fileSystemEntity) {
      return fileSystemEntity.path.endsWith(
        ArbDocument.extension,
      );
    },
  ).map(
    (fileSystemEntity) {
      return fileSystemEntity.path;
    },
  );

  return Future.wait(arbPaths.map(ArbDocument.read));
}

Future<List<ArbDocument>> readMultiArbDocuments(
  R13nConfiguration configuration,
) async {
  final arbPath = path.join(
    Directory.current.path,
    configuration.arbDir,
  );
  final arbDirectory = Directory(arbPath);

  final allArbPaths = await listSyncArbPaths(configuration);

  final arbDocuments = await Future.wait(
    configuration.preferredSupportedLocales.map(
      (region) async {
        final arbPath = path.join(
          arbDirectory.path,
          ArbDocument.createFileName(
            prefix: 'app_',
            region: region,
          ),
        );
        final arbDocument = ArbDocument.initial(arbPath, region);

        final regionArbPaths =
            allArbPaths.where(arbDocument.isSameRegion).toList();

        return combineArbDocument(
          configuration,
          arbDocument,
          regionArbPaths,
        );
      },
    ),
  );

  return arbDocuments;
}

Future<List<String>> listSyncArbPaths(
  R13nConfiguration configuration,
) async {
  final inputDirectoryPath = path.join(
    Directory.current.path,
    configuration.inputDirectory,
  );
  final inputDirectory = Directory(inputDirectoryPath);

  final allFiles = inputDirectory.listSync(
    recursive: true,
  );

  final subArbPaths = allFiles.where(
    (fileSystemEntity) {
      return fileSystemEntity.path.endsWith(ArbDocument.extension);
    },
  ).map(
    (fileSystemEntity) {
      return fileSystemEntity.path;
    },
  ).toList();

  return subArbPaths;
}

Future<ArbDocument> combineArbDocument(
  R13nConfiguration configuration,
  ArbDocument arbDocument,
  List<String> regionArbPaths,
) async {
  final subArbDocuments = await Future.wait(
    regionArbPaths.map(ArbDocument.read),
  );

  for (final element in subArbDocuments) {
    arbDocument.values.addAll(element.values);
  }

  return Future.value(arbDocument);
}

/// The classes below should be part of their own library, but Mason
/// does not yet support that, so for now they are here.
///
/// Enjoy.

class R13nConfiguration {
  const R13nConfiguration._({
    required this.arbDir,
    required this.templateArbFile,
    required this.multipleArbFiles,
    required this.inputDirectory,
    required this.inputFilePattern,
    required this.outputDirectory,
    required this.outputFileName,
    required this.preferredSupportedLocales,
  });

  factory R13nConfiguration._fromYamlMap(YamlMap map) {
    final arbDir = (map['arb-dir'] ?? 'lib/r13n/arb') as String;
    final outputDirectory = (map['output-directory'] ?? arbDir) as String;

    final inputDirectory = (map['input-directory'] ?? 'lib') as String;

    final inputFilePattern =
        (map['input-file-pattern'] ?? '_{{locale}}.arb') as String;

    var preferredSupportedLocales = <String>[];

    if (map['preferred-supported-locales'] != null) {
      preferredSupportedLocales =
          (map['preferred-supported-locales'] as YamlList?)
                  ?.nodes
                  .map((e) => e.toString())
                  .toList() ??
              <String>[];
    }

    final templateArbFile =
        (map['template-arb-file'] ?? 'app_us.arb') as String;

    final multipleArbFiles = (map['multiple-arb-files'] ?? false) as bool;
    final outputFileName = (map['output-file_name'] ?? '') as String;

    return R13nConfiguration._(
      arbDir: arbDir,
      templateArbFile: templateArbFile,
      multipleArbFiles: multipleArbFiles,
      inputDirectory: inputDirectory,
      inputFilePattern: inputFilePattern,
      outputDirectory: outputDirectory,
      outputFileName: outputFileName,
      preferredSupportedLocales: preferredSupportedLocales,
    );
  }

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

  // advanced properties
  final bool multipleArbFiles;
  final String inputDirectory;
  final String inputFilePattern;
  final String outputDirectory;
  final String outputFileName;
  final List<String> preferredSupportedLocales;
}

class ArbValue {
  const ArbValue({
    required this.key,
    required this.value,
    this.source = '',
  });

  final String key;
  final String value;
  final String source;

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'source': source,
    };
  }
}

class ArbDocument {
  const ArbDocument._internal({
    required this.path,
    required this.values,
  });

  factory ArbDocument.initial(
    String path,
    String region,
  ) {
    return ArbDocument._internal(
      path: path,
      values: [
        ArbValue(
          key: '@@region',
          value: region,
          source: path,
        )
      ],
    );
  }

  factory ArbDocument.create({
    required String path,
    required List<ArbValue> values,
  }) {
    return ArbDocument._internal(
      path: path,
      values: values,
    );
  }

  static const extension = '.arb';

  static String createFileName({
    required String region,
    String prefix = '',
  }) {
    return '$prefix$region${ArbDocument.extension}';
  }

  bool isSameRegion(String path) {
    return path.endsWith(
      createFileName(
        region: region,
      ),
    );
  }

  static Future<ArbDocument> read(String path) async {
    assert(path.endsWith(extension), 'File is not a valid arb file: $path');

    final file = File(path);
    final json = await file.readAsString();
    final content = jsonDecode(json) as Map<String, dynamic>;

    final values = content.entries.map((e) {
      return ArbValue(
        key: e.key,
        value: e.value as String,
        source: path.replaceAll(Directory.current.path, ''),
      );
    }).toList();

    return ArbDocument.create(
      path: path,
      values: values,
    );
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
bool isCompatibleWithR13n(VersionConstraint version) {
  return VersionConstraint.parse(compatibleR13nVersion).allowsAll(version);
}

/// Ensures that the current version of `brick:r13n` is compatible
/// with the version of `package:r13n` used in the [cwd].
void ensureRuntimeCompatibility(Directory cwd) {
  final pubspecFile = File(path.join(cwd.path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    throw R13nCompatibilityException(
      message: 'Expected to find a pubspec.yaml in ${cwd.path}.',
    );
  }

  final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
  final dependencyEntry = pubspec.dependencies.entries.where(
    (e) => e.key == 'r13n',
  );

  if (dependencyEntry.isEmpty) {
    throw const R13nCompatibilityException(
      message: 'Expected to find a dependency on "r13n" in the pubspec.yaml',
    );
  }

  final dependency = dependencyEntry.first.value;
  if (dependency is HostedDependency) {
    if (!isCompatibleWithR13n(dependency.version)) {
      throw R13nCompatibilityException(
        message:
            '''The current version of "brick:r13n" requires "package:r13n" $compatibleR13nVersion.\nBecause the current version of "package:r13n" is ${dependency.version}, version solving failed.''',
      );
    }
  }
}
