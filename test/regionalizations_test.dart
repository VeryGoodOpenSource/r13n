// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// Not needed for test files
// ignore_for_file: prefer_const_constructors
// Not needed for test files
// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:r13n/r13n.dart';

class _TestRegionalizationsDelegate extends RegionalizationsDelegate<bool> {
  _TestRegionalizationsDelegate(this.loader);

  final bool Function(Region) loader;

  @override
  bool isSupported(Region region) => true;

  @override
  bool load(Region region) => loader(region);

  @override
  bool shouldReload(covariant RegionalizationsDelegate<dynamic> old) => true;
}

void main() {
  group('Region', () {
    group('can be instantiated', () {
      test('with named constructor', () {
        expect(Region(regionalCode: ''), isA<Region>());
      });

      test('with empty constructor', () {
        expect(Region.empty, isA<Region>());
      });

      test('with fromPlatform factory', () {
        expect(Region.fromPlatform(), isA<Region>());
      });
    });

    group('== operator', () {
      test('is true when regionalCodes are the same', () {
        const regionalCode = 'abc';
        expect(
          Region(regionalCode: regionalCode) ==
              Region(regionalCode: regionalCode),
          isTrue,
        );
      });

      test('is false when regionalCodes differ', () {
        expect(
          Region(regionalCode: 'a') == Region(regionalCode: 'b'),
          isFalse,
        );
      });
    });

    test('hashCode is based on regionalCode', () {
      const regionalCode = 'abc';
      expect(
        Region(regionalCode: regionalCode).hashCode,
        equals(regionalCode.hashCode),
      );
    });

    test('toString returns normally', () {
      expect(
        () => Region.empty.toString(),
        returnsNormally,
      );
    });
  });

  group('Regionalizations', () {
    test('can be instantiated', () {
      expect(
        Regionalizations(region: Region.empty),
        isA<Regionalizations>(),
      );
    });

    group('regionOf', () {
      testWidgets('gets region', (tester) async {
        const region = Region.empty;
        late final BuildContext buildContext;
        await tester.pumpWidget(
          Regionalizations(
            region: region,
            child: Builder(
              builder: (context) {
                buildContext = context;
                return SizedBox.shrink();
              },
            ),
          ),
        );

        expect(
          Regionalizations.regionOf(buildContext),
          equals(region),
        );
      });

      testWidgets(
        'throws AssertionError when there is no Regionalizations ancestor',
        (tester) async {
          late final BuildContext buildContext;
          await tester.pumpWidget(
            Builder(
              builder: (context) {
                buildContext = context;
                return SizedBox.shrink();
              },
            ),
          );

          expect(
            () => Regionalizations.regionOf(buildContext),
            throwsAssertionError,
          );
        },
      );
    });

    group('of', () {
      testWidgets('returns resource', (tester) async {
        const region = Region.empty;
        late final BuildContext buildContext;
        const resource = true;
        await tester.pumpWidget(
          Regionalizations(
            region: region,
            delegates: [
              _TestRegionalizationsDelegate((_) => resource),
            ],
            child: Builder(
              builder: (context) {
                buildContext = context;
                return SizedBox.shrink();
              },
            ),
          ),
        );

        expect(
          Regionalizations.of<bool>(buildContext, bool),
          equals(resource),
        );
      });

      testWidgets(
        'returns null when there is no resource of given type',
        (tester) async {
          late final BuildContext buildContext;
          await tester.pumpWidget(
            Regionalizations(
              region: Region.empty,
              child: Builder(
                builder: (context) {
                  buildContext = context;
                  return SizedBox.shrink();
                },
              ),
            ),
          );

          expect(
            Regionalizations.of<Object>(buildContext, Object),
            isNull,
          );
        },
      );

      testWidgets(
        'returns null when there is no Regionalizations ancestor',
        (tester) async {
          late final BuildContext buildContext;
          await tester.pumpWidget(
            Builder(
              builder: (context) {
                buildContext = context;
                return SizedBox.shrink();
              },
            ),
          );

          expect(
            Regionalizations.of<Object>(buildContext, Object),
            isNull,
          );
        },
      );
    });

    group('updateDependencies', () {
      testWidgets('updates Region', (tester) async {
        late BuildContext buildContext;
        late StateSetter stateSetter;
        var region = Region.empty;
        final delegate = _TestRegionalizationsDelegate(
          (region) => region == Region.empty,
        );

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              stateSetter = setState;
              return Regionalizations(
                region: region,
                delegates: [delegate],
                child: Builder(
                  builder: (context) {
                    buildContext = context;
                    return SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        );

        expect(
          Regionalizations.of<bool>(buildContext, bool),
          equals(delegate.load(region)),
        );

        region = Region(regionalCode: 'test');
        stateSetter(() {});
        await tester.pump();

        expect(
          Regionalizations.of<bool>(buildContext, bool),
          equals(delegate.load(region)),
        );
      });

      group('updates delegates', () {
        testWidgets('when delegates length changes', (tester) async {
          late BuildContext buildContext;
          late StateSetter stateSetter;
          var delegates = [_TestRegionalizationsDelegate((_) => true)];

          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                stateSetter = setState;
                return Regionalizations(
                  region: Region.empty,
                  delegates: delegates,
                  child: Builder(
                    builder: (context) {
                      buildContext = context;
                      return SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          );

          expect(
            Regionalizations.of<bool>(buildContext, bool),
            isNotNull,
          );

          delegates = [];
          stateSetter(() {});
          await tester.pump();

          expect(
            Regionalizations.of<bool>(buildContext, bool),
            isNull,
          );
        });

        testWidgets('when delegates change', (tester) async {
          late BuildContext buildContext;
          late StateSetter stateSetter;
          var delegates = [_TestRegionalizationsDelegate((_) => true)];

          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                stateSetter = setState;
                return Regionalizations(
                  region: Region.empty,
                  delegates: delegates,
                  child: Builder(
                    builder: (context) {
                      buildContext = context;
                      return SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          );

          expect(
            Regionalizations.of<bool>(buildContext, bool),
            isTrue,
          );

          delegates = [_TestRegionalizationsDelegate((_) => false)];
          stateSetter(() {});
          await tester.pump();

          expect(
            Regionalizations.of<bool>(buildContext, bool),
            isFalse,
          );
        });
      });
    });
  });

  group('RegionalizationsDelegate', () {
    test('toString returns normally', () {
      expect(
        () => _TestRegionalizationsDelegate((_) => true).toString(),
        returnsNormally,
      );
    });
  });
}
