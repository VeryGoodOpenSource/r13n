# 🌐 r13n

[![Very Good Ventures][logo_white]][very_good_ventures_link_dark]
[![Very Good Ventures][logo_black]][very_good_ventures_link_light]

[![ci][ci_badge]][ci_link]
[![coverage][coverage_badge]][ci_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

---

A Flutter package that makes regionalization easy. Heavily inspired by [flutter_localizations][flutter_localizations_link] and [intl][intl_pub_link].

Similar to l10n which is short for localization, this package is called `r13n` as shorthand for regionalization.

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

## What is regionalization? 📍

Regionalization helps you display text in the app based on a person's region.

Example: Say your app’s users are in the US and the UK. On your support page, you want to display the correct support email based on the user’s region. You can use the `r13n` package to display support.uk@mycompany.com to users in the UK and support.us@mycompany.com to users in the US.

Similarly, l10n helps you display translations based on the user’s locale.

Example: When using l10n, your app will display text in the user’s preferred language.

The `r13n` package can and should be used in conjunction with l10n. `r13n` is an additional mechanism to personalize information presented to users in an app.

## How it works ⚙️

Similar to l10n, the `r13n` package uses `.arb` files to house the region-specific configurations.

The arb file contains strings for region-specific values. The `r13n` brick is used to generate compile-safe Dart code in order to access the correct versions of each value based on the user's region.

## Quick Start 🚀

1. For each supported region, add a new `.arb` file in `lib/r13n/arb`.

```
├── r13n
│   ├── arb
│   │   ├── app_gb.arb
│   │   └── app_us.arb
```

2. Add the translated strings to each `.arb` file:

`app_us.arb`

```arb
{
    "@@region": "us",
    "supportEmail": "us@verygood.ventures"
}
```

`app_gb.arb`

```arb
{
    "@@region": "gb",
    "supportEmail": "gb@verygood.ventures"
}
```

3. If you don't already have [`mason_cli`][mason_cli], use the following command:

```sh
$ dart pub global activate mason_cli
```

4. Then, install the [`r13n` brick][brickhub_r13n_link] globally.

```
$ mason add r13n -g
```

5. Add a new yaml file to the root directory of the Flutter project called `r13n.yaml` with the following content:

```yaml
arb-dir: lib/r13n/arb
template-arb-file: app_us.arb
```

6. Generate files.

```
$ mason make r13n --on-conflict overwrite
```

```
├── r13n
│   ├── arb
│   │   ├── gen
│   │   │   ├── app_regionalizations_gb.g.dart
│   │   │   ├── app_regionalizations_us.g.dart
│   │   │   └── app_regionalizations.g.dart
│   │   ├── app_us.arb
│   │   └── app_gb.arb
```

7. Add a `Regionalizations` widget to the widget tree.

```dart
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Regionalizations(
      region: Region.fromPlatform(),
      delegates: const [AppRegionalizations.delegate],
      child: MaterialApp(...)
      ...
    );
```

8. Use the new string.

```dart
import 'package:example/r13n/r13n.dart';

@override
Widget build(BuildContext context) {
  final r13n = AppRegionalizations.of(context);
  return Text(r13n.supportEmail);
}
```

## Roadmap 🗺

- [ ] Support asynchronous delegates
- [ ] Support regionalization based on IP address
- [ ] Provide API's to support sub-regions (for example, states in the U.S.)

## Additional Resources 📚

For more information, see the [example][example_link], the [r13n brick][brickhub_r13n_link] and the [source code][github_r13n_link].

[brickhub_r13n_link]: https://brickhub.dev/bricks/r13n
[ci_badge]: https://github.com/VeryGoodOpenSource/r13n/actions/workflows/main.yaml/badge.svg
[ci_link]: https://github.com/VeryGoodOpenSource/r13n/actions/workflows/main.yaml
[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/r13n/main/coverage_badge.svg
[example_link]: https://github.com/VeryGoodOpenSource/r13n/tree/main/example
[flutter_localizations_link]: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html
[github_r13n_link]: https://github.com/VeryGoodOpenSource/r13n
[intl_pub_link]: https://pub.dev/packages/intl
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_cli]: https://github.com/felangel/mason/tree/master/packages/mason_cli
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures/?utm_source=github
[very_good_ventures_link_dark]: https://verygood.ventures/?utm_source=github#gh-dark-mode-only
[very_good_ventures_link_light]: https://verygood.ventures/?utm_source=github#gh-light-mode-only
