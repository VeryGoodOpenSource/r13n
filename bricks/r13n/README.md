# Regionalization (r13n)

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A brick that generates regionalization (r13n) code from arb files.

## Getting Started 🚀

1. Add a new yaml file to the root directory of the Flutter project called `r13n.yaml` with the following content:

```yaml
arb-dir: lib/r13n/arb
template-arb-file: us.arb
```

2. Now, run `mason make r13n` so that codegen takes place. You should see generated files in `lib/r13n/arb/gen`.


## Configuration ⚙️

| Option            | Description                                                                | Default                           |
|-------------------|----------------------------------------------------------------------------|-----------------------------------|
| arb-dir           | Directory of the regionalized arb files.                                   | Not supported, must be specified. |
| template-arb-file | Fallback regionalization; used when the user is in a non-supported region. | Not supported, must be specified. |

