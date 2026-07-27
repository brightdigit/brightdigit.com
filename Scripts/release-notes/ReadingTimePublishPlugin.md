# Release Notes

## 1.0.0-alpha.1

ReadingTimePublishPlugin computes reading time for
[Publish](https://github.com/brightdigit/Publish) items. This release moves the package to Swift
6.4 with complete strict concurrency and consumes Publish from its standalone repository.

### Library
* Build `ReadingTime`, `ReadingTimeMetadata` and the console output helper on `swift-tools-version:6.4` with complete strict concurrency by @leogdion in https://github.com/brightdigit/ReadingTimePublishPlugin/pull/1

### Tests
* Add coverage for item reading-time calculation and console output, with shared fixtures by @leogdion in https://github.com/brightdigit/ReadingTimePublishPlugin/pull/1

### Dependencies
* Consume Publish from its standalone repository rather than a monorepo path by @leogdion in https://github.com/brightdigit/ReadingTimePublishPlugin/pull/1

### Tooling & CI
* Move linting to mise with `.mise.toml`, `.swift-format`, `.swiftlint.yml`, `.periphery.yml` and `Scripts/lint.sh` by @leogdion in https://github.com/brightdigit/ReadingTimePublishPlugin/pull/1
* Replace the old `test.yml` workflow with the shared multi-platform CI template (macOS/Linux/Windows/Android) plus `check-unsafe-flags`, `swift-source-compat` and `cleanup-caches` workflows by @leogdion in https://github.com/brightdigit/ReadingTimePublishPlugin/pull/1

**Full Changelog**: https://github.com/brightdigit/ReadingTimePublishPlugin/compare/0.3.0...1.0.0-alpha.1
