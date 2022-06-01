import 'package:flutter/widgets.dart';
import 'package:r13n/r13n.dart';

abstract class AppRegionalizations extends Regionalizations {
  const AppRegionalizations();

  static const _fallback = AppRegionalizationsFallback();

  static const RegionalizationsDelegate<AppRegionalizations> delegate =
      _AppRegionalizationsDelegate(
    regions: {},
  );

  static AppRegionalizations of(BuildContext context) {
    return Regionalizations.of<AppRegionalizations>(
          context,
          AppRegionalizations,
        ) ??
        _fallback;
  }
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