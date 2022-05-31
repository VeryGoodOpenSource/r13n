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
  String? fallbackCode;

  final documents = await readArbDocuments(configuration, context);
  for (final document in documents) {
    final fileName = document.path.split('/').last;
    final regionCode = fileName.split('.').first;

    final region = {
      'code': regionCode,
      'values': document.values.map((value) => value.toMap()).toList(),
    };
    regions.add(region);

    final isTemplate = document.path.endsWith(configuration.templateArbFile);
    if (fallbackCode == null || isTemplate) {
      fallbackCode = regionCode;
    }
  }

  final getters = documents.first.values
      .map(
        (entry) => {'value': entry.key},
      )
      .toList();

  context.vars = {
    'regions': regions,
    'getters': getters,
    'fallbackCode': fallbackCode,
  };
}

class R13nException implements Exception {
  const R13nException(this.error);

  final Object error;
}

void onError(HookContext context, Object error, StackTrace stackTrace) {
  if (error is R13nException) {
    context.logger.err('Something happend:');
    throw error;
  }
  throw error;
}

Future<List<ArbDocument>> readArbDocuments(
  R13nYamlConfiguration configuration,
  HookContext context,
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

  final documents = <ArbDocument>[];
  for (final path in arbPaths) {
    final document = await ArbDocument.read(path, context);
    documents.add(document);
  }

  return documents;
}

class ArbDocument {
  const ArbDocument._({
    required this.path,
    required this.values,
  });

  static const _extension = '.arb';

  static Future<ArbDocument> read(String path, HookContext context) async {
    assert(
      path.endsWith(_extension),
      'Path $path does not end with $_extension',
    );

    final file = File(path);

    final encoding = Encoding.getByName('utf-8');
    final json = await file.readAsString(encoding: encoding!);
    // context.logger.prompt(json.toString());
    final content = jsonDecode(json) as Map<String, dynamic>;
    // context.logger.prompt(content.toString());

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
  _R13YamlNotFound(Object error) : super(error);
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

  // context.vars = {
  //   'regions': [
  //     {
  //       'code': 'us',
  //       'values': [
  //         {
  //           'key': 'supportEmail',
  //           'value': 'email@us.com',
  //         },
  //       ],
  //     },
  //     {
  //       'code': 'es',
  //       'values': [
  //         {
  //           'key': 'supportEmail',
  //           'value': 'email@us.com',
  //         },
  //       ],
  //     }
  //   ],
  // };

