# 🌐 Regionalization (r13n) 

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link] [![License: MIT][license_badge]][license_link]

---

A Flutter package that makes regionalization easy. Heavily inspired by [flutter_localizations][flutter_localizations_link] and [intl][intl_pub_link].

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

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

4. Then, install the `r13n` brick globally.

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

[mason_cli]: https://github.com/felangel/mason/tree/master/packages/mason_cli
[github_r13n_link]: https://github.com/VeryGoodOpenSource/r13n
[brickhub_r13n_link]: https://brickhub.dev/bricks/r13n/0.1.0-dev.2
[flutter_localizations_link]: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html
[intl_pub_link]: https://pub.dev/packages/intl
[ci_badge]: https://github.com/VeryGoodOpenSource/r13n/actions/workflows/r13n.yaml/badge.svg
[ci_link]: https://github.com/VeryGoodOpenSource/r13n/actions/workflows/r13n.yaml
[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/r13n/main/packages/r13n/coverage_badge.svg
[example_link]: https://github.com/VeryGoodOpenSource/r13n/tree/main/example
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures