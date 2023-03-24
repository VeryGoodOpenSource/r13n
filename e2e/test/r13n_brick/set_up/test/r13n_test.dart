import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:r13n/r13n.dart';
import 'package:r13n_e2e_test/r13n/arb/gen/app_regionalizations_gb.g.dart';
import 'package:r13n_e2e_test/r13n/arb/gen/app_regionalizations_us.g.dart';

void main() {
  group('AppRegionalizationsGb', () {
    test('has "gb" region', () {
      final regionalizations = AppRegionalizationsGb();
      final region = Region(regionalCode: 'gb');
      expect(regionalizations.region, equals(region));
    });

    test('has "gb@verygood.ventures" email', () {
      final regionalizations = AppRegionalizationsGb();
      final supportEmail = 'gb@verygood.ventures';
      expect(regionalizations.supportEmail, equals(supportEmail));
    });
  });

  group('AppRegionalizationsUs', () {
    test('has "us" region', () {
      final regionalizations = AppRegionalizationsUs();
      final region = Region(regionalCode: 'us');
      expect(regionalizations.region, equals(region));
    });

    test('has "us@verygood.ventures" email', () {
      final regionalizations = AppRegionalizationsUs();
      final supportEmail = 'us@verygood.ventures';
      expect(regionalizations.supportEmail, equals(supportEmail));
    });
  });

  group('Regionalizations', () {
    testWidgets('has "us" region as default', (tester) async {
      late BuildContext buildContext;
      await tester.pumpWidget(
        Regionalizations(
          region: Region(regionalCode: 'us'),
          child: StatefulBuilder(
            builder: (context, _) {
              buildContext = context;
              return SizedBox();
            },
          ),
        ),
      );

      final region = Region(regionalCode: 'us');
      expect(Regionalizations.regionOf(buildContext), equals(region));
    });
  });
}
