# BrightDigit.com — Product Requirements Document

**Repository:** brightdigit/brightdigit.com  
**Last Updated:** 2026-08-04  
**Status:** Living document — reflects current open issues

---

## Overview

This document organizes all open GitHub issues into phases. The work spans four major concerns:

1. **Content & AI citation** — evidence-backed article optimization and article edits
2. **Infrastructure Modernization** — Swift 6.4, package extraction, repo boundaries
3. **Publishing Pipeline** — Buttondown + Buffer integration, newsletter/podcast tooling
4. **Platform Migration** — GitHub Pages, AT Protocol support

### Phase organization: one quadrant per phase

**Every phase occupies exactly one quadrant** of {**content**, **code**} × {**this-repo**,
**external-repo**}. A phase never mixes article writing with Swift work, and never mixes work
contained in this repo with work that requires touching another repo. This makes "what content
work is ready?" and "what needs an external repo?" answerable from the milestone list alone.

The phases were renumbered on **2026-07-28** to enforce this. Phases 0–2 and 4 (Swift 6.4 main
package, monorepo cleanup, OpenAPI migration) and the old Phase 5 (subrepos + components) are
**complete** and retained below as historical record; their original numbering is preserved in
those sections.

| Phase | Quadrant | Focus |
|---|---|---|
| **Phase 1** | code · external-repo | Package extraction & repo boundaries |
| **Phase 2** | content · this-repo | AI-CITE content optimization |
| **Phase 3** | code · this-repo | Site SEO code & measurement |
| **Phase 4** | content · external-repo | Content Ops planning layer |
| **Phase 5** | code · this-repo | Publishing infrastructure — internal |
| **Phase 6** | code · external-repo | Publishing infrastructure — external platforms |
| **Phase 7** | code · external-repo | Platform migration |
| **Phase 8** | code · this-repo | Final cleanup |
| **Phase 9** | code · external-repo | Upstream contributions |
| **Phase 10** | content · external-repo | Content authority & off-site |
| **Post-Migration** | content · this-repo | Article edits |
| **Site Defects** | code · this-repo | Live-site rendering bugs |
| **Documentation** | code · external-repo | READMEs, DocC, cross-repo docs |

### Dependency Chain

