# Homebrew tap for my personal apps


## NSLite
This is the official Homebrew tap for
[nslite](https://github.com/tacf/nslite), with support for macOS and Linux.

### Install

```sh
brew install tacf/tap/nslite
```

The formula builds the v1.0.0 tag from source using Homebrew's SDL3, Lua, and
PCRE2 packages, then links the `nsl` command into Homebrew's managed `bin`
directory. On macOS, the executable is ad-hoc signed during installation.

To upgrade to a newer release:

```sh
brew upgrade nslite
```

To reinstall the current tagged release:

```sh
brew reinstall tacf/tap/nslite
```

To remove nslite:

```sh
brew uninstall nslite
brew untap tacf/tap
```

## Development

After publishing the tap repository, test a formula with:

```sh
brew install --build-from-source tacf/tap/<name>
brew test tacf/tap/<name>
```

Before committing formula changes, run:

```sh
brew style Formula/<name>.rb
brew audit --strict tacf/tap/<name>
```
