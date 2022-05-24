// ignore_for_file: use_key_in_widget_constructors

import 'package:example/r13n/app_regionalizations.dart';
import 'package:r13n/r13n.dart';

class AppRegionalizationsUs extends AppRegionalizations {
  const AppRegionalizationsUs()
      : super(
          region: const Region(regionalCode: 'us'),
        );

  @override
  String get supportEmail => 'support@vgv.com';
}
