import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'hooks.dart';

class R13nConfiguration {

  R13nConfiguration._fromYamlMap(YamlMap map)
      : this._(
          arbDir: map['arb-dir'] as String,
          templateArbFile: map['template-arb-file'] as String,
        );
  const R13nConfiguration._({
    required this.arbDir,
    required this.templateArbFile,
  });

  final String arbDir;
  final String templateArbFile;

  static const _fileName = 'r13n.yaml';

  static Future<R13nConfiguration> read() async {
    try {
      final file = File(path.join(Directory.current.path, _fileName));
      final content = await file.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return R13nConfiguration._fromYamlMap(yaml);
    } on FileSystemException catch (_) {
      throw R13nYamlNotFoundException();
    }
  }
}

