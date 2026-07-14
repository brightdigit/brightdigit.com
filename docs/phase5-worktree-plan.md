# Plan: Execute Milestone 5 (Phase 5) via Grove Worktrees & Branches

> **Status:** Confirmed after a full decision-tree review (24 decisions). This supersedes
> the earlier draft. Where this document and the milestone/PRD/issue bodies disagree, this
> document wins — several issue bodies are stale (see notes).

## Context

**Goal:** Work through the code issues in [Milestone 5 — "Phase 5: Swift 6.3 Subrepos + Components"](https://github.com/brightdigit/brightdigit.com/milestone/5), organized into parallel tracks using **grove** worktrees and branches.

**Environment:** grove bare-clone + worktree layout. Grove root is
`/Users/leo/Documents/Projects/brightdigit.com/`, bare clone is `brightdigit.com.git/`, each
sibling dir is a worktree whose name matches its branch (kebab-case). `grove add <name>`
creates worktree+branch; `grove go`, `grove list`, `grove pr` navigate.

### Integration model (standing directive)
- **`phase-05` is the integration BASE branch.** All Phase 5 worktrees **branch from `phase-05`**
  and all Phase 5 PRs **target `phase-05`**. **Nothing is committed directly on `phase-05`.**
- `grove add` is run from inside the `phase-05` worktree so new branches inherit `phase-05`
  as base. `phase-05` integrates to `main` once, at milestone end.
- **One PR per issue/worktree.** Each dependency gate is a merge into `phase-05`.

**Toolchain reality:** already Swift 6.4 (main package on 6.4 strict concurrency). All "6.3"
references in the milestone/PRD/issues are stale. Remaining subrepo work is the vendored
**Publish/Plot** stack (`swift-tools-version:5.5`/`5.4`) — this is what #121 targets.

---

## Worktrees (6 total)

| # | Worktree | Track | Hosts |
|---|----------|-------|-------|
| 1 | `phase5-spinetail-openapi` | A | Spinetail read-path verify/finish |
| 2 | `phase5-buttondown` | A | #124, #127, #122, #126 (one worktree, separate PRs) |
| 3 | `phase5-publish-upgrade` | B | #121 |
| 4 | `phase5-tailwind-upgrade` | B | Tailwind v2→v4 site migration |
| 5 | `phase5-tailwindkit` | B | #69 |
| 6 | `phase5-component-migration` | B | #67 then #53 |

~10 PRs: spinetail, #124, #127, #122, #126, #121, v4-upgrade, #69, #67, #53.

The four Track-A inbound issues share one worktree (same ButtondownKit surface); #67+#53 share
one worktree (#53 can't compile until #67 done, same rendering surface). **#31/#33** are a
decoupled outbound sub-track — no worktree in current scope (a potential 7th if pursued).

---

## Track A — Buttondown

**#124 (P0) is the true entry point.** The earlier assumption that #31/#33 (outbound publish)
must land first was rejected: the Buttondown account is already populated, and #124/#122/#127
test against the existing corpus + fixtures. #31/#33 are **decoupled** and not on the critical
path.

### Newsletter archive state (why #127 exists and its real shape)
- Local `Content/newsletters/` has **116 issues (issueNo 1–117)**; front matter is **100% valid**
  (all have issueNo/title/date), but **bodies are pervasively cruft-laden** (115/116 carry
  mailchimp/gallery URLs, 112/116 raw email HTML + client chrome, 12/116 invisible-spacer runs).
- Buttondown's public archive covers only **~98–118 (20 issues)** and is broken: missing the
  entire early history (~1–97), **missing #114**, and issues 115–117 show HTML artifacts.
- Therefore local `.md` **cannot** be the clean-body source (same Mailchimp origin, same cruft).
  **Canonical source = Mailchimp**, read via the **rebuilt Spinetail** (`sentCampaigns` +
  `archiveHTML`), NOT the deprecated `ContributeMailchimp`.

### Items
- **#124 — `listEmails` wrapper.** Paged public wrapper over `Operations.list_emails` on
  `ButtondownClient`. Fixture-tested (mirror existing ButtondownKit tests). The read primitive
  everything else uses. → `phase5-buttondown`.
- **Spinetail read path** — `phase5-spinetail-openapi`. `sentCampaigns`/`archiveHTML` already
  implemented against real spec ops (`getCampaigns`, `getCampaignsIdContent`); **likely
  verify-only** — scope to whatever's actually missing. **Gate before #127.**
- **#127 — archive one-shot (fix at source).** Self-contained reconciliation:
  Mailchimp (via Spinetail) → clean HTML→Markdown → **Buttondown ONLY** via
  `createEmail` (backfill missing ~1–97 + #114, as archived/no-send) and `updateEmail`
  (clean cruft in 98–117). Requires adding `update_email` to
  `openapi-generator-config.yaml` + regenerating. **Does NOT touch local `Content/newsletters/*.md`**
  and does **NOT** use the #31/#33 outbound orchestrator. → `phase5-buttondown`.
- **#122 — import new/missing newsletters.** Incremental `import buttondown`: list Buttondown
  emails, skip any issueNo already present locally, generate `.md` only for new ones (118+).
  Old-issue import is best-effort, not a requirement. Blocked on #124. → `phase5-buttondown`.
- **#126 — subscribe form swap.** Replace Netlify `subscribers` forms + hardcoded Mailchimp
  footer/RSS links with Buttondown equivalents. Independent. → `phase5-buttondown`.
- **#31/#33 — outbound publish.** Decoupled sub-track (future live sends). Not scheduled here.

**Critical files:** `ButtondownKit/…/ButtondownClient.swift` (add `listEmails`, `updateEmail`
mirroring `createDraft`/`sendDraft`/`email(id:)`); `ButtondownKit/…/OpenAPI/openapi-generator-config.yaml`
+ generate script (regen for `update_email`); `Packages/BrightDigit/Spinetail/…/MailchimpClient.swift`
(`sentCampaigns`/`archiveHTML`); new `Sources/ContributeButtondown/`; `CommandDispatcher.swift`
+ new `Import.ButtondownCommand.swift`; `NewsletterItem+Content.swift`/`PostItem+Content.swift`
(forms); `Node+HTML.swift`/`Node+Head.swift` (footer/RSS links).

---

## Track B — Plot/Rendering

Hard gates: **{#121, v4-upgrade, #69} → #67 → #53.**

- **#121 — modernize vendored Publish/Plot.** Broad dependency modernization **fenced to
  `Packages/Publish/*`** (Publish, Plot, Splash, Publish plugins). **Excludes** SwiftTube/Spinetail
  (own tracks) and main-app deps. Bump tools-versions 5.5/5.4 → 6.4, resolve strict-concurrency
  properly (never lower language mode). **Hard gate before #67.** → `phase5-publish-upgrade`.
- **Tailwind v2 → v4 site migration** — `phase5-tailwind-upgrade`. **v4-only.** Rip out the
  PostCSS-plugin setup (`postcss.config.js` requiring `tailwindcss`/`tailwindcss/nesting`) for the
  v4 engine; move `tailwind.config.js` → CSS-first `@theme`; `styles.css` `@tailwind base/components/utilities`
  → `@import "tailwindcss"`; rename all v2 class strings in existing `Sources/BrightDigitSite/**`
  markup to v4. **Verified visually** (byte output must change). Done **before** #67.
- **#69 — TailwindKit.** Standalone **`TailwindStyle` value builder** — fluent, every member
  returns `TailwindStyle` (bare utilities like `.flex`/`.gap` as computed properties; parameterized
  like `.gap(4)`/`.font(.medium)`/`.bg(.blue,.500)` as methods). Plus **one Plot sugar**
  `.tailwind(_ style: TailwindStyle)` → `.class(style.rendered)`, for call sites like
  `.tailwind(.flex.items(.center).gap)`. Utilities are a **closed enum**, grown **component-driven**;
  the escape hatch for unmodeled classes is **Plot's existing `.class("...")`** (kept public).
  Emits **v4 tokens only**. Plot-independent; unit-tested by string equality
  (`.rendered == "flex items-center gap-4"`). → `phase5-tailwindkit`.
- **#67 — component migration + Mermaid.** Starts after #121 + v4-upgrade + #69 all merge.
  **Commit 1 = reconcile:** make TailwindKit emit every v4 class the migrated markup uses (close
  gaps between the upgrade and the module). Then the structural Node→component refactor of
  `PiHTMLFactory` + all `Nodes/`, producing **byte-identical `Output/` HTML** (excluding mermaid).
  Add Mermaid: ```mermaid``` blocks → `<div class="mermaid">` + mermaid.js in `<head>`.
  → `phase5-component-migration`.
- **#53 — enforce component-only at the theme seam.** Change the **vendored Publish**
  `HTMLFactory` protocol (`Packages/Publish/Publish/Sources/Publish/API/HTMLFactory.swift`) so its
  methods return **`Component`** instead of `Node<HTML.BodyContext>`. Element factories stay
  **public** (components are authored from them). Compiles iff #67 has migrated every factory
  method to components. → `phase5-component-migration` (after #67).

**Critical files:** `Packages/Publish/Publish/Package.swift`, `Packages/Publish/Plot/Package.swift`;
`Styling/package.json`, `postcss.config.js`, `tailwind.config.js`, `styles/styles.css`; new
`Sources/TailwindKit/`; `PiHTMLFactory.swift`, `Node+HTML.swift`, `Nodes/**`, new
`Sources/BrightDigitSite/Components/*`; `Packages/Publish/Publish/…/API/HTMLFactory.swift` (+ `Theme.swift`).

---

## Excluded

**#24 (YouTube videos), #25 (unique frameworks)** — fully out of scope; no tracking in this plan.
Nothing in the eight code issues depends on them.

---

## Dependency graph

```
TRACK A:
  phase5-spinetail-openapi ─┐
  #124 (P0) ────────────────┼─> #127 (archive one-shot → Buttondown only)
                            └─> #122 (import new/missing) [needs #124]
  #126 (independent)     #31/#33 (decoupled outbound; not scheduled)

TRACK B:
  #121 (fenced Publish/Plot) ─┐
  phase5-tailwind-upgrade (v4)┤
  #69 TailwindKit (v4 module) ┴─> #67 [reconcile → Node→component, byte-identical] ─> #53
```

Tracks A and B run in parallel.

---

## Grove command sequence

Run from inside the `phase-05` worktree so each branch bases on `phase-05`:

```sh
# Track A
grove add phase5-spinetail-openapi
grove add phase5-buttondown

# Track B — foundational (parallel)
grove add phase5-publish-upgrade      # #121
grove add phase5-tailwind-upgrade     # v2 -> v4 site migration
grove add phase5-tailwindkit          # #69

# Track B — migration (create after v4-upgrade + #69 merge into phase-05)
grove add phase5-component-migration  # #67 then #53
```

---

## Verification

- **#124:** unit-test `listEmails` paging against a recorded fixture.
- **Spinetail:** build the worktree; confirm `sentCampaigns`/`archiveHTML` return usable data
  (verify-first — likely no code needed).
- **#127:** run the one-shot; spot-check early (2019) / mid / latest emails in the Buttondown
  archive for backfill + no content loss; confirm #114 present. Needs `BUTTONDOWN_API_KEY` and
  `MAILCHIMP_API_KEY` (env only, never committed).
- **#122:** run `import buttondown`; confirm only new issues create `Content/newsletters/NNN-*.md`
  with correct front matter + issueNo continuation.
- **#126:** staging deploy; submit each form → address lands in Buttondown list; footer/RSS links resolve.
- **#121:** `swift build` under 6.4 strict concurrency (macOS + CI container); zero new warnings.
- **v4-upgrade:** Tailwind v4 build succeeds; **visual** equivalence vs pre-upgrade.
- **#69:** `.rendered` strings match v4 output (`.bg(.blue,.500) == "bg-blue-500"`); Plot-independent tests.
- **#67:** generated `Output/` **byte-identical** to pre-migration (excluding mermaid); mermaid renders.
- **#53:** after flipping `HTMLFactory` to `Component`, `swift build` still succeeds — proving no
  direct node construction remains at the theme layer.

**General:** strict concurrency is mandatory (never lower language mode); resolve module-name
collisions at the call site; append user corrections to `.claude/agent-notes.md`.

---

## Facts to verify at execution (not decisions)

1. Whether `phase5-spinetail-openapi` needs real code or is verify-only.
2. Whether the `update_email` regen is clean.
3. Whether Buttondown #118 is a real published issue or a draft (affects #122's first test only).
