import 'package:example/r13n/app_regionalizations.dart';
import 'package:flutter/widgets.dart';

export 'app_regionalizations.dart';

extension AppRegionalizationsX on BuildContext {
  AppRegionalizations get r13n => AppRegionalizations.of(this);
}
