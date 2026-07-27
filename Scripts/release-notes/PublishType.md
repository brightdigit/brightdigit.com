# Release Notes

## 1.0.0-alpha.1

First release of PublishType as a standalone package, split out of the brightdigit.com monorepo.
It provides type-safe abstractions over [Publish](https://github.com/brightdigit/Publish) for
building sections, pages and content.

### Library
* Add `SectionBuilder` and `SectionBuilderProtocol` for type-safe section page generation, with `SectionContent`, `SectionContentFactory` and `SectionItem` by @leogdion in https://github.com/brightdigit/PublishType/pull/1
* Add `PageBuilder`, `PageContent`, `DynamicPageContent` and `AnyPageMainBuilder` for the dynamic page content system by @leogdion in https://github.com/brightdigit/PublishType/pull/1
* Add `ContentBuilder` and `ItemContent` for reusable content construction by @leogdion in https://github.com/brightdigit/PublishType/pull/1
* Add `WebsiteMetadata` and `MetadataAttached` for typed site metadata, plus `PublishTypeError`, `MissingField` and `MissingFields` for diagnosing incomplete front matter by @leogdion in https://github.com/brightdigit/PublishType/pull/1
* Build on `swift-tools-version:6.4` with complete strict concurrency, depending on Publish by remote URL rather than a monorepo path by @leogdion in https://github.com/brightdigit/PublishType/pull/1

### Tooling & CI
* Add the shared multi-platform CI template (macOS/Linux/Windows/Android) with mise-based linting via `.mise.toml`, `.swift-format`, `.swiftlint.yml` and `Scripts/lint.sh` by @leogdion in https://github.com/brightdigit/PublishType/pull/1
