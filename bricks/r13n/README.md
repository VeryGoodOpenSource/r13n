# 🌐 r13n

[![Very Good Ventures][logo_white]][very_good_ventures_link_dark]

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

[![ci][ci_badge]][ci_link]
[![coverage][coverage_badge]][ci_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

---

A brick that generates regionalization (r13n) code from arb files. Designed to be used in conjunction with the [r13n][r13n_pub_link] Flutter package.

## Getting Started 🚀

1. Add a new yaml file to the root directory of the Flutter project called `r13n.yaml` with the following content:

`Single arb-file per region` (with multiple-arb-files == false)
```yaml
arb-dir: lib/r13n/arb
output-directory: lib/r13n/arb/gen
template-arb-file: app_us.arb
```

`Support multiple-arb-files per region` (with multiple-arb-files == true)
```yaml
arb-dir: lib/r13n/arb
template-arb-file: app_us.arb
multiple-arb-files: true
input-directory: lib
input-file-pattern: _{{locale}}.arb
output-directory: lib/r13n/gen
output-file_name: app_regionalizations.g.dart
preferred-supported-locales:
  - es
  - gb
  - us
```

2. Next, add an `app_us.arb` file in the same directory specified by `r13n.yaml`.

Simple case (with multiple-arb-files == false), which is `lib/r13n/arb`:
```
lib
├── r13n
│   ├── arb
│   │   └── app_us.arb
```

With **multiple-arb-files** per region (with multiple-arb-files == true)

you can add anywhere inside the `lib` folder
```
lib
├── app
│   ├── app.dart
│   └── locacalization
│       ├── app_es.arb
│       ├── app_gb.arb
│       └── app_us.arb
├── features
│   ├── home
│   │   ├── home.dart
│   │   ├── locacalization
│   │   │   ├── home_es.arb
│   │   │   ├── home_gb.arb
│   │   │   └── home_us.arb
│   │   ├── navigation
│   │   └── widgets
│   └── intro
├── main.dart
```


3. Following, add the regionalized strings to your `.arb` file:

`app_us.arb`

```arb
{
    "@@region": "us",
    "supportEmail": "us@verygood.ventures"
}
```

4. To generate regionalization code use the following command:

```sh
$ mason make r13n --on-conflict overwrite
```

6. You should see generated files in `lib/r13n/arb/gen`:

```
<< with multiple-arb-files == false >>
lib
├── r13n
│   ├── arb
│   │   ├── gen
│   │   │   ├── app_regionalizations_us.g.dart
│   │   │   └── app_regionalizations.g.dart
│   │   ├── app_us.arb

<< with multiple-arb-files == true >>
lib
├── ...
├── main.dart
└── r13n
    ├── gen
    │   ├── app_regionalizations.g.dart <-- main file
    │   ├── app_regionalizations_es.g.dart <-- translation classes
    │   ├── app_regionalizations_gb.g.dart <-- translation classes
    │   └── app_regionalizations_us.g.dart <-- translation classes
    └── r13n.dart
```

## Configuring `r13n.yaml` ⚙️

| Option            | Description                                                                | Default                           |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------- |
| arb-dir           | Directory of the regionalized arb files.                                   | Not supported, must be specified. |
| template-arb-file | Fallback regionalization; used when the user is in a non-supported region. | Not supported, must be specified. |

[ci_badge]: https://github.com/VeryGoodOpenSource/r13n/actions/workflows/main.yaml/badge.svg
[ci_link]: https://github.com/VeryGoodOpenSource/r13n/actions/workflows/main.yaml
[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/r13n/main/coverage_badge.svg
[r13n_pub_link]: https://pub.dev/packages/r13n
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_ventures_link]: https://verygood.ventures
