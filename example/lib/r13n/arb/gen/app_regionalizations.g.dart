// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/widgets.dart';
import 'package:r13n/r13n.dart';

import 'app_regionalizations_es.g.dart';
import 'app_regionalizations_gb.g.dart';
import 'app_regionalizations_us.g.dart';

abstract class AppRegionalizations extends Regionalizations {
  const AppRegionalizations({required super.region, super.key});

  static const _fallback = AppRegionalizationsUs();

  static const RegionalizationsDelegate<AppRegionalizations> delegate =
      _AppRegionalizationsDelegate(
    regions: {
      'es': AppRegionalizationsEs(),
      'gb': AppRegionalizationsGb(),
      'us': AppRegionalizationsUs(),
    },
  );

  static AppRegionalizations of(BuildContext context) =>
      Regionalizations.of<AppRegionalizations>(context, AppRegionalizations) ??
      _fallback;

  String get supportEmail;
}

@immutable
class _AppRegionalizationsDelegate
    extends RegionalizationsDelegate<AppRegionalizations> {
  const _AppRegionalizationsDelegate({
    required Map<String, AppRegionalizations> regions,
  }) : _regions = regions;

  final Map<String, AppRegionalizations> _regions;

  @override
  AppRegionalizations load(Region region) => _regions[region.regionalCode]!;

  @override
  bool isSupported(Region region) => _regions.containsKey(region.regionalCode);

  @override
  bool shouldReload(_AppRegionalizationsDelegate old) => false;
}
