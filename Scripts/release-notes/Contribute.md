# Release Notes

## 1.0.0-beta.1

Contribute is the shared framework behind the ContributeButtondown, ContributeMailchimp,
ContributeRSS, ContributeWordPress and ContributeYouTube importers. This release raises the
package to Swift 6.4 and converts the download stack to `async`/`await`, which is source-breaking
for anything calling `URLDownloader` or `FileURLDownloader` directly.

### Library
* Swift 6.4 tools version, async/await download stack, and WASI guards (`URLSessionable`, `URLDownloader` and `FileURLDownloader` are now `async throws` on Foundation's native `URLSession.download(from:)`, replacing completion handlers) by @leogdion in https://github.com/brightdigit/Contribute/pull/19
* Guard the `URLSession` paths behind `#if !os(WASI)`, where a remote URL now throws `URLDownloaderError.networkUnavailable` by @leogdion in https://github.com/brightdigit/Contribute/pull/19
* Fix the download path discarding the session error when a destination URL was returned by @leogdion in https://github.com/brightdigit/Contribute/pull/19
* Swift 6.4 toolchain, SwiftSoup markdown generator, and modernized CI by @leogdion in https://github.com/brightdigit/Contribute/pull/9
* V1.0.0 (de-vendored into a standalone package with complete strict concurrency) by @leogdion in https://github.com/brightdigit/Contribute/pull/5

### Documentation
* Add full README documenting the Contribute API by @leogdion in https://github.com/brightdigit/Contribute/pull/13
* Adopt unified badge header (SPI dynamic + qlty/Codecov/CodeFactor) by @leogdion in https://github.com/brightdigit/Contribute/pull/17
* Wave 0 review feedback: CI hygiene, docs & agent tooling by @leogdion in https://github.com/brightdigit/Contribute/pull/15

### Tooling & CI
* Move linting to mise with `.mise.toml`, `.swift-format`, `.swiftlint.yml`, `.periphery.yml`, and a `.swift-version` toolchain pin by @leogdion in https://github.com/brightdigit/Contribute/pull/9
* Sync subrepo branch brightdigit-com-260621 by @leogdion in https://github.com/brightdigit/Contribute/pull/14
* Add Claude Code GitHub Workflow by @leogdion in https://github.com/brightdigit/Contribute/pull/11
* Drop two stale comments from the CI workflow by @leogdion in https://github.com/brightdigit/Contribute/pull/18

**Full Changelog**: https://github.com/brightdigit/Contribute/compare/1.0.0-alpha.5...1.0.0-beta.1
