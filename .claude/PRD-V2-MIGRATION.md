# Product Requirements Document: Swift 6 Migration for BrightDigit Website

## Executive Summary

### Migration Goals

Modernize the BrightDigit static site generator infrastructure by:
1. Consolidating 17 external packages into monorepo using git-subrepo (Publish ecosystem + BrightDigit packages + forked plugins)
2. Migrating API client generation from SwagGen to Apple's swift-openapi-generator
3. Replacing legacy dependencies (Ink, ShellOut) with official Apple frameworks (swift-markdown, swift-subprocess)
4. Upgrading to Swift 6 with strict concurrency compliance
5. Adding mermaid diagram support for enhanced documentation

This three-phase approach ensures dependency stability before tackling the Swift 6 language migration.

**Primary Objectives:**
1. **Monorepo Consolidation** - Consolidate 17 packages into monorepo using git-subrepo (Publish ecosystem [8] + BrightDigit packages [7] + forked plugins [2])
2. **Apple Framework Migration** - Replace Ink with swift-markdown, ShellOut with swift-subprocess
3. **API Modernization** - Migrate SwiftTube and Spinetail from SwagGen to swift-openapi-generator
4. **Swift 6 Compliance** - Achieve strict concurrency checking and eliminate data race violations
5. **Enhanced Features** - Add mermaid diagram support for documentation
6. **Maintain Compatibility** - Zero functional regressions, byte-for-byte identical site output
7. **Publishing Infrastructure** - Build Buttondown (newsletter) and Buffer (social media) integrations using the swift-openapi-generator toolchain established in Phase 2

**Success Criteria:**
- All 17 packages managed as git-subrepos in Packages/ directory (organized by source/purpose)
- swift-markdown (SPM) successfully replaces Ink with identical markdown output
- swift-subprocess (SPM) successfully replaces ShellOut with identical functionality
- SwiftTube and Spinetail generate from OpenAPI specs using swift-openapi-generator
- Prch framework successfully replaced with swift-openapi-runtime
- Mermaid diagrams render correctly in generated site via mermaid.js
- YoutubePublishPlugin and ReadingTimePublishPlugin forked to BrightDigit organization
- All subrepos can pull upstream changes with `git subrepo pull`
- Project compiles with Swift 6 language mode enabled
- Zero concurrency warnings or errors
- All tests pass on macOS and Ubuntu
- Generated site is byte-for-byte identical to current production (excluding new mermaid diagram pages)
- GitLab CI/CD pipeline executes successfully
- Publishing tool (ButtondownKit + BufferKit) compiles with Swift 6 strict concurrency, runs on Linux, and successfully sends newsletter drafts and social posts

### Timeline Expectations

