// ignore_for_file: prefer_const_constructors
// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:r13n/r13n.dart';

class _TestRegionalizationsDelegate extends RegionalizationsDelegate<bool> {
  _TestRegionalizationsDelegate(this.resource);

  final bool resource;

  @override
  bool isSupported(Region region) => true;

  @override
  bool load(Region region) => resource;

  @override
  bool shouldReload(covariant RegionalizationsDelegate old) => true;
}

void main() {
  group('Region', () {
    group('can be instantied', () {
      test('with named constructor', () {
        expect(Region(regionalCode: ''), isA<Region>());
      });

      test('with empty contrustor', () {
        expect(Region.empty(), isA<Region>());
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
        () => Region.empty().toString(),
        returnsNormally,
      );
    });
  });

  group('Regionalizations', () {
    test('can be instantiated', () {
      expect(
        Regionalizations(region: Region.empty()),
        isA<Regionalizations>(),
      );
    });

    group('regionOf', () {
      testWidgets('gets region', (tester) async {
        const region = Region.empty();
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
        'throws AssertionError when there is no Regionalization ancestor',
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
        const region = Region.empty();
        const resource = true;
        late final BuildContext buildContext;
        await tester.pumpWidget(
          Regionalizations(
            region: region,
            delegates: [_TestRegionalizationsDelegate(resource)],
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
              region: Region.empty(),
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
        'returns null when there is no Regionalization ancestor',
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
  });
}
