import '../hooks.dart';

class R13nYamlNotFoundException extends R13nException {
  R13nYamlNotFoundException()
      : super(
          message: 'No r13n.yaml found.',
        );
}
