// ignore_for_file: use_key_in_widget_constructors

import 'package:example/r13n/app_regionalizations.dart';
import 'package:r13n/r13n.dart';

class AppRegionalizationsFallback extends AppRegionalizations {
  const AppRegionalizationsFallback()
      : super(
          region: const Region(regionalCode: 'fallback'),
        );

  @override
  String get supportEmail => 'Your region is not supported.';
}
