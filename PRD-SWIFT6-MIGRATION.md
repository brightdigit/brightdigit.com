# Product Requirements Document: Swift 6 Migration for BrightDigit Website

## Executive Summary

### Migration Goals

Modernize the BrightDigit static site generator infrastructure by:
1. Creating a unified Publish framework package under BrightDigit ownership
2. Migrating API client generation from SwagGen to Apple's swift-openapi-generator
3. Upgrading to Swift 6 with strict concurrency compliance

This three-phase approach ensures dependency stability before tackling the Swift 6 language migration.

**Primary Objectives:**
1. **Dependency Consolidation** - Fork Publish ecosystem (10 packages) into single unified BrightDigit-owned package
2. **API Modernization** - Migrate SwiftTube and Spinetail from SwagGen to swift-openapi-generator
3. **Swift 6 Compliance** - Achieve strict concurrency checking and eliminate data race violations
4. **Maintain Compatibility** - Zero functional regressions, byte-for-byte identical site output

**Success Criteria:**
- Unified Publish package builds successfully with all 10 dependencies integrated
- SwiftTube and Spinetail generate from OpenAPI specs using swift-openapi-generator
- Prch framework successfully replaced with swift-openapi-runtime
- Project compiles with Swift 6 language mode enabled
- Zero concurrency warnings or errors
- All tests pass on macOS and Ubuntu
- Generated site is byte-for-byte identical to current production
- GitLab CI/CD pipeline executes successfully

### Timeline Expectations

**Phase 1: Publish Unification** (2-3 weeks)
- Fork 10 Publish ecosystem packages into unified repository
- Create BrightDigitPublish package with all dependencies
- Update brightdigit.com to use unified package
- Validate site generation produces identical output

**Phase 2: OpenAPI Generator Migration** (4-6 weeks)
- Migrate SwiftTube from SwagGen to swift-openapi-generator
- Migrate Spinetail from SwagGen to swift-openapi-generator
- Replace Prch framework with swift-openapi-runtime + swift-openapi-urlsession
- Update ContributeYouTube and ContributeMailchimp client code
- Comprehensive API integration testing

**Phase 3: Swift 6 Migration** (4-6 weeks)
- Update to Swift 6 language mode
- Fix concurrency violations (Testimonial.swift, async/await patterns)
- Add Sendable conformances
- Expand test coverage
- Performance benchmarking and validation

**Total Estimated Duration:** 10-15 weeks

---

## Technical Requirements

### Phase 1 Requirements: Publish Unification

**Objective:** Create BrightDigitPublish - a unified package containing the entire Publish ecosystem

**Packages to Consolidate (10 total):**

1. **Publish** (0.9.0) - Core static site generator
2. **Plot** (0.14.0) - HTML DSL
3. **Ink** (0.6.0) - Markdown parser
4. **Files** (4.2.0) - File system abstraction
5. **Codextended** (0.3.0) - Swift extensions
6. **Sweep** (0.4.0) - String utilities
7. **ShellOut** (2.3.0) - Shell command execution
8. **CollectionConcurrencyKit** (0.2.0) - Async collection operations
9. **Splash** (0.16.0) - Syntax highlighting
10. **SplashPublishPlugin** (0.2.0) - Syntax highlighting plugin

**Package Structure:**
```
BrightDigitPublish/
├── Sources/
│   ├── Publish/          (from johnsundell/Publish)
│   ├── Plot/             (from johnsundell/Plot)
│   ├── Ink/              (from johnsundell/Ink)
│   ├── Files/            (from johnsundell/Files)
│   ├── Codextended/      (from johnsundell/Codextended)
│   ├── Sweep/            (from johnsundell/Sweep)
│   ├── ShellOut/         (from johnsundell/ShellOut)
│   ├── CollectionConcurrencyKit/ (from johnsundell/CollectionConcurrencyKit)
│   ├── Splash/           (from johnsundell/Splash)
│   └── SplashPublishPlugin/ (from johnsundell/SplashPublishPlugin)
├── Tests/                (consolidated tests)
├── Package.swift         (unified manifest with 10 targets)
└── README.md
```

**brightdigit.com Package.swift Changes:**
```swift
dependencies: [
  // Replace all these:
  // .package(url: "https://github.com/johnsundell/Publish.git", from: "0.9.0"),
  // .package(url: "https://github.com/johnsundell/SplashPublishPlugin.git", from: "0.2.0"),
  // ... etc

  // With single dependency:
  .package(url: "https://github.com/brightdigit/BrightDigitPublish.git", from: "1.0.0"),
]
```

**PublishType Module:** Remains in brightdigit.com repository as separate target (not merged into BrightDigitPublish)

