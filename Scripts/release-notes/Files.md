# Release Notes

## 5.0.0-alpha.1

First release of the BrightDigit fork of [Files](https://github.com/JohnSundell/Files) by John Sundell, de-vendored out of the brightdigit.com monorepo into a standalone package. The original MIT `LICENSE` and every upstream source header are kept verbatim.

### Library
* Updates from brightdigit.com (initial fork bring-up: `Sources/` and `Tests/FilesTests` moved onto Swift 6.4 with complete strict concurrency) by @leogdion in https://github.com/brightdigit/Files/pull/3
* V1.0.0 (de-vendored into a standalone package; `swift-tools-version:6.4` with platforms raised to macOS 15 / iOS 18 / tvOS 18 / watchOS 11 for `Synchronization.Mutex`) by @leogdion in https://github.com/brightdigit/Files/pull/5

### Documentation
* Wave 0 review feedback: CI hygiene, fork attribution & agent tooling (root `NOTICE` crediting © 2017 John Sundell, README fork notice, and a `Scripts/header.sh` guard protecting upstream copyright headers) by @leogdion in https://github.com/brightdigit/Files/pull/2

### Tooling & CI
* Wave 0 review feedback: CI hygiene, fork attribution & agent tooling (`sersoft-gmbh/swift-coverage-action@v5`, `fail-fast: true`, watchOS gate removed, visionOS leg added, `.spi.yml` and dev container normalized) by @leogdion in https://github.com/brightdigit/Files/pull/2
* V1.0.0 (standalone multi-platform CI — Linux, macOS, Apple platforms, Windows, Android — plus mise, swift-format, SwiftLint and Periphery config) by @leogdion in https://github.com/brightdigit/Files/pull/5
* Drop the stale ENABLE_WATCHOS comment from the CI workflow by @leogdion in https://github.com/brightdigit/Files/pull/6

**Full Changelog**: https://github.com/brightdigit/Files/compare/4.3.0...5.0.0-alpha.1
