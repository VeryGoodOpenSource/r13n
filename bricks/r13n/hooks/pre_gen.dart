import 'dart:async';
import 'dart:convert' show Encoding, jsonDecode;

import 'package:mason/mason.dart';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async => runZonedGuarded(
      () => _run(context),
      (error, stack) => onError(context, error, stack),
    );

Future<void> _run(HookContext context) async {
  final configuration = await R13nYamlConfiguration.read();

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
      .map(
        (entry) => {'value': entry.key},
      )
      .toList();

  context.vars = {
    'currentYear': DateTime.now().year,
    'regions': regions,
    'getters': getters,
    'fallbackCode': fallbackRegion,
    'arbDir': configuration.arbDir,
  };
}

class R13nException implements Exception {
  const R13nException(
    this.error, {
    required this.message,
  });

  final Object error;

  final String message;
}

void onError(HookContext context, Object error, StackTrace stackTrace) {
  if (error is R13nException) {
    context.logger.err('Oops, something went wrong!');
    context.logger.err(error.message);
  }
  Error.throwWithStackTrace(error, stackTrace);
}

Future<List<ArbDocument>> readArbDocuments(
  R13nYamlConfiguration configuration,
) async {
  final arbPath = path.join(Directory.current.path, configuration.arbDir);
  final arbDirectory = Directory(arbPath);
  final arbPaths = arbDirectory
      .listSync()
      .where(
        (fileSystemEntity) =>
            fileSystemEntity.path.endsWith(ArbDocument._extension),
      )
      .map((fileSystemEntity) => fileSystemEntity.path);

  final documents = await Future.wait([
    for (final path in arbPaths) ArbDocument.read(path),
  ]);
  return documents;
}

class _ArbMissingRegionTag extends R13nException {
  const _ArbMissingRegionTag(Object error)
      : super(
          error,
          message:
              'Missing region tag in arb file, make sure to include @@region',
        );
}

class ArbDocument {
  const ArbDocument._({
    required this.path,
    required this.values,
  });

  static const _extension = '.arb';

  static Future<ArbDocument> read(String path) async {
    assert(
      path.endsWith(_extension),
      'File is not a valid arb file: $path',
    );

    final file = File(path);

    final encoding = Encoding.getByName('utf-8');
    final json = await file.readAsString(encoding: encoding!);
    final content = jsonDecode(json) as Map<String, dynamic>;

    final values = <ArbValue>[];
    for (final key in content.keys) {
      final value = ArbValue(
        key: key,
        value: content[key],
      );
      values.add(value);
    }

    return ArbDocument._(
      path: path,
      values: values,
    );
  }

  String get region {
    try {
      return values
          .firstWhere(
            (value) => value.key == '@@region',
          )
          .value;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(_ArbMissingRegionTag(error), stackTrace);
    }
  }

  Iterable<ArbValue> get regionalizedValues =>
      values.where((value) => !value.key.startsWith('@@'));

  final String path;
  final List<ArbValue> values;
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

R13nYamlConfiguration? _r13nYamlConfiguration;

class _R13YamlNotFound extends R13nException {
  _R13YamlNotFound(Object error)
      : super(
          error,
          message: 'No r13n.yaml found.',
        );
}

class R13nYamlConfiguration {
  const R13nYamlConfiguration._({
    required this.arbDir,
    required this.templateArbFile,
  });

  R13nYamlConfiguration._fromYamlMap(YamlMap map)
      : this._(
          arbDir: map['arb-dir'] as String,
          templateArbFile: map['template-arb-file'] as String,
        );

  static const _fileName = 'r13n.yaml';

  static Future<R13nYamlConfiguration> read() async {
    if (_r13nYamlConfiguration != null) return _r13nYamlConfiguration!;

    try {
      final file = File(path.join(Directory.current.path, _fileName));
      final content = await file.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      final options =
          _r13nYamlConfiguration = R13nYamlConfiguration._fromYamlMap(yaml);
      return options;
    } on FileSystemException catch (error, stackTrace) {
      Error.throwWithStackTrace(_R13YamlNotFound(error), stackTrace);
    }
  }

  final String arbDir;
  final String templateArbFile;
}
