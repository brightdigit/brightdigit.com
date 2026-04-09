# BrightDigit.com — Product Requirements Document

**Repository:** brightdigit/brightdigit.com  
**Last Updated:** 2026-04-09  
**Status:** Living document — reflects current open issues

---

## Overview

This document organizes all open GitHub issues into sequential phases and milestones. The work spans four major concerns:

1. **Content & SEO** — AI-CITE schema optimization and article edits
2. **Infrastructure Modernization** — OpenAPI migration, dependency replacements, Swift 6
3. **Publishing Pipeline** — Buttondown + Buffer integration, newsletter/podcast tooling
4. **Platform Migration** — GitHub Pages, AT Protocol support

### Dependency Chain

```
Phase 0/0B (housekeeping/articles) — independent, can run at any time
Phase 1 (AI-CITE) ──────────────── independent, can run in parallel with Phase 2
Phase 2 (Monorepo cleanup) ──────── prerequisite: #36 ✓ (complete)
Phase 3 (OpenAPI migration) ─────── requires Phase 2
Phase 4 (Swift 6 + Components) ──── requires Phase 3 — major PiHTMLFactory/Nodes rewrite
Phase 5 (Publishing infra) ──────── requires Phase 3 (swift-openapi-generator toolchain)
Phase 6 (Platform migration) ────── requires Phase 4/5
Phase 7 (Final cleanup) ─────────── anytime, low priority
```

---

## Priority Labels

| Label | Meaning |
|-------|---------|
| P0-critical | Must complete first; blocks other work |
| P1-high | High priority within its phase |
| P2-medium | Important but not blocking |
| (none) | Standard priority |

---

## Phase 0: Quick Wins & Housekeeping

**Goal:** Remove stale tooling and fix broken content — no code architecture changes.

| # | Title | Status |
|---|-------|--------|
| #11 | Fix Content Updates | Open |
| #18 | Add seomachine.io | Open |
| #35 | Remove dev-server.sh | Open |

**Notes:**
- These are independent of all other phases and can be done at any time.
- #35 removes the shell-based dev server; replaced by the Swift-native approach.

---

## Phase 0B: Article Edits

**Goal:** Small content fixes to existing articles. Needs an `article-edit` label added on GitHub.

| # | Title | Status |
|---|-------|--------|
| #3 | Add Additional Local Storage Options | Open |
| #4 | Add Main Actor to Swift 6 Article Solution | Open |
| #13 | Clarify String vs Reference design choice in MistKit article | Open |

**Notes:**
- Pure markdown/content edits; no code changes required.
- Recommend adding an `article-edit` label to GitHub to distinguish from code issues.

---

## Phase 1: AI-CITE Optimization

**Milestone:** AI-CITE Phase 1 (target: Feb 28, 2026)  
**Goal:** Implement structured schema markup and optimize priority articles so BrightDigit content is cited by AI systems (ChatGPT, Google AI Overview, etc.).

### 1A: Schema Implementation

| # | Title | Priority | Status |
|---|-------|----------|--------|
| #19 | Implement FAQ Schema Markup in `PiHTMLFactory` | P0-critical | In Progress |
| #20 | Implement HowTo Schema Markup in `PiHTMLFactory` | P1-high | Open |

**Implementation files:**
- `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift` — head generation
- `Sources/BrightDigitSite/PiHTMLFactory.swift` — main factory

**#19 acceptance criteria (summarized):**
- `FAQSchema.swift` created with data models
- `.jsonLDSchema()` helper added to `HTML.HeadContext`
- `.head()` includes FAQ schema when present in article frontmatter
- Schema validates in Google Rich Results Test

### 1B: Article Optimization

| # | Title | Priority | Status |
|---|-------|----------|--------|
| #21 | Optimize Mise Setup Guide for AI-CITE | P1-high | Open |
| #22 | Optimize Best Backend Article for AI-CITE | P1-high | Open |
| #26 | Optimize iOS CI/CD Article for AI-CITE | P1-high | Open |
| #27 | Optimize iOS Architecture Article for AI-CITE | P1-high | Open |
| #28 | Optimize Remaining Priority Articles (Batch) | P1-high | Open |

