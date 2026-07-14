# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Swift-based static site generator for the BrightDigit website using the Publish framework. The project includes multiple Swift modules for content management, podcast integration, newsletter automation, and website generation.

## Development Commands

### Building and Testing
```bash
# Build the project
swift build

# Run tests
swift test

# Build for release
swift build -c release --product brightdigitwg

# Run the main executable (defaults to publish command)
swift run brightdigitwg --mode production
swift run brightdigitwg --mode drafts
```

### Content Development
```bash
# Import content from external sources
swift run brightdigitwg import mailchimp --mailchimp-api-key=<key> --mailchimp-list-id=<id> --export-markdown-directory=Content/newsletters
swift run brightdigitwg import podcast --youtube-api-key=<key> --export-markdown-directory Content/episodes
swift run brightdigitwg import wordpress --wordpress-url=<url> --export-markdown-directory=Content/articles

# Publish content (--mode is required)
swift run brightdigitwg publish --mode production
swift run brightdigitwg publish --mode drafts
```

### Code Quality
```bash
# SwiftLint and SwiftFormat configurations exist but are not actively enforced in CI
# .swiftlint.yml - relaxed limits for content-heavy project (line length: 150, file length: 550)
# .swiftformat - code formatting rules
```

### Content Quality Check
`Scripts/check-content.js` (Node, no dependencies) scans for content-quality
defects — raw/broken HTML tags in front-matter `title`/`description`, escaped
tags / MailChimp merge-fields that render as literal text (e.g. `<<First Name>>`),
double-escaped entities (`&amp;amp;`), and UTF-8 mojibake (`â€™`). It scans the
built `Output/` HTML first (the rendered ground truth), then the `Content/`
markdown sources to locate where each defect originates. Report-only — see issue
#142.
```bash
# Scan Content/ sources (no build needed). Add Output/ automatically if present.
node Scripts/check-content.js

# Include the rendered site too: build Output/ first, then scan.
swift run brightdigitwg publish --mode production
node Scripts/check-content.js

# --quotes        also report straight vs. curly quote inconsistency (noisy)
# --newsletters   include the imported MailChimp newsletter archive, which is
#                 suppressed by default (low-priority cruft, e.g. literal
#                 <<First Name>> merge fields); the summary still reports the
#                 suppressed count
# --strict        exit non-zero when defects exist (reserved for a future CI gate)
```
Always exits 0 by default (never gates a build). Not wired into CI yet.

## Coding Conventions (always apply)

1. **Strict concurrency is mandatory.** Every Swift target enables complete strict
   concurrency checking (`swift-tools-version:6.4`, Swift 6 language mode, i.e.
   `-strict-concurrency=complete`). When a strict-concurrency error surfaces, **fix it
   properly** (add `Sendable`/`@Sendable`, isolate with actors/`@MainActor`, restructure
   ownership) — do **not** lower the language mode, relax the setting, or silence the
   diagnostic to make it build.

2. **Resolve module-name collisions in the call site, not by renaming our own types.**
   When two modules export the same symbol (e.g. swift-markdown's `Markdown` vs. Publish's
   `Markdown`), disambiguate with — in order of preference — SwiftPM `moduleAliases:`, the
   Swift 6.4 module selector (`Module::Symbol`), a `typealias`, or a selective
   `import struct Module.Symbol`. Never work around a collision by renaming our own
   first-party type.

## Architecture

### Core Components
- **brightdigitwg** - Main executable entry point (located in executable target)
- **BrightDigitArgs** - Command-line interface using ArgumentParser with three subcommands:
  - `publish` (default) - Generates the static site with production/drafts modes
  - `import` - Imports content from Mailchimp, YouTube, WordPress, or podcast RSS
  - `url` - URL utilities
- **BrightDigitSite** - Main site generation logic with custom publishing pipeline
  - Defines `SectionID` enum for content types (articles, episodes, tutorials, newsletters, products)
  - Configures publishing steps (markdown processing, RSS generation, sitemap, npm build)
  - Implements two modes: drafts (includes future-dated content) vs production (filters by date)
- **PublishType** - Type-safe abstractions for Publish framework
  - `SectionBuilder` - Type-safe section page generation
  - `PageBuilder` - Dynamic page content system
  - `ContentBuilder` - Reusable content construction patterns
- **PiHTMLFactory** - Custom HTML factory implementing the site's theme
  - Generates HTML for index, sections, items, and pages
  - Integrates with Plot DSL for type-safe HTML generation

### Content Integration Modules
- **ContributeMailchimp** - Mailchimp newsletter import and markdown generation
- **ContributeYouTube** - YouTube content integration via SwiftTube
- **ContributeRSS** - RSS feed processing via SyndiKit
- **BrightDigitPodcast** - Podcast episode management combining YouTube and RSS
- **Tagscriber** - Markdown generation from web content using Kanna

