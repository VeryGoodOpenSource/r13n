import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

Future<void> run(HookContext context) async => preGen(context);

Future<void> preGen(HookContext context) async {
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
    } on FileSystemException catch (error) {
      throw YamlNotFoundException(error);
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
        ArbMissingRegionTagException(error),
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
  const R13nException(
    this.error, {
    required this.message,
  });

  final Object error;

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class YamlNotFoundException extends R13nException {
  YamlNotFoundException(super.error)
      : super(
          message: 'No r13n.yaml found.',
        );
}

class ArbMissingRegionTagException extends R13nException {
  const ArbMissingRegionTagException(super.error)
      : super(
          message:
              'Missing region tag in arb file, make sure to include @@region',
        );
}