**Dependency:** #19 must be complete before article optimization begins (schema must exist to add frontmatter).

### 1C: Validation

| # | Title | Priority | Status |
|---|-------|----------|--------|
| #23 | Test AI-CITE Baseline and Validate Schema | P1-high | Open |

### 1D: Content Strategy

| # | Title | Priority | Status |
|---|-------|----------|--------|
| #24 | YouTube Video Content Strategy | P2-medium | Open |
| #25 | Create Unique BrightDigit Frameworks/Methodologies | P2-medium | Open |

---

## Phase 2: Monorepo Cleanup

**Goal:** Finish loose ends from the monorepo consolidation (#36, completed via #42 and #48).

| # | Title | Status |
|---|-------|--------|
| ~~#36~~ | ~~Phase 1: Monorepo Consolidation (17 packages)~~ | **Completed** (#42, #48) |
| #43 | Upgrade SyndiKit subrepo from 0.3.7 to main branch | Open |
| #47 | Remove MarkdownGenerator dependency | Open |

---

## Phase 3: OpenAPI & Dependency Migration

**Goal:** Replace SwagGen + Prch with Apple's swift-openapi-generator and async/await throughout. Replace other stale dependencies.

**Estimated effort:** 4–6 weeks

| # | Title | Notes |
|---|-------|-------|
| #45 | Replace Prch with swift-openapi-* | First step — unblocks async/await everywhere |
| #37 | OpenAPI Generator Migration (SwiftTube + Spinetail) | ~521 generated files replaced; rewrites `ContributeYouTube` and `ContributeMailchimp` |
| #40 | Replace Ink with swift-markdown | Ink is used transitively via Publish's markdown pipeline |
| #41 | Replace ShellOut with swift-subprocess | Only affects `Tagscriber/PandocMarkdownGenerator.swift` |
| #46 | Replace ShellOut with swift-subprocess | Duplicate of #41 — resolve together |
| #44 | Replace swift-argument-parser with swift-configuration | Affects all 7 files in `BrightDigitArgs/` |

**Target architecture after Phase 3:**
- `swift-openapi-generator` produces protocol-based async clients for YouTube and Mailchimp APIs
- `swift-openapi-runtime` + `swift-openapi-urlsession` replace `Prch` entirely
- `DispatchSemaphore`/`DispatchGroup` replaced with `async/await` + `TaskGroup`
- `BrightDigitArgs` commands updated for async execution

**Success criteria:**
- `SwiftTube 1.0.0` and `Spinetail 1.0.0` released with swift-openapi-generator
- Full newsletter import (113 newsletters) + podcast import produces identical markdown output
- CI/CD content automation job passes

---

## Phase 4: Swift 6 + Component Migration

**Goal:** Enable Swift 6 strict concurrency mode across all 17 subrepos. Migrate Plot HTML generation to a component-based API. Add Mermaid diagram support.

**Estimated effort:** 5–7 weeks  
**Dependency:** Phase 3 must be complete.

> **High Impact Warning:** This phase substantially rewrites `PiHTMLFactory` and all `Nodes/` files.

| # | Title | Status |
|---|-------|--------|
| #38 | Swift 6 Language Mode + Component Migration + Mermaid Support | Open |

### Key Tasks

**Swift 6 Upgrades:**
- Update all 17 subrepos to `// swift-tools-version: 6.0`
- Fix `Testimonial.swift` data race (`static var lastID` — remove auto-increment)
- Add `Sendable` conformances: `Newsletter.Source`, `YouTubeContent.Source`, `RSSContent.Source`, `BrightDigitPodcast.Source`
- Fix force-try: `YAMLStringFix.swift:6`, `String.swift:4`, `RSSContent.swift:21`

**Component-Based Plot API — Files Affected:**

| File | Lines | Change |
|------|-------|--------|
| `Sources/BrightDigitSite/PiHTMLFactory.swift` | 129 | Refactored to use components |
| `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift` | 242 | Substantially rewritten |
| `Sources/BrightDigitSite/Nodes/Pages/` (4 files) | — | Converted to components |
| `Sources/BrightDigitSite/Nodes/Section/` (5 files) | — | Converted to components |
| `Sources/BrightDigitSite/Nodes/Social/` (7 files) | — | Converted to components |

**New components to create in `Sources/BrightDigitSite/Components/`:**
- Layout: `HeaderComponent`, `FooterComponent`, `NavigationComponent`, `PageLayoutComponent`
- Content: `ArticleCardComponent`, `NewsletterItemComponent`, `PodcastEpisodeComponent`, `TutorialItemComponent`, `ProductCardComponent`

**Mermaid Support:**
- Detect `mermaid` code blocks and wrap in `<div class="mermaid">` instead of `<pre><code>`
- Add mermaid.js CDN script to HTML `<head>`

**Success criteria:**
- Zero concurrency warnings across all 17 subrepos
- `swift build` with Swift 6 strict mode passes on macOS and Ubuntu
- Site output byte-for-byte identical (excluding mermaid blocks — visual verification)

---

## Phase 5: Publishing Infrastructure

**Goal:** Replace the Mailchimp-based newsletter workflow with a Buttondown + Buffer Swift CLI. Enable video podcast publishing.

**Dependency:** Phase 3 (swift-openapi-generator toolchain available).

| # | Title | Status |
|---|-------|--------|
| #33 | Swift Publishing Tool: Buttondown + Buffer Architecture | Open |
| #31 | Migrate Newsletters | Open |
| #30 | Public Buffer API | Open |
| #32 | Video Podcasts | Open |

**Architecture (#33):**

| Channel | Platform | API Style |
|---------|----------|-----------|
| Newsletter | Buttondown | REST — swift-openapi-generator (official OpenAPI 3.0.2 spec) |
| Social | Buffer | GraphQL — handwritten `Codable` client (no code gen) |

**Package structure:**
```
Sources/
  PublishKit/     # Core orchestrator + protocol definitions
  ButtondownKit/  # Newsletter transport (swift-openapi-generator)
  BufferKit/      # Social transport (handwritten GraphQL + Codable)
  publish/        # CLI entry point
```

**Notes:**
- #33 depends on #37 for swift-openapi-generator toolchain and #38 for Swift 6 compliance
- #31 (newsletter migration) follows after #33 tooling is complete
- #30 (Buffer API) is a prerequisite for #33's social publishing leg
- Subscriber data stays on Buttondown's servers — nothing stored in this repo

---

## Phase 6: Platform Migration

**Goal:** Migrate hosting to GitHub Pages and add AT Protocol support.

| # | Title | Notes |
|---|-------|-------|
| #50 | Migrate to Github Pages | Currently deployed via Netlify |
| #49 | Support AT Protocol | Reference: [A Social Filesystem](https://overreacted.io/a-social-filesystem/) |

---

## Phase 7: Final Cleanup

**Goal:** Low-priority cleanup deferred until core work is stable.

| # | Title | Notes |
|---|-------|-------|
| #34 | Remove or repurpose Import/Wordpress XML files | Clean up leftover import artifacts |
| #1 | Skip Campaign Download For Existing Newsletters | May be superseded by Phase 5 ButtonDown migration; keep for now |

---

## Excluded Issues

| # | Title | Reason |
|---|-------|--------|
| #12 | Make Repo Public | Already completed |

---

## Issue Count by Phase

| Phase | Issues | Notes |
|-------|--------|-------|
| Phase 0 | 3 | Quick wins |
| Phase 0B | 3 | Article edits |
| Phase 1 | 10 | AI-CITE (milestone active) |
| Phase 2 | 2 | Monorepo cleanup (1 already done) |
| Phase 3 | 6 | OpenAPI migration |
| Phase 4 | 1 | Swift 6 + components (large scope) |
| Phase 5 | 4 | Publishing infrastructure |
| Phase 6 | 2 | Platform migration |
| Phase 7 | 2 | Deferred cleanup |
| **Total** | **33** | Excludes #12 (done), #36 (done) |
