import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

import 'hooks.dart';

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

/// The version range of package:r13n
/// supported by the current version of the r13n brick.
const compatibleR13nVersion = '>=0.1.0-dev.1 <0.1.0-dev.3';

/// Whether current version of the r13n brick is compatible
/// with the provided [version] of package:r13n.
bool isCompatibleWithR13n(Version version) {
  return VersionConstraint.parse(compatibleR13nVersion).allows(version);
}
