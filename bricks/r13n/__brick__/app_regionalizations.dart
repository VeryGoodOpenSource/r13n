import 'package:flutter/widgets.dart';
import 'package:r13n/r13n.dart';

{{> regions_imports.dart }}

abstract class AppRegionalizations extends Regionalizations {
  const AppRegionalizations({required super.region, super.key});

  static const _fallback = AppRegionalizations{{#pascalCase}}{{fallbackCode}}{{/pascalCase}}();

  static const RegionalizationsDelegate<AppRegionalizations> delegate =
      _AppRegionalizationsDelegate(
    regions: {
{{> regions_map.dart }}
    },
  );

  static AppRegionalizations of(BuildContext context) =>
      Regionalizations.of<AppRegionalizations>(
        context,
        AppRegionalizations,
      ) ??
      _fallback;

  {{> regions_getters.dart }}
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