**Pre-Migration Cleanup** (prerequisite)
- Remove `dev-server.sh` (hardcoded local path — issue #35)
- Remove or archive `Import/Wordpress/` XML files (issue #34)

**Phase 1: Monorepo Consolidation** ~~(3-4 weeks)~~ ✅ COMPLETE (2026-04-13) — issue #36
- Set up git-subrepo for 17 external packages (Publish ecosystem + BrightDigit + forked plugins)
- Organize packages into Packages/Publish/, Packages/BrightDigit/, Packages/Plugins/ directories
- Fork YoutubePublishPlugin and ReadingTimePublishPlugin to BrightDigit organization
- Replace Ink with swift-markdown (SPM dependency)
- Replace ShellOut with swift-subprocess (SPM dependency)
- Update Package.swift to reference local subrepos
- Validate site generation produces identical output

**Phase 2: Swift 6 Migration (Main Package)** (2-3 weeks) — issue #38
- Update main `brightdigit.com` Package.swift to Swift 6 language mode
- Fix concurrency violations in `Sources/` (Testimonial.swift, Sendable conformances, force-try)
- Subrepos remain at their current language modes — a Swift 6 package can depend on older Swift packages
- This unblocks adoption of Swift 6.3-only libraries (swift-subprocess, swift-openapi-generator) in Phase 3

**Phase 3: OpenAPI Generator Migration** (4-6 weeks) — issue #37
- Migrate SwiftTube from SwagGen to swift-openapi-generator
- Migrate Spinetail from SwagGen to swift-openapi-generator
- Replace Prch framework with swift-openapi-runtime + swift-openapi-urlsession
- Update ContributeYouTube and ContributeMailchimp client code
- Replace ShellOut with swift-subprocess (now available — main package is Swift 6)
- Comprehensive API integration testing

**Phase 4: Publishing Infrastructure** (3-4 weeks, follows Phase 3) — issues #30, #31, #33
- Build Buttondown newsletter client using swift-openapi-generator (official OpenAPI 3.0.2 spec)
- Build Buffer social media GraphQL client (handwritten Codable client, ClientTransport)
- Create PublishKit orchestrator with protocol-based SubscriberListProvider + NewsletterSender architecture
- All modules run on Linux via AsyncHTTPClientTransport; no audience data stored in repo

**Video Podcasts** (scope TBD, parallel with or after Phase 4) — issue #32
- Add video podcast support to the BrightDigit podcast section

**Total Estimated Duration:** 15-21 weeks (plus cleanup prerequisites)

---

## Technical Requirements

### Pre-Migration Repository Cleanup

These issues should be resolved before Phase 1 begins to avoid carrying forward technical debt.

#### Remove dev-server.sh (issue #35)

`dev-server.sh` hardcodes a personal system path (`/Users/leo/.nvm/versions/node/v16.14.0/bin/npm`) making it non-portable and exposing local environment details.

**Action:** Delete `dev-server.sh` and add it to `.gitignore`. If a watch script remains useful, replace with a portable version using `$(which npm)` or relying on `$PATH`.

#### Remove or Archive WordPress Import Files (issue #34)

`Import/Wordpress/articles.xml` and `Import/Wordpress/tutorials.xml` are ~20k-line WordPress export files used for a one-time content migration. They serve no ongoing purpose and contain contributor email addresses (`admin@brightdigit.com`, `patrick@hyperverses.com`).

**Options:**
- **Remove entirely** — delete the files and add `Import/` to `.gitignore` (preferred if no future WordPress import is planned)
- **Archive as test fixtures** — only if `ContributeWordPress` v2 is planned and these files are needed for testing

---

### Phase 1 Requirements: Monorepo Consolidation

**Objective:** Consolidate 17 external packages into monorepo using git-subrepo, organized by source/purpose

**Packages to Consolidate (17 total via git-subrepo):**

**Publish Ecosystem (8 packages from johnsundell) → Packages/Publish/**
1. **Publish** (0.9.0) - Core static site generator
2. **Plot** (0.14.0) - HTML DSL
3. **Files** (4.2.0) - File system abstraction
4. **Codextended** (0.3.0) - Swift extensions
5. **Sweep** (0.4.0) - String utilities
6. **CollectionConcurrencyKit** (0.2.0) - Async collection operations
7. **Splash** (0.16.0) - Syntax highlighting
8. **SplashPublishPlugin** (0.2.0) - Syntax highlighting plugin

**BrightDigit Packages (7 packages) → Packages/BrightDigit/**
9. **SwiftTube** (0.2.0-beta.5) - YouTube API client
10. **Spinetail** (0.3.0) - Mailchimp API client
11. **SyndiKit** (0.3.7) - RSS/Atom feed parsing
12. **NPMPublishPlugin** (1.0.0) - NPM build integration
13. **Contribute** (1.0.0-alpha.5) - Content contribution framework
14. **ContributeWordPress** (1.0.0) - WordPress content import
15. **TransistorPublishPlugin** (1.0.0) - Transistor podcast integration

**Third-party Plugins (2 packages, forked to BrightDigit) → Packages/Plugins/**
16. **YoutubePublishPlugin** (1.0.1) - YouTube embed plugin (forked from tanabe1478)
17. **ReadingTimePublishPlugin** (0.3.0) - Reading time calculator (forked from alexito4)

**Apple Framework Replacements (SPM dependencies, NOT subrepos):**
- **swift-markdown** - Replaces Ink (0.6.0) for markdown parsing
- **swift-subprocess** - Replaces ShellOut (2.3.0) for shell command execution

**Retained Dependencies (No viable Apple alternatives, Linux-compatible):**
- **Kanna** (5.2.2) - HTML/XML parsing (cross-platform: macOS, iOS, tvOS, watchOS, Linux)
- **MarkdownGenerator** (0.4.0) - Markdown generation (swift-markdown is parse-only)
- **Yams** (4.0.4) - YAML encoding (Foundation has no YAML support)
- **Files** (4.0+) - Via Publish dependency (indirect, Publish-managed)

**Package Structure:**
```
brightdigit.com/  (monorepo with subrepos)
├── Packages/                         # External dependencies as git-subrepos
│   ├── Publish/                      # Publish ecosystem (8 packages)
│   │   ├── Publish/                  # git-subrepo from johnsundell/Publish
│   │   ├── Plot/                     # git-subrepo from johnsundell/Plot
│   │   ├── Files/                    # git-subrepo from johnsundell/Files
│   │   ├── Codextended/              # git-subrepo from johnsundell/Codextended
│   │   ├── Sweep/                    # git-subrepo from johnsundell/Sweep
│   │   ├── CollectionConcurrencyKit/ # git-subrepo from johnsundell/CollectionConcurrencyKit
│   │   ├── Splash/                   # git-subrepo from johnsundell/Splash
│   │   └── SplashPublishPlugin/      # git-subrepo from johnsundell/SplashPublishPlugin
│   ├── BrightDigit/                  # BrightDigit packages (7 packages)
│   │   ├── SwiftTube/                # git-subrepo from brightdigit/SwiftTube
│   │   ├── Spinetail/                # git-subrepo from brightdigit/Spinetail
│   │   ├── SyndiKit/                 # git-subrepo from brightdigit/SyndiKit
│   │   ├── NPMPublishPlugin/         # git-subrepo from brightdigit/NPMPublishPlugin
│   │   ├── Contribute/               # git-subrepo from brightdigit/Contribute
│   │   ├── ContributeWordPress/      # git-subrepo from brightdigit/ContributeWordPress
│   │   └── TransistorPublishPlugin/  # git-subrepo from brightdigit/TransistorPublishPlugin
│   └── Plugins/                      # Third-party plugins (2 packages, forked)
│       ├── YoutubePublishPlugin/     # git-subrepo from brightdigit/YoutubePublishPlugin
│       └── ReadingTimePublishPlugin/ # git-subrepo from brightdigit/ReadingTimePublishPlugin
├── Sources/                          # Local site-specific code
│   ├── brightdigitwg/                # Main executable
│   ├── BrightDigitArgs/              # CLI argument parsing
│   ├── BrightDigitSite/              # Site generation logic
│   ├── BrightDigitPodcast/           # Podcast integration
│   ├── ContributeMailchimp/          # Mailchimp content import
│   ├── ContributeYouTube/            # YouTube content import
│   ├── ContributeRSS/                # RSS feed import
│   ├── Tagscriber/                   # Web content extraction
│   └── PublishType/                  # Type-safe Publish abstractions
├── Tests/
├── Content/                          # Markdown source files
└── Package.swift                     # References all packages
```

**brightdigit.com Package.swift Changes:**
```swift
dependencies: [
  // Packages/* as local path dependencies
  .package(path: "Packages/Publish/Publish"),
  .package(path: "Packages/Publish/Plot"),
  .package(path: "Packages/Publish/Files"),
  // ... all 17 subrepos

  // Apple frameworks as SPM dependencies (replacing Ink + ShellOut)
  .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.4.0"),
  .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),

  // Retained utilities (Linux-compatible, no viable Apple alternatives)
  .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),  // YAML encoding
  .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "5.2.2"),  // HTML/XML parsing
  .package(url: "https://github.com/eneko/MarkdownGenerator.git", from: "0.4.0"),  // Markdown generation

  // Other utilities
  .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.3")
]
```

**Note:** Hybrid strategy allows future extraction of Packages/* to separate BrightDigitPublish v2.0 repository

---

## Subrepo Management Strategy

### What is git-subrepo?

Git-subrepo is a tool that allows embedding external repositories as subdirectories without using git submodules. It provides a simpler workflow for managing dependencies while keeping the repository history clean.

**Advantages over git submodules:**
- No `.gitmodules` complexity or configuration files
- Easier for contributors (no `git submodule init/update` required)
- Full history embedded in the main repository
- Easy upstream syncing with simple commands
- Works transparently with standard git commands

**Advantages over SPM dependencies:**
- Unified development workflow across all packages
- Test changes across multiple packages in single commit
- No need to wait for package releases during development
- Easier debugging and code navigation
- Single CI/CD pipeline for all code

### Installation

```bash
# macOS via Homebrew
brew install git-subrepo

# Or via git clone
git clone https://github.com/ingydotnet/git-subrepo ~/.git-subrepo
echo 'source ~/.git-subrepo/.rc' >> ~/.bashrc
```

### Initial Setup Commands

For each of the 17 external packages:

```bash
# Publish ecosystem packages (8 packages)
git subrepo clone https://github.com/johnsundell/Publish.git Packages/Publish/Publish --branch=main
git subrepo clone https://github.com/johnsundell/Plot.git Packages/Publish/Plot --branch=main
git subrepo clone https://github.com/johnsundell/Files.git Packages/Publish/Files --branch=main
git subrepo clone https://github.com/johnsundell/Codextended.git Packages/Publish/Codextended --branch=main
git subrepo clone https://github.com/johnsundell/Sweep.git Packages/Publish/Sweep --branch=main
git subrepo clone https://github.com/johnsundell/CollectionConcurrencyKit.git Packages/Publish/CollectionConcurrencyKit --branch=main
git subrepo clone https://github.com/johnsundell/Splash.git Packages/Publish/Splash --branch=main
git subrepo clone https://github.com/johnsundell/SplashPublishPlugin.git Packages/Publish/SplashPublishPlugin --branch=main

# BrightDigit packages (7 packages)
git subrepo clone https://github.com/brightdigit/SwiftTube.git Packages/BrightDigit/SwiftTube --branch=main
git subrepo clone https://github.com/brightdigit/Spinetail.git Packages/BrightDigit/Spinetail --branch=main
git subrepo clone https://github.com/brightdigit/SyndiKit.git Packages/BrightDigit/SyndiKit --branch=main
git subrepo clone https://github.com/brightdigit/NPMPublishPlugin.git Packages/BrightDigit/NPMPublishPlugin --branch=main
git subrepo clone https://github.com/brightdigit/Contribute.git Packages/BrightDigit/Contribute --branch=main
git subrepo clone https://github.com/brightdigit/ContributeWordPress.git Packages/BrightDigit/ContributeWordPress --branch=main
git subrepo clone https://github.com/brightdigit/TransistorPublishPlugin.git Packages/BrightDigit/TransistorPublishPlugin --branch=main

# Forked third-party plugins (2 packages) - fork first, then clone
# Step 1: Fork tanabe1478/YoutubePublishPlugin to brightdigit/YoutubePublishPlugin on GitHub
# Step 2: Fork alexito4/ReadingTimePublishPlugin to brightdigit/ReadingTimePublishPlugin on GitHub
git subrepo clone https://github.com/brightdigit/YoutubePublishPlugin.git Packages/Plugins/YoutubePublishPlugin --branch=main
git subrepo clone https://github.com/brightdigit/ReadingTimePublishPlugin.git Packages/Plugins/ReadingTimePublishPlugin --branch=main
```

### Updating from Upstream

Pull the latest changes from upstream repositories:

```bash
# Update a specific subrepo
git subrepo pull Packages/Publish/Publish

# Update all subrepos (from project root)
find Packages -type d -name ".git" -prune -o -type f -name ".gitrepo" -exec dirname {} \; | xargs -I {} git subrepo pull {}
```

### Contributing Changes Back

Push changes made in the monorepo back to upstream:

```bash
# Push changes to upstream repo
git subrepo push Packages/BrightDigit/SwiftTube

# Push to specific branch
git subrepo push Packages/BrightDigit/SwiftTube --branch=feature/swift-6
```

### Development Workflow

1. **Clone subrepos** - Pull all 17 external repos into Packages/ directory
2. **Develop locally** - Modify code directly in Packages/* subdirectories
3. **Test in context** - Run tests across all packages in monorepo
4. **Commit to monorepo** - Commit changes to main brightdigit.com repository
5. **Push to upstream** - Use `git subrepo push` to contribute changes back to original repos
6. **Tag releases** - Tag releases in monorepo, individual packages can follow

### Subrepo Status

View status of all subrepos:

```bash
git subrepo status
```

### Migration Benefits

- **Unified development**: Work on Publish, SwiftTube, and site code simultaneously
- **Cross-package changes**: Refactor across multiple packages in single PR
- **Simplified CI/CD**: One pipeline tests all packages together
- **Easy onboarding**: New contributors just clone one repo
- **Future flexibility**: Can extract Packages/* to BrightDigitPublish v2.0 later

---

## Dependency Modernization Research

This section documents research findings for replacing third-party dependencies with Apple frameworks or modern alternatives.

### Executive Summary

**Research Question**: Which dependencies can be replaced with official Apple frameworks?

**Conclusion**: Only **Ink** and **ShellOut** have viable Apple framework replacements. Four other dependencies (Kanna, MarkdownGenerator, Yams, Files) must be **retained** due to Linux compatibility requirements and lack of alternatives.

**Critical Constraint**: GitLab CI runs on Ubuntu (Linux), requiring all dependencies to be cross-platform compatible (macOS + Linux).

### Summary Table

| Dependency | Current Version | Replacement Considered | Decision | Rationale |
|---|---|---|---|---|
| **Ink** | 0.6.0 | swift-markdown | ✅ REPLACE | Transitive via Publish; replace inside Publish subrepo |
| **ShellOut** | 2.3.0 | swift-subprocess | ✅ REPLACE | Official Apple framework for shell commands |
| **Kanna** | 5.2.2 | Demark (evaluated) | ❌ KEEP | Linux-compatible, Demark is Apple-only (requires WebKit) |
| **MarkdownGenerator** | 0.4.0 | swift-markdown (evaluated) | ❌ KEEP | Linux-compatible, swift-markdown is parse-only (not generation) |
| **Yams** | 4.0.4 | Foundation (evaluated) | ❌ KEEP | No Apple YAML support exists in Foundation |
| **Files** | 4.0+ | Foundation.FileManager | ❌ KEEP | Indirect Publish dependency, not under direct control |

### Detailed Analysis

#### 1. Kanna + MarkdownGenerator - NO REPLACEMENT (Linux Requirement BLOCKS Demark)

**Current Architecture:**
- **Purpose**: HTML → Markdown conversion in Tagscriber module
- **Kanna**: HTML/XML parsing using XPath and CSS selectors
- **MarkdownGenerator**: Programmatic markdown document generation
- **Integration**: KannaMarkdownGenerator parses HTML DOM and generates markdown elements

**Evaluation: swift-markdown - NOT SUITABLE**
- **Directionality**: swift-markdown is **parse-only** (Markdown → AST)
- **Missing Feature**: No HTML-to-Markdown conversion capability
- **Use Case Mismatch**: Tagscriber needs generation, not parsing

**Evaluation: Demark - REJECTED (Linux Blocker)**
- **Description**: Modern HTML-to-Markdown converter (2025 by @steipete)
- **Features**: Two engines (Turndown.js via WKWebView, html-to-md via JavaScriptCore)
- **BLOCKER**: Requires WebKit framework - **Apple platforms only**
- **Linux Support**: ❌ **NO** - Cannot run on GitLab CI Ubuntu builds
- **GitHub**: https://github.com/steipete/demark

**Current Dependencies ARE Linux-Compatible:**

**Kanna (5.2.2)**:
- **Platforms**: Explicitly supports Linux (macOS, iOS, tvOS, watchOS, Linux)
- **Ubuntu Setup**: `sudo apt-get install libxml2-dev`
- **Features**: XPath 1.0 + CSS3 selectors
- **GitHub**: https://github.com/tid-kijyun/Kanna
- **Status**: ✅ Working in GitLab CI

**MarkdownGenerator (0.4.0)**:
- **Platforms**: Author (Eneko Alonso) tests Swift packages on Linux using Docker
- **Likely Compatibility**: Already working in current GitLab CI Ubuntu builds
- **GitHub**: https://github.com/eneko/MarkdownGenerator
- **Status**: ✅ Proven track record

**Files Affected:**
- `/Sources/Tagscriber/KannaMarkdownGenerator.swift` - NO CHANGES (keep as-is)
- `/Sources/Tagscriber/MarkdownGenerator.swift` - NO CHANGES (keep protocol)
- `/Sources/Tagscriber/PandocMarkdownGenerator.swift` - NO CHANGES (keep alternative)

**Decision**: ✅ **KEEP** current dependencies - proven Linux compatibility, no viable cross-platform replacement

---

#### 2. Yams - NO APPLE ALTERNATIVE EXISTS

**Current Usage:**
- **Purpose**: YAML front matter encoding in Contribute package
- **Primary Use**: `YAMLEncoder` for converting Codable types to YAML strings
- **Location**: `/Contribute/Sources/Contribute/FrontMatterYAMLExporter.swift`
- **Test Usage**: YAML parsing tests in `/Tests/BrightDigitSiteTests/`

**Evaluation: Foundation - NO YAML SUPPORT**
- **JSON**: ✅ Foundation provides `JSONEncoder` / `JSONDecoder`
- **Property List**: ✅ Foundation provides `PropertyListEncoder` / `PropertyListDecoder`
- **XML**: ✅ Foundation provides `XMLDocument` / `XMLParser`
- **YAML**: ❌ **NO native support** in Foundation framework

**Swift Community Consensus**:
- Swift Forums confirm Foundation YAML support "doesn't exist"
- Codable is extensible, but someone must implement the encoder/decoder
- Yams (v4.0.4+, v6.0.1 available) is the de facto standard in Swift ecosystem

**Decision**: ✅ **KEEP** Yams - well-maintained, no viable alternative

---

#### 3. Files (via Publish) - INDIRECT DEPENDENCY

**Current Architecture:**
- **Source**: Indirect dependency through Publish v0.9.0
- **Usage**: Via PublishingContext API (`context.folder()`, `context.outputFolder()`)
- **Abstraction**: Type-safe folder/file operations wrapper
- **Control**: Managed by Publish library, not directly in Package.swift

**Evaluation: Foundation.FileManager - NOT PRACTICAL**
- **Capability**: ✅ FileManager supports all file operations
- **API Style**: More verbose than Files package convenience methods
- **Blocker**: Would require **forking Publish** to change implementation
- **Benefit**: No functional improvement, just different API style

**Decision**: ✅ **KEEP** Files - Publish dependency, not under direct control

---

### Cross-Platform Compatibility Matrix

| Dependency | macOS | Linux | Required By | Can Replace? |
|---|---|---|---|---|
| Kanna | ✅ | ✅ | Tagscriber | ❌ (No cross-platform alternative) |
| MarkdownGenerator | ✅ | ✅ | Tagscriber | ❌ (swift-markdown wrong direction) |
| Yams | ✅ | ✅ | Contribute | ❌ (Foundation lacks YAML) |
| Files | ✅ | ✅ | Publish | ❌ (Indirect dependency) |
| Ink | ✅ | ✅ | Publish (transitive) | ✅ (replaced inside Publish subrepo) |
| ShellOut | ✅ | ✅ | Tagscriber | ✅ (swift-subprocess replaces) |

### Research Sources

- [Kanna GitHub Repository](https://github.com/tid-kijyun/Kanna) - Cross-platform HTML/XML parser
- [Kanna Swift Package Registry](https://swiftpackageregistry.com/tid-kijyun/Kanna) - Package information
- [MarkdownGenerator GitHub](https://github.com/eneko/MarkdownGenerator) - Markdown generation library
- [MarkdownGenerator Swift Package Index](https://swiftpackageindex.com/eneko/MarkdownGenerator)
- [Demark GitHub](https://github.com/steipete/demark) - Apple-only HTML-to-Markdown (evaluated, rejected)
- [Eneko's Blog - Linux Swift Testing](https://github.com/eneko/Blog/issues/12) - Docker-based Linux testing
- [Swift Markdown GitHub](https://github.com/swiftlang/swift-markdown) - Apple's official markdown parser
- [Swift Subprocess GitHub](https://github.com/swiftlang/swift-subprocess) - Apple's process execution

### Recommendations

1. **Replace Only 2 Dependencies**:
   - Ink → swift-markdown (markdown parsing)
   - ShellOut → swift-subprocess (shell commands)

2. **Retain 4 Dependencies**:
   - Kanna (HTML parsing - Linux-compatible, no alternative)
   - MarkdownGenerator (Markdown generation - Linux-compatible, no alternative)
   - Yams (YAML encoding - no Foundation support)
   - Files (Publish-managed - indirect dependency)

3. **Linux Compatibility First**:
   - GitLab CI Ubuntu builds are non-negotiable
   - All dependencies MUST support Linux
   - Evaluate Apple frameworks ONLY if cross-platform

4. **Future Monitoring**:
   - Watch for swift-markdown generation capabilities (if added)
   - Monitor if Apple adds native YAML support to Foundation (unlikely)
   - Consider Demark if Linux support added (via libxml2 backend)

---

### Phase 2 Requirements: Swift 6 Language Mode (Main Package)

> **Scope:** Only the top-level `brightdigit.com` package needs Swift 6 before Phase 3. A Swift 6 package can depend on older Swift packages, so the 17 subrepos remain at their current language modes. Subrepo Swift 6 upgrades (and component migration, mermaid support) continue in Phase 3 alongside the OpenAPI migration.

See [Phase 3 Requirements](#phase-3-requirements-openapi-generator-migration) for the original Phase 3 content (now moved to Phase 3).

---

### Phase 3 Requirements: OpenAPI Generator Migration

**Objective:** Replace SwagGen-based API clients with Apple's swift-openapi-generator

> **Note:** The swift-openapi-generator toolchain and `ClientTransport` pattern established in this phase are also used in Phase 4 to generate the Buttondown newsletter client (ButtondownKit) and wrap the Buffer GraphQL client (BufferKit).

**Current Architecture:**
- SwagGen generates enum-based operations + Prch framework integration
- 261 generated Swift files in SwiftTube
- 260 generated Swift files in Spinetail
- Prch provides generic Client abstraction

**Target Architecture:**
- swift-openapi-generator creates protocol-based clients
- Built-in async/await support
- swift-openapi-runtime + swift-openapi-urlsession (no Prch)
- Pre-generated code (not build plugin approach)

**SwiftTube Migration:**

Current pattern:
```swift
let request = Videos.YoutubeVideosList.Request(
  fields: "...",
  key: apiKey,
  part: ["contentDetails", "snippet"],
  id: ids
)
let youtubeClient = Prch.Client(api: YouTube.API(), session: URLSession.shared)
let response = try youtubeClient.request(request)
```

Target pattern:
```swift
let client = Client(
  serverURL: try Servers.server1(),
  transport: URLSessionTransport(),
  middlewares: [AuthenticationMiddleware(apiKey: apiKey)]
)
let response = try await client.listVideos(
  query: .init(part: ["contentDetails", "snippet"], id: ids)
)
```

**Spinetail Migration:**

Similar transformation from Prch-based to protocol-based client.

**Dependencies to Add:**
- swift-openapi-generator (build-time only)
- swift-openapi-runtime
- swift-openapi-urlsession

**Dependencies to Remove:**
- Prch (completely replaced)

**Code Changes Required:**
1. **SwiftTube** - Regenerate all 261 files, rewrite API client extensions
2. **Spinetail** - Regenerate all 260 files, rewrite API client extensions
3. **ContributeYouTube** - Update YouTubeContent.swift and Prch.APIClient.Podcast.swift
4. **ContributeMailchimp** - Update Prch.APIClient.Newsletter.swift
5. **BrightDigitPodcast** - Update to use new client patterns

### Phase 3 (continued) Requirements: Swift 6 Language Mode + Subrepos + Mermaid

**Current State:**
- Swift tools version: 5.8
- Platform requirement: macOS 12+
- Callback-based concurrency patterns
- No explicit Sendable conformances

**Target State:**
- Swift tools version: 6.0
- Platform requirement: macOS 13+ (Swift 6 minimum)
- Async/await throughout
- Strict concurrency checking enabled

**Package.swift Changes:**
```swift
// swift-tools-version: 6.0

platforms: [
  .macOS(.v13)
]

// Add to all targets:
swiftSettings: [
  .enableExperimentalFeature("StrictConcurrency")
]
```

**Critical Code Changes:**
1. **Testimonial.swift** - Remove mutable global state (`static var lastID`)
2. **Async/await migration** - Already handled by swift-openapi-generator in Phase 2
3. **Sendable conformances** - Add to all API models and Source types
4. **Error handling** - Replace force-try with safe patterns

---

## Migration Phases

### Phase 1: Monorepo Consolidation ✅ COMPLETE (2026-04-13)

**Objective:** Consolidate 17 external packages into monorepo using git-subrepo, organized by source/purpose

> **Status:** Complete. All packages are present in `Packages/` as local path dependencies. `swift build` and `swift test` both pass on macOS. Two items from the original plan were deferred: Ink → swift-markdown and ShellOut → swift-subprocess replacements (ShellOut remains a remote SPM dependency; Ink is present in `Packages/Publish/` but not yet replaced). `YoutubePublishPlugin` was placed under `Packages/BrightDigit/` rather than `Packages/Plugins/` as originally planned.

**Week 1: Subrepo Setup and Fork Preparation**

1. **Install git-subrepo**
   - Install on macOS via Homebrew or git clone
   - Verify installation: `git subrepo version`
   - Configure git-subrepo settings if needed

2. **Fork Third-party Plugins**
   - Fork `tanabe1478/YoutubePublishPlugin` to `brightdigit/YoutubePublishPlugin`
   - Fork `alexito4/ReadingTimePublishPlugin` to `brightdigit/ReadingTimePublishPlugin`
   - Set up branch protection rules on forked repos

3. **Clone Publish Ecosystem Packages (8 subrepos)**
   - Clone johnsundell/Publish, Plot, Files, Codextended, Sweep, CollectionConcurrencyKit, Splash, SplashPublishPlugin
   - Organize into `Packages/Publish/` directory
   - Preserve `.gitrepo` metadata files

4. **Clone BrightDigit Packages (7 subrepos)**
   - Clone SwiftTube, Spinetail, SyndiKit, NPMPublishPlugin, Contribute, ContributeWordPress, TransistorPublishPlugin
   - Organize into `Packages/BrightDigit/` directory

5. **Clone Forked Plugins (2 subrepos)**
   - Clone YoutubePublishPlugin and ReadingTimePublishPlugin from BrightDigit forks
   - Organize into `Packages/Plugins/` directory

**Week 2: Package.swift Migration**

6. **Update Package.swift Dependencies**
   - Replace SPM URLs with local `.package(path: "Packages/...")` references for all 17 subrepos
   - Remove `ShellOut` dependency completely
   - Add `swift-markdown` as SPM dependency (replacing Ink indirectly via Publish subrepo)
   - Add `swift-subprocess` as SPM dependency
   - Update target dependencies to reference local packages

7. **Migrate from Ink to swift-markdown (via Publish subrepo)**
   - Note: Ink is a transitive dependency of Publish, not a direct dependency in Package.swift
   - Update the Publish subrepo (`Packages/Publish/Publish/`) to use swift-markdown instead of Ink
   - Update markdown parsing code in `Packages/Publish/Publish/Sources/Publish/`
   - Ensure markdown output is byte-for-byte identical
   - Run tests to validate markdown rendering

8. **Migrate from ShellOut to swift-subprocess**
   - Update Tagscriber module (currently uses ShellOut)
   - Replace `shellOut(to:)` calls with swift-subprocess Process API
   - Test shell command execution functionality

**Week 3: Integration and Validation**

9. **Build and Test**
   - Run `swift build` to compile all packages
   - Run `swift test` to validate all tests pass
   - Fix any compilation errors from local path dependencies

10. **Validation Testing**
    - Run full site generation with `swift run brightdigitwg publish --mode production`
    - Compare output with baseline (byte-for-byte HTML comparison)
    - Verify all 113 newsletters render correctly
    - Verify all podcast episodes render correctly
    - Test GitLab CI/CD pipeline on both macOS and Ubuntu

11. **Documentation**
    - Document subrepo management workflow in README
    - Update CLAUDE.md with new monorepo architecture
    - Create developer onboarding guide

**Week 4: Stabilization and Tagging**

12. **Subrepo Status Verification**
    - Run `git subrepo status` to verify all subrepos
    - Test `git subrepo pull` on sample package
    - Test `git subrepo push` workflow (dry run)

13. **Tag Monorepo Release**
    - Create git tag: `v1.0.0-monorepo`
    - Document all 17 package versions included
    - Update CHANGELOG.md

14. **Deploy to Staging**
    - Test full deployment pipeline
    - Performance benchmarking (compare with baseline)
    - Visual regression testing
    - Rollback testing

**Deliverables:**
- [x] All 17 packages present in Packages/ directory as local path dependencies
- [x] YoutubePublishPlugin and ReadingTimePublishPlugin forked to BrightDigit (YoutubePublishPlugin placed in Packages/BrightDigit/ rather than Packages/Plugins/)
- [ ] Ink replaced with swift-markdown inside Publish subrepo (deferred — Ink still present in Packages/Publish/)
- [ ] ShellOut successfully replaced with swift-subprocess (deferred — ShellOut retained as remote SPM dependency)
- [x] Kanna and MarkdownGenerator retained (Linux-compatible, no viable replacement)
- [x] Yams and Files retained (documented rationale in Dependency Modernization Research)
- [x] Package.swift using local path dependencies for all subrepos
- [x] All tests passing on macOS (`swift build` and `swift test` both pass)
- [ ] Site generation produces byte-for-byte identical output (not yet validated)
- [ ] GitLab CI/CD pipeline passing (not yet validated on Ubuntu)
- [ ] Monorepo v1.0.0 tagged and documented

---

### Phase 2: Swift 6 Migration — Main Package (2-3 weeks)

**Objective:** Upgrade the top-level `brightdigit.com` package to Swift 6 language mode, fixing all concurrency violations in `Sources/`. Subrepos remain at current language modes — Swift 6 packages can depend on older packages. This unlocks adoption of Swift 6.3-only libraries in Phase 3.

**Key tasks:**
1. Update `Package.swift`: `// swift-tools-version: 6.0`, `.macOS(.v13)`
2. Add `swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]` to all targets
3. **Fix Testimonial.swift data race (CRITICAL)** — remove `static var lastID`, make `id` a required parameter
4. Add `Sendable` conformances to `ContributeMailchimp`, `ContributeYouTube`, `ContributeRSS`, `BrightDigitPodcast` source types
5. Fix force-try statements in `YAMLStringFix.swift`, `String.swift`, `RSSContent.swift`
6. Validate `swift build` and `swift test` pass with Swift 6 strict concurrency

**Deliverables:**
- [ ] `brightdigit.com` Package.swift on `swift-tools-version: 6.0`
- [ ] Zero concurrency warnings in `Sources/`
- [ ] All tests passing under Swift 6
- [ ] Subrepos unchanged (still at prior language modes)

---

### Phase 3: OpenAPI Generator Migration + Subrepo Swift 6 + Mermaid (7-9 weeks)

**Objective:** Migrate SwiftTube and Spinetail from SwagGen to swift-openapi-generator, eliminating Prch dependency

**Week 1-2: SwiftTube Migration**

1. **Preparation**
   - Validate existing YouTube OpenAPI spec (`openapi.yaml`)
   - Create `openapi-generator-config.yaml`:
     ```yaml
     generate:
       - types
       - client
     accessModifier: public
     additionalImports:
       - Foundation
     ```
   - Set up swift-openapi-generator as dependency

2. **Code Generation**
   - Run swift-openapi-generator on YouTube spec
   - Review generated Client protocol and Types
   - Compare with SwagGen output for completeness

3. **Client Implementation**
   - Remove Prch dependency from SwiftTube
   - Add swift-openapi-runtime and swift-openapi-urlsession
   - Create authentication middleware for API key
   - Implement YouTubeClient wrapper around generated client

4. **Testing**
   - Test video listing operations
   - Test playlist operations
   - Validate response parsing
   - Performance comparison with SwagGen version

**Week 3-4: Spinetail Migration**

5. **Mailchimp OpenAPI Preparation**
   - Validate Mailchimp OpenAPI spec
   - Create openapi-generator-config.yaml
   - Handle data center URL templating

6. **Code Generation**
   - Run swift-openapi-generator on Mailchimp spec
   - Review generated code
   - Validate campaign and list operations

7. **Client Implementation**
   - Remove Prch dependency
   - Add swift-openapi dependencies
   - Create Basic auth middleware
   - Implement MailchimpClient wrapper

8. **Testing**
   - Test campaign fetching
   - Test list operations
   - Validate HTML content retrieval

**Week 5: Integration Layer Updates**

9. **Update ContributeYouTube**
   - Rewrite `YouTubeContent.swift` (lines 17-57) to use new client
   - Rewrite `Prch.APIClient.Podcast.swift` completely
   - Remove `DispatchSemaphore` and `DispatchGroup` patterns
   - Use async/await with TaskGroup for parallel requests

10. **Update ContributeMailchimp**
    - Rewrite `Prch.APIClient.Newsletter.swift` to use new client
    - Convert to async/await patterns
    - Update campaign filtering logic

11. **Update BrightDigitArgs Commands**
    - Update `Mailchimp.swift` import command
    - Update `PodcastCommand.swift`
    - Ensure async command execution works with ArgumentParser

**Week 6: Testing and Stabilization**

12. **Integration Testing**
    - Test full newsletter import flow (113 newsletters)
    - Test full podcast import flow
    - Validate markdown generation matches previous output
    - Test CI/CD content automation job

13. **Release New Versions**
    - SwiftTube 1.0.0 (with swift-openapi-generator)
    - Spinetail 1.0.0 (with swift-openapi-generator)
    - Update Package.resolved

**Deliverables:**
- [ ] SwiftTube migrated to swift-openapi-generator
- [ ] Spinetail migrated to swift-openapi-generator
- [ ] Prch dependency completely removed
- [ ] All API operations working with new clients
- [ ] Integration tests passing
- [ ] Content import produces identical markdown
- [ ] SwiftTube 1.0.0 and Spinetail 1.0.0 released

---

### Phase 3 (continued): Subrepo Swift 6 Upgrades + Component Migration + Mermaid Support

**Objective:** Upgrade all 17 subrepos to Swift 6, enforce component-based HTML generation, add mermaid diagram support

**Note:** Async/await patterns already in place from Phase 3 OpenAPI migration above. Main package is already on Swift 6 from Phase 2.

**Week 1: Subrepo Swift 6 Upgrades (Publish Ecosystem)**

1. **Update Publish Ecosystem Packages to Swift 6 (8 subrepos)**
   - Update Package.swift in each: `// swift-tools-version: 6.0`
   - Platform requirement: `.macOS(.v13)` for all
   - Add strict concurrency checking to Publish, Plot, Files, Codextended, Sweep, CollectionConcurrencyKit, Splash, SplashPublishPlugin
   - Fix any concurrency warnings in Publish/Plot/swift-markdown integration
   - Test all modules compile independently

2. **Enforce Component-Based Plot API**
   - Mark direct Node HTML creation as `internal` (currently `public`)
   - Keep Component protocol and @ComponentBuilder public
   - Update Plot documentation to emphasize components
   - This deprecates direct `.element()`, `.div()`, etc. usage

3. **Push Updates to Upstream (if applicable)**
   - Use `git subrepo push` for BrightDigit-owned packages
   - Create PRs for johnsundell packages (optional, for community contribution)
   - Tag releases in monorepo

**Week 2: BrightDigit Packages Swift 6 Upgrades (7 subrepos)**

4. **Update SwiftTube 2.0.0**
   - Update Package.swift: `// swift-tools-version: 6.0`
   - swift-openapi-generator produces Swift 6 code
   - Add Sendable conformances
   - Enable strict concurrency
   - Test with Swift 6

5. **Update Spinetail 2.0.0**
   - Same process as SwiftTube
   - Add Sendable conformances
   - Swift 6 compatibility

6. **Update Remaining BrightDigit Packages**
   - SyndiKit 1.0.0 (Swift 6)
   - Contribute 2.0.0 (Swift 6 - promote from alpha)
   - NPMPublishPlugin, ContributeWordPress, TransistorPublishPlugin
   - Update Package.swift in each subrepo
   - Add strict concurrency checking
   - Push updates to upstream repos using `git subrepo push`

7. **Update Forked Third-party Plugins**
   - YoutubePublishPlugin (Swift 6)
   - ReadingTimePublishPlugin (Swift 6)
   - Push updates to forked repos on BrightDigit organization

**Week 3-4: Component Migration in brightdigit.com**

8. **Create Site Component Library**

   New files to create in `Sources/BrightDigitSite/Components/`:

   **Layout Components:**
   - `HeaderComponent.swift` - Site header using Component protocol
   - `FooterComponent.swift` - Site footer
   - `NavigationComponent.swift` - Navigation menu
   - `PageLayoutComponent.swift` - Overall page structure with @ComponentBuilder

   **Content Components:**
   - `ArticleCardComponent.swift` - Article listing cards
   - `NewsletterItemComponent.swift` - Newsletter cards
   - `PodcastEpisodeComponent.swift` - Podcast episode cards
   - `TutorialItemComponent.swift` - Tutorial listing
   - `ProductCardComponent.swift` - Product showcase

9. **Migrate Existing Plot Code to Components**

   Files to update:
   - `Sources/BrightDigitSite/PiHTMLFactory.HTML.swift`
     - Replace `.header()` and `.footer()` Node extensions with Component calls
     - Convert all direct Node creation to component usage

   - `Sources/BrightDigitSite/Nodes/Pages/`
     - `IndexBuilder.swift` - Convert to components
     - `AboutBuilder.swift` - Convert to components
     - `ContactBuilder.swift` - Convert to components
     - `ServicesBuilder.swift` - Convert to components

   - `Sources/BrightDigitSite/Nodes/Section/`
     - All item renderers (ArticleItem, NewsletterItem, etc.) to components

10. **Component Testing**
   - Verify HTML output identical to previous Plot code
   - Test component reusability
   - Validate all 113 newsletters render
   - Validate all podcast episodes render

**Week 5: brightdigit.com Swift 6 Migration**

11. **Update brightdigit.com Package.swift**
    - `// swift-tools-version: 6.0`
    - Platform: `.macOS(.v13)`
    - Strict concurrency on all targets
    - Dependencies:
      - BrightDigitPublish 2.0.0
      - SwiftTube 2.0.0
      - Spinetail 2.0.0
      - Contribute 2.0.0
      - SyndiKit 1.0.0

12. **Fix Testimonial.swift Data Race (CRITICAL)**
    - File: `Sources/BrightDigitSite/Testimonial.swift`
    - Remove `static var lastID = 0` (line 5)
    - Remove auto-increment (lines 19-20)
    - Make `id` required parameter
    - Update all static testimonial definitions with explicit IDs
    - Effort: 1-2 hours

13. **Add Sendable Conformances**
    - `Newsletter.Source` (ContributeMailchimp)
    - `YouTubeContent.Source` (ContributeYouTube)
    - `RSSContent.Source` (ContributeRSS)
    - `BrightDigitPodcast.Source`
    - All new Component types

14. **Fix Force-Try Statements**
    - `YAMLStringFix.swift:6` - NSRegularExpression lazy closure
    - `String.swift:4` - NSRegularExpression lazy closure
    - `RSSContent.swift:21` - Explicit error handling instead of try?

**Week 6: Mermaid Diagram Support**

15. **Add Mermaid.js Integration**
    - Include mermaid.js library in HTML templates (`Sources/BrightDigitSite/PiHTMLFactory.HTML.swift`)
    - Add mermaid.js CDN link to `<head>` section
    - Configure mermaid initialization script
    - ```html
      <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
      <script>mermaid.initialize({ startOnLoad: true, theme: 'neutral' });</script>
      ```

16. **Detect Mermaid Code Blocks**
    - Update markdown processing in Publish/swift-markdown integration
    - Detect code blocks with `mermaid` language identifier
    - Wrap mermaid code blocks in `<div class="mermaid">` instead of `<pre><code>`
    - Example transformation:
      ```markdown
      ```mermaid
      graph TD
          A[Start] --> B[Process]
      ```
      ```
      becomes:
      ```html
      <div class="mermaid">
      graph TD
          A[Start] --> B[Process]
      </div>
      ```

17. **Test Mermaid Rendering**
    - Create test markdown file with sample mermaid diagrams (flowcharts, sequence diagrams, class diagrams)
    - Verify diagrams render correctly in generated site
    - Test different mermaid diagram types
    - Validate accessibility and responsive design

18. **Document Mermaid Usage**
    - Add documentation for content authors on how to use mermaid in markdown
    - Provide examples of different diagram types
    - Update CLAUDE.md with mermaid support

**Week 7: Testing and Deployment**

19. **Comprehensive Testing**
    - All 113 newsletters render correctly
    - All podcast episodes render correctly
    - Components produce identical HTML
    - GitLab CI passes (macOS + Ubuntu)
    - Performance within 10% baseline

20. **Expand Test Coverage**
    - Component unit tests
    - Concurrency safety tests
    - Integration tests
    - Mermaid rendering tests
    - Target: >50% coverage (from ~5%)

21. **Production Deployment**
    - Deploy to staging
    - Byte-for-byte HTML comparison (excluding mermaid diagrams - visual verification)
    - Visual regression testing
    - Test mermaid diagrams in production environment
    - Deploy to production

**Deliverables:**
- [ ] All 17 subrepos upgraded to Swift 6
- [ ] Publish ecosystem packages (8) support swift-markdown
- [ ] BrightDigit packages (7) upgraded to Swift 6
- [ ] Forked plugins (2) upgraded to Swift 6
- [ ] brightdigit.com using components exclusively
- [ ] Zero direct Plot HTML creation in codebase
- [ ] Zero concurrency warnings across all 17 subrepos
- [ ] Testimonial data race fixed
- [ ] All Sendable conformances added
- [ ] Mermaid diagram support integrated (client-side mermaid.js)
- [ ] Mermaid diagrams render correctly in test content
- [ ] Test coverage >50%
- [ ] All subrepo updates pushed to upstream repos
- [ ] Production deployment successful with mermaid support

---

### Phase 4: Publishing Infrastructure (3-4 weeks)

**Objective:** Build an open source Swift package that integrates into the BrightDigit.com publishing pipeline to deliver content across newsletter (Buttondown) and social media (Buffer) channels — without storing any audience data in the repository.

This phase depends on Phase 3 (swift-openapi-generator toolchain) and Phase 2 (Swift 6 compliance).

#### Constraints

- **Open source repo:** No subscriber emails or audience data in the repo. All credentials are environment variables. All audience list management is delegated to the platform.
- **Linux compatibility:** All HTTP clients use `ClientTransport` from `swift-openapi-runtime`, allowing the transport to be swapped per platform:
  ```swift
  // Linux (CI/CD, server-side Swift):
  let transport: any ClientTransport = AsyncHTTPClientTransport()
  // Apple platforms:
  let transport: any ClientTransport = URLSessionTransport()
  ```
- **General-purpose:** Multi-channel publishing. Social posts go to Buffer, which fans out to X/Twitter, LinkedIn, Mastodon, and others from a single API call.

#### New Source Modules

These are added to `Sources/` in the monorepo (not git-subrepos — they are new code local to this project):

```
Sources/
  PublishKit/       # Core orchestrator + protocol definitions
  ButtondownKit/    # Newsletter: Buttondown REST client (swift-openapi-generator)
  MailgunKit/       # Newsletter: sending-only transport (no list management)
  BufferKit/        # Social: handwritten GraphQL client (ClientTransport, Codable)
```

#### Newsletter Transport: Buttondown

**Protocol architecture** (exact shapes TBD during implementation):

- `SubscriberListProvider` — fetching/managing the list of recipients
- `NewsletterSender` — delivering a composed issue to recipients

This split allows Mailgun (sender-only) to be composed with a separate list provider without a full platform swap.

**Why Buttondown:** Newsletter-native API. Sending an issue is two REST calls:
```
POST /emails              → create draft (body is markdown string)
POST /emails/{id}/send-draft  → send to all subscribers
```
Subscriber management, unsubscribe links, bounce handling, and CAN-SPAM compliance are all managed by Buttondown. **Cost:** $9/month.

**Code generation:** swift-openapi-generator from the official Buttondown OpenAPI 3.0.2 spec at [github.com/buttondown/openapi](https://github.com/buttondown/openapi).

**Why not Mailgun as a complete solution:** Mailgun is a transactional email API — it does not manage subscribers. Owning the subscriber list means storing ~400 email addresses, which has no safe home in an open source repo. Mailgun remains a valid `NewsletterSender` implementation when paired with a separate list provider.

#### Social Transport: Buffer

Buffer publishes to X/Twitter, LinkedIn, Mastodon, Instagram, Threads, Bluesky, and more from a single GraphQL mutation — no per-platform OAuth or rate-limit handling required.

**Implementation:** `BufferTransport` wraps a `ClientTransport` instance. Encodes the GraphQL mutation as `{"query": "...", "variables": {...}}` and decodes the response with `Codable`. No Apollo, no code generation dependency — fully Linux-compatible.

```graphql
mutation CreatePost {
  createPost(input: {
    text: "...",
    channelId: "...",
    schedulingType: automatic,
    mode: shareNow        # or addToQueue for scheduling
  }) {
    ... on PostActionSuccess { post { id } }
    ... on MutationError { message }
  }
}
```

#### Credential Model

| Variable | Used By | Never Stored In |
|---|---|---|
| `BUTTONDOWN_API_KEY` | ButtondownKit | Repo, subscriber list |
| `BUFFER_API_TOKEN` | BufferKit | Repo, audience data |

#### Week 1-2: Core Protocol Design + ButtondownKit

1. Define `SubscriberListProvider` and `NewsletterSender` protocol shapes in PublishKit
2. Run swift-openapi-generator against Buttondown's OpenAPI 3.0.2 spec
3. Implement `ButtondownTransport` conforming to both protocols
4. Wire up `ClientTransport` (AsyncHTTPClientTransport on Linux, URLSessionTransport on Apple)
5. Test: create draft, send draft, verify delivery

#### Week 3: BufferKit + MailgunKit

6. Implement `BufferTransport` — plain HTTP POST to GraphQL endpoint
7. Encode mutation as JSON body; decode response with Codable
8. Implement `MailgunTransport` (sender-only; list provider injected separately)
9. Test: publish a social post through Buffer; test Mailgun send path in isolation

#### Week 4: PublishKit Integration + Swift 6 Compliance

10. Implement `Publisher` orchestrator in PublishKit
11. Integrate with BrightDigit.com publishing pipeline (Publish plugin entry point or CLI subcommand)
12. Ensure all modules pass Swift 6 strict concurrency checks
13. Validate Linux builds in CI (Ubuntu, AsyncHTTPClientTransport)
14. End-to-end test: publish a real newsletter draft and a real social post

#### Decision Summary

| Decision | Choice | Reason |
|---|---|---|
| Newsletter platform | Buttondown | Open source constraint eliminates subscriber ownership; REST + official OpenAPI spec; markdown-native |
| Social platform | Buffer | Single API for all networks; GraphQL early access available; no per-platform integration |
| Newsletter architecture | Split `SubscriberListProvider` + `NewsletterSender` | Mailgun = sender only; separation allows composition with any list provider |
| Newsletter code gen | swift-openapi-generator | Official OpenAPI 3.0.2 spec from Buttondown |
| Social code gen | None | Buffer API is GraphQL; handwritten Codable client requires no code gen dependency |
| HTTP transport abstraction | `ClientTransport` (swift-openapi-runtime) | Swap `AsyncHTTPClientTransport` (Linux) / `URLSessionTransport` (Apple) — applies to all clients |
| Subscriber storage | None (Buttondown-managed) | Cannot store audience data in open source repo |
| Integration target | BrightDigit.com SSG (Publish, migration pending) | Tool is a publishing pipeline plugin, not a standalone CLI |

**Deliverables:**
- [ ] PublishKit protocols defined (`SubscriberListProvider`, `NewsletterSender`)
- [ ] ButtondownKit generated from official OpenAPI 3.0.2 spec
- [ ] BufferKit handwritten GraphQL client, Linux-compatible
- [ ] MailgunKit sender-only transport
- [ ] All modules Swift 6 strict concurrency compliant
- [ ] All modules build on Linux (Ubuntu) via AsyncHTTPClientTransport
- [ ] Integration with BrightDigit.com publishing pipeline
- [ ] Credentials sourced from environment variables only

---

### Video Podcasts (issue #32)

**Scope:** TBD — add video podcast support to the BrightDigit podcast section. Likely builds on the YouTube integration established in Phase 2 and the component system from Phase 3.

**Candidate work items (to be defined):**
- Support video-first podcast episodes (YouTube video as primary media)
- Display embedded video player in episode pages alongside audio player
- Update podcast RSS feed generation to include video enclosures where applicable
- Update `ContributeYouTube` / `BrightDigitPodcast` to distinguish video vs audio episodes

**Dependencies:** Phase 3 (#37) for YouTube client, Phase 3 (#38) for component system.

---

### AI-CITE Content Optimization (parallel, ongoing — branch: ai-cite-optimization, PR #39)

**Scope:** Optimize BrightDigit article and tutorial content to be cited by AI systems (ChatGPT, Google AI Overview) using the AI-CITE framework (Answer-first, Intent-matched headings, Clear structure, Indexed schema, Trusted sources, Exclusive POV). Based on Jesse Schoberg's MicroConf Europe 2025 methodology.

**Framework:** AI-CITE — each element maps to a content transformation:
- **A (Answer-first):** Lead with the direct answer in the first paragraph
- **I (Intent-matched headings):** Rewrite headings as search queries (e.g., "Three Ways to Mock Swift Dependencies")
- **C (Clear structure):** Replace dense prose with tables, numbered lists, decision guides, TLDR sections
- **I (Indexed schema):** Add FAQPage, HowTo, and Article JSON-LD structured data
- **T (Trusted sources):** Link to Apple docs, WWDC sessions, Swift.org, official repos
- **E (Exclusive POV):** Create branded frameworks/methodologies unique to BrightDigit

**Target Success Rate:** 60% of priority articles get AI mentions within 1 week of optimization.

**Reference Documentation:** `.claude/ai-cite-optimization/`
- [`00-README.md`](./ai-cite-optimization/00-README.md) — framework overview and quick links
- [`ai-cite-audit.md`](./ai-cite-optimization/ai-cite-audit.md) — top 10 "money articles" identified for optimization
- [`implementation-summary.md`](./ai-cite-optimization/implementation-summary.md) — before/after metrics
- [`schema-implementation-plan.md`](./ai-cite-optimization/schema-implementation-plan.md) — JSON-LD structured data design
- [`VALIDATION.md`](./ai-cite-optimization/VALIDATION.md) — testing and validation approach
- [`complete-status.md`](./ai-cite-optimization/complete-status.md) — sprint status tracker
- [`issues/INDEX.md`](./ai-cite-optimization/issues/INDEX.md) — all 10 GitHub issues

**Planned Content Files (to be added in subsequent PRs):**
- `Content/articles/dependency-management-swift.md` — rewritten with AI-CITE structure (answer-first, FAQ section, comparison tables, structured code examples)
- `Content/articles/mise-implementation-guide.md` — new comprehensive Mise adoption guide (~4,980 lines, internal reference article)
- `Content/tutorials/mise-setup-guide.md` — new public-facing Mise setup tutorial
- `Content/tutorials/project-setup-guide.md` — new project setup tutorial (draft)
- `Content/tutorials/why-mistkit.md` — new MistKit explanation (draft)

**Sprint Plan (from `complete-status.md`):**
- Sprint 1 — FAQ/HowTo schema, Mise setup guide optimization (issues #21, #22, #23)
- Sprint 2 — Baseline testing and validation (issue #26)
- Sprint 3 — Remaining 10 priority articles (issue #28)
- Sprint 4+ — YouTube video strategy and unique frameworks (issues #24, #25)

**GitHub Issues:** #21–#30 (tracked in `.claude/ai-cite-optimization/issues/`)

**Dependencies:** None — runs parallel to all technical phases. Schema markup (JSON-LD) from the Indexed element may benefit from Phase 3's component system if `PiHTMLFactory` is updated to inject structured data into page `<head>` automatically.

---

### Appendix: Early Concurrency Analysis (Pre-Phase 2)

**Critical Files for Modernization:**

**1. ContributeMailchimp/Prch.APIClient.Newsletter.swift**
- Convert `campaigns(fromRequest:) throws` to `async throws`
- Replace `requestSync` with Prch's native async `request()` API
- Update all callers to use async/await

**2. ContributeYouTube/Prch.APIClient.Podcast.swift**
- **Most Complex Migration** - Replace DispatchSemaphore + mutable closure captures
- Convert to `withThrowingTaskGroup` for parallel video fetching
- Lines 14-26: Eliminate semaphore synchronization
- Lines 33-62: Replace DispatchGroup with TaskGroup

**3. BrightDigitArgs/Import/Mailchimp.swift**
- Line 47: Convert force-try NSRegularExpression to lazy closure
- Lines 108-120: Convert `run()` to `async throws`
- Update ArgumentParser command to use async

**4. Error Handling Modernization**

Force-try statements to eliminate:
- `Mailchimp.swift:47` - NSRegularExpression initialization
- `YAMLStringFix.swift:6` - NSRegularExpression initialization
- `String.swift:4` - NSRegularExpression initialization

Replace with lazy static closures or throwing getters.

**5. Error Suppression**
- `RSSContent.swift:21` - Replace `try?` with explicit error handling and logging

**Deliverables:**
- [ ] All `requestSync` usage eliminated
- [ ] All DispatchSemaphore usage replaced with async/await
- [ ] All DispatchGroup usage replaced with TaskGroup
- [ ] Force-try statements replaced with proper error handling
- [ ] ArgumentParser commands use async run() methods

### Appendix: Early Strict Concurrency Analysis (Pre-Phase 3)

**Critical Issue 1: Mutable Global State**

**File:** `Sources/BrightDigitSite/Testimonial.swift`

**Current Code (Lines 5, 19-20):**
```swift
static var lastID = 0  // ❌ Data race
internal init(id: Int? = nil, ...) {
  self.id = id ?? (Self.lastID + 1)
  Self.lastID += 1  // ❌ Not thread-safe
}
```

**Recommended Solution:** Remove auto-increment, use explicit IDs
- All testimonials already have static definitions with IDs
- Make `id` parameter required (remove default `nil`)
- Remove `static var lastID`
- **Risk:** LOW - straightforward refactor
- **Effort:** 1-2 hours

**Critical Issue 2: URLSession Sendable Compliance**

**Files:** `Mailchimp.swift:109`, `YouTubeContent.swift:20`
- Verify Prch.Client is Sendable
- Verify API types (YouTube.API, Mailchimp.API) are Sendable
- Add explicit type annotations

**Critical Issue 3: Implicit Sendable Conformances**

Types needing explicit Sendable conformance:
- `Newsletter.Source` (ContributeMailchimp)
- `YouTubeContent.Source` (ContributeYouTube)
- `RSSContent.Source` (ContributeRSS)
- `BrightDigitPodcast.Source`

**Deliverables:**
- [ ] Testimonial.lastID data race resolved
- [ ] All Sendable conformances added
- [ ] URLSession usage verified thread-safe
- [ ] Zero concurrency warnings in Xcode
- [ ] Swift 6 strict mode enabled and passing

### Appendix: Early Testing and Validation Analysis (Pre-Phase 3)

**Current Test Coverage:** ~5% (1 test file: `StringTests.swift`)

**Required Test Expansion:**

1. **Concurrency Safety Tests**
   - Testimonial ID thread safety
   - Concurrent video fetching
   - Concurrent campaign fetching

2. **Migration Validation Tests**
   - Generate site and compare with baseline (byte-for-byte)
   - Verify async version produces same results as sync

3. **Integration Tests**
   - Full newsletter import flow
   - Full podcast import flow
   - Site generation pipeline
   - GitLab CI compatibility

**Performance Benchmarking:**

| Operation | Target | Measurement |
|-----------|--------|-------------|
| Newsletter import | Within 10% of baseline | Time to import 113 newsletters |
| Podcast import | Within 10% of baseline | Time to fetch YouTube playlist |
| Site generation | Within 10% of baseline | Time to run publish command |
| Memory usage | Within 20% of baseline | Peak memory during build |

**Deliverables:**
- [ ] Test coverage expanded to >50%
- [ ] All concurrency-critical paths tested
- [ ] CI/CD pipeline passing on all platforms
- [ ] Performance benchmarks within acceptable range
- [ ] Deployment to staging validated
- [ ] Production deployment checklist complete

---

## Critical Code Changes Required

### File-by-File Migration Guide

#### 1. Package.swift (CRITICAL)
**Changes:**
- Line 1: Update to `// swift-tools-version: 6.0`
- Lines 11-12: Update platform to `.macOS(.v13)`
- Add `swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]` to all targets
- **Estimated Effort:** 2-3 hours (includes testing)

#### 2. Testimonial.swift
**Changes:**
- Line 5: Remove `static var lastID = 0`
- Lines 19-20: Remove auto-increment logic
- Line 18: Make `id` parameter required
- **Risk/Complexity:** LOW/LOW
- **Estimated Effort:** 1-2 hours

#### 3. Prch.APIClient.Podcast.swift (HIGHEST COMPLEXITY)
**Changes:**
- Lines 14-26: Convert to async/await
- Lines 28-75: Rewrite using `withThrowingTaskGroup`
- Lines 33-62: Replace DispatchGroup with TaskGroup
- Line 53: Remove mutable array with closure mutation
- **Risk/Complexity:** HIGH/MEDIUM
- **Estimated Effort:** 1-2 days

#### 4. Prch.APIClient.Newsletter.swift
**Changes:**
- Lines 14-21: Convert `campaigns` to async
- Lines 23-30: Convert `htmlFromCampaign` to async
- Lines 32-41: Update `source` to async
- Lines 43-52: Update `newsletters` to async with TaskGroup
- **Risk/Complexity:** MEDIUM/LOW
- **Estimated Effort:** 4-6 hours

#### 5. Mailchimp.swift
**Changes:**
- Line 47: Convert force-try regex to lazy closure
- Lines 108-120: Convert `run()` to `async throws`
- **Risk/Complexity:** MEDIUM/LOW
- **Estimated Effort:** 3-4 hours

#### 6. YouTubeContent.swift
**Changes:**
- Lines 17-57: Convert to async
- Line 20: Ensure URLSession.shared Sendable compliance
- **Risk/Complexity:** LOW/LOW
- **Estimated Effort:** 2-3 hours

#### 7. YAMLStringFix.swift
**Changes:**
- Lines 6-9: Convert force-try to lazy closure
- **Risk/Complexity:** LOW/LOW
- **Estimated Effort:** 30 minutes

#### 8. ContributeRSS/String.swift
**Changes:**
- Line 4: Convert force-try to lazy closure
- **Risk/Complexity:** LOW/LOW
- **Estimated Effort:** 30 minutes

#### 9. RSSContent.swift
**Changes:**
- Lines 19-22: Replace try? with do-catch and logging
- **Risk/Complexity:** LOW/LOW
- **Estimated Effort:** 1 hour

---

## Risk Assessment

### Breaking Changes Impact

**High-Risk Changes:**

1. **Async/Await Conversion** (HIGH IMPACT)
   - Impact: Import commands become async
   - Mitigation: ArgumentParser supports async commands natively
   - Likelihood: LOW | Severity: MEDIUM

2. **Dependency Version Updates** (MEDIUM IMPACT)
   - Impact: Breaking API changes possible
   - Mitigation: Review changelogs, create compatibility layer if needed
   - Likelihood: MEDIUM | Severity: HIGH

3. **Platform Requirement Increase** (macOS 13+)
   - Impact: CI/CD runners, developer machines
   - Mitigation: Verify GitLab runner macOS version
   - Likelihood: MEDIUM | Severity: LOW

### Deployment Risks

| Risk | Likelihood | Impact | Priority | Mitigation |
|------|-----------|--------|----------|------------|
| Site generation produces different output | LOW | HIGH | P1 | Byte-for-byte comparison, staging deploy |
| Import commands fail silently | MEDIUM | HIGH | P1 | Expand error handling, logging |
| CI/CD pipeline breaks | LOW | HIGH | P1 | Test in feature branch |
| Performance regression | LOW | MEDIUM | P2 | Benchmark before/after |
| Ubuntu build fails | MEDIUM | MEDIUM | P2 | Test early, update Docker image |

### Rollback Strategy

**Rollback Triggers:**
1. Site generation produces incorrect output
2. Import commands fail to fetch new content
3. CI/CD pipeline cannot deploy
4. Performance degrades >25%
5. Critical dependency incompatibility discovered

**Rollback Procedure:**
```bash
# Git-based rollback
git revert <migration-commit-range>
git push origin main

# Artifact-based rollback
cp brightdigitwg-Darwin-arm64.backup brightdigitwg-Darwin-arm64
netlify deploy --site $NETLIFY_PRODUCTION_SITE_ID --prod
```

**Rollback SLA:** <70 minutes from detection to recovery

---

## Success Metrics

### Compilation Metrics
- [ ] Zero errors with Swift 6 language mode
- [ ] Zero concurrency warnings
- [ ] Zero data race safety errors
- [ ] All targets compile successfully
- [ ] Tests pass on macOS and Linux

### Runtime Metrics
- [ ] Newsletter import produces identical markdown
- [ ] Podcast import produces identical markdown
- [ ] Site generation produces identical HTML
- [ ] All 113 existing newsletters load correctly
- [ ] All existing podcast episodes load correctly
- [ ] GitLab CI content automation succeeds

### Performance Validation

| Operation | Baseline (Swift 5.8) | Target (Swift 6) |
|-----------|---------------------|------------------|
| Import 113 newsletters | TBD | ≤110% baseline |
| Fetch YouTube playlist | TBD | ≤110% baseline |
| Generate full site | TBD | ≤110% baseline |
| Memory peak | TBD | ≤120% baseline |

### Quality Metrics
- Test coverage: >25% (from current ~5%)
- Concurrency test coverage: 100% of concurrent code paths
- Zero force-try statements (except truly infallible operations)

---

## Open Questions

### Technical Decisions Requiring Investigation

**1. SwiftTube Package Strategy**
- **Decision: SwiftTube is owned by BrightDigit — create a new branch for Swift 6 migration (no fork needed)**
- No upstream wait required; we control the repo and will push changes directly via `git subrepo push`

**2. Publish Framework Version**
- Question: Stay on 0.9.0 or upgrade to latest main?
- **Investigation Needed: Document the actual differences between 0.9.0 and latest main before deciding**
- Recommendation: Stay on 0.9.0 pending changelog review (Swift 6 compatible, proven stable)

**3. MarkdownGenerator Replacement**
- **Decision: Migrate to [swiftlang/swift-markdown](https://github.com/swiftlang/swift-markdown) (Apple's official parser)**
- Ink is no longer an option; swift-markdown is the designated replacement per Phase 1 plan

**4. macOS Version Requirement**
- **Decision: Require macOS 13+ — drop macOS 12 support (don't care)**
- Swift 6 officially requires macOS 13+; no investigation needed

**5. Testing Strategy**
- **Decision: Target 25% test coverage overall**
- Current: ~5% | Target: 25% (revised down from original >50% proposal)

**6. Deployment Strategy**
- **Decision: Parallel module-by-module work — a lot of work can be done simultaneously**
- Modules can be migrated in parallel across subrepos; not strictly big-bang

**7. Content Validation**
- **Decision: Use automated HTML diffing to validate 113+ newsletters and episodes**
- Manual spot-checking and visual regression testing are not required

**8. Contribute Package Ownership**
- **Decision: BrightDigit is the maintainer — we will release Contribute 1.0.0**
- No external coordination needed; release criteria to be defined internally

**9. Publishing Protocol Shapes**
- Question: What are the exact method signatures for `SubscriberListProvider` and `NewsletterSender`?
- Context: PRD documents architectural intent; final API TBD during Phase 4 implementation
- Investigation Needed: Buttondown API capabilities, composability with Mailgun
- Decision Maker: Technical Lead
- Deadline: Phase 4 Week 1

**10. Buffer GraphQL Schema Stability**
- Question: Is the Buffer GraphQL API (early access) stable enough for production use?
- Context: Buffer's GraphQL API is labeled "early access" — schema may change
- Investigation Needed: Buffer API changelog, breaking-change policy, fallback to REST v1
- Decision Maker: Technical Lead
- Deadline: Phase 4 Week 1

**11. Publishing Pipeline Integration Point**
- Question: Does the publishing tool integrate as a Publish plugin, a CLI subcommand, or a standalone binary?
- Options: Publish plugin (inline with site generation), new `publish` subcommand in BrightDigitArgs, or separate tool
- Context: The SSG itself is being migrated (brightdigit/brightdigit.com#31); integration point may shift
- Decision Maker: Technical Lead
- Deadline: Phase 4 Week 1

---

## Critical Files for Implementation

Based on analysis, the most critical files requiring changes:

1. **`Package.swift`**
   - Controls entire project compilation environment
   - Must be updated first
   - Priority: CRITICAL

2. **`Sources/ContributeYouTube/Prch.APIClient.Podcast.swift`**
   - Most complex concurrency violation (DispatchSemaphore + mutable captures + DispatchGroup)
   - Core podcast import functionality
   - Priority: CRITICAL - Highest technical complexity

3. **`Sources/ContributeMailchimp/Prch.APIClient.Newsletter.swift`**
   - Newsletter import synchronous wrapper
   - Production automation dependency
   - Priority: CRITICAL

4. **`Sources/BrightDigitSite/Testimonial.swift`**
   - Textbook mutable global state data race
   - Simple but critical for strict concurrency
   - Priority: HIGH

5. **`Sources/BrightDigitArgs/Import/Mailchimp.swift`**
   - CLI integration, force-try regex
   - Entry point for automation
   - Priority: HIGH

---

## Summary

This PRD documents a comprehensive modernization of the BrightDigit static site generator infrastructure through three sequential phases:

### Phase 1: Monorepo Consolidation (3-4 weeks)
- Consolidate 17 external packages into monorepo using git-subrepo
- Organize into Packages/Publish/ (8), Packages/BrightDigit/ (7), Packages/Plugins/ (2)
- Fork YoutubePublishPlugin and ReadingTimePublishPlugin to BrightDigit organization
- Replace Ink with swift-markdown (SPM dependency)
- Replace ShellOut with swift-subprocess (SPM dependency)
- **Deliverable:** Monorepo v1.0.0 with all 17 subrepos

### Phase 2: OpenAPI Generator Migration (4-6 weeks)
- Migrate SwiftTube from SwagGen to swift-openapi-generator
- Migrate Spinetail from SwagGen to swift-openapi-generator
- Replace Prch framework with swift-openapi-runtime
- Modernize all API client code to async/await
- **Deliverable:** SwiftTube 1.0.0, Spinetail 1.0.0 (with Apple's OpenAPI generator)

### Phase 3: Swift 6 + Component Migration + Mermaid Support (5-7 weeks)
- Upgrade all 17 subrepos to Swift 6
- Enforce component-based HTML generation (deprecate direct Plot API)
- Create SwiftUI-like component library for site
- Fix concurrency violations (Testimonial.swift data race)
- Add Sendable conformances
- Integrate mermaid.js for diagram rendering
- Expand test coverage from ~5% to >50%
- **Deliverable:** Full Swift 6 compliance with component-only architecture and mermaid support

### Phase 4: Publishing Infrastructure (3-4 weeks)
- Build Buttondown newsletter client (ButtondownKit) using swift-openapi-generator
- Build Buffer social media client (BufferKit) — handwritten GraphQL, ClientTransport
- Build MailgunKit sender-only transport for future composability
- Create PublishKit orchestrator with `SubscriberListProvider` + `NewsletterSender` protocols
- All modules Swift 6 compliant, Linux-compatible, credentials via env vars only
- **Deliverable:** Open source publishing pipeline integrated into BrightDigit.com SSG

**Total Duration:** 15-21 weeks (technical phases) + ongoing content optimization

### AI-CITE Content Optimization (parallel, ongoing)
- Apply AI-CITE framework (Answer-first, Intent-matched, Clear, Indexed, Trusted, Exclusive) to top 10 priority articles
- Add FAQPage and HowTo JSON-LD structured data to optimized content
- Create branded BrightDigit methodology frameworks for Exclusive POV
- Target: 60% AI citation rate within 1 week of optimization per article
- Reference docs: `.claude/ai-cite-optimization/` — audit, sprint plan, schema design, validation
- **Deliverable:** All 10 priority articles optimized; JSON-LD schema in `PiHTMLFactory` (Phase 3 integration)

**Key Architectural Changes:**
1. **Monorepo Consolidation** - 17 packages managed as git-subrepos (Publish ecosystem + BrightDigit + forked plugins)
2. **Apple Framework Migration** - Ink → swift-markdown, ShellOut → swift-subprocess (ONLY these two dependencies)
3. **Retained Dependencies** - Kanna, MarkdownGenerator, Yams, Files (Linux compatibility + no alternatives)
4. **API Client Modernization** - SwagGen/Prch → Apple's swift-openapi-generator
5. **HTML Generation** - Direct Plot calls → SwiftUI-like components
6. **Concurrency** - Callbacks/semaphores → async/await/TaskGroup
7. **Language** - Swift 5.8 → Swift 6 with strict concurrency across all 17 subrepos
8. **Documentation** - Added mermaid.js support for diagrams in markdown
9. **Publishing Infrastructure** - ButtondownKit + BufferKit + MailgunKit + PublishKit; open source, no audience data in repo, Linux-compatible

**Success Criteria:**
- All 17 packages managed as git-subrepos in organized structure
- swift-markdown and swift-subprocess integrated successfully (ONLY 2 Apple framework replacements)
- Kanna, MarkdownGenerator, Yams, Files retained (Linux compatibility + no alternatives)
- Zero concurrency warnings across all 17 subrepos
- Site output byte-for-byte identical to current production (excluding mermaid diagrams)
- All 113 newsletters and podcast episodes render correctly
- Mermaid diagrams render correctly via client-side mermaid.js
- CI/CD pipeline passes on macOS and Ubuntu (cross-platform compatibility validated)
- Component-only HTML generation throughout codebase
- All subrepo updates pushed to upstream repositories
- Publishing tool compiles with Swift 6 strict concurrency, runs on Linux, and integrates with BrightDigit.com pipeline
