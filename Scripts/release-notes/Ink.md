# Release Notes

## 1.0.0-alpha.1

First release of the BrightDigit fork of [Ink](https://github.com/JohnSundell/Ink) by John Sundell, de-vendored out of the brightdigit.com monorepo into a standalone package. Original work © 2019 John Sundell, distributed under the original MIT License; see `LICENSE` and `NOTICE`.

### Library
* Sync subrepo branch brightdigit-com-260406 (initial fork bring-up: `Ink` sources and `InkTests` migrated to Swift 6.4 with complete strict concurrency) by @leogdion in https://github.com/brightdigit/Ink/pull/1
* v1.0.0 (de-vendored into a standalone package; `swift-tools-version:6.4`, platforms raised to macOS 15 / iOS 18 / tvOS 18 / watchOS 11) by @leogdion in https://github.com/brightdigit/Ink/pull/8
* Updates from brightdigit.com by @leogdion in https://github.com/brightdigit/Ink/pull/3
* Revert "Updates from brightdigit.com" (backs out #3) by @leogdion in https://github.com/brightdigit/Ink/pull/5

### Dependencies
* v1.0.0 (adds swiftlang/swift-markdown, pinned to `branch: "main"`; the `Markdown` module collision with Ink's own `Markdown` type is resolved at the call site with the Swift 6.4 module selector) by @leogdion in https://github.com/brightdigit/Ink/pull/8

### Documentation
* Wave 0 review feedback: CI hygiene, fork attribution & agent tooling (root `NOTICE`, README fork notice, and a `Scripts/header.sh` guard so upstream Sundell headers are never rewritten) by @leogdion in https://github.com/brightdigit/Ink/pull/6

### Tooling & CI
* Wave 0 review feedback: CI hygiene, fork attribution & agent tooling (`sersoft-gmbh/swift-coverage-action@v5`, `fail-fast: true`, visionOS leg, normalized `.spi.yml` and dev container) by @leogdion in https://github.com/brightdigit/Ink/pull/6
* v1.0.0 (standalone multi-platform CI workflow plus mise, swift-format, SwiftLint and Periphery configuration) by @leogdion in https://github.com/brightdigit/Ink/pull/8
* Drop the stale ENABLE_WATCHOS comment from the CI workflow by @leogdion in https://github.com/brightdigit/Ink/pull/9

**Full Changelog**: https://github.com/brightdigit/Ink/compare/0.6.0...1.0.0-alpha.1
