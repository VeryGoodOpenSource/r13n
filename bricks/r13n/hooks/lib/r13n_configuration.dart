import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:r13n_hooks/hooks.dart';
import 'package:yaml/yaml.dart';

/// {@template r13n_yaml_not_found_exception}
/// Exception thrown when [R13nConfiguration] fails to find
/// [R13nConfiguration.fileName] file.
///
/// A [R13nConfiguration.fileName] file is required to define the location of
/// the arb files and other configurations.
/// {@endtemplate}
class R13nYamlNotFoundException extends R13nException {
  /// {@macro r13n_yaml_not_found_exception}
  R13nYamlNotFoundException() : super(message: 'No r13n.yaml found.');
}

/// {@template r13n_yaml_parse_exception}
/// Exception thrown when [R13nConfiguration] fails to parse the
/// [R13nConfiguration.fileName] file.
/// {@endtemplate}
class R13nYamlParseException extends R13nException {
  /// {@macro r13n_yaml_parse_exception}
  R13nYamlParseException(String message) : super(message: message);
}

/// {@template r13n_configuration}
/// Defines the configuration for the r13n brick.
///
/// The configuration is read from [R13nConfiguration.fileName] file. This
/// should be a yaml file with the following structure:
/// ```yaml
/// arb-dir: lib/l10n # path relative to the file location indicating the location of the arb files
/// template-arb-file: app_en.arb # the name of the template (default) arb file
/// ```
/// {@endtemplate}
class R13nConfiguration {
  /// {@macro r13n_configuration}
  const R13nConfiguration._({
    required this.arbDir,
    required this.templateArbFile,
  });

  /// The name of the configuration file.
  @visibleForTesting
  static const fileName = 'r13n.yaml';

  /// Reads the configuration from [R13nConfiguration.fileName] file.
  ///
  /// Throws a [R13nYamlNotFoundException] if the file is not found.
  static Future<R13nConfiguration> read() async {
    final file = File(path.join(Directory.current.path, fileName));
    if (!file.existsSync()) {
      throw R13nYamlNotFoundException();
    }

    late final YamlMap yaml;
    try {
      final content = await file.readAsString();
      yaml = loadYaml(content) as YamlMap;
    } catch (e, stackTrace) {
      throw R13nYamlParseException(
        'Failed to parse $fileName file. \n'
        'Failed with error: $e '
        'Stack trace: $stackTrace',
      );
    }

    final arbDir = yaml['arb-dir'] as String?;
    if (arbDir == null) {
      throw R13nYamlParseException(
        'Missing required field "arb-dir" in $fileName',
      );
    }

    final templateArbFile = yaml['template-arb-file'] as String?;
    if (templateArbFile == null) {
      throw R13nYamlParseException(
        'Missing required field "template-arb-file" in $fileName',
      );
    }

    return R13nConfiguration._(
      arbDir: arbDir,
      templateArbFile: templateArbFile,
    );
  }

  /// The directory where the arb files are located.
  ///
  /// All the arb files to be used for regionalization should be located in
  /// directly under this directory.
  ///
  /// The path value is relative to the location of
  /// [R13nConfiguration.fileName] file.
  ///
  /// For example:
  /// ```yaml
  /// arb-dir: lib/r13n/arb
  /// ```
  ///
  /// `arb-dir` is a required field in the configuration file.
  final String arbDir;

  /// The name of the template arb file.
  ///
  /// The template arb file is the file that contains the default values for
  /// the messages (acting as a fallback for the other arb files). It is similar
  /// to `template-arb-file` in the intl flutter package.
  ///
  /// For example:
  /// ```yaml
  /// template-arb-file: app_en.arb
  /// ```
  ///
  /// `template-arb-file` is a required field in the configuration file.
  final String templateArbFile;
}
