import 'dart:collection';

import 'package:arb_parser/arb_parser.dart';
import 'package:r13n_hooks/hooks.dart';

/// {@template r13n_arb_document_missing_region_tag_exception}
/// Thrown when an [R13nArbDocument] does not have a region tag.
///
/// A region tag is a key in the form of `@@region` that specifies the region
/// of the document.
/// {@endtemplate}
class R13nArbDocumentMissingRegionTagException extends R13nException {
  /// {@macro r13n_arb_document_missing_region_tag_exception}
  const R13nArbDocumentMissingRegionTagException()
      : super(
          message:
              'Missing region tag in arb file, make sure to include @@region',
        );
}

/// {@template r13n_arb_document}
/// A special type of [ArbDocument] used for regionalization.
///
/// An [R13nArbDocument] must have a region tag in the form of `@@region`. Its
/// other values are considered as regionalized values, which are the values
/// that are to be regionalized.
/// {@endtemplate}
class R13nArbDocument extends ArbDocument {
  /// {@macro r13n_arb_document}
  R13nArbDocument({required super.path});

  /// Reads the arb file at [path], initializing the [values].
  ///
  /// In addition to reading the values, this method also reads the region
  /// of the document and the regionalized values.
  ///
  /// If the document does not have a region tag, a
  /// [R13nArbDocumentMissingRegionTagException] will be thrown.
  @override
  Future<void> read() async {
    await super.read();

    final region = values.where((tag) => tag.key == '@@region');
    if (region.isEmpty) {
      throw const R13nArbDocumentMissingRegionTagException();
    }
    this.region = region.first.value;

    final regionalizedValues =
        values.where((value) => !value.key.startsWith('@@'));
    this.regionalizedValues = UnmodifiableListView(regionalizedValues);
  }

  /// The region of the document.
  ///
  /// An [R13nArbDocument] must have a region tag in the form of `@@region`,
  /// specifying the region of the document. If a document has multiple region
  /// tags, the first one will be used.
  ///
  /// For example, if the region tag is `@@region: us`, then the region
  /// of the document is `us`.
  ///
  /// Accessing this property before [read] is called will throw a
  /// `LateInitializationError`.
  late final String region;

  /// The values of the document that are regionalized.
  ///
  /// Regionalized values are values that are not prefixed with `@@`,
  /// since those are used as [R13nArbDocument] metadata.
  ///
  /// Accessing this property before [read] is called will throw a
  /// `LateInitializationError`.
  late final UnmodifiableListView<ArbValue> regionalizedValues;
}