### Phase 2 Requirements: OpenAPI Generator Migration

**Objective:** Replace SwagGen-based API clients with Apple's swift-openapi-generator

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

### Phase 3 Requirements: Swift 6 Language Mode

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

### Phase 1: Publish Ecosystem Unification (2-3 weeks)

**Objective:** Create BrightDigitPublish package and migrate brightdigit.com to use it

**Week 1: Repository Setup and Package Creation**

1. **Create BrightDigitPublish Repository**
   - Create new repo: `https://github.com/brightdigit/BrightDigitPublish`
   - Initialize with Package.swift
   - Add README with migration rationale

2. **Fork and Consolidate Source Code**
   - Clone all 10 source repositories from johnsundell
   - Copy source code into respective targets
   - Preserve original LICENSE files (all MIT)
   - Update imports to use unified module names

3. **Create Unified Package.swift**
   ```swift
   // swift-tools-version: 5.8
   let package = Package(
     name: "BrightDigitPublish",
     platforms: [.macOS(.v12)],
     products: [
       .library(name: "Publish", targets: ["Publish"]),
       .library(name: "Plot", targets: ["Plot"]),
       .library(name: "Ink", targets: ["Ink"]),
       // ... all 10 products
     ],
     targets: [
       .target(name: "Publish", dependencies: ["Ink", "Plot", "Files", ...]),
       .target(name: "Plot", dependencies: []),
       .target(name: "Ink", dependencies: []),
       // ... all 10 targets with proper dependencies
     ]
   )
   ```

4. **Consolidate Tests**
   - Merge test suites from all packages
   - Ensure all tests pass

**Week 2: Integration and Validation**

5. **Update brightdigit.com Package.swift**
   - Replace 10 separate dependencies with single BrightDigitPublish
   - Update imports if module names changed
   - Verify build succeeds

6. **Validation Testing**
   - Run full site generation
   - Compare output with baseline (byte-for-byte)
   - Verify all 113 newsletters render correctly
   - Verify all podcast episodes render correctly
   - Test GitLab CI/CD on both macOS and Ubuntu

7. **Documentation**
   - Document package structure
   - Create migration guide for external consumers
   - Update CLAUDE.md with new dependency architecture

**Week 3: Stabilization**

8. **Release BrightDigitPublish 1.0.0**
   - Tag release
   - Publish to GitHub
   - Update Package.resolved in brightdigit.com

9. **Deploy to Staging**
   - Test full deployment pipeline
   - Performance benchmarking
   - Visual regression testing

**Deliverables:**
- [ ] BrightDigitPublish repository created with all 10 packages
- [ ] All tests passing in unified package
- [ ] brightdigit.com using BrightDigitPublish dependency
- [ ] Site generation produces identical output
- [ ] GitLab CI/CD pipeline passing
- [ ] BrightDigitPublish 1.0.0 released

---

### Phase 2: OpenAPI Generator Migration (4-6 weeks)

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

### Phase 3: Swift 6 + Component Migration (4-6 weeks)

**Objective:** Upgrade to Swift 6, enforce component-based HTML generation, eliminate concurrency violations

**Note:** Async/await patterns already in place from Phase 2 OpenAPI migration

**Week 1: BrightDigitPublish Swift 6 Upgrade**

1. **Update BrightDigitPublish to Swift 6**
   - Update Package.swift: `// swift-tools-version: 6.0`
   - Platform requirement: `.macOS(.v13)`
   - Add strict concurrency checking to all 10 targets
   - Fix any concurrency warnings in Publish/Plot/Ink code
   - Test all modules compile

2. **Enforce Component-Based Plot API**
   - Mark direct Node HTML creation as `internal` (currently `public`)
   - Keep Component protocol and @ComponentBuilder public
   - Update Plot documentation to emphasize components
   - This deprecates direct `.element()`, `.div()`, etc. usage

3. **Release BrightDigitPublish 2.0.0**
   - Swift 6 compatible
   - Component-only public API

**Week 2: API Client Swift 6 Upgrades**

4. **Update SwiftTube 2.0.0**
   - swift-openapi-generator produces Swift 6 code
   - Add Sendable conformances
   - Enable strict concurrency
   - Test with Swift 6

5. **Update Spinetail 2.0.0**
   - Same process
   - Add Sendable conformances
   - Swift 6 compatibility

6. **Update Supporting Packages**
   - SyndiKit 1.0.0 (Swift 6)
   - Contribute 2.0.0 (Swift 6 - promote from alpha)

**Week 3-4: Component Migration in brightdigit.com**

7. **Create Site Component Library**

   New files to create in `/Users/leo/Documents/Projects/brightdigit.com/Sources/BrightDigitSite/Components/`:

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

