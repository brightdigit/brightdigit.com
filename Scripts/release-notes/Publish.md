# Release Notes

## 1.0.0-alpha.1

### Library
* Fork Publish for the BrightDigit stack and adopt the Swift 6.4 toolchain with complete strict concurrency by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Remove the last GCD in the graph: delete the synchronous `publish` overloads, their `DispatchSemaphore`, and the `Mutex`-backed `ResultBox`, leaving the pre-existing `async` overloads as the only entry points by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Drop `PublishingContext`'s `TagCache` `Mutex` and compute `allTags` on demand by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Remove Splash and SplashPublishPlugin references now that syntax highlighting is handled client-side by highlight.js by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Remove the deployment API (`DeploymentMethod`) and the `PublishCLI` / `PublishCLICore` targets, including the project generator, website runner, and deployer by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Split the monolithic `PublishingStep`, `PublishingContext`, `Website`, and `MarkdownMetadataDecoder` files into focused files (`PublishingStep+Content/Files/Generation/Mutations`, `PublishingContext+API`, `Website+Publishing`, and per-container decoder files) by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Rework the Plot integration: replace `PlotComponents`/`PlotModifiers`/`PlotEnvironmentKeys` with focused `Node+HTML`, `Node+Feed`, `Markdown`, `ItemList`, `ItemTagList`, `SiteHeader`, `SiteFooter`, `VideoPlayer`, and `AudioPlayer+Publish` files by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Move the Foundation theme's HTML out of `Theme+Foundation` into a dedicated `FoundationHTMLFactory` by @leogdion in https://github.com/brightdigit/Publish/pull/1

### Tests
* Rebuild the test suite for the new API surface, replacing the CLI, deployment, and `PublishingContext` test files and adding `HTMLGenerationTests+Themes`, `ContentMutationTests+Pages`, and `RSSFeedGenerationTests+Caching` by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Replace the `Require` test helper with a typed `RequireError`, and add `Folder+Temporary` and `String+FirstSubstring` helpers by @leogdion in https://github.com/brightdigit/Publish/pull/1

### Documentation
* Rewrite the README and documentation index for the fork, and remove the Splash syntax-highlighting how-to by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Add a `NOTICE` file crediting John Sundell's original Publish by @leogdion in https://github.com/brightdigit/Publish/pull/1

### Dependencies
* Refresh `Package.swift` and `Package.resolved` for the trimmed dependency graph after removing the CLI, deployment, and Splash integrations by @leogdion in https://github.com/brightdigit/Publish/pull/1

### Tooling & CI
* Rename the default branch from `master` to `main` by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Move linting and formatting to mise, adding `.mise.toml`, `.swift-format`, `.swiftlint.yml`, `.periphery.yml`, and `Scripts/lint.sh` by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Rebuild CI on the shared multi-platform template (macOS/Linux/Windows/Android) and add the `check-unsafe-flags`, `swift-source-compat`, `cleanup-caches`, and Claude review workflows by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Add a devcontainer, Dependabot config, a `.swift-version` pin, `codecov.yml`, and `Scripts/header.sh` for license-header stamping by @leogdion in https://github.com/brightdigit/Publish/pull/1
* Add `AGENTS.md` agent instructions for the repository by @leogdion in https://github.com/brightdigit/Publish/pull/1
