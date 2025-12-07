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
# Watch for content changes and rebuild (development server)
# Note: Requires NPM_PATH environment variable for dev-server.sh
# Example: NPM_PATH=/path/to/npm ./dev-server.sh
./dev-server.sh

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
The project uses GitLab CI (.gitlab-ci.yml) with six stages and multi-platform support:

1. **automate-content** - Scheduled job that imports content from Mailchimp and YouTube
   - Commits new content automatically with timestamp
   - Uses `AUTOMATE_CONTENT` variable to trigger

2. **build** - Parallel builds on macOS and Linux (Ubuntu Jammy via brightdigit/publish-xml image)
   - Runs `swift build` and `swift test` on both platforms
   - Skips if executable already exists or only certain files changed

3. **package** - Creates release binaries for macOS and Linux
   - Only runs on main branch after Swift file changes
   - Outputs: `brightdigitwg-Darwin-arm64` and `brightdigitwg-Linux-x86_64`

4. **deploy** - Generates site and deploys to Netlify
   - Production deployment on main branch (`--mode production`, `--prod` flag)
   - Draft deployment on other branches (`--mode drafts`, preview URLs)
   - Requires `NETLIFY_AUTH_TOKEN` and `NETLIFY_PRODUCTION_SITE_ID`

### Testing and Build Environment
- Tests are located in `Tests/BrightDigitSiteTests/`
- Run tests: `swift test`
- Project requires Swift 5.8+ and macOS 12+
- Linux builds use Ubuntu Jammy (22.04) with custom Docker image
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
- Development server uses `md5` checksums to detect Content/ directory changes
- Requires Node.js/NPM for final styling build step via NPMPublishPlugin
- GitLab CI caches `.build/` directory based on `Package.resolved` for faster builds