# Release Notes

## 1.0.0-alpha.1

First release of the BrightDigit fork of [Plot](https://github.com/JohnSundell/Plot) by John Sundell, de-vendored out of the brightdigit.com monorepo into a standalone package. John Sundell's original MIT copyright headers and `LICENSE` are preserved verbatim; fork attribution lives in `NOTICE` and the README.

### Library
* Updates from brightdigit.com (initial fork bring-up: `Sources/Plot` and `PlotTests` migrated to the Swift 6.4 toolchain with complete strict concurrency) by @leogdion in https://github.com/brightdigit/Plot/pull/1
* v1.0.0 (de-vendored into a standalone package on `swift-tools-version:6.4`) by @leogdion in https://github.com/brightdigit/Plot/pull/4

### Documentation
* Wave 0 review feedback: CI hygiene, fork attribution & agent tooling (adds a root `NOTICE` crediting © 2019 John Sundell, a README fork notice, and a `Scripts/header.sh` guard that refuses to rewrite upstream-attributed headers) by @leogdion in https://github.com/brightdigit/Plot/pull/2

### Tooling & CI
* Wave 0 review feedback: CI hygiene, fork attribution & agent tooling (`sersoft-gmbh/swift-coverage-action@v5`, `fail-fast: true`, added visionOS leg, normalized `.spi.yml` and dev container) by @leogdion in https://github.com/brightdigit/Plot/pull/2
* v1.0.0 (standalone multi-platform CI — Ubuntu/wasm, macOS, Windows, Apple simulators, Android — plus mise, swift-format, SwiftLint and Periphery config) by @leogdion in https://github.com/brightdigit/Plot/pull/4
* Drop the stale ENABLE_WATCHOS comment from the CI workflow by @leogdion in https://github.com/brightdigit/Plot/pull/5

**Full Changelog**: https://github.com/brightdigit/Plot/compare/0.14.0...1.0.0-alpha.1
