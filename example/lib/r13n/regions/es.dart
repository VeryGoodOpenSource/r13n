// ignore_for_file: use_key_in_widget_constructors

import 'package:example/r13n/app_regionalizations.dart';
import 'package:r13n/r13n.dart';

class AppRegionalizationsEs extends AppRegionalizations {
  const AppRegionalizationsEs()
      : super(
          region: const Region(regionalCode: 'es'),
        );

  @override
  String get supportEmail => 'support@vgv.es';
}
