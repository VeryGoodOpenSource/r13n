// ignore_for_file: use_key_in_widget_constructors

import 'package:example/r13n/app_regionalizations.dart';
import 'package:r13n/r13n.dart';

class AppRegionalizationsUk extends AppRegionalizations {
  const AppRegionalizationsUk()
      : super(
          region: const Region(regionalCode: 'uk'),
        );

  @override
  String get supportEmail => 'support@vgv.co.uk';
}
