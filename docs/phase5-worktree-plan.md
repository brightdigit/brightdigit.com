# Plan: Execute Milestone 5 (Phase 5) via Grove Worktrees & Branches

## Context

**Goal:** Work through all 10 open issues in [Milestone 5 — "Phase 5: Swift 6.3 Subrepos + Components"](https://github.com/brightdigit/brightdigit.com/milestone/5), organizing them into batches and parallel tracks using **grove** worktrees and branches.

**Environment:** This repo uses a **grove bare-clone + worktree** layout. The grove root is `/Users/leo/Documents/Projects/brightdigit.com/`, the bare clone is `brightdigit.com.git/`, and each sibling directory is a worktree whose name matches its branch (kebab-case). `grove add <name>` creates a new worktree+branch; `grove go <branch>` navigates; `grove list` shows all; `grove pr` checks out a PR. The working dir the agent was invoked in is NOT itself a git repo — you must operate inside a worktree.

**Key discoveries from exploration that shape the plan:**

1. **Toolchain is already Swift 6.4, not 6.3.** `Package.swift` is `swift-tools-version:6.4`, `.swift-version` is `6.4.x-snapshot`, CI/Dockerfiles target 6.4. All "6.3" references in the milestone/PRD/issues are stale. The **main package is already on 6.4 strict concurrency**; Phase 5's remaining subrepo work is the vendored **Publish/Plot stack**, whose `Package.swift` files are still `swift-tools-version:5.4`/`5.5` (this is what #121 "outdated dependencies" targets).

2. **#38 (Phase 2 dependency) is CLOSED** — the component migration (#67) and #53 are unblocked.

3. **Buttondown upstream deps #31 & #33 are OPEN (in Phase 6).** #122/#126/#127 declare soft dependencies on them. Per the user's decision, **#31 and #33 are pulled into this effort** so the full outbound→inbound Buttondown chain is coherent. #83 (ButtondownKit exists via swift-openapi-generator) is already CLOSED.

4. **#124 is the P0 critical-path blocker** for the Buttondown inbound track — a thin `listEmails` wrapper. `list_emails` is already generated in `Generated/Client.swift`; only the `ButtondownClient` public wrapper is missing. `update_email` (needed by #127) is NOT yet generated — it must be added to `openapi-generator-config.yaml` and regenerated.

5. **TailwindKit (#69) must be usable to define components** (user constraint). Therefore #69 must land **before** #67's component migration, so new components emit type-safe Tailwind classes from day one rather than being retrofitted.

6. **#24 (YouTube videos) and #25 (unique frameworks) are EXCLUDED** from this code-worktree plan per the user's decision — they are a separate content/media track handled outside grove.

---

## Issue Inventory & Dependency Graph

**In scope (8 code issues): 6 from the milestone + 2 pulled-in Phase 6 deps.**

```
BUTTONDOWN TRACK (outbound → inbound):
  #33 Buttondown+Buffer CLI architecture  ─┐
  #31 Migrate Newsletters (outbound publish)┤ (Phase 6, pulled in — establish first published issue)
        │
        ├──> #124 listEmails wrapper (P0)  ──> #122 import buttondown ─┐
        │                                  └──> #127 hosted-HTML cleanup (needs updateEmail wrapper)
        └──> #126 subscribe form → Buttondown (independent of #124; needs #31 list live)

PLOT / RENDERING TRACK:
  #121 Upgrade Publish + remove outdated deps  ─┐ (foundational)
  #69  TailwindKit module                        ┤ (foundational; must precede #67 per user)
        └──> #67 Component migration + Mermaid ──> #53 enforce component-only (Node internal)

CONTENT TRACK (excluded from code plan):
  #24 YouTube videos, #25 Unique frameworks — handled separately, not in grove
```

---

## Batching & Parallelization Strategy

Three independent tracks run in **parallel worktrees**. Within each track, work is sequenced by dependency. Grove keeps each track's file changes isolated so the heavy #67 rewrite never collides with Buttondown or content edits.

### Track A — Buttondown (worktree: `phase5-buttondown`)

The Buttondown issues all touch `ButtondownKit`, `ContributeButtondown`, and site subscribe forms — closely related, best done **sequentially in one worktree** to share the client-wrapper foundation and avoid churn.

Order:
1. **#33 → #31 (outbound foundation):** finish the Buttondown+Buffer CLI architecture and the outbound "Migrate Newsletters" publish path so at least one real issue is published to Buttondown. *This is the prerequisite that makes #122/#127 testable* — you cannot import or clean hosted emails that don't exist yet. Verify one issue is actually published before proceeding.
2. **#124 (P0) listEmails wrapper:** add public `listEmails` (paged) over `Operations.list_emails` to `ButtondownClient.swift`; unit-test against a recorded fixture.
3. **Fan out (can be two sub-branches off #124 if desired, but low conflict — keep in one worktree):**
   - **#122 import buttondown:** new `Sources/ContributeButtondown` mirroring `ContributeMailchimp`; register `import buttondown` command in `CommandDispatcher.run()`. Buttondown is Markdown-native → far simpler extractor (likely skip HTML→Markdown). Decide `issueNo` continuation from the Mailchimp sequence.
   - **#127 hosted-HTML cleanup:** add `update_email` to `openapi-generator-config.yaml`, regenerate, add `updateEmail` wrapper (PATCH `/emails/{id}`); script a one-time pass stripping Mailchimp cruft and PATCH back.
4. **#126 subscribe form:** replace the two Netlify `subscribers` forms and the hardcoded Mailchimp footer/RSS links with Buttondown equivalents. Independent of #124/#122 but shares the same worktree/track; can be done any time after #31 provides a live Buttondown list.

**Critical files:**
- `Packages/BrightDigit/ButtondownKit/Sources/ButtondownKit/ButtondownClient.swift` (wrappers: `listEmails`, `updateEmail` — mirror existing `createDraft`/`sendDraft`/`email(id:)`)
- `Packages/BrightDigit/ButtondownKit/Sources/ButtondownKit/OpenAPI/openapi-generator-config.yaml` + `Scripts/generate-openapi-buttondown.sh` (regen for `update_email`)
- `Sources/ContributeButtondown/` (new — mirror `Sources/ContributeMailchimp/`: Source, Newsletter, MarkdownExtractor, FrontMatter, FrontMatterTranslator)
- `Sources/BrightDigitArgs/Config/CommandDispatcher.swift` (register `import buttondown`) + new `Import.ButtondownCommand.swift`
- `Sources/BrightDigitSite/Nodes/Section/NewsletterItem+Content.swift`, `.../PostItem+Content.swift` (forms)
- `Sources/BrightDigitSite/Nodes/Node+HTML.swift` (footer archive link), `.../Node+Head.swift` (RSS link)

### Track B — Plot/Rendering (worktrees: `phase5-publish-upgrade`, `phase5-tailwindkit`, then `phase5-component-migration`)

Per the user's "split foundational vs migration" choice with the TailwindKit-in-components constraint:

**Phase B1 — foundational, two parallel worktrees:**
- **`phase5-publish-upgrade` (#121):** bump vendored `Packages/Publish/Publish/Package.swift` (5.5) and `Packages/Publish/Plot/Package.swift` (5.4) toward 6.4 tools-version; remove outdated deps; confirm the whole tree still builds under strict concurrency. (Note: #121 has an empty GitHub body — scope inferred from the vendored-package tools-version gap; **confirm exact intended scope on the issue before starting**.)
- **`phase5-tailwindkit` (#69):** upgrade Tailwind from v2 (`Styling/package.json` `tailwindcss ^2.2.17`) and design/implement the `TailwindKit` Swift module emitting type-safe utility strings (`.bg(.blue, .500) → "bg-blue-500"`). Deliver the API surface + generated-class verification. **This must be mergeable before B2** so components can consume it.

**Phase B2 — migration, sequential in one worktree `phase5-component-migration`:**
- **#67 Component migration + Mermaid** (high-impact, rewrites `PiHTMLFactory` + all `Nodes/`): follow the issue's order — (1) header/footer in `Node+HTML.swift`/`PiHTMLFactory.swift`, (2) `Nodes/Section/`, (3) `Nodes/Pages/`. New components in `Sources/BrightDigitSite/Components/` **use TailwindKit** from #69. Keep `PageContent.main` as `[Node<HTML.BodyContext>]`; bridge leaf components via `.convertToNode()` (existing pattern in `ProductItem+Content.swift`/`ServicesBuilder.swift`). Add Mermaid: detect ```mermaid``` blocks → `<div class="mermaid">`, add mermaid.js CDN to `<head>`.
- **#53 enforce component-only** (depends on #67 being complete): in the vendored Plot fork (`Packages/Publish/Plot/Sources/Plot/API/`), mark `Node` element factories (`.element()`, `.div()`, …) `internal`; keep `Component`/`@ComponentBuilder` public. This is compile-time enforcement — it only passes once #67 removes all direct Node construction in `Sources/`.

**Why #67→#53 stay sequential in one worktree:** #53 cannot compile until #67 is done, and both touch the same rendering surface; splitting them into parallel worktrees would guarantee conflicts and broken intermediate builds.

**Critical files:**
- `Packages/Publish/Publish/Package.swift`, `Packages/Publish/Plot/Package.swift` (tools-version)
- `Styling/package.json`, `tailwind.config.js`, `postcss.config.js` (Tailwind upgrade); new `Sources/TailwindKit/` module + `Package.swift` product wiring
- `Sources/BrightDigitSite/PiHTMLFactory.swift`, `Sources/BrightDigitSite/Nodes/Node+HTML.swift`, `Nodes/Pages/*`, `Nodes/Section/*`, `Nodes/Social/*`
- `Sources/BrightDigitSite/Components/*` (new components), reuse `SectionElement`/`ServiceBox`/`Icon`/`ListItem` patterns
- `Packages/Publish/Plot/Sources/Plot/API/{Node,HTMLElements}.swift` (visibility change for #53)

### Track C — Content (NOT in grove/code plan)

**#24 (YouTube videos), #25 (unique frameworks)** — excluded per user decision. Tracked separately as content/media work. (If #25's Markdown deliverables are later wanted in-repo, they'd go in `Content/articles/` in their own worktree, but that is out of scope here.)

---

## Grove Command Sequence

Create worktrees off the default branch. Run each `grove add` from inside the grove root or any existing worktree.

```sh
# Track A — Buttondown (one sequential worktree)
grove add phase5-buttondown

# Track B — foundational (two parallel worktrees)
grove add phase5-publish-upgrade      # #121
grove add phase5-tailwindkit          # #69

# Track B — migration (created after #69 merges, so it branches from a tree that has TailwindKit)
grove add phase5-component-migration  # #67 then #53
```

**Branch/worktree naming** follows the observed repo convention (descriptive kebab-case, phase/issue-scoped, e.g. existing `buttondown-phase5-reprioritize`, `issue-142-content-checker`). Worktree dir name = branch name.

**Merge ordering (to minimize conflicts):**
1. `phase5-publish-upgrade` (#121) and `phase5-tailwindkit` (#69) — parallel, merge whichever lands first.
2. `phase5-component-migration` — **create after #69 is merged** so it inherits TailwindKit; merge #67 then #53.
3. `phase5-buttondown` — independent of Track B; merge whenever its chain (#33→#31→#124→#122/#127, plus #126) is complete. Sequence the Buttondown issues as their own PRs off this branch if per-issue review is desired.

Each issue should map to its own PR (grove branches can host multiple commits; open a PR per issue for reviewability, or per track if the user prefers fewer PRs).

---

## Execution Order Summary (dependency-respecting)

| Order | Track | Issue(s) | Worktree | Parallel with |
|-------|-------|----------|----------|---------------|
| 1a | B | #121 Upgrade Publish | `phase5-publish-upgrade` | 1b, 1c, 1d |
| 1b | B | #69 TailwindKit | `phase5-tailwindkit` | 1a, 1c, 1d |
| 1c | A | #33 CLI arch → #31 outbound publish | `phase5-buttondown` | 1a, 1b, 1d |
| 2c | A | #124 listEmails (P0) | `phase5-buttondown` | B tracks |
| 3c | A | #122 import, #127 cleanup, #126 form | `phase5-buttondown` | B tracks |
| 2b | B | #67 Component migration + Mermaid | `phase5-component-migration` (after #69 merges) | Track A |
| 3b | B | #53 enforce component-only | `phase5-component-migration` | Track A |

Tracks A and B run fully in parallel. The only hard intra-plan gate is **#69 → #67** (TailwindKit before component migration) and **#67 → #53**.

---

## Verification

**Buttondown track:**
- `#124`: unit test `listEmails` against a recorded fixture (mirror existing ButtondownKit tests); confirm paging works.
- `#31/#33`: end-to-end — create draft, send draft, verify one issue is actually published to Buttondown (needs `BUTTONDOWN_API_KEY` env var, never committed).
- `#122`: run `swift run … import buttondown`, confirm a new `Content/newsletters/NNN-*.md` renders correctly with correct front matter and `issueNo` continuation.
- `#127`: run the one-time PATCH script, spot-check early-2019 / mid / latest emails in Buttondown for no content loss.
- `#126`: draft/staging deploy — submit each subscribe form, confirm the address lands in the Buttondown list; footer archive + head RSS links resolve to Buttondown.

**Plot track:**
- `#121`: `swift build` passes under Swift 6.4 strict concurrency on macOS (and Ubuntu via CI container `brightdigit/publish-xml:6.4`); zero new concurrency warnings.
- `#69`: generated class names match Tailwind's expected output (e.g. `.bg(.blue, .500)` == `"bg-blue-500"`); Tailwind build (`npm run publish` in `Styling/` via NPMPublishPlugin) succeeds and produces valid CSS.
- `#67`: **site output byte-for-byte identical** to pre-migration (excluding mermaid blocks) — diff the generated `Output/` HTML; visually verify mermaid flowchart/sequence/class diagrams render. Use `/verify` or `/run` to build the site and inspect output.
- `#53`: compile-time — after marking Node factories `internal`, `swift build` must still succeed, proving no direct `.div()`/`.element()` remains in `Sources/`.

**General:** respect CLAUDE.md — strict concurrency is mandatory (never lower language mode to silence warnings); resolve module-name collisions at the call site; append any user corrections to `.claude/agent-notes.md`.

---

## Open Questions / Risks to Confirm Before Executing

1. **#121 scope** — the GitHub issue body is empty. Scope here is inferred (vendored Publish/Plot tools-version bump 5.4/5.5 → 6.4, remove outdated deps). Confirm the actual intent before starting.
2. **#31/#33 effort** — pulling these Phase 6 issues in adds real outbound-publishing work (Buffer client, PublishKit orchestrator wiring) beyond the milestone's stated scope. Confirm appetite, or #124 can proceed alone (wrapper only) while #122/#127 wait.
3. **PR granularity** — one PR per issue (more reviewable) vs one PR per track (fewer, larger). Assumed per-issue above.
