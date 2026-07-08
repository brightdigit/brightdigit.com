# BrightDigit.com — Product Requirements Document

**Repository:** brightdigit/brightdigit.com  
**Last Updated:** 2026-04-13  
**Status:** Living document — reflects current open issues

---

## Overview

This document organizes all open GitHub issues into sequential phases and milestones. The work spans four major concerns:

1. **Content & SEO** — AI-CITE schema optimization and article edits
2. **Infrastructure Modernization** — Swift 6.3, OpenAPI migration, dependency replacements
3. **Publishing Pipeline** — Buttondown + Buffer integration, newsletter/podcast tooling
4. **Platform Migration** — GitHub Pages, AT Protocol support

### Dependency Chain

```
Phase 0 (housekeeping) ─────────────── independent, can run at any time
Phase 1 (Monorepo cleanup) ──────────── prerequisite: [#36](https://github.com/brightdigit/brightdigit.com/issues/36) ✓ (complete)
Phase 2 (Swift 6.3 main package) ────── requires Phase 1
Phase 3 (AI-CITE schema + validation) ─ requires Phase 2 (intentional: implement after Swift 6.3 upgrade)
Phase 4 (OpenAPI migration) ─────────── requires Phase 2 — Swift 6.3-only toolchain
Phase 5 (Swift 6.3 subrepos + components) requires Phase 4  [+ high-priority Buttondown email work pulled forward — see note]
Phase 6 (Publishing infra) ──────────── requires Phase 4 (swift-openapi-generator toolchain)
Phase 7 (Platform migration) ────────── requires Phase 5/6
Phase 8 (Final cleanup) ─────────────── anytime, low priority
```

