import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:arb_parser/arb_parser.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

import 'lib/hooks.dart';

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

  final documents = await _readArbDocuments(configuration);
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

Future<List<R13nArbDocument>> _readArbDocuments(
  R13nConfiguration configuration,
) async {
  final arbPath = path.join(Directory.current.path, configuration.arbDir);
  final arbDirectory = Directory(arbPath);
  final arbFileSystemEntities = arbDirectory.listSync().where(
        (fileSystemEntity) =>
            fileSystemEntity.path.endsWith(ArbDocument.extension),
      );
  final r13nDocuments = arbFileSystemEntities
      .map((fileSystemEntity) => R13nArbDocument(path: fileSystemEntity.path))
      .toList();
  await Future.wait(r13nDocuments.map((document) => document.read()));
  return r13nDocuments;
}
