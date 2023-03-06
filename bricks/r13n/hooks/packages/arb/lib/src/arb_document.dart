import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:arb/arb.dart';

/// {@template arb_document}
/// An [ArbDocument] represents an arb file and its [values].
/// {@endtemplate}
class ArbDocument {
  /// {@macro arb_document}
  ArbDocument({
    required this.path,
  }) : assert(path.endsWith(extension), 'File is not a valid arb file: $path');

  /// Reads the arb file at [path], initializing the [values].
  Future<void> read() async {
    final file = File(path);
    final json = await file.readAsString();
    final content = jsonDecode(json) as Map<String, dynamic>;
    final values = content.entries
        .map((e) => ArbValue(key: e.key, value: e.value as String))
        .toList();
    this.values = UnmodifiableListView(values);
  }

  /// The file extension for arb files.
  static const extension = '.arb';

  /// The path to the arb file.
  final String path;

  /// The [ArbValue]s in the arb file.
  ///
  /// The order of the values is the same as the order in the file.
  ///
  /// Accessing this property before [read] is called will throw a
  /// `LateInitializationError`.
  late final UnmodifiableListView<ArbValue> values;
}