> **Note (Buttondown priority):** Phase 5 and Phase 6 are siblings — both require only Phase 4,
> neither requires the other. Because the Buttondown newsletter/email work is now high priority,
> the email-import + hosted-HTML-cleanup chain ([#124](https://github.com/brightdigit/brightdigit.com/issues/124)
> → [#122](https://github.com/brightdigit/brightdigit.com/issues/122),
> [#127](https://github.com/brightdigit/brightdigit.com/issues/127)) and the subscribe form
> ([#126](https://github.com/brightdigit/brightdigit.com/issues/126)) have been pulled forward
> into **Phase 5** to run concurrently with the component migration. The outbound publishing leg
> ([#33](https://github.com/brightdigit/brightdigit.com/issues/33),
> [#31](https://github.com/brightdigit/brightdigit.com/issues/31)) and social/video
> ([#30](https://github.com/brightdigit/brightdigit.com/issues/30),
> [#32](https://github.com/brightdigit/brightdigit.com/issues/32),
> [#49](https://github.com/brightdigit/brightdigit.com/issues/49)) remain in Phase 6.

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
| [#11](https://github.com/brightdigit/brightdigit.com/issues/11) | Fix Content Updates | Open |
| [#35](https://github.com/brightdigit/brightdigit.com/issues/35) | Remove dev-server.sh | Open |

**Notes:**
- These are independent of all other phases and can be done at any time.
- [#35](https://github.com/brightdigit/brightdigit.com/issues/35) removes the shell-based dev server (`dev-server.sh` hardcodes `/Users/leo/.nvm/...`); replaced by the Swift-native approach.

---

## Phase 1: Monorepo Cleanup

**Goal:** Finish loose ends from the monorepo consolidation ([#36](https://github.com/brightdigit/brightdigit.com/issues/36), completed via [#42](https://github.com/brightdigit/brightdigit.com/issues/42) and [#48](https://github.com/brightdigit/brightdigit.com/issues/48)).

| # | Title | Status |
|---|-------|--------|
| ~~[#36](https://github.com/brightdigit/brightdigit.com/issues/36)~~ | ~~Phase 1: Monorepo Consolidation (17 packages)~~ | **Completed** ([#42](https://github.com/brightdigit/brightdigit.com/issues/42), [#48](https://github.com/brightdigit/brightdigit.com/issues/48)) |

**Notes:**
- Phase 1 has no remaining open work. The `MarkdownGenerator` removal originally tracked by [#47](https://github.com/brightdigit/brightdigit.com/issues/47) has been folded into Phase 4 [#40](https://github.com/brightdigit/brightdigit.com/issues/40) (swift-markdown covers both Ink replacement and MarkdownGenerator replacement, since both libraries are swapped for the same dependency). [#47](https://github.com/brightdigit/brightdigit.com/issues/47) has been retitled and moved to Phase 4 to track the orthogonal Kanna → SwiftSoup migration in `Tagscriber` — it was previously a TBD row there.

---

## Phase 2: Swift 6.3 — Main Package

**Goal:** Upgrade the top-level `brightdigit.com` package to Swift 6.3 language mode. Subrepos remain at their current language modes — a Swift 6.3 package can depend on older Swift packages. This unblocks Phase 4 (swift-openapi-generator and swift-subprocess require Swift 6.3+).

**Estimated effort:** 2–3 weeks  
**Dependency:** Phase 1.

| # | Title | Status |
|---|-------|--------|
| [#38](https://github.com/brightdigit/brightdigit.com/issues/38) | Swift 6 Language Mode + Component Migration + Mermaid Support | Open |
| [#54](https://github.com/brightdigit/brightdigit.com/issues/54) | Migrate linting and style configs to Swift-App-Template patterns | Open |
| [#65](https://github.com/brightdigit/brightdigit.com/issues/65) | CI cache key doesn't track docker image — stale `.build/` segfaults release binary | Open — short-term `-v2-` mitigation applied; durable fix pending |
| TBD | Fast-deploy: cache prebuilt binary so content-only commits skip `swift build` | Open |

**Content/code separation note:** `Content/` markdown files are already runtime data — they are not compiled into the binary. The problem is CI/CD latency: every commit triggers `swift build` even when only markdown changed. Solution: store the prebuilt `brightdigitwg` binary as a GitLab CI artifact; content-only commits (no `*.swift` or `Package.swift` changes) download the cached binary and run deploy directly. Cache must be invalidated when `Package.resolved` changes.

**Key tasks:**
- Update `Package.swift`: `// swift-tools-version: 6.3`, `.macOS(.v13)`
- **Fix `Testimonial.swift` data race (critical):** remove `static var lastID`, make `id` a required parameter
- Add `Sendable` conformances: `Newsletter.Source`, `YouTubeContent.Source`, `RSSContent.Source`, `BrightDigitPodcast.Source`
- Fix force-try: `YAMLStringFix.swift:6`, `String.swift:4`, `RSSContent.swift:21`

**Deliverables:**
- [ ] `brightdigit.com` Package.swift on `swift-tools-version: 6.3`
- [ ] Zero concurrency warnings in `Sources/`
- [ ] All tests passing under Swift 6.3
- [ ] Subrepos unchanged (still at prior language modes)

---

## Phase 3: AI-CITE Optimization

**Milestone:** AI-CITE Phase 1 (target: Feb 28, 2026)  
**Branch:** `ai-cite-optimization` (PR [#39](https://github.com/brightdigit/brightdigit.com/issues/39))  
**Goal:** Implement structured schema markup and optimize priority articles so BrightDigit content is cited by AI systems (ChatGPT, Google AI Overview, etc.). AI-CITE is fundamentally an integration into the Swift site-building code (`PublishType` protocol + `BrightDigitSite` implementation) — not just article-level content edits. Intentionally sequenced after Phase 2 to avoid doing this work twice across a Swift 6.3 boundary.

**Framework:** AI-CITE — Answer-first, Intent-matched headings, Clear structure, Indexed schema, Trusted sources, Exclusive POV.  
**Target:** 60% of priority articles get AI mentions within 1 week of optimization.

### 3A: Schema Implementation

| # | Title | Priority | Status |
|---|-------|----------|--------|
| [#56](https://github.com/brightdigit/brightdigit.com/issues/56) | Evaluate correct schema.org types for each content section | P0-critical | Open |
| [#18](https://github.com/brightdigit/brightdigit.com/issues/18) | Add seomachine.io integration | P1-high | Open |
| [#19](https://github.com/brightdigit/brightdigit.com/issues/19) | Implement FAQ Schema Markup in `PiHTMLFactory` | P0-critical | In Progress |
| [#20](https://github.com/brightdigit/brightdigit.com/issues/20) | Implement HowTo Schema Markup in `PiHTMLFactory` | P1-high | Open |

**Note:** [#56](https://github.com/brightdigit/brightdigit.com/issues/56) must be resolved before [#19](https://github.com/brightdigit/brightdigit.com/issues/19) and [#20](https://github.com/brightdigit/brightdigit.com/issues/20) — schema type selection drives the implementation.

**Implementation files:**
- `Sources/PublishType/PageContent.swift` — add `schemaMarkup: String?` requirement (`PublishType` owns the protocol contract)
- `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift` — `head(forPage:)` emits `<script type="application/ld+json">` when `schemaMarkup` is non-nil
- `Sources/BrightDigitSite/PiHTMLFactory.swift` — main factory (not a protocol)
- `Sources/BrightDigitSite/BrightDigitSite.swift` — extend `ItemMetadata` with `faqItems: [FAQItem]?`, `howToSteps: [HowToStep]?`
- Each `Sources/BrightDigitSite/Nodes/Section/*.swift` — implement `schemaMarkup` (the `BrightDigitSite` layer provides the concrete values)

**Integration architecture:**
- `PublishType` defines the requirement; `BrightDigitSite` types fulfill it — consistent with the existing layering throughout the codebase
- Adding `schemaMarkup: String?` to `PageContent` is additive and does not conflict with the Phase 5 component migration (which rewrites how content is built, not the protocol shape)
- Schema types per section (auto-generated from existing metadata unless noted):
  - Articles → `Article` (title, description, date, featuredImage — zero new front matter)
  - Tutorials → `HowTo` (requires `howToSteps` front matter array, or extracted from `##` headings)
  - Products → `SoftwareApplication` (platforms, technologies, appStoreURL, githubRepoName)
  - FAQ pages → `FAQPage` (requires `faqItems` front matter array)
  - Index / About-Us → `Organization` (hardcoded BrightDigit metadata)
- The `.claude/ai-cite-optimization/` docs already define `FAQSchema`, `HowToSchema`, `ArticleSchema`, `Person`, `Organization`, `ImageObject` structures — wire these to the Swift build

**Note:** FAQ and HowTo schemas are most valuable for AI citations. `Article` and `SoftwareApplication` schemas provide additional richness at zero content-authoring cost since all required fields already exist in `ItemMetadata`.

### 3B: Validation

| # | Title | Priority | Status |
|---|-------|----------|--------|
| [#23](https://github.com/brightdigit/brightdigit.com/issues/23) | Test AI-CITE Baseline and Validate Schema | P1-high | Open |

**Reference:** `.claude/ai-cite-optimization/`

---

## Phase 4: OpenAPI & Dependency Migration

**Goal:** Replace SwagGen + Prch with Apple's swift-openapi-generator and async/await throughout. Replace other stale dependencies.

**Estimated effort:** 4–6 weeks  
**Dependency:** Phase 2 (Swift 6.3 main package).

| # | Title | Notes |
|---|-------|-------|
| [#45](https://github.com/brightdigit/brightdigit.com/issues/45) | Replace Prch with swift-openapi-* | First step — unblocks async/await everywhere |
| [#37](https://github.com/brightdigit/brightdigit.com/issues/37) | OpenAPI Generator Migration (SwiftTube + Spinetail) | ~521 generated files replaced; rewrites `ContributeYouTube` and `ContributeMailchimp` |
| [#40](https://github.com/brightdigit/brightdigit.com/issues/40) | Replace Ink **and** MarkdownGenerator with swift-markdown | swift-markdown is the single replacement for both libraries: parsing (was Ink, used transitively via Publish's markdown pipeline) and generation (was MarkdownGenerator in `Tagscriber/KannaMarkdownGenerator.swift`). Covers both via its public block/inline initializers + `MarkupFormatter`. This is the parsing/emission swap only — the input-side Kanna → SwiftSoup migration is tracked separately under [#47](https://github.com/brightdigit/brightdigit.com/issues/47) and can land in either order. |
| [#41](https://github.com/brightdigit/brightdigit.com/issues/41) | ~~Replace ShellOut with swift-subprocess (Tagscriber)~~ | **Obsolete.** The `Tagscriber` target and its ShellOut-backed `PandocMarkdownGenerator` are removed (see [#47](https://github.com/brightdigit/brightdigit.com/issues/47)); HTML→Markdown is now in-process via `SwiftSoupMarkdownGenerator`, so there is no ShellOut/pandoc usage left to migrate. |
| [#46](https://github.com/brightdigit/brightdigit.com/issues/46) | Replace ShellOut with swift-subprocess (Publish/NPMPublishPlugin) | Affects subrepos — NPMPublishPlugin currently runs `npm ci` + `npm run publish` in `Styling/` via ShellOut; replacing ShellOut requires updating the plugin itself. If node-swift ([#51](https://github.com/brightdigit/brightdigit.com/issues/51)) is viable it may eliminate NPMPublishPlugin entirely (run npm via native Node.js embedding). |
| [#47](https://github.com/brightdigit/brightdigit.com/issues/47) | SwiftSoup-based generator replaces Pandoc | `KannaMarkdownGenerator` → `SwiftSoupMarkdownGenerator` (pure-Swift SwiftSoup + swift-markdown, no external `pandoc` binary). The generator now lives in the **Contribute** package (not `Tagscriber`, which is deleted) so it can replace `PandocMarkdownGenerator` across Contribute/ContributeWordPress. `PandocMarkdownGenerator` and its ShellOut wiring are removed entirely. |
| [#44](https://github.com/brightdigit/brightdigit.com/issues/44) | Replace swift-argument-parser with swift-configuration | Affects all 7 files in `BrightDigitArgs/` |

**Dependency decisions:**

| Dependency | Decision | Reason |
|---|---|---|
| Ink | ✅ Replace with swift-markdown | Transitive via Publish subrepo |
| ShellOut | ✅ Replace with swift-subprocess | Official Apple framework |
| Kanna | ✅ Replace with SwiftSoup (tracked under [#47](https://github.com/brightdigit/brightdigit.com/issues/47)) | Used in `Tagscriber/KannaMarkdownGenerator.swift` for HTML traversal (tag names, text, attributes, child selection). SwiftSoup is a pure Swift Linux-compatible replacement — XPath swaps for CSS selectors, properties become method calls. Rename `KannaMarkdownGenerator` → `SwiftSoupMarkdownGenerator`. Independent of [#40](https://github.com/brightdigit/brightdigit.com/issues/40); the two halves of the file (HTML parsing vs Markdown emission) can be migrated in separate PRs. |
| MarkdownGenerator | ✅ Replace with swift-markdown (part of [#40](https://github.com/brightdigit/brightdigit.com/issues/40)) | `eneko/MarkdownGenerator` is stale (v1.1.0, Jan 2021, Swift 4.0+) and used by only one file, `Sources/Tagscriber/KannaMarkdownGenerator.swift`. swift-markdown supports programmatic construction — `Heading`, `Paragraph`, `CodeBlock`, `BlockQuote`, `UnorderedList`/`OrderedList`, `Image`, `Link`, `Emphasis`, `Strong` all expose public initializers — and `MarkupFormatter` renders a `Markup` tree back to CommonMark. Swift 6 concurrency-ready (immutable value types), Linux-compatible. Net dependency delta: −1 (swift-markdown is already added by [#40](https://github.com/brightdigit/brightdigit.com/issues/40) for the Ink replacement, so MarkdownGenerator's removal piggybacks for free). The Kanna → SwiftSoup rename is a separate step under [#47](https://github.com/brightdigit/brightdigit.com/issues/47). |
| Yams | ❌ Keep | Foundation has no YAML support |

**Target architecture after Phase 4:**
- `swift-openapi-generator` produces protocol-based async clients for YouTube and Mailchimp APIs
- `swift-openapi-runtime` + `swift-openapi-urlsession` replace `Prch` entirely
- `DispatchSemaphore`/`DispatchGroup` replaced with `async/await` + `TaskGroup`
- `BrightDigitArgs` commands updated for async execution

**Success criteria:**
- `SwiftTube 1.0.0` and `Spinetail 1.0.0` released with swift-openapi-generator
- Full newsletter import (113 newsletters) + podcast import produces identical markdown output
- CI/CD content automation job passes
- Optionally: implement [#1](https://github.com/brightdigit/brightdigit.com/issues/1) (Skip Campaign Download For Existing Newsletters) as part of this migration

---

## Phase 5: Swift 6.3 Subrepos + Component Migration + Mermaid

**Goal:** Upgrade all 17 subrepos to Swift 6.3 strict concurrency. Migrate `PiHTMLFactory` and all `Nodes/` files to a component-based Plot API. Add Mermaid diagram support.

**Estimated effort:** 5–7 weeks  
**Dependency:** Phase 4.

> **High Impact Warning:** This phase substantially rewrites `PiHTMLFactory` and all `Nodes/` files.

**Plot API context:** Plot has two coexisting APIs. The **Node API** (`Node<HTML.BodyContext>`) is lower-level and functional — used throughout `Nodes/`. The **Component API** (`Component` protocol, SwiftUI-style `var body: Component`) is declarative and already used in `Components/` (SectionElement, ServiceBox, Icon, ListItem) and in `ServicesBuilder.swift` and `ProductItem.swift`. Nodes conform to `Component`; components bridge back via `.convertToNode()`.

**Migration approach:** Keep `PageContent.main` as `[Node<HTML.BodyContext>]`; leaf components call `.convertToNode()` at the boundary. This matches the pattern already established in `ProductItem.swift` and avoids a `PageContent` protocol break. The `schemaMarkup: String?` property added to `PageContent` in Phase 3 carries forward unchanged.

**Migration order:** (1) header/footer in `PiHTMLFactory.HTML.swift` (affects every page), (2) `Nodes/Section/` item content files, (3) `Nodes/Pages/` builders.

**[#53](https://github.com/brightdigit/brightdigit.com/issues/53) enforcement:** No direct `Node<HTML.BodyContext>` construction in `BrightDigitSite` — all HTML must flow through a `Component`. Enforcement mechanism TBD (SwiftLint custom rule or build-time assertion).

**TailwindKit module:** "Create library for easy Tailwind access" means a new Swift module that maps to Tailwind utility class names (e.g., `.bg(.blue, .500)` → `"bg-blue-500"`), providing compile-time safety for CSS classes used in components.

| # | Title | Status |
|---|-------|--------|
| [#38](https://github.com/brightdigit/brightdigit.com/issues/38) | Swift 6.3 Language Mode + Component Migration + Mermaid Support | Open |
| [#53](https://github.com/brightdigit/brightdigit.com/issues/53) | Enforce component-based Plot API (no direct Node creation) | Open |
| TBD | Upgrade Tailwind + `TailwindKit` Swift module for type-safe class names | Open |
| [#24](https://github.com/brightdigit/brightdigit.com/issues/24) | YouTube Video Content Strategy | Open |
| [#25](https://github.com/brightdigit/brightdigit.com/issues/25) | Create Unique BrightDigit Frameworks/Methodologies | Open |

**Buttondown newsletter/email work (pulled forward from Phase 6 — high priority; sibling phase, both gated only on Phase 4):**

| # | Title | Priority | Status |
|---|-------|----------|--------|
| [#124](https://github.com/brightdigit/brightdigit.com/issues/124) | ButtondownClient: expose `listEmails` (paged) | P0-critical | Open — foundational; blocks #122, #127 |
| [#122](https://github.com/brightdigit/brightdigit.com/issues/122) | Import published newsletters from Buttondown (`import buttondown`) | P1-high | Open — blocked by #124; new issues only |
| [#127](https://github.com/brightdigit/brightdigit.com/issues/127) | Fix HTML of MailChimp-imported emails hosted in Buttondown (REST API) | P1-high | Open — needs #124 + `updateEmail` wrapper |
| [#126](https://github.com/brightdigit/brightdigit.com/issues/126) | Point subscribe form at Buttondown | P1-high | Open — decoupled from the component migration (uses Plot static factories, not the `Node()` init restricted by #53) |

**Swift 6.3 subrepo upgrades (17 total):**
- Publish ecosystem (8): Publish, Plot, Files, Codextended, Sweep, CollectionConcurrencyKit, Splash, SplashPublishPlugin
- BrightDigit packages (7): SwiftTube 2.0.0, Spinetail 2.0.0, SyndiKit 1.0.0, NPMPublishPlugin, Contribute 2.0.0, ContributeWordPress, TransistorPublishPlugin
- Forked plugins (2): YoutubePublishPlugin, ReadingTimePublishPlugin

**Component-Based Plot API — Files Affected:**

| File | Lines | Change |
|------|-------|--------|
| `Sources/BrightDigitSite/PiHTMLFactory.swift` | 129 | Refactored to use components |
| `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift` | 242 | Substantially rewritten |
| `Sources/BrightDigitSite/Nodes/Pages/` (4 files) | — | Converted to components |
| `Sources/BrightDigitSite/Nodes/Section/` (5 files) | — | Converted to components |
| `Sources/BrightDigitSite/Nodes/Social/` (7 files) | — | Converted to components |

**New components in `Sources/BrightDigitSite/Components/`:**
- Layout: `HeaderComponent`, `FooterComponent`, `NavigationComponent`, `PageLayoutComponent`
- Content: `ArticleCardComponent`, `NewsletterItemComponent`, `PodcastEpisodeComponent`, `TutorialItemComponent`, `ProductCardComponent`

**AI-CITE Content Strategy (post-migration):**
- [#24](https://github.com/brightdigit/brightdigit.com/issues/24) and [#25](https://github.com/brightdigit/brightdigit.com/issues/25) align with the refactored AI-CITE integration into Publish/BrightDigitSite — execute after component migration is stable.

**Mermaid Support:**
- Detect `mermaid` code blocks and wrap in `<div class="mermaid">` instead of `<pre><code>`
- Add mermaid.js CDN script to HTML `<head>`

**Success criteria:**
- Zero concurrency warnings across all 17 subrepos
- `swift build` with Swift 6.3 strict mode passes on macOS and Ubuntu
- Site output byte-for-byte identical (excluding mermaid blocks — visual verification)

---

## Phase 6: Publishing Infrastructure

**Goal:** Replace the Mailchimp-based newsletter workflow with a Buttondown + Buffer Swift CLI. Enable video podcast publishing.

**Dependency:** Phase 4 (swift-openapi-generator toolchain available).

> **Moved to Phase 5:** The inbound email-import + hosted-HTML-cleanup chain
> ([#124](https://github.com/brightdigit/brightdigit.com/issues/124),
> [#122](https://github.com/brightdigit/brightdigit.com/issues/122),
> [#127](https://github.com/brightdigit/brightdigit.com/issues/127)) and the subscribe form
> ([#126](https://github.com/brightdigit/brightdigit.com/issues/126)) were pulled forward into
> Phase 5 as high-priority Buttondown work. This phase retains the **outbound** publishing leg
> and social/video below.

| # | Title | Status |
|---|-------|--------|
| [#33](https://github.com/brightdigit/brightdigit.com/issues/33) | Swift Publishing Tool: Buttondown + Buffer Architecture | Open |
| [#31](https://github.com/brightdigit/brightdigit.com/issues/31) | Migrate Newsletters | Open |
| [#30](https://github.com/brightdigit/brightdigit.com/issues/30) | Public Buffer API | Open |
| [#32](https://github.com/brightdigit/brightdigit.com/issues/32) | Video Podcasts | Open |
| [#49](https://github.com/brightdigit/brightdigit.com/issues/49) | Support AT Protocol | Open — feeds posts into Buffer |

**Architecture ([#33](https://github.com/brightdigit/brightdigit.com/issues/33)):**

New source modules (local to this repo, not subrepos):

| Module | Purpose | Implementation |
|--------|----------|----------------|
| `PublishKit` | Core orchestrator + protocol definitions (`SubscriberListProvider`, `NewsletterSender`) | — |
| `ButtondownKit` | Newsletter transport | swift-openapi-generator from official Buttondown OpenAPI 3.0.2 spec |
| `MailgunKit` | Sender-only transport (no list management) | Composable with any `SubscriberListProvider` |
| `BufferKit` | Social: X/Twitter, LinkedIn, Mastodon, etc. — accepts AT Protocol records as input | Handwritten GraphQL + Codable (no code gen) |
| `ATProtoKit` | Compose posts as AT Protocol records (`app.bsky.feed.post`) for Buffer fan-out ([#49](https://github.com/brightdigit/brightdigit.com/issues/49)) | Reference: [A Social Filesystem](https://overreacted.io/a-social-filesystem/) |

**Why Buttondown:** Two REST calls to send an issue (`POST /emails`, `POST /emails/{id}/send-draft`). Subscriber management and CAN-SPAM compliance are platform-managed — no audience data stored in this repo.

**Why Buffer:** Single GraphQL mutation fans out to all social platforms. No per-platform OAuth.

**HTTP transport:** All clients use `ClientTransport` from `swift-openapi-runtime` — `AsyncHTTPClientTransport` on Linux (CI/CD), `URLSessionTransport` on Apple platforms.

**Notes:**
- [#31](https://github.com/brightdigit/brightdigit.com/issues/31) (newsletter migration) follows after [#33](https://github.com/brightdigit/brightdigit.com/issues/33) tooling is complete
- [#30](https://github.com/brightdigit/brightdigit.com/issues/30) (Buffer API) is a prerequisite for [#33](https://github.com/brightdigit/brightdigit.com/issues/33)'s social publishing leg
- [#49](https://github.com/brightdigit/brightdigit.com/issues/49) (AT Protocol) authors posts as `app.bsky.feed.post` records that `BufferKit` consumes — single canonical post format fans out across networks
- Subscriber data stays on Buttondown's servers — nothing stored in this repo

---

## Phase 7: Platform Migration

**Goal:** Migrate hosting to GitHub Pages and add AT Protocol support.

| # | Title | Notes |
|---|-------|-------|
| [#50](https://github.com/brightdigit/brightdigit.com/issues/50) | Migrate to GitHub Pages | Currently deployed via Netlify |
| TBD | New form integration: contact us + subscribe button (Buttondown?) | New GitHub issue(s) needed; evaluate contact form and subscribe button as part of Buttondown migration |

---

## Phase 8: Final Cleanup

**Goal:** Low-priority cleanup deferred until core work is stable.

| # | Title | Notes |
|---|-------|-------|
| [#34](https://github.com/brightdigit/brightdigit.com/issues/34) | Remove or repurpose Import/Wordpress XML files | Clean up leftover import artifacts |
| [#1](https://github.com/brightdigit/brightdigit.com/issues/1) | Skip Campaign Download For Existing Newsletters | Should be implemented as part of `ButtondownKit` integration (Phase 6) |
| [#51](https://github.com/brightdigit/brightdigit.com/issues/51) | Research node-swift | Evaluate [kabiroberai/node-swift](https://github.com/kabiroberai/node-swift); prerequisite for NPMPublishPlugin ShellOut replacement ([#46](https://github.com/brightdigit/brightdigit.com/issues/46)) — evaluate before implementing Phase 4 [#46](https://github.com/brightdigit/brightdigit.com/issues/46) |

---

## Post-Migration Content Tasks

**Goal:** Pure content edits and article optimization — no code changes required. Deferred until the schema pipeline (Phase 3A + Swift migration) is stable.

**Note:** Apply the `article-edit` GitHub label to all issues below to distinguish from migration/code issues.

### Article Edits (formerly Phase 0B)

| # | Title | Status |
|---|-------|--------|
| [#3](https://github.com/brightdigit/brightdigit.com/issues/3) | Add Additional Local Storage Options | Open |
| [#4](https://github.com/brightdigit/brightdigit.com/issues/4) | Add Main Actor to Swift 6 Article Solution | Open |
| [#13](https://github.com/brightdigit/brightdigit.com/issues/13) | Clarify String vs Reference design choice in MistKit article | Open |

### Article Optimization (formerly Phase 1B)

| # | Title | Priority | Status |
|---|-------|----------|--------|
| [#21](https://github.com/brightdigit/brightdigit.com/issues/21) | Optimize Mise Setup Guide for AI-CITE | P1-high | Open |
| [#22](https://github.com/brightdigit/brightdigit.com/issues/22) | Optimize Best Backend Article for AI-CITE | P1-high | Open |
| [#26](https://github.com/brightdigit/brightdigit.com/issues/26) | Optimize iOS CI/CD Article for AI-CITE | P1-high | Open |
| [#27](https://github.com/brightdigit/brightdigit.com/issues/27) | Optimize iOS Architecture Article for AI-CITE | P1-high | Open |
| [#28](https://github.com/brightdigit/brightdigit.com/issues/28) | Optimize Remaining Priority Articles (Batch) | P1-high | Open |

**Dependency:** Phase 3A ([#19](https://github.com/brightdigit/brightdigit.com/issues/19) schema implementation) must be complete and stable before article optimization begins.

---

## Excluded Issues

| # | Title | Reason |
|---|-------|--------|
| [#12](https://github.com/brightdigit/brightdigit.com/issues/12) | Make Repo Public | Already completed |

---

## Issue Count by Phase

| Phase | Issues | Notes |
|-------|--------|-------|
| Phase 0 | 2 | Quick wins |
| Phase 1 | 0 | Monorepo cleanup ([#36](https://github.com/brightdigit/brightdigit.com/issues/36) already done; MarkdownGenerator removal folded into Phase 4 [#40](https://github.com/brightdigit/brightdigit.com/issues/40); [#47](https://github.com/brightdigit/brightdigit.com/issues/47) retitled and moved to Phase 4) |
| Phase 2 | 4 | Swift 6.3 main package + lint config ([#54](https://github.com/brightdigit/brightdigit.com/issues/54)) + CI cache ([#65](https://github.com/brightdigit/brightdigit.com/issues/65)) + rebuild-avoidance (TBD) |
| Phase 3 | 5 | AI-CITE schema ([#56](https://github.com/brightdigit/brightdigit.com/issues/56), [#18](https://github.com/brightdigit/brightdigit.com/issues/18), [#19](https://github.com/brightdigit/brightdigit.com/issues/19), [#20](https://github.com/brightdigit/brightdigit.com/issues/20)) + validation ([#23](https://github.com/brightdigit/brightdigit.com/issues/23)) |
| Phase 4 | 7 | OpenAPI migration + Kanna → SwiftSoup ([#47](https://github.com/brightdigit/brightdigit.com/issues/47)) |
| Phase 5 | 5 | Swift 6.3 subrepos + components + Tailwind (TBD) + AI-CITE content strategy ([#24](https://github.com/brightdigit/brightdigit.com/issues/24), [#25](https://github.com/brightdigit/brightdigit.com/issues/25)) |
| Phase 6 | 5 | Publishing infrastructure + AT Protocol ([#49](https://github.com/brightdigit/brightdigit.com/issues/49)) feeds Buffer |
| Phase 7 | 2 | Platform migration + form integration (TBD) |
| Phase 8 | 3 | Deferred cleanup |
| Post-Migration | 8 | Article edits ([#3](https://github.com/brightdigit/brightdigit.com/issues/3), [#4](https://github.com/brightdigit/brightdigit.com/issues/4), [#13](https://github.com/brightdigit/brightdigit.com/issues/13)) + article optimization ([#21](https://github.com/brightdigit/brightdigit.com/issues/21), [#22](https://github.com/brightdigit/brightdigit.com/issues/22), [#26](https://github.com/brightdigit/brightdigit.com/issues/26), [#27](https://github.com/brightdigit/brightdigit.com/issues/27), [#28](https://github.com/brightdigit/brightdigit.com/issues/28)) |
| **Total** | **41** | Excludes [#12](https://github.com/brightdigit/brightdigit.com/issues/12) (done), [#36](https://github.com/brightdigit/brightdigit.com/issues/36) (done), [#43](https://github.com/brightdigit/brightdigit.com/issues/43) (dropped); includes 3 TBD issues awaiting GitHub creation (Phase 2 rebuild-avoidance, Phase 5 Tailwind, Phase 7 form integration) |
