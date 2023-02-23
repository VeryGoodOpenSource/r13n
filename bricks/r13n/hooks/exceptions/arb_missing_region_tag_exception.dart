import '../hooks.dart';

class ArbMissingRegionTagException extends R13nException {
  const ArbMissingRegionTagException()
      : super(
    message:
    'Missing region tag in arb file, make sure to include @@region',
  );
}