8. **Migrate Existing Plot Code to Components**

   Files to update:
   - `/Users/leo/Documents/Projects/brightdigit.com/Sources/BrightDigitSite/PiHTMLFactory.HTML.swift`
     - Replace `.header()` and `.footer()` Node extensions with Component calls
     - Convert all direct Node creation to component usage

   - `/Users/leo/Documents/Projects/brightdigit.com/Sources/BrightDigitSite/Nodes/Pages/`
     - `IndexBuilder.swift` - Convert to components
     - `AboutBuilder.swift` - Convert to components
     - `ContactBuilder.swift` - Convert to components
     - `ServicesBuilder.swift` - Convert to components

   - `/Users/leo/Documents/Projects/brightdigit.com/Sources/BrightDigitSite/Nodes/Section/`
     - All item renderers (ArticleItem, NewsletterItem, etc.) to components

9. **Component Testing**
   - Verify HTML output identical to previous Plot code
   - Test component reusability
   - Validate all 113 newsletters render
   - Validate all podcast episodes render

**Week 5: brightdigit.com Swift 6 Migration**

10. **Update brightdigit.com Package.swift**
    - `// swift-tools-version: 6.0`
    - Platform: `.macOS(.v13)`
    - Strict concurrency on all targets
    - Dependencies:
      - BrightDigitPublish 2.0.0
      - SwiftTube 2.0.0
      - Spinetail 2.0.0
      - Contribute 2.0.0
      - SyndiKit 1.0.0

11. **Fix Testimonial.swift Data Race (CRITICAL)**
    - File: `/Users/leo/Documents/Projects/brightdigit.com/Sources/BrightDigitSite/Testimonial.swift`
    - Remove `static var lastID = 0` (line 5)
    - Remove auto-increment (lines 19-20)
    - Make `id` required parameter
    - Update all static testimonial definitions with explicit IDs
    - Effort: 1-2 hours

12. **Add Sendable Conformances**
    - `Newsletter.Source` (ContributeMailchimp)
    - `YouTubeContent.Source` (ContributeYouTube)
    - `RSSContent.Source` (ContributeRSS)
    - `BrightDigitPodcast.Source`
    - All new Component types

13. **Fix Force-Try Statements**
    - `YAMLStringFix.swift:6` - NSRegularExpression lazy closure
    - `String.swift:4` - NSRegularExpression lazy closure
    - `RSSContent.swift:21` - Explicit error handling instead of try?

**Week 6: Testing and Deployment**

14. **Comprehensive Testing**
    - All 113 newsletters render correctly
    - All podcast episodes render correctly
    - Components produce identical HTML
    - GitLab CI passes (macOS + Ubuntu)
    - Performance within 10% baseline

15. **Expand Test Coverage**
    - Component unit tests
    - Concurrency safety tests
    - Integration tests
    - Target: >50% coverage (from ~5%)

16. **Production Deployment**
    - Deploy to staging
    - Byte-for-byte HTML comparison
    - Visual regression testing
    - Deploy to production

**Deliverables:**
- [ ] BrightDigitPublish 2.0.0 with Swift 6 and component-only API
- [ ] All API clients upgraded to Swift 6
- [ ] brightdigit.com using components exclusively
- [ ] Zero direct Plot HTML creation in codebase
- [ ] Zero concurrency warnings
- [ ] Testimonial data race fixed
- [ ] All Sendable conformances added
- [ ] Test coverage >50%
- [ ] Production deployment successful

---

### Phase 2: Code Modernization (async/await, error handling)

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

### Phase 3: Strict Concurrency Compliance

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

### Phase 4: Testing and Validation

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
- Test coverage: >50% (from current ~5%)
- Concurrency test coverage: 100% of concurrent code paths
- Zero force-try statements (except truly infallible operations)

---

## Open Questions

### Technical Decisions Requiring Investigation

**1. SwiftTube Package Strategy**
- Question: Fork SwiftTube or wait for upstream fix?
- Investigation Needed: Time estimate to fix, upstream responsiveness
- Decision Maker: Technical Lead
- Deadline: End of Phase 1

**2. Publish Framework Version**
- Question: Stay on 0.9.0 or upgrade to latest main?
- Recommendation: Stay on 0.9.0 (Swift 6 compatible, proven stable)
- Decision Maker: Technical Lead
- Deadline: Phase 1 Week 1

**3. MarkdownGenerator Replacement**
- Question: Keep MarkdownGenerator or migrate to alternative?
- Options: Keep if compatible, migrate to Swift Markdown (Apple), or Ink
- Investigation Needed: Swift 6 compatibility test results
- Decision Maker: Technical Lead
- Deadline: Phase 1 Week 2

**4. macOS Version Requirement**
- Question: Require macOS 13+ or try to support macOS 12?
- Context: Swift 6 officially requires macOS 13+
- Investigation Needed: GitLab runner OS version, developer machine impact
- Decision Maker: Technical Lead + DevOps
- Deadline: Phase 1 Week 1

**5. Testing Strategy**
- Question: What level of test coverage is sufficient?
- Current: ~5% | Proposed: >50% overall, 100% concurrency paths
- Decision Maker: Technical Lead
- Deadline: Phase 2 Week 1

**6. Deployment Strategy**
- Question: Big-bang migration or gradual module-by-module?
- Recommendation: Big-bang via feature branch (modules too interdependent)
- Decision Maker: Technical Lead
- Deadline: Phase 1 Week 1

**7. Content Validation**
- Question: How to validate 113+ newsletters and episodes render correctly?
- Options: Manual spot-checking, automated HTML diffing, visual regression testing
- Investigation Needed: Tools for HTML diffing at scale
- Decision Maker: Technical Lead + QA
- Deadline: Phase 3 Week 1

**8. Contribute Package Ownership**
- Question: Who will release Contribute 1.0.0?
- Actions Needed: Identify maintainer, agree on release criteria
- Decision Maker: Package Maintainer
- Deadline: Phase 1 Week 1

---

## Critical Files for Implementation

Based on analysis, the most critical files requiring changes:

1. **`/Users/leo/Documents/Projects/brightdigit.com/Package.swift`**
   - Controls entire project compilation environment
   - Must be updated first
   - Priority: CRITICAL

2. **`/Users/leo/Documents/Projects/brightdigit.com/Sources/ContributeYouTube/Prch.APIClient.Podcast.swift`**
   - Most complex concurrency violation (DispatchSemaphore + mutable captures + DispatchGroup)
   - Core podcast import functionality
   - Priority: CRITICAL - Highest technical complexity

3. **`/Users/leo/Documents/Projects/brightdigit.com/Sources/ContributeMailchimp/Prch.APIClient.Newsletter.swift`**
   - Newsletter import synchronous wrapper
   - Production automation dependency
   - Priority: CRITICAL

4. **`/Users/leo/Documents/Projects/brightdigit.com/Sources/BrightDigitSite/Testimonial.swift`**
   - Textbook mutable global state data race
   - Simple but critical for strict concurrency
   - Priority: HIGH

5. **`/Users/leo/Documents/Projects/brightdigit.com/Sources/BrightDigitArgs/Import/Mailchimp.swift`**
   - CLI integration, force-try regex
   - Entry point for automation
   - Priority: HIGH

---

## Summary

This PRD documents a comprehensive modernization of the BrightDigit static site generator infrastructure through three sequential phases:

### Phase 1: Publish Unification (2-3 weeks)
- Fork 10 Publish ecosystem packages into BrightDigitPublish
- Create unified package under BrightDigit ownership
- Eliminate dependency on johnsundell repositories
- **Deliverable:** BrightDigitPublish 1.0.0

### Phase 2: OpenAPI Generator Migration (4-6 weeks)
- Migrate SwiftTube from SwagGen to swift-openapi-generator
- Migrate Spinetail from SwagGen to swift-openapi-generator
- Replace Prch framework with swift-openapi-runtime
- Modernize all API client code to async/await
- **Deliverable:** SwiftTube 1.0.0, Spinetail 1.0.0 (with Apple's OpenAPI generator)

### Phase 3: Swift 6 + Component Migration (4-6 weeks)
- Upgrade all packages to Swift 6
- Enforce component-based HTML generation (deprecate direct Plot API)
- Create SwiftUI-like component library for site
- Fix concurrency violations (Testimonial.swift data race)
- Add Sendable conformances
- Expand test coverage from ~5% to >50%
- **Deliverable:** Full Swift 6 compliance with component-only architecture

**Total Duration:** 10-15 weeks

**Key Architectural Changes:**
1. **Dependency Consolidation** - 10 packages → 1 BrightDigitPublish package
2. **API Client Modernization** - SwagGen/Prch → Apple's swift-openapi-generator
3. **HTML Generation** - Direct Plot calls → SwiftUI-like components
4. **Concurrency** - Callbacks/semaphores → async/await/TaskGroup
5. **Language** - Swift 5.8 → Swift 6 with strict concurrency

**Success Criteria:**
- Zero concurrency warnings
- Site output byte-for-byte identical to current production
- All 113 newsletters and podcast episodes render correctly
- CI/CD pipeline passes on macOS and Ubuntu
- Component-only HTML generation throughout codebase
