# Regionalization (r13n)

[![Very Good Ventures][logo_white]][very_good_ventures_link_dark]

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

[![License: MIT][license_badge]][license_link] [![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

--- 

A brick that generates regionalization (r13n) code from arb files. Designed to be used in conjunction with the [r13n][github_r13n_link] Flutter package.

## Getting Started 🚀

1. Add a new yaml file to the root directory of the Flutter project called `r13n.yaml` with the following content:

```yaml
arb-dir: lib/r13n/arb
template-arb-file: app_us.arb
```

2. Next, add an `app_us.arb` file in the same directory specified by `r13n.yaml`, which is `lib/r13n/arb`:

```
├── r13n
│   ├── arb
│   │   └── app_us.arb
```

3. Following, add the regionalised strings to your `.arb` file:

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
├── r13n
│   ├── arb
│   │   ├── gen
│   │   │   ├── app_regionalizations_us.g.dart
│   │   │   └── app_regionalizations.g.dart
│   │   ├── app_us.arb
```


## Configuring `r13n.yaml` ⚙️

| Option            | Description                                                                | Default                           |
|-------------------|----------------------------------------------------------------------------|-----------------------------------|
| arb-dir           | Directory of the regionalized arb files.                                   | Not supported, must be specified. |
| template-arb-file | Fallback regionalization; used when the user is in a non-supported region. | Not supported, must be specified. |

[github_r13n_link]: https://github.com/VeryGoodOpenSource/r13n
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_ventures_link]: https://verygood.ventures