```text
Phase 1  (Package extraction)     ─── #168 → #169 → #136; unblocks Phase 4 + Documentation
Phase 2  (AI-CITE content)        ─── ready now; no code dependency — runs in parallel
Phase 3  (Site SEO code)          ─── independent; #167 follows #129
Phase 4  (Content Ops planning)   ─── requires Phase 1 (#169 defines the boundaries #139 needs)
Phase 5  (Publishing internal)    ─── #140 requires the Phase 4 planning layer
Phase 6  (Publishing external)    ─── siblings with Phase 5
Phase 7  (Platform migration)     ─── requires Phase 5/6
Phase 8  (Final cleanup)          ─── anytime, low priority
Phase 9  (Upstream contributions) ─── anytime
Phase 10 (Content authority)      ─── anytime; long-running
Documentation                     ─── requires Phase 1 (repo purposes change)
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

## Phase 1: Package Extraction & Repo Boundaries

**Quadrant:** code · external-repo · **Milestone:** Phase 1: Package Extraction & Repo Boundaries

**Goal:** Finish the repo split that de-vendoring started — extract the remaining Swift code into its own package repo, and turn the three-repo content/code arrangement from prose into an executable contract.

**Why this is Phase 1:** it is the only phase that *unblocks* others — Phase 4 (Content Ops) and Documentation both wait on it, and #136's spec generator cannot be honest about contract versions until `ItemMetadata` lives in a released package. Phase 2's content work has no dependency on it and **runs in parallel**; sequencing here is about clearing the blocker first, not about pausing the article rewrites.

**Context:** De-vendoring shipped in [#159](https://github.com/brightdigit/brightdigit.com/pull/159)/[#161](https://github.com/brightdigit/brightdigit.com/pull/161) (2026-07-28) — all 20 first-party packages are external released repos and `Packages/` is gone. `Sources/` is the last thing still mixing Swift code with content in this repo.

| # | Title | Priority | Depends on |
|---|-------|----------|-----------|
| [#168](https://github.com/brightdigit/brightdigit.com/issues/168) | Extract `Sources/` into a new `brightdigit/BrightDigitSite` package repo | P1-high | — |
| [#169](https://github.com/brightdigit/brightdigit.com/issues/169) | Define content-repo boundaries (three homes, two seams) | P1-high | #168 |
| [#135](https://github.com/brightdigit/brightdigit.com/issues/135) | Cross-media link schema on published items (Swift types) | P1-high | — (foundational) |
| [#136](https://github.com/brightdigit/brightdigit.com/issues/136) | Swift-type → companion-spec generator | P1-high | #135, #168, #169 |

### The three homes

| Repo | Visibility | Owns |
|---|---|---|
| `leogdion/year-in-review` | private | Topic/campaign **records**, per-medium drafts, voice + pillar guides, `/content-topic-mining` |
| `brightdigit/BrightDigitSite` | public *(new — #168)* | Swift code **and the `ItemMetadata` / `PublishType` contract** |
| `brightdigit/brightdigit.com` | public | Finished `Content/*.md` + site config; consumes the contract as a dependency |

Plus a fourth content destination worth writing down: **new tutorial/template content belongs in `brightdigit/Swift-App-Template`**, not here.

### The two seams

1. **Contract seam** (package repo → everywhere). [#136](https://github.com/brightdigit/brightdigit.com/issues/136) pulls the latest Swift type from the released `BrightDigitSite` package and emits the companion spec, which flows to `brightdigit.com` (publish-time validation) and `year-in-review` (drafts authored against current fields).
2. **Content seam** (`year-in-review` → `brightdigit.com`). **Only finished items plus their #135 link fields cross.** Topic records, briefs, and voice guides stay private.

**Why the extraction matters to #136:** today the generator would read `ItemMetadata` from a subfolder path. After #168 it resolves a **versioned package dependency** — so the generated spec can be honest about *which version* of the contract it describes. Per `.claude/docs/content-ops-plan.md`: *"Splitting the packages out actually strengthens I2: the source of truth is a released package, not a path."*

**Reconcile with the subrepo restore:** `AGENTS.md` states the subrepo model is canonical and gets restored for the `v2.0.0-alpha.2` cycle. #168 must decide explicitly whether `BrightDigitSite` is restored as a subrepo alongside the other 20 or stays a plain dependency.

---
## Phase 2: AI-CITE Content Optimization

**Quadrant:** content · this-repo · **Milestone:** Phase 2: AI-CITE Content Optimization

**Goal:** Get BrightDigit content cited by AI systems (ChatGPT, Claude, Perplexity, Google AI Overview) by rewriting the priority "money articles" around the **evidence-backed** citation levers. Pure content work — no code changes. Ready now; nothing gates it.

> **⚠️ Evidence reframe (2026-07).** This phase was originally schema-markup-first (JSON-LD in `PiHTMLFactory`). The GEO Evidence Review in the `llm-ready-web` research repo ([`brightdigit/llm-ready-web`](https://github.com/brightdigit/llm-ready-web) `main`) — 300k+ domain studies + Google's own guidance — establishes that **schema/JSON-LD is not a proven AI-citation lever** (Google: *"there's no special schema.org markup you need to add"*; FAQ rich results deprecated 2023–24) and that **`llms.txt` has null effect**. The AI-CITE framework consequently **removed its "Indexed Schema" element**. The old schema issues (#19 FAQ, #20 HowTo, #56 schema-types, #18 seomachine.io) are **closed as `wontfix`**, and the retired `PiHTMLFactory` JSON-LD plan is gone.

### The weighted model (supersedes the flat 5-element scorecard)

The elements are **not equally supported**. Score against the weighted table from the
[`geo-audit` skill](https://github.com/brightdigit/llm-ready-web/blob/main/tooling/skills/geo-audit/SKILL.md) (Step 4):

| Element | Weight | Check |
|---|---|---|
| Answer-first | ⭐⭐⭐ | Direct answer in the first third / first paragraph? |
| Question-style headings | ⭐⭐⭐ | H2/H3s phrased as the real user questions? |
| Trusted sources | ⭐⭐⭐ | Citations, quotations, statistics present? |
| Clear structure | ⭐⭐ | Lists/tables/comparisons, not walls of text? |
| Exclusive POV | ⭐⭐ | Original data, named framework, unique angle? |
| **No keyword stuffing** | ⭐⭐ | **Natural language — stuffing measurably hurts (~10%)** |

"No keyword stuffing" is a **sixth scored element** absent from the original 5-element framework.

### Cite the evidence, not the framework

AI-CITE is a **vendor conference framework** (Jesse Schoberg, DropInBlog, MicroConf Europe 2025).
Its headline claim — *"60% of customers got more mentions in a week"* — is single-vendor
self-reported data, the same evidence class the GEO Evidence Review **rejected** when it discarded
Seer Interactive's conversion stats (0 of 3 adversarial verification votes). The framework has
already been wrong once and corrected (the retired schema element).

What is independently supported comes from [**Princeton GEO** (arXiv:2311.09735)](https://arxiv.org/abs/2311.09735)
and [**Google's AI-optimization guide**](https://developers.google.com/search/docs/fundamentals/ai-optimization-guide):

| Lever | Effect | Source |
|---|---|---|
| Citations, quotations, statistics | up to **+40%** (quotes +43.8%, stats +34.2%, citations +29.0%) | Princeton GEO |
| Answer-first placement | **44.2%** of cited content comes from the first third | 1.2M-response analysis |
| Question-style headings | **78.4%** of question-based citations come from headings | Same |
| Keyword stuffing | **−10%** — measurably backfires | Princeton GEO |

AI-CITE's A/I/C/T/E maps onto these, which is why it remains useful shorthand — but **where the
framework and the evidence disagree, the evidence wins**. The **"8+ citations" target is
Schoberg's assertion, not a studied threshold**: treat it as a guideline, never a gate. Do not pad
to hit a count.

### Priorities follow the June-2026 audit tiers

The [June-2026 whole-site audit](https://github.com/brightdigit/llm-ready-web/blob/main/case-studies/brightdigit-ai-cite/ai-citation-audit-2026-06.md)
ranked the work Tier 1/2/3. Priorities below reflect that ranking, not uniform P1.

| # | Title | Priority | Audit rationale |
|---|-------|----------|-----------------|
| [#21](https://github.com/brightdigit/brightdigit.com/issues/21) | Optimize Mise Setup Guide | **P0** | Tier 1 — already cited; quick-start is buried behind rationale. Lowest effort, page already trusted |
| [#22](https://github.com/brightdigit/brightdigit.com/issues/22) | Optimize Best Backend Article | **P0** | Tier 1 — already cited; best-structured page on the site, missing only a comparison table |
| [#130](https://github.com/brightdigit/brightdigit.com/issues/130) | Split `dependency-management-swift` | **P0** | Tier 1 — buries the answer ~60% in and blends "management" with "injection", matching neither query |
| [#26](https://github.com/brightdigit/brightdigit.com/issues/26) | Optimize iOS CI/CD Article | P1 | Tier 2 |
| [#27](https://github.com/brightdigit/brightdigit.com/issues/27) | Optimize iOS Architecture Article | P1 | Tier 2 — not surfacing; all headings declarative, dated 2020 |
| [#28](https://github.com/brightdigit/brightdigit.com/issues/28) | Optimize Remaining Priority Articles (Batch) | P1 | Tier 2 |

**The Tier-1 pages are the ones that already get cited.** Strengthening a page AI tools already
trust is cheaper and more likely to pay off than rescuing one they ignore.

---
## Phase 3: Site SEO Code & Measurement

**Quadrant:** code · this-repo · **Milestone:** Phase 3: Site SEO Code & Measurement

**Goal:** The site-level code that supports AI citation, plus the measurement loop that tells us whether any of it is working.

| # | Title | Priority | Notes |
|---|-------|----------|-------|
| [#129](https://github.com/brightdigit/brightdigit.com/issues/129) | Fix misleading freshness signal: real publish/`dateModified` dates sitewide | P1-high | Tier 2 (was P0 — audit ranks freshness below the Tier-1 content wins) |
| [#167](https://github.com/brightdigit/brightdigit.com/issues/167) | Enforce AI/SEO invariants in Swift (type-level + build-time) | P1-high | Makes #129 permanent — a required per-page date is unforgeable |
| [#23](https://github.com/brightdigit/brightdigit.com/issues/23) | Track AI-citation rate on a recurring cadence (baseline: 2/5) | P1-high | Reframed: the baseline already exists |
| [#131](https://github.com/brightdigit/brightdigit.com/issues/131) | Add `robots.txt` with a `Sitemap:` line | P2-medium | Tier 3 hygiene — **Sitemap line only** |
| [#132](https://github.com/brightdigit/brightdigit.com/issues/132) | Normalize brand name ("BrightDigit") sitewide | P2-medium | Tier 3 — evidence grades entity-consistency ❔ *Unestablished* |

**#129 is the one surviving `PiHTMLFactory` code task:** the footer at `Sources/BrightDigitSite/Components/FooterMeta.swift:41` renders `.year()` (current build year) as a false freshness signal; replace it and surface real per-page dates (`item.metadata.date` already exists across `Nodes/Section/*`). **#167 then makes the fix structural** — a required `PageSEO` value that `Node+Head.swift` consumes, so no page can render without a description, a canonical, and a real date.

> **⚠️ Crawlability is already excellent — do not "fix" it.** The audit found `robots.txt` returns
> **404**, which means every AI crawler (GPTBot, ClaudeBot, PerplexityBot, Google-Extended, CCBot,
> OAI-SearchBot) is **implicitly allowed**. The site is server-rendered with a valid ~360-URL
> sitemap and canonicals present. **Adding a `robots.txt` with allow rules can only ever *remove*
> access** — #131 is scoped to a `Sitemap:` line and nothing more.

### Measurement baseline (2026-06-14): cited in 2 of 5 target prompts

| Target question | Cited? | Competitors winning the citation |
|---|---|---|
| how to manage dependencies in Swift | ❌ | Swift by Sundell, Adobe SPM docs, MoldStud |
| best Swift dependency injection | ❌ | SwiftLee, CocoaCasts, QuickBird, SwiftAnytime |
| how to set up Mise for Swift | ✅ | Tuist, mise.jdx.dev, SwiftToolkit |
| what backend should I use for an iOS app | ✅ | Back4app, iosapptemplates, Pontis |
| iOS software architecture best practices | ❌ | Medium, Kodeco, Essential Developer |

**Target:** movement above 2/5 sustained across consecutive runs, with the Tier-1 pages (#21, #22, #130) the first expected movers. Re-test every 2–4 weeks; watch the trend, not any single run.

**Reference:** `brightdigit/llm-ready-web` `main` — [`case-studies/brightdigit-ai-cite/ai-citation-audit-2026-06.md`](https://github.com/brightdigit/llm-ready-web/blob/main/case-studies/brightdigit-ai-cite/ai-citation-audit-2026-06.md), [`resources/geo-evidence-review.md`](https://github.com/brightdigit/llm-ready-web/blob/main/resources/geo-evidence-review.md), [`resources/site-analysis-runbook.md`](https://github.com/brightdigit/llm-ready-web/blob/main/resources/site-analysis-runbook.md), [`resources/ai-visibility-tools.md`](https://github.com/brightdigit/llm-ready-web/blob/main/resources/ai-visibility-tools.md), [`tooling/skills/geo-audit/SKILL.md`](https://github.com/brightdigit/llm-ready-web/blob/main/tooling/skills/geo-audit/SKILL.md), `resources/ai-cite-framework.md`.

---

## Phase 4: Content Ops Planning Layer

**Quadrant:** content · external-repo · **Milestone:** Phase 4: Content Ops Planning Layer

**Goal:** Build the content-planning / scaffolding infrastructure so Claude Code can *guide* future content across every medium/platform **without writing full drafts**. Full design in [`.claude/docs/content-ops-plan.md`](.claude/docs/content-ops-plan.md).

**Dependency:** Phase 1 — [#169](https://github.com/brightdigit/brightdigit.com/issues/169) defines the boundaries the portable skill needs, and [#136](https://github.com/brightdigit/brightdigit.com/issues/136) supplies the spec the briefs validate against.

| # | Title | Priority | Depends on |
|---|-------|----------|-----------|
| [#138](https://github.com/brightdigit/brightdigit.com/issues/138) | Per-medium/platform content briefs (scaffolds, not drafts) | P1-high | #135, #136 |
| [#139](https://github.com/brightdigit/brightdigit.com/issues/139) | Portable `/content-plan` skill | P1-high | #135, #136, #138, #169 |
| [#137](https://github.com/brightdigit/brightdigit.com/issues/137) | Canonical topic-entity definition (private-only records) | P2-medium | relates #135 |

**Why this is the external-repo content quadrant:** the topic **records** (#137), the briefs (#138), and the drafts all live in the private `year-in-review` repo. Only finished items cross into `brightdigit.com`. The skill (#139) is explicitly **portable** — the *same* package runs in both repos, which is what keeps the two seams honest.

**The fan-out leg lives in Phase 5:** [#140](https://github.com/brightdigit/brightdigit.com/issues/140) consumes this planning layer plus the Buttondown/Buffer/AT modules.

---
## Phase 5: Publishing Infrastructure — Internal

**Quadrant:** code · this-repo · **Milestone:** Phase 5: Publishing Infrastructure — Internal

**Goal:** The publishing orchestrator and content-plan wiring that live **inside this repo**. Splitting the old Phase 6 along the internal/external line keeps the quadrant clean: `PublishKit` and the fan-out wiring are code we own here; the platform integrations in Phase 6 require credentials, external APIs, and other repos.

| # | Title | Priority | Depends on |
|---|-------|----------|-----------|
| [#33](https://github.com/brightdigit/brightdigit.com/issues/33) | Swift Publishing Tool: Buttondown + Buffer Architecture | — | #30 for the social leg |
| [#140](https://github.com/brightdigit/brightdigit.com/issues/140) | Wire the content plan to the publish + fan-out pipeline | P1-high | Phase 4 (#135–#139) + #33/#31/#30/#49 |

> **Historical note:** the inbound email-import + hosted-HTML-cleanup chain
> ([#124](https://github.com/brightdigit/brightdigit.com/issues/124),
> [#122](https://github.com/brightdigit/brightdigit.com/issues/122),
> [#127](https://github.com/brightdigit/brightdigit.com/issues/127)) and the subscribe form
> ([#126](https://github.com/brightdigit/brightdigit.com/issues/126)) were pulled forward into the
> old Phase 5 and are **complete**. What remains is the **outbound** publishing leg.

---

## Phase 6: Publishing Infrastructure — External Platforms

**Quadrant:** code · external-repo · **Milestone:** Phase 6: Publishing Infrastructure — External Platforms

**Goal:** The platform integrations — social fan-out, newsletter migration, video podcasts, AT Protocol.

| # | Title | Status |
|---|-------|--------|
| [#31](https://github.com/brightdigit/brightdigit.com/issues/31) | Migrate Newsletters | Open — follows #33 tooling |
| [#30](https://github.com/brightdigit/brightdigit.com/issues/30) | Public Buffer API | Open — prerequisite for #33's social leg |
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

**Quadrant:** code · external-repo · **Milestone:** Phase 7: Platform Migration

**Goal:** Migrate hosting to GitHub Pages and settle form hosting.

| # | Title | Notes |
|---|-------|-------|
| [#50](https://github.com/brightdigit/brightdigit.com/issues/50) | Migrate to GitHub Pages | Currently deployed via Netlify |
| [#70](https://github.com/brightdigit/brightdigit.com/issues/70) | Contact form integration + form-hosting decisions | Blocked on #50 — hosting determines the options |

---

## Phase 8: Final Cleanup

**Quadrant:** code · this-repo · **Milestone:** Phase 8: Final Cleanup

**Goal:** Low-priority internal cleanup deferred until core work is stable. Upstream-facing work moved to Phase 9.

| # | Title | Notes |
|---|-------|-------|
| [#162](https://github.com/brightdigit/brightdigit.com/issues/162) | `Files`: modernize to true value semantics (retire class-in-struct + `Mutex<String>`) | |
| [#153](https://github.com/brightdigit/brightdigit.com/issues/153) | Reclaim parallel page generation (investigate, measure-first) | P1-high |
| [#114](https://github.com/brightdigit/brightdigit.com/issues/114) | Root `.periphery.yml` uses invalid key `targets` | |
| [#77](https://github.com/brightdigit/brightdigit.com/issues/77) | Add macOS build job for the site executable to main CI | |
| ~~[#34](https://github.com/brightdigit/brightdigit.com/issues/34)~~ | ~~Remove or repurpose Import/Wordpress XML files~~ | **Completed** (2026-08-04): `Import/Wordpress/*.xml` deleted. [#105](https://github.com/brightdigit/brightdigit.com/issues/105) now needs a fresh WordPress export to verify against. |
| [#105](https://github.com/brightdigit/brightdigit.com/issues/105) | Verify `import wordpress` end-to-end against real WordPress export | Was **unmilestoned** until the 2026-07-28 reorg |
| [#51](https://github.com/brightdigit/brightdigit.com/issues/51) | Research node-swift | Evaluate [kabiroberai/node-swift](https://github.com/kabiroberai/node-swift) |

---

## Post-Migration: Article Edits

**Quadrant:** content · this-repo · **Milestone:** Post-Migration: Article Edits

**Goal:** Standalone article corrections — no code changes, and not AI-CITE structural work. (The AI-CITE **article optimization** issues formerly listed here — #21/#22/#26/#27/#28 — moved into **Phase 2**.)

**Note:** Apply the `article-edit` GitHub label to all issues below to distinguish from migration/code issues.

| # | Title | Status |
|---|-------|--------|
| [#3](https://github.com/brightdigit/brightdigit.com/issues/3) | Add Additional Local Storage Options | Open |
| [#4](https://github.com/brightdigit/brightdigit.com/issues/4) | Add Main Actor to Swift 6 Article Solution | Open |
| [#13](https://github.com/brightdigit/brightdigit.com/issues/13) | Clarify String vs Reference design choice in MistKit article | Open |

---

## Phase 9: Upstream Contributions

**Quadrant:** code · external-repo · **Milestone:** Phase 9: Upstream Contributions

**Goal:** Patches contributed back to third-party upstream projects. Split out of Phase 8 because the work lands in someone else's repo on their timeline — it cannot be scheduled like internal cleanup.

| # | Title | Notes |
|---|-------|-------|
| [#112](https://github.com/brightdigit/brightdigit.com/issues/112) | Upstream swift-coverage-action Swift 6.4 Linux fix to sersoft-gmbh | Blocked on upstream review |

---

## Phase 10: Content Authority & Off-Site

**Quadrant:** content · external-repo · **Milestone:** Phase 10: Content Authority & Off-Site

**Goal:** Authority signals that live off the site. Both issues were previously stranded in the old Phase 5 (a *code* milestone) despite being content work.

| # | Title | Priority | Notes |
|---|-------|----------|-------|
| [#25](https://github.com/brightdigit/brightdigit.com/issues/25) | Create Unique BrightDigit Frameworks/Methodologies | P2-medium | AI-CITE's "E" (Exclusive POV) — the ⭐⭐ tier, not ⭐⭐⭐ |
| [#24](https://github.com/brightdigit/brightdigit.com/issues/24) | YouTube Video Content Strategy | P2-medium | 40–60h estimate; rests on a single vendor quote — keep low priority |

> **Evidence caveat.** The "YouTube multiplier" rationale behind #24 traces entirely to a Jesse
> Schoberg conference quote, with no controlled study behind it. It is plausible (Google does
> transcribe YouTube) but unverified, and the effort estimate is the largest of any open issue.
> Sequence it behind the ⭐⭐⭐ levers in Phase 2.

---

## Site Defects

**Quadrant:** code · this-repo · **Milestone:** Site Defects

**Goal:** Rendering bugs and dead code on the live site — independent of the migration phases.

| # | Title | Type |
|---|-------|------|
| [#163](https://github.com/brightdigit/brightdigit.com/issues/163) | ProductSection: AppStore/GitHub/Press Kit links never render (nested ListItem) | bug |
| [#164](https://github.com/brightdigit/brightdigit.com/issues/164) | Podcast featured card renders the Transistor player twice | bug |
| [#166](https://github.com/brightdigit/brightdigit.com/issues/166) | Cleanup: dead `Node.li(for:at:)` and `socialPlatforms(_:)`, inaccurate lint-packages comment | enhancement |

---

## Documentation

**Quadrant:** code · external-repo · **Milestone:** Documentation

**Goal:** Close the documentation gaps created (and revealed) by the package extraction.

| # | Title | Priority |
|---|-------|----------|
| [#170](https://github.com/brightdigit/brightdigit.com/issues/170) | Post-extraction documentation: README, LICENSE, repo-boundary docs | P2-medium |
| [#171](https://github.com/brightdigit/brightdigit.com/issues/171) | DocC + contract docs for the tagged package repos | P2-medium |

**Audited state (all 20 tagged repos):** every one already has a README, a LICENSE, and an
AGENTS/CLAUDE file. **`brightdigit.com` itself is the outlier** — it has none of the three, with
`AGENTS.md` doing README duty.

The remaining gaps split along the **fork vs first-party** line:

- **Sundell forks** (`Plot`, `Files`, `Ink`, `Publish`) have zero DocC *and the largest READMEs of
  the set* (Plot 3,794 words; Publish 2,123; Ink 1,799). Sundell documented via README, not DocC.
  **Do not add DocC to the forks** — badge parity only (they carry 4–5 badges vs the 8 standard).
- **`PublishType` is the priority:** a three-line README and no DocC, yet it is where the
  `ItemMetadata` contract lands after [#168](https://github.com/brightdigit/brightdigit.com/issues/168)
  and exactly what [#136](https://github.com/brightdigit/brightdigit.com/issues/136) must parse.

> **⚠️ Not a gap: SyndiKit's Swift version.** `SyndiKit` ships **two manifests** —
> `Package.swift` (`swift-tools-version:5.10`, iOS 13) and **`Package@swift-6.0.swift`**
> (`swift-tools-version:6.0`, iOS 16). SwiftPM picks the versioned file on a 6.x toolchain; the
> 5.10 file is the deliberate fallback keeping the library reachable for consumers on older
> toolchains. On the 6.0 path SyndiKit is the **most** aggressively configured package in the set
> (Swift 6 language mode + six upcoming-feature flags). **When auditing package config, check for
> `Package@swift-*.swift` before concluding anything from `Package.swift` alone** — SyndiKit is the
> only one of the 20 with a versioned manifest.

---

## Excluded Issues

| # | Title | Reason |
|---|-------|--------|
| [#12](https://github.com/brightdigit/brightdigit.com/issues/12) | Make Repo Public | Already completed |

---

## Issue Count by Phase

**43 open issues across 13 single-quadrant milestones** (as of 2026-08-04).

| Phase | Quadrant | Issues | Contents |
|-------|----------|--------|----------|
| Phase 1: Package Extraction & Repo Boundaries | code · external-repo | 4 | [#168](https://github.com/brightdigit/brightdigit.com/issues/168), [#169](https://github.com/brightdigit/brightdigit.com/issues/169), [#135](https://github.com/brightdigit/brightdigit.com/issues/135), [#136](https://github.com/brightdigit/brightdigit.com/issues/136) |
| Phase 2: AI-CITE Content Optimization | content · this-repo | 6 | Article rewrites — [#21](https://github.com/brightdigit/brightdigit.com/issues/21), [#22](https://github.com/brightdigit/brightdigit.com/issues/22), [#130](https://github.com/brightdigit/brightdigit.com/issues/130) (P0, Tier 1); [#26](https://github.com/brightdigit/brightdigit.com/issues/26), [#27](https://github.com/brightdigit/brightdigit.com/issues/27), [#28](https://github.com/brightdigit/brightdigit.com/issues/28) (P1, Tier 2) |
| Phase 3: Site SEO Code & Measurement | code · this-repo | 5 | [#129](https://github.com/brightdigit/brightdigit.com/issues/129), [#167](https://github.com/brightdigit/brightdigit.com/issues/167), [#23](https://github.com/brightdigit/brightdigit.com/issues/23), [#131](https://github.com/brightdigit/brightdigit.com/issues/131), [#132](https://github.com/brightdigit/brightdigit.com/issues/132) |
| Phase 4: Content Ops Planning Layer | content · external-repo | 3 | [#137](https://github.com/brightdigit/brightdigit.com/issues/137), [#138](https://github.com/brightdigit/brightdigit.com/issues/138), [#139](https://github.com/brightdigit/brightdigit.com/issues/139) |
| Phase 5: Publishing Infra — Internal | code · this-repo | 2 | [#33](https://github.com/brightdigit/brightdigit.com/issues/33), [#140](https://github.com/brightdigit/brightdigit.com/issues/140) |
| Phase 6: Publishing Infra — External | code · external-repo | 4 | [#30](https://github.com/brightdigit/brightdigit.com/issues/30), [#31](https://github.com/brightdigit/brightdigit.com/issues/31), [#32](https://github.com/brightdigit/brightdigit.com/issues/32), [#49](https://github.com/brightdigit/brightdigit.com/issues/49) |
| Phase 7: Platform Migration | code · external-repo | 2 | [#50](https://github.com/brightdigit/brightdigit.com/issues/50), [#70](https://github.com/brightdigit/brightdigit.com/issues/70) |
| Phase 8: Final Cleanup | code · this-repo | 6 | [#162](https://github.com/brightdigit/brightdigit.com/issues/162), [#153](https://github.com/brightdigit/brightdigit.com/issues/153), [#114](https://github.com/brightdigit/brightdigit.com/issues/114), [#77](https://github.com/brightdigit/brightdigit.com/issues/77), [#105](https://github.com/brightdigit/brightdigit.com/issues/105), [#51](https://github.com/brightdigit/brightdigit.com/issues/51) |
| Phase 9: Upstream Contributions | code · external-repo | 1 | [#112](https://github.com/brightdigit/brightdigit.com/issues/112) |
| Phase 10: Content Authority & Off-Site | content · external-repo | 2 | [#24](https://github.com/brightdigit/brightdigit.com/issues/24), [#25](https://github.com/brightdigit/brightdigit.com/issues/25) |
| Post-Migration: Article Edits | content · this-repo | 3 | [#3](https://github.com/brightdigit/brightdigit.com/issues/3), [#4](https://github.com/brightdigit/brightdigit.com/issues/4), [#13](https://github.com/brightdigit/brightdigit.com/issues/13) |
| Site Defects | code · this-repo | 3 | [#163](https://github.com/brightdigit/brightdigit.com/issues/163), [#164](https://github.com/brightdigit/brightdigit.com/issues/164), [#166](https://github.com/brightdigit/brightdigit.com/issues/166) |
| Documentation | code · external-repo | 2 | [#170](https://github.com/brightdigit/brightdigit.com/issues/170), [#171](https://github.com/brightdigit/brightdigit.com/issues/171) |
| **Total** | | **43** | |

### Quadrant totals

| | this-repo | external-repo |
|---|---|---|
| **content** | 9 | 5 |
| **code** | 16 | 13 |

### What changed in the 2026-07-28 reorganization

- **Milestones now hold exactly one quadrant each.** Five were impure: the old Phase 3 mixed article rewrites with site code (split into the AI-CITE content phase and the site-SEO code phase); the old Content Ops mixed Swift schema work with planning tooling (split across the package-extraction phase and the content-ops phase); the old Phase 6 mixed internal orchestration with external platform integrations (split into Phases 5 and 6).
- **[#105](https://github.com/brightdigit/brightdigit.com/issues/105) had no milestone at all** → Phase 8.
- **[#24](https://github.com/brightdigit/brightdigit.com/issues/24)/[#25](https://github.com/brightdigit/brightdigit.com/issues/25)** were content issues stranded in the old Phase 5 *code* milestone → Phase 10.
- **[#112](https://github.com/brightdigit/brightdigit.com/issues/112)** is an upstream PR to `sersoft-gmbh` sitting in an internal cleanup milestone → Phase 9.
- **Old Phase 5 closed** (0 open, 10 closed) once #24/#25 moved out.
- **Phase 2 priorities re-ranked to the June-2026 audit tiers** — the pages that already get cited became P0; [#129](https://github.com/brightdigit/brightdigit.com/issues/129) moved P0 → P1.
- **[#23](https://github.com/brightdigit/brightdigit.com/issues/23) reframed** from a one-time pre-work baseline into a recurring re-test, with the existing 2/5 result imported.
- **5 new issues:** [#167](https://github.com/brightdigit/brightdigit.com/issues/167) (AI/SEO enforcement in Swift — nothing enforced it before), [#168](https://github.com/brightdigit/brightdigit.com/issues/168) (package extraction), [#169](https://github.com/brightdigit/brightdigit.com/issues/169) (repo boundaries), [#170](https://github.com/brightdigit/brightdigit.com/issues/170)/[#171](https://github.com/brightdigit/brightdigit.com/issues/171) (documentation).

---

# Appendix: Completed Phases (historical)

The sections below are retained as record. Their phase numbers are the **original** numbering and
do not correspond to the active phases above.

> **Toolchain note:** these sections originally said "Swift 6.3." The active toolchain is **6.4**
> (`.swift-version` pins the `6.4.x-snapshot`), so the references have been corrected to 6.4.

## ✅ Completed — Phase 0 (historical): Quick Wins & Housekeeping

**Goal:** Remove stale tooling and fix broken content — no code architecture changes.

| # | Title | Status |
|---|-------|--------|
| [#11](https://github.com/brightdigit/brightdigit.com/issues/11) | Fix Content Updates | Open |
| [#35](https://github.com/brightdigit/brightdigit.com/issues/35) | Remove dev-server.sh | Open |

**Notes:**
- These are independent of all other phases and can be done at any time.
- [#35](https://github.com/brightdigit/brightdigit.com/issues/35) removes the shell-based dev server (`dev-server.sh` hardcodes `/Users/leo/.nvm/...`); replaced by the Swift-native approach.

---

## ✅ Completed — Phase 1 (historical): Monorepo Cleanup

**Goal:** Finish loose ends from the monorepo consolidation ([#36](https://github.com/brightdigit/brightdigit.com/issues/36), completed via [#42](https://github.com/brightdigit/brightdigit.com/issues/42) and [#48](https://github.com/brightdigit/brightdigit.com/issues/48)).

| # | Title | Status |
|---|-------|--------|
| ~~[#36](https://github.com/brightdigit/brightdigit.com/issues/36)~~ | ~~Phase 1: Monorepo Consolidation (17 packages)~~ | **Completed** ([#42](https://github.com/brightdigit/brightdigit.com/issues/42), [#48](https://github.com/brightdigit/brightdigit.com/issues/48)) |

**Notes:**
- Phase 1 has no remaining open work. The `MarkdownGenerator` removal originally tracked by [#47](https://github.com/brightdigit/brightdigit.com/issues/47) has been folded into Phase 4 [#40](https://github.com/brightdigit/brightdigit.com/issues/40) (swift-markdown covers both Ink replacement and MarkdownGenerator replacement, since both libraries are swapped for the same dependency). [#47](https://github.com/brightdigit/brightdigit.com/issues/47) has been retitled and moved to Phase 4 to track the orthogonal Kanna → SwiftSoup migration in `Tagscriber` — it was previously a TBD row there.

---

## ✅ Completed — Phase 2 (historical): Swift 6.4 — Main Package

**Goal:** Upgrade the top-level `brightdigit.com` package to Swift 6.4 language mode. Subrepos remain at their current language modes — a Swift 6.4 package can depend on older Swift packages. This unblocks Phase 4 (swift-openapi-generator and swift-subprocess require Swift 6.4+).

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
- Update `Package.swift`: `// swift-tools-version: 6.4`, `.macOS(.v13)`
- **Fix `Testimonial.swift` data race (critical):** remove `static var lastID`, make `id` a required parameter
- Add `Sendable` conformances: `Newsletter.Source`, `YouTubeContent.Source`, `RSSContent.Source`, `BrightDigitPodcast.Source`
- Fix force-try: `YAMLStringFix.swift:6`, `String.swift:4`, `RSSContent.swift:21`

**Deliverables:**
- [ ] `brightdigit.com` Package.swift on `swift-tools-version: 6.4`
- [ ] Zero concurrency warnings in `Sources/`
- [ ] All tests passing under Swift 6.4
- [ ] Subrepos unchanged (still at prior language modes)

---

## ✅ Completed — Phase 4 (historical): OpenAPI & Dependency Migration

**Goal:** Replace SwagGen + Prch with Apple's swift-openapi-generator and async/await throughout. Replace other stale dependencies.

**Estimated effort:** 4–6 weeks  
**Dependency:** Phase 2 (Swift 6.4 main package).

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

## ✅ Completed — Phase 5 (historical): Swift 6.4 Subrepos + Component Migration + Mermaid

**Goal:** Upgrade all 17 subrepos to Swift 6.4 strict concurrency. Migrate `PiHTMLFactory` and all `Nodes/` files to a component-based Plot API. Add Mermaid diagram support.

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
| [#38](https://github.com/brightdigit/brightdigit.com/issues/38) | Swift 6.4 Language Mode + Component Migration + Mermaid Support | Open |
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

**Swift 6.4 subrepo upgrades (17 total):**
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
- `swift build` with Swift 6.4 strict mode passes on macOS and Ubuntu
- Site output byte-for-byte identical (excluding mermaid blocks — visual verification)

---