### Content Structure
- `Content/` - Source markdown files for site content
  - `articles/` - Blog articles
  - `newsletters/` - Newsletter content (auto-generated from Mailchimp)
  - `episodes/` - Podcast episodes (auto-generated)
  - `tutorials/` - Tutorial content
- `Sources/` - Swift source code modules
- `Tests/` - Unit tests

### Key Dependencies
- **Publish** - Static site generation framework by John Sundell
- **Plot** - Type-safe HTML DSL for Swift
- **SwiftTube** - YouTube Data API v3 integration
- **SyndiKit** - RSS/Atom feed parsing (used for podcast import)
- **Spinetail** - Mailchimp API client (for newsletter import)
- **Kanna** - HTML/XML parsing (used by Tagscriber for web content extraction)
- **ArgumentParser** - Apple's Swift Argument Parser for CLI
- **MarkdownGenerator** - Markdown document generation
- Publish Plugins: SplashPublishPlugin, YoutubePublishPlugin, ReadingTimePublishPlugin, TransistorPublishPlugin, NPMPublishPlugin

### Deployment Pipeline
CI/CD runs on **GitHub Actions** (`.github/workflows/main.yaml`). All Linux jobs run in the `brightdigit/publish-xml:6.4` container (Swift 6.4, Ubuntu Noble — based on the `swiftlang/swift:nightly-6.4.x-noble` snapshot), built from this repo's `Dockerfile`. Jobs:

1. **automate-content** - Manual/dispatch job (self-hosted macOS) that imports content from Mailchimp and YouTube, then commits and pushes any new content. Triggered via the `AUTOMATE_CONTENT` workflow input.

2. **build-linux** - Runs `swift build` and `swift test` in the container. Caches `.build/` with a key that embeds the Swift toolchain version (`swift --version`), so a toolchain change auto-invalidates the cache.

3. **package-linux** - Builds the release binary (`swift build -c release --product brightdigitwg`) and uploads it as an artifact (`brightdigitwg-Linux-x86_64`).

4. **deploy** - Downloads the artifact, generates the site (`--mode production` on `main`, `--mode drafts` otherwise), and deploys to Netlify (`--prod` on `main`). Requires `NETLIFY_AUTH_TOKEN` and `NETLIFY_PRODUCTION_SITE_ID`.

The self-hosted macOS `build`/`package` jobs are currently commented out in the workflow. The Docker image is bumped by editing `Dockerfile` and pushing `brightdigit/publish-xml:6.4` (+ `:latest`). **Swift 6.4 is currently a pre-release nightly** — the image is based on `swiftlang/swift:nightly-6.4.x-noble`. Since 6.4 is not yet released, `.swift-version` pins the `6.4.x-snapshot` toolchain (install with `swiftly install 6.4.x-snapshot`); the Xcode 6.4 toolchain (`xcrun swift`) also works for local builds.

### Testing and Build Environment
- Tests are located in `Tests/BrightDigitSiteTests/`
- Run tests: `swift test`
- Project requires Swift 6.4+ and macOS 13+
- Linux builds use Ubuntu Noble (24.04) with custom Docker image
- Swift Package Manager handles all dependency resolution

## Important Notes

### Publishing Pipeline
- Site generation uses a multi-step pipeline defined in `BrightDigitSite.swift`
  - Pre-markdown: Copy resources, install plugins, add markdown files
  - Post-markdown: Fix YAML, calculate reading time, sort items, generate HTML/RSS/sitemap
  - Final step: NPM build process for styling (requires `NPM_PATH` environment variable)
- Two publishing modes control content visibility:
  - `production` - Filters out future-dated content (items where `date > now`)
  - `drafts` - Includes all content including future-dated items

### Content Import System
- All content importers use the `Contribute` framework for markdown generation
- Each importer has three components:
  - `Source` - API client/data fetcher
  - `FrontMatterTranslator` - Converts API data to front matter
  - `MarkdownExtractor` - Generates markdown body content
- Tagscriber module can extract markdown from arbitrary web URLs using Kanna

### Theme System
- Custom `PiHTMLFactory` implements all HTML generation using Plot DSL
- `PublishType` framework provides type-safe abstractions for sections and pages
- Each section type (articles, episodes, tutorials, newsletters) has its own `SectionItem` implementation

### Development Environment
- Requires Node.js/NPM for final styling build step via NPMPublishPlugin
- GitHub Actions caches the `.build/` directory keyed on the Swift toolchain version + `Package.resolved` for faster builds
