import 'package:example/r13n/arb/gen/app_regionalizations.g.dart';
import 'package:flutter/widgets.dart';

export 'package:example/r13n/arb/gen/app_regionalizations.g.dart';

extension AppRegionalizationsX on BuildContext {
  AppRegionalizations get r13n => AppRegionalizations.of(this);
}
