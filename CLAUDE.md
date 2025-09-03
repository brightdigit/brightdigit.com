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

# Run the main executable
swift run brightdigitwg

# Run with specific publishing mode
swift run brightdigitwg --mode production
swift run brightdigitwg --mode drafts
```

### Content Development
```bash
# Watch for content changes and rebuild (development server)
./dev-server.sh

# Import content from external sources
swift run brightdigitwg import mailchimp --mailchimp-api-key=<key> --mailchimp-list-id=<id> --export-markdown-directory=Content/newsletters
swift run brightdigitwg import podcast --youtube-api-key=<key> --export-markdown-directory Content/episodes

# Publish content
swift run brightdigitwg publish
```

### Code Quality
```bash
# SwiftLint configuration is in .swiftlint.yml
# SwiftFormat configuration is in .swiftformat
```

## Architecture

### Core Components
- **brightdigitwg** - Main executable entry point
- **BrightDigitSite** - Main site generation logic using Publish framework
- **BrightDigitArgs** - Command-line interface and argument parsing
- **PublishType** - Custom type system for Publish framework extensions
- **PiHTMLFactory** - Custom HTML factory for site theme generation

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
- **Publish** - Static site generation framework
- **Plot** - HTML DSL for Swift
- **SwiftTube** - YouTube API integration
- **SyndiKit** - RSS/Atom feed parsing
- **Spinetail** - Mailchimp API client
- **Kanna** - HTML/XML parsing
- **ArgumentParser** - Command-line interface

### Deployment Pipeline
The project uses GitLab CI with automated content generation:
1. Content automation runs on schedule to pull new newsletters/podcasts
2. Swift code is built and tested on both macOS and Linux (Ubuntu Jammy)
3. Release binaries are packaged for distribution
4. Site is deployed to Netlify with environment-specific configurations

### Testing
Tests are located in `Tests/BrightDigitSiteTests/` and focus on core site functionality. Run tests with `swift test`.

## Important Notes
- The site uses a custom Publish theme (`PiHTMLFactory`) with company-specific styling
- Content can be automatically imported from Mailchimp and YouTube via scheduled CI jobs
- Development server (`dev-server.sh`) watches for content changes and rebuilds automatically
- SwiftLint rules are configured with relaxed limits for this content-heavy project