# Release Notes

## 1.0.0-alpha.1

YoutubePublishPlugin embeds YouTube content in a [Publish](https://github.com/brightdigit/Publish)
site. This release moves the package to Swift 6.4 with complete strict concurrency and refactors
the embed pipeline into named, testable pieces.

### Library
* Modernize for Swift 6.4: lint tooling, source refactor, and real tests by @leogdion in https://github.com/brightdigit/YoutubePublishPlugin/pull/1
* Split the embed pipeline into `YoutubeEmbedGenerator`, `YoutubeEmbedConfiguration`, `YoutubeRenderer` and `DefaultYoutubeRenderer`, alongside `EmbeddedYoutube`, `Modifier` and `Plugin` by @leogdion in https://github.com/brightdigit/YoutubePublishPlugin/pull/1

### Tests
* Replace the placeholder test target with real coverage of the embed generator and renderer by @leogdion in https://github.com/brightdigit/YoutubePublishPlugin/pull/1

### Dependencies
* Consume Publish from its standalone repository rather than a monorepo path by @leogdion in https://github.com/brightdigit/YoutubePublishPlugin/pull/1

### Tooling & CI
* Move linting to mise with `.mise.toml`, `.swift-format`, `.swiftlint.yml`, `.periphery.yml` and `Scripts/lint.sh` by @leogdion in https://github.com/brightdigit/YoutubePublishPlugin/pull/1
* Adopt the shared multi-platform CI template (macOS/Linux/Windows/Android) plus `check-unsafe-flags`, `swift-source-compat` and `cleanup-caches` workflows by @leogdion in https://github.com/brightdigit/YoutubePublishPlugin/pull/1

**Full Changelog**: https://github.com/brightdigit/YoutubePublishPlugin/compare/0.1.0...1.0.0-alpha.1
