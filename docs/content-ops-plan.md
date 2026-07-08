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
scaffolding infrastructure, aligned to the existing migration phases.

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
