# Release Notes

## 1.0.0-alpha.1

First release of ContributeYouTube as a standalone package, split out of the brightdigit.com
monorepo. It imports YouTube videos and playlists into Markdown via the
[Contribute](https://github.com/brightdigit/Contribute) framework, backed by
[SwiftTube](https://github.com/brightdigit/SwiftTube). The module is no longer deprecated.

### Library
* Provide the Contribute importer trio for YouTube — `Source`, `FrontMatterTranslator` and `MarkdownExtractor` — over `YouTubeContent` by @leogdion in https://github.com/brightdigit/ContributeYouTube/pull/1
* Add `YouTubePlaylistRequest` for playlist-scoped imports, `YouTubeContent+Write` for Markdown emission, and `YoutubeError` for import failures by @leogdion in https://github.com/brightdigit/ContributeYouTube/pull/1
* Add a `TimeInterval` extension parsing ISO 8601 durations into video runtimes by @leogdion in https://github.com/brightdigit/ContributeYouTube/pull/1
* Build on `swift-tools-version:6.4` with complete strict concurrency, depending on Contribute and SwiftTube by remote URL rather than a monorepo path by @leogdion in https://github.com/brightdigit/ContributeYouTube/pull/1

### Tests
* Add coverage for the front-matter translator, Markdown extractor, ISO 8601 duration parsing and video durations by @leogdion in https://github.com/brightdigit/ContributeYouTube/pull/1

### Documentation
* Add a `ContributeYouTube.docc` catalog with logo resources by @leogdion in https://github.com/brightdigit/ContributeYouTube/pull/1

### Tooling & CI
* Add the shared multi-platform CI template (macOS/Linux/Windows/Android) with mise-based linting via `.mise.toml`, `.swift-format`, `.swiftlint.yml` and `Scripts/lint.sh` by @leogdion in https://github.com/brightdigit/ContributeYouTube/pull/1
