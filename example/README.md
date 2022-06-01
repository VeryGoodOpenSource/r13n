# Regionalizations (r13n) Example

[![License: MIT][license_badge]][license_link]

An example application that showcases the usage of the r13n flutter package.

_Built by [Very Good Ventures][very_good_ventures_link]_

---

## Getting Started 🚀

To run the desired project either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
$ flutter pub get
$ flutter run
```

---

## Working with Regionalizations 🌐

This project relies on [flutter_localizations][flutter_localizations_link] and follows the [official internationalization guide for Flutter][internationalization_link].

### Adding Regions

1. For each supported region, add a new ARB file in `lib/r13n/arb`.

```
├── r13n
│   ├── arb
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

2. Add the translated strings to each `.arb` file:

`app_us.arb`

```arb
{
    "@@region": "us",
    "supportEmail": "us@verygood.ventures"
}
```

`app_es.arb`

```arb
{
    "@@region": "us",
    "supportEmail": "es@verygood.ventures"
}
```

3. Generate regionalized files.
```
$ mason make r13n --on-conflict overwrite
```

```
├── r13n
│   ├── arb
│   │   ├── gen
│   │   │   ├── app_regionalizations_es.g.dart
│   │   │   ├── app_regionalizations_us.g.dart
│   │   │   └── app_regionalizations.g.dart
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

4. Use the new string

```dart
import 'package:example/r13n/r13n.dart';

@override
Widget build(BuildContext context) {
  final r13n = context.r13n;
  return Text(r13n.supportEmail);
}
```


[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_ventures_link]: https://verygood.ventures/
[workflow_link]: https://github.com/flutter/pinball/actions/workflows/main.yaml