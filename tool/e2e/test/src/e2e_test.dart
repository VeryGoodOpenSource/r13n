import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  test('quick start', () async {
    final tempDirectory = Directory.current.createTempSync();

    final arbPath = path.join(tempDirectory.path, 'lib', 'r13n', 'arb');
    Directory(arbPath).createSync(recursive: true);

    final arbUsPath = path.join(arbPath, 'app_us.arb');
    const arbUsFileContent = '''
{
    "@@region": "us",
    "supportEmail": "us@verygood.ventures"
}
''';

    File(arbUsPath)
      ..writeAsStringSync(arbUsFileContent)
      ..createSync();

    final arbGbPath = path.join(arbPath, 'app_gb.arb');
    const arbGbFileContent = '''
{
    "@@region": "gb",
    "supportEmail": "gb@verygood.ventures"
}
''';
    File(arbGbPath)
      ..writeAsStringSync(arbGbFileContent)
      ..createSync();

    final r13nYamlPath = path.join(tempDirectory.path, 'r13n.yaml');
    final r13nYamlFileContent = '''
arb-dir: ${path.relative(arbPath, from: tempDirectory.path)}
template-arb-file: ${path.basename(arbUsPath)}
''';
    File(r13nYamlPath)
      ..writeAsStringSync(r13nYamlFileContent)
      ..createSync();

    final rootPath = Directory.current.path;
    final r13nBrickPath = path.join(rootPath, 'bricks', 'r13n');
    final r13nBrick = Brick.path(r13nBrickPath);
    final r13nMasonGenerator = await MasonGenerator.fromBrick(r13nBrick);
    final directoryGeneratorTarget = DirectoryGeneratorTarget(tempDirectory);
    await r13nMasonGenerator.hooks
        .preGen(workingDirectory: tempDirectory.path, vars: {});
    await r13nMasonGenerator.generate(directoryGeneratorTarget);
    await r13nMasonGenerator.hooks
        .postGen(workingDirectory: tempDirectory.path, vars: {});
  });
}
