# BrightDigit.com — Product Requirements Document

**Repository:** brightdigit/brightdigit.com  
**Last Updated:** 2026-07-09  
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
Phase 3 (AI-CITE content optimization) ─ requires Phase 2 (intentional: implement after Swift 6.3 upgrade)
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

**Goal:** Get BrightDigit content cited by AI systems (ChatGPT, Claude, Perplexity, Google AI Overview) by optimizing content around the **evidence-backed** AI-citation levers, plus the small set of site-level tasks that support them. Sequenced after Phase 2 (Swift 6.3) so content/code work isn't redone across that boundary.

> **⚠️ Evidence reframe (2026-07).** This phase was originally schema-markup-first (JSON-LD in `PiHTMLFactory`). The GEO Evidence Review in the `llm-ready-web` research repo ([`brightdigit/llm-ready-web`](https://github.com/brightdigit/llm-ready-web) `main`) — 300k+ domain studies + Google's own guidance — establishes that **schema/JSON-LD is not a proven AI-citation lever** (Google: *"there's no special schema.org markup you need to add"*; FAQ rich results deprecated 2023–24) and that **`llms.txt` has null effect**. The AI-CITE framework consequently **removed its "Indexed Schema" element**. The old schema issues (#19 FAQ, #20 HowTo, #56 schema-types, #18 seomachine.io) are **closed as `wontfix`**, and the retired `PiHTMLFactory` JSON-LD plan is gone. This phase now tracks the proven levers instead.

**Framework:** AI-CITE (5 elements) — **A**nswer-first · **I**ntent-matched headings · **C**lear structure (lists/tables) · **T**rusted sources (citations) · **E**xclusive POV.
**Proven levers (ranked):** citations/quotes/statistics (up to +40%) · answer-first placement (first third of page) · question-style headings · crawlability (the one technical must-have).
**Target:** 6/10 priority queries surface a BrightDigit mention within 2–3 weeks of optimization (source-reported "60% in a week" is a directional target, not independently verified).

### 3A: Content optimization (per-article — the proven levers)

Answer-first rewrites, question-style headings, comparison tables, and authoritative citations on the priority "money articles." Moved into Phase 3 from the former "Post-Migration: Content & Articles" milestone (the schema dependency gate is gone, so these are immediately actionable).

| # | Title | Priority | Status |
|---|-------|----------|--------|
| [#21](https://github.com/brightdigit/brightdigit.com/issues/21) | Optimize Mise Setup Guide for AI-CITE | P1-high | Open |
| [#22](https://github.com/brightdigit/brightdigit.com/issues/22) | Optimize Best Backend Article for AI-CITE | P1-high | Open |
| [#26](https://github.com/brightdigit/brightdigit.com/issues/26) | Optimize iOS CI/CD Article for AI-CITE | P1-high | Open |
| [#27](https://github.com/brightdigit/brightdigit.com/issues/27) | Optimize iOS Architecture Article for AI-CITE | P1-high | Open |
| [#28](https://github.com/brightdigit/brightdigit.com/issues/28) | Optimize Remaining Priority Articles (Batch) | P1-high | Open |
| [#130](https://github.com/brightdigit/brightdigit.com/issues/130) | Split `dependency-management-swift` into two answer-first pages | P1-high | Open |

### 3B: Site-level tasks

| # | Title | Priority | Status |
|---|-------|----------|--------|
| [#129](https://github.com/brightdigit/brightdigit.com/issues/129) | Fix misleading freshness signal: real publish/`dateModified` dates sitewide | P0-critical | Open |
| [#131](https://github.com/brightdigit/brightdigit.com/issues/131) | Add `robots.txt` with a `Sitemap:` line | P2-medium | Open |
| [#132](https://github.com/brightdigit/brightdigit.com/issues/132) | Normalize brand name ("BrightDigit") sitewide | P2-medium | Open |

**#129 is the one surviving `PiHTMLFactory` code task:** the footer at `Sources/BrightDigitSite/Nodes/Node+HTML.swift:187-191` renders `.year()` (current build year) as a false freshness signal; replace it and surface real per-page dates (`item.metadata.date` already exists across `Nodes/Section/*`). Crawlability is otherwise good (server-rendered, `index,follow` meta emitted, valid sitemap); #131 just adds the `Sitemap:` pointer.

### 3C: Measurement

| # | Title | Priority | Status |
|---|-------|----------|--------|
| [#23](https://github.com/brightdigit/brightdigit.com/issues/23) | Establish AI-citation baseline test | P1-high | Open |

Run the 10-query baseline (ChatGPT/Claude/Perplexity + Google AI Overview) **before** the content work lands, then re-test weekly. No schema validation.

**Reference:** `brightdigit/llm-ready-web` `main` — `resources/geo-evidence-review.md`, `resources/ai-cite-framework.md`, `case-studies/brightdigit-ai-cite/`.

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

**Migration approach:** Keep `PageContent.main` as `[Node<HTML.BodyContext>]`; leaf components call `.convertToNode()` at the boundary. This matches the pattern already established in `ProductItem.swift` and avoids a `PageContent` protocol break. (The `schemaMarkup: String?` property once planned for Phase 3 is no longer being added — the schema work was retired in the 2026-07 evidence reframe — so there is nothing extra to carry through this migration.)

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

**Goal:** Pure content edits — no code changes required. (The AI-CITE **article optimization** issues formerly listed here — #21/#22/#26/#27/#28 — moved into **Phase 3** as part of the 2026-07 evidence reframe; see Phase 3 §3A.)

**Note:** Apply the `article-edit` GitHub label to all issues below to distinguish from migration/code issues.

### Article Edits (formerly Phase 0B)

| # | Title | Status |
|---|-------|--------|
| [#3](https://github.com/brightdigit/brightdigit.com/issues/3) | Add Additional Local Storage Options | Open |
| [#4](https://github.com/brightdigit/brightdigit.com/issues/4) | Add Main Actor to Swift 6 Article Solution | Open |
| [#13](https://github.com/brightdigit/brightdigit.com/issues/13) | Clarify String vs Reference design choice in MistKit article | Open |

---

## Content Ops

**Goal:** Build a content-planning / scaffolding infrastructure so Claude Code can *guide* future content across every medium/platform without writing full drafts. Full design in [`docs/content-ops-plan.md`](docs/content-ops-plan.md).

**Milestone:** Content Ops — a post-migration milestone that runs alongside the migration phases where related, and is **not** gated on the active Phase 3 AI-CITE article work. The planning layer (schema/spec/briefs/skill) lands here; the publish/fan-out leg ([#140](https://github.com/brightdigit/brightdigit.com/issues/140)) lives in **Phase 6** because it depends on the Buttondown/Buffer/AT modules.

| # | Title | Priority | Depends on |
|---|-------|----------|-----------|
| [#135](https://github.com/brightdigit/brightdigit.com/issues/135) | Cross-media link schema on published items (Swift types) | P1-high | — (foundational) |
| [#136](https://github.com/brightdigit/brightdigit.com/issues/136) | Swift-type → companion-spec generator | P1-high | #135 |
| [#137](https://github.com/brightdigit/brightdigit.com/issues/137) | Canonical topic-entity definition (private-only records) | P2-medium | relates #135 |
| [#138](https://github.com/brightdigit/brightdigit.com/issues/138) | Per-medium/platform content briefs (scaffolds, not drafts) | P1-high | #135, #136 |
| [#139](https://github.com/brightdigit/brightdigit.com/issues/139) | Portable `/content-plan` skill | P1-high | #135, #136, #138 |

**Note (#135 / Phase 5 overlap):** #135 adds additive `ItemMetadata` fields — coordinate with the Phase 5 component migration ([#67](https://github.com/brightdigit/brightdigit.com/issues/67), [#53](https://github.com/brightdigit/brightdigit.com/issues/53)); additive fields don't conflict with the component rewrite (same rationale the PRD used for the retired `schemaMarkup` field).

**Phase 6 leg:** [#140](https://github.com/brightdigit/brightdigit.com/issues/140) — Wire the content plan to the publish + fan-out pipeline (depends on #135–#139 + [#33](https://github.com/brightdigit/brightdigit.com/issues/33)/[#31](https://github.com/brightdigit/brightdigit.com/issues/31)/[#30](https://github.com/brightdigit/brightdigit.com/issues/30)/[#49](https://github.com/brightdigit/brightdigit.com/issues/49)).

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
| Phase 3 | 10 | AI-CITE content optimization (evidence reframe): articles [#21](https://github.com/brightdigit/brightdigit.com/issues/21)/[#22](https://github.com/brightdigit/brightdigit.com/issues/22)/[#26](https://github.com/brightdigit/brightdigit.com/issues/26)/[#27](https://github.com/brightdigit/brightdigit.com/issues/27)/[#28](https://github.com/brightdigit/brightdigit.com/issues/28) + split [#130](https://github.com/brightdigit/brightdigit.com/issues/130); site-level dates [#129](https://github.com/brightdigit/brightdigit.com/issues/129)/robots [#131](https://github.com/brightdigit/brightdigit.com/issues/131)/brand [#132](https://github.com/brightdigit/brightdigit.com/issues/132); baseline [#23](https://github.com/brightdigit/brightdigit.com/issues/23). Schema issues #19/#20/#56/#18 **closed as wontfix** |
| Phase 4 | 7 | OpenAPI migration + Kanna → SwiftSoup ([#47](https://github.com/brightdigit/brightdigit.com/issues/47)) |
| Phase 5 | 5 | Swift 6.3 subrepos + components + Tailwind (TBD) + AI-CITE content strategy ([#24](https://github.com/brightdigit/brightdigit.com/issues/24), [#25](https://github.com/brightdigit/brightdigit.com/issues/25)) |
| Phase 6 | 6 | Publishing infrastructure + AT Protocol ([#49](https://github.com/brightdigit/brightdigit.com/issues/49)) feeds Buffer; + content-plan fan-out wiring ([#140](https://github.com/brightdigit/brightdigit.com/issues/140)) |
| Phase 7 | 2 | Platform migration + form integration (TBD) |
| Phase 8 | 3 | Deferred cleanup |
| Post-Migration | 3 | Article edits ([#3](https://github.com/brightdigit/brightdigit.com/issues/3), [#4](https://github.com/brightdigit/brightdigit.com/issues/4), [#13](https://github.com/brightdigit/brightdigit.com/issues/13)); article-optimization issues moved to Phase 3 |
| Content Ops | 5 | Content-planning infrastructure ([docs/content-ops-plan.md](docs/content-ops-plan.md)): cross-media link schema ([#135](https://github.com/brightdigit/brightdigit.com/issues/135)), spec generator ([#136](https://github.com/brightdigit/brightdigit.com/issues/136)), topic entity ([#137](https://github.com/brightdigit/brightdigit.com/issues/137)), briefs ([#138](https://github.com/brightdigit/brightdigit.com/issues/138)), `/content-plan` skill ([#139](https://github.com/brightdigit/brightdigit.com/issues/139)). Post-migration milestone; fan-out leg ([#140](https://github.com/brightdigit/brightdigit.com/issues/140)) lives in Phase 6 |
| **Total** | **47** | Excludes [#12](https://github.com/brightdigit/brightdigit.com/issues/12) (done), [#36](https://github.com/brightdigit/brightdigit.com/issues/36) (done), [#43](https://github.com/brightdigit/brightdigit.com/issues/43) (dropped), and the 4 schema issues [#19](https://github.com/brightdigit/brightdigit.com/issues/19)/[#20](https://github.com/brightdigit/brightdigit.com/issues/20)/[#56](https://github.com/brightdigit/brightdigit.com/issues/56)/[#18](https://github.com/brightdigit/brightdigit.com/issues/18) (closed wontfix, 2026-07); Phase 3 gained 4 new issues ([#129](https://github.com/brightdigit/brightdigit.com/issues/129)–[#132](https://github.com/brightdigit/brightdigit.com/issues/132)). New **Content Ops** milestone + 6 content-plan issues ([#135](https://github.com/brightdigit/brightdigit.com/issues/135)–[#140](https://github.com/brightdigit/brightdigit.com/issues/140)) added 2026-07-09. Includes 3 TBD issues awaiting GitHub creation (Phase 2 rebuild-avoidance, Phase 5 Tailwind, Phase 7 form integration) |
