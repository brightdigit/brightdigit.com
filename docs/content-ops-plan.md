# Content-Planning Infrastructure — Proposed Issue Set

**Status:** Draft for review · **Target repo:** `brightdigit/brightdigit.com` · **2026-07**

## Context

`leogdion/year-in-review` (private) is the planning/draft hub for all BrightDigit/EmpowerApps
content — articles, podcast episodes, newsletters, multi-platform social posts, and talks. It
already has a mature-but-ad-hoc system: content organized by medium, YAML front matter with a
hand-authored `related:` graph, a `/content-topic-mining` skill, per-platform voice guides, and
three content pillars (AI+Swift, Opinion/Reflection, OSS Releases). It already links to **live
brightdigit.com URLs** (e.g. a social clip's `related.episode:
https://brightdigit.com/episodes/209-…/`), and newsletters are Buttondown-markdown-native.

**The gap:** there is no *defined, executable infrastructure* that lets Claude Code **guide** future
content across every medium/platform **without writing full drafts**. Today the cross-media fan-out
is inferred from matching filenames + a drifting `related:` vocabulary; there is no canonical
"topic" record; status tracking is duplicated and manual; and none of it is connected to the Swift
program that actually renders and publishes the public site.

The public site (`brightdigit.com`) is a Swift Publish static-site generator: five sections
(`articles`/`episodes`/`tutorials`/`newsletters`/`products`), one `Codable` metadata struct
(`BrightDigitSite.ItemMetadata`) that the pipeline decodes from front matter and that the renderer
plus the future fan-out consume. "Draft" today = future-dated only (no `draft:` flag). Phase 6 will
add `PublishKit`/`ButtondownKit`/`BufferKit`/`ATProtoKit` for newsletter + social fan-out. A future
refactor will separate `Content/*.md` from `Sources/*.swift` — the front-matter↔Swift-struct
contract is unchanged by that split.

**Goal:** define the GitHub issues (in `brightdigit.com`) that build a content-planning /
scaffolding infrastructure, aligned to the existing migration phases. See
[How it works end-to-end](#how-it-works-end-to-end) for a concrete walkthrough of the whole system in
motion before the issue catalog.

## Design decisions

1. **Deliverables (all four):** canonical topic entity · per-medium/platform briefs · unified
   cross-media link schema · a `/content-plan` skill.
2. **Coupling:** build the **planning layer now**; wire publish/fan-out **later** (do not block on
   unbuilt Phase 6 modules).
3. **Phase fit — split:** schema + spec-generator + briefs + skill → **Phase 3 (content)**;
   publish/fan-out wiring → **Phase 6 (publishing infra)**.
4. **Schema is Swift-first, spec is derived.** The authoritative contract is the Swift metadata
   types (`PublishType` / `ItemMetadata`) — the fields the renderer and fan-out require, because the
   Swift program is what renders HTML and publishes/fans out. **No hand-maintained spec doc.**
   Instead a generator (a skill, or a `/content-plan` sub-step) **parses the latest Swift type and
   emits the companion spec on the fly** — an easy "pull latest Swift file → produce current spec"
   path. The private repo and the skill consume that generated spec.
5. **Skill is portable:** a self-contained `/content-plan` skill package (+ voice/pillar/platform
   guides) usable from **both** repos.
6. **Topic entity is private-only for now:** the topic/campaign record is a first-class entity, but
   its records live **only in year-in-review**. brightdigit.com published items carry only the
   cross-media **link fields**; the public site never hosts topic records.

## How it works end-to-end

The issue set above (I1–I6) is a parts list. This section shows the machine running: how the repos
are arranged, and one concrete topic traveling from a mining hit to published-and-fanned-out content
across media. It describes the **target** arrangement — the Swift-package split and the Phase-6
fan-out are planned, not yet shipped; the language below flags what is future work.

### The repo arrangement

The plan splits along **two axes at once**: private-vs-public *and* content-vs-Swift-code. Today
`brightdigit.com` is a single repo mixing `Content/*.md` with `Sources/*.swift`. The target pulls the
Swift packages out into their own repo(s), leaving the content + site repo depending on them — three
homes joined by two seams.

- **`leogdion/year-in-review` (private) — the planning hub.** Holds the topic/campaign **records** (I3
  shape), the `/content-topic-mining` skill, the three pillars (AI+Swift, Opinion/Reflection, OSS
  Releases), the per-platform voice guides (`social-posts/README.md`, `newsletters/README.md`,
  `planning/content-strategy-2026.md`), and per-medium **draft** copy. This is where a human plus
  Claude Code plan and write.

- **`brightdigit.com` (public) — the content + site repo.** After the split it keeps `Content/*.md`
  plus site config in place and **depends on** the extracted Swift package repo(s). It holds the
  published items — front matter carrying only the cross-media **link fields** (I1), never topic
  records — and the **derived companion spec** (I2 output, pulled from the package repo). It runs the
  Publish pipeline that renders, publishes, and fans out. It no longer *owns* the metadata types.

- **Extracted Swift package repo(s) — the contract + the engine.** `BrightDigitSite`, `PublishType`,
  and the Phase-6 modules (`PublishKit` / `ButtondownKit` / `BufferKit` / `ATProtoKit`) move here as
  standalone Swift packages. **The authoritative front-matter↔Swift-struct contract (`ItemMetadata` /
  `PublishType`) travels with them** — so the schema lives in the package repo and the content repo
  consumes it as a versioned dependency. This is the single source of truth I2 reads from.

**Two seams keep everything in sync:**

- **The contract seam (package repo → everywhere).** I2's "pull latest Swift type → emit current spec"
  now means *pull from the package repo* — a clean versioned dependency boundary, not reaching into a
  subfolder. The generated spec flows into both the content repo (validation at publish time) and
  `year-in-review` (so drafts are authored against the current fields). Splitting the packages out
  actually *strengthens* I2: the source of truth is a released package, not a path.
- **The content seam (year-in-review → brightdigit.com).** Only **finished items plus their I1 link
  fields** land in `Content/`. Topic records, briefs, and voice guides stay private.

The **`/content-plan` skill (I5) is portable** — the *same* skill package runs in both the private and
public repos, which is what lets both seams stay clean: identical rules on both sides. And because the
contract is optional Codable fields on a struct, the repo split changes *which repo owns
`ItemMetadata`*, not the field vocabulary — I1's fields travel with the packages unchanged (the same
[Refactor-proof](#alignment-notes) logic, extended from a `Content/`↔`Sources/` folder split to a full
repo split).

### The walkthrough: mining hit → money article → newsletter → social

One topic, eight beats. **Beats 1–4 are private planning, beat 5 is the boundary crossing, beats 6–8
are the public pipeline.** Throughout, the system **guides and scaffolds — it never ghost-writes the
long-form copy**; that stays a human/`prose-editor` step (beat 4).

1. **Mining hit** *(year-in-review · Claude Code · existing `/content-topic-mining`)*. Mining surfaces
   a candidate: *"developers keep asking how to wire up mise for a Swift CI toolchain."*

2. **Topic record created** *(year-in-review · `/content-plan`, I5 → I3)*. The skill turns the hit into
   a canonical **topic entity**: slug `mise-swift-ci`, source (the mining hit / a related PR), pillar
   `AI+Swift`, status, and a **fan-out map** — the media/platforms this topic will spawn (article →
   newsletter → X/LinkedIn/Mastodon). No drafts yet. The record lives only here.

3. **Briefs generated** *(year-in-review · `/content-plan`, I4 + I2 spec)*. The skill emits per-medium
   **briefs** — the article brief (hook, angle, AI-CITE key points, CTA, links), the newsletter brief,
   the social variants. **Scaffolds, not copy.** Their link fields are validated against the
   **I2-derived spec** so they will conform to what the Swift renderer expects.

4. **Article drafted + AI-CITE optimized** *(year-in-review · human/Claude Code + `prose-editor`)*. The
   "money article" is written from the brief, applying the Phase-3 AI-CITE levers — **A**nswer-first,
   **I**ntent-matched (question) headings, **C**lear structure, **T**rusted sources (citations),
   **E**xclusive POV. The `prose-editor` agent reviews. The long-form copy lives privately until ready.

5. **Item crosses into `brightdigit.com` with link fields** *(the boundary · I1)*. The finished article
   moves to `Content/articles/…md`, and its front matter now carries the **proposed I1 cross-media link
   fields** — additive, optional, Codable, decoded by `ItemMetadata`:

   ```yaml
   # today — bare front matter (Content/articles/2020-apple-watch.md)
   title: Why 2020 will be amazing for the Apple Watch
   date: 2020-04-13 06:30
   description: …
   tags: Apple Hardware, Apple Watch, apple-development, swiftui
   featuredImage: /media/…/daniel-canibano-….jpg
   ```

   ```yaml
   # with the proposed I1 fields (additive — nothing above changes)
   title: Wiring up mise for a Swift CI toolchain
   date: 2026-08-01 06:30
   description: …
   featuredImage: /media/…/mise-swift-ci.jpg
   topicSlug: mise-swift-ci                              # I1 (proposed)
   sourceRef: year-in-review#mise-swift-ci              # I1 (proposed)
   related:                                              # I1 (proposed)
     newsletter: /newsletters/2026-08-mise-swift-ci/
     social: https://bsky.app/profile/…/post/…
   ```

   Additive safety is already proven in this repo: content files carry YAML keys `ItemMetadata` does
   not model (`campaignID`, `newsletterTitle`, `tags`) and Publish decodes them without failure — the
   same rationale the PRD gave the (retired) `schemaMarkup` field.

6. **Staged as a draft via future-dating** *(brightdigit.com)*. Because **"draft" = future-dated
   only**, the item ships with a future `date:` — visible in `--mode drafts` builds, stripped from
   production by the `item.date > now` filter (`Sources/BrightDigitSite/BrightDigitSite.swift:196`) —
   until launch day. No `draft:` flag is needed; this is the existing mechanism I6 leans on.

7. **Published** *(brightdigit.com · Swift pipeline)*. On or after the date, `--mode production` renders
   the article; the renderer reads the I1 fields; the item goes live at `brightdigit.com/articles/…`.

8. **Fan-out** *(brightdigit.com · I6, Phase 6 — later)*. The topic's fan-out map plus the item's I1
   link fields drive the outbound leg: newsletter via `ButtondownKit`, social via `BufferKit` /
   `ATProtoKit` (a canonical `app.bsky.feed.post` record → a single GraphQL mutation → all networks).
   The published article is the hub the newsletter and posts link back to. This beat **depends on
   #33/#31/#30/#49** and the Phase-6 modules existing.

### Which issue powers which beat

| Beat | Issue | Repo | New capability |
|---|---|---|---|
| 2 topic record | I3 | year-in-review | canonical topic entity (records private) |
| 3 briefs | I4 (+ I2 spec) | year-in-review | per-medium scaffolds, spec-validated |
| 2–5 orchestration | I5 | both (portable) | `/content-plan` skill |
| 5 link fields | I1 | package repo (fields) → brightdigit.com (values) | additive `ItemMetadata` fields |
| 3 / 5 spec | I2 | package repo → content repo + year-in-review | Swift-type → spec generator (pull latest package) |
| 8 fan-out | I6 | brightdigit.com + package repo | publish + Buttondown/Buffer/AT wiring |

### Why this arrangement

Records stay private because a content strategy and backlog is not something to publish. The **Swift
package repo owns the contract** because the Swift program is what actually renders HTML and fans out —
the fields it needs are the fields that matter — while the content repo depends on that package and
carries only link-field *values*. The portable `/content-plan` skill and the package-derived spec are
the two seams that keep private planning and public publishing in sync without duplicating the
vocabulary. The repo split makes that contract a **versioned dependency rather than a folder**, which
is exactly what lets the spec generator (I2) stay honest.

## Proposed issues

Ordering: **I1** (link-field schema) is foundational — the generator (I2), briefs (I4), and skill
(I5) all consume it. **I6** (fan-out) is Phase 6 and depends on the Phase 3 pieces landing.

### Phase 3 — planning layer (schema, spec, briefs, skill)

#### I1 — Cross-media link schema on published items (Swift types) · P1-high
Extend `BrightDigitSite.ItemMetadata` (`Sources/BrightDigitSite/BrightDigitSite.swift`) and the
`PublishType` protocol layer (`Sources/PublishType/`) with a **unified, validated cross-media link
vocabulary**, replacing the drifting free-text `related.social` / `related.newsletter` /
`related.episode`. Fields let a published site item declare its topic slug and cross-media siblings
(e.g. `topicSlug`, `sourceRef`, `related.{episode,newsletter,social,article,talk,video}`). Codable,
optional, additive (does not break existing content). This is the **contract** the renderer and the
future fan-out read.
*Coordinate with the Phase-5 component migration — additive fields on `ItemMetadata` don't conflict
(same rationale the PRD uses for `schemaMarkup`).*
Labels: `enhancement`.

#### I2 — Swift-type → companion-spec generator · P1-high · depends on I1
A capability (standalone skill, or a sub-step invoked by `/content-plan`) that **reads the latest
`ItemMetadata` / `PublishType` Swift source and emits a current, human/machine-readable companion
spec** (fields, types, link vocabulary). No hand-maintained schema doc — always derived from the
authoritative Swift types via an easy "pull latest → generate spec" path. Output is what the private
repo drafts and the briefs/skill validate against.
Labels: `enhancement`, `documentation`.

#### I3 — Canonical topic-entity definition (private-only records) · P2-medium · relates to I1
Define the topic/campaign entity: id/slug, source (repo/PR/episode/release), status, and the fan-out
map (which media + platforms it spawns). Specify it as a **type/shape** so records are consistent,
but its **records live only in year-in-review** — brightdigit.com hosts the *definition* + the link
fields (I1), not topic records. Documents how a topic threads mining → briefs → per-platform drafts
→ published items.
Labels: `documentation`, `enhancement`.

#### I4 — Per-medium/platform content briefs (scaffolds, not drafts) · P1-high · depends on I1, I2
Templates/scaffolds per medium+platform (article, tutorial, episode clip, newsletter, and
Twitter/LinkedIn/Mastodon/YouTube/Patreon variants): hook, angle, key points, CTA, length, voice,
links — **structured guidance, not full copy**. Encodes the voice/pillar/platform guides distilled
from year-in-review (`social-posts/README.md`, `newsletters/README.md`,
`planning/content-strategy-2026.md`). Conforms to the I1 fields / I2 spec.
Labels: `documentation`.

#### I5 — Portable `/content-plan` skill · P1-high · depends on I1, I2, I4
A self-contained skill package usable from both repos. Input: a source (mining hit / episode /
release / PR). Output: a topic record (I3 shape) + per-medium/platform briefs (I4), enforcing the
pillars and voice/platform guides and emitting front matter conformant to the I1 fields (validated
via the I2-generated spec). Complements the existing `/content-topic-mining` skill (mining → this →
briefs). **Writes guidance, never final long-form copy.**
Labels: `enhancement`.

### Phase 6 — publish / fan-out wiring (later)

#### I6 — Wire the content plan to the publish + fan-out pipeline · P1-high · depends on I1–I5, #33/#31/#30/#49
Consume the I1 link fields / topic plan to drive fan-out once Phase 6 modules exist: newsletter via
`ButtondownKit`, social via `BufferKit`/`ATProtoKit`, site items via the Publish pipeline + the
future-date "draft" mechanism. Turns a planned topic into scheduled/published outputs across media.
Labels: `enhancement`.

## Alignment notes

- **Phase 3** currently holds the evidence-backed content-optimization work (PR #133 reframe:
  articles + site tasks + baseline). The planning-infra issues (I1–I5) fit its "content" theme.
- **Phase 6** holds the publishing architecture (`#33` umbrella, `#31` newsletters, `#30` Buffer,
  `#49` AT). I6 slots there and depends on them.
- House style: dependency links as `Depends on:` / `Related:` body lines; reuse existing labels
  (`enhancement`, `documentation`, `P0/P1/P2-*`); milestone via `-m`.
- **Refactor-proof:** the schema is front-matter fields on a Codable Swift struct — the future
  `Content/` ↔ `Sources/` split changes *where files live*, not the field contract, so I1's fields
  travel with the content unchanged.

## Open sequencing question

Whether to group I1–I5 under a **new "Content Ops" milestone** vs. folding into Phase 3 was raised;
current choice is the **split (Phase 3 + Phase 6)**. If Phase 3 gets crowded, revisit a dedicated
milestone at execution time.
