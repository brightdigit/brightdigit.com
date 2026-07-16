# Plan: Execute Milestone 5 (Phase 5) via Grove Worktrees & Branches

> **Status:** Confirmed after a full decision-tree review (24 decisions). This supersedes
> the earlier draft. Where this document and the milestone/PRD/issue bodies disagree, this
> document wins — several issue bodies are stale (see notes).

---

## ⚡ Execution status — updated 2026-07-16 (Track A complete; #121 merged; #67+#53 in review on PR #157)

The design below is the pre-execution plan; **this section reflects current reality.**

### PR ↔ issue status
| Issue | PR | Branch | Status |
|-------|-----|--------|--------|
| #146 Spinetail read-path | #148 | `phase5-spinetail-openapi` | ✅ merged into `phase-05` |
| #124 listEmails wrapper | #147 | `phase5-buttondown` | ✅ merged into `phase-05` |
| #145 Tailwind v2→v4 | #150 | `phase5-tailwind-upgrade` | ✅ merged |
| #69 TailwindKit | #149 | `phase5-tailwindkit` | ✅ merged |
| #126 subscribe-form swap | #154 | `phase5-buttondown-form` | ✅ merged into `phase-05` |
| #127 archive one-shot | #156 | `phase5-buttondown-archive` | ✅ merged into `phase-05` |
| #122 import new/missing | #155 | `phase5-buttondown-import` | ✅ merged into `phase-05` |
| #121 Publish stack | #151 | `phase5-publish-upgrade` | ✅ merged into `phase-05` (commit `aed12dec`) |
| #67 + #53 | **#157** | `phase5-component-migration` | 🔄 **open, ready for review — CI green (both workflows); awaiting Leo's merge** |

**Tracks A + B foundational work are fully landed on `phase-05`.** The only open Phase-5 PR is
**#157 (#67 + #53, combined)**. All originally-planned Phase-5 code issues are now either merged
or in review on #157.

New tracking issues filed: **#152** (remove vendored Files → stdlib `FilePath`/Foundation, staged, post-phase-5) · **#153** (reclaim parallel page generation — measure-first, likely not worth it).

### #67 + #53 execution (PR #157, 2026-07-16) — READY FOR REVIEW

**Leo decisions this session:** one **combined PR** for #67 + #53; TailwindKit models **only officially documented Tailwind v4 classes** (nothing custom); Mermaid is **verify-only**; success criterion is **semantic (whitespace-normalized) equivalence**, not strict byte-identical.

**Three issue-body corrections discovered (repo reality overrides stale issue text):**
1. **Site markup uses semantic/BEM classes, not Tailwind utilities.** The Tailwind utilities live in `Styling/styles/styles.css` via **391 `@apply` directives**; BrightDigitSite does not depend on TailwindKit. So #67's "Commit 1 = reconcile TailwindKit / byte-identical utility migration" premise is false — TailwindKit coverage is a **separate module-only** deliverable, not wired into markup.
2. **Mermaid + highlight.js are already integrated client-side** (`Styling/scripts/index.ts` → `/js/main.js`); #67's Mermaid checklist was already satisfied → verify-only.
3. **`HTMLFactory` already returns `HTML` (full document), not `Node<HTML.BodyContext>`.** #53's real change: methods return `Component`; the factory yields the document via `HTML(...).node` (`Node<HTML>: Component`), which still renders `<!DOCTYPE html>`.

**Landed on `phase5-component-migration` (all verified, semdiff = 0 structural across 449 pages):**
- **Part A (#67 Node→Component):** `HeaderComponent`/`FooterComponent`, `PostItem`, `NewsletterItem`, `PodcastItem`, `IndexBuilder`+`IndexBuilder+LatestArticle`+`Testimonial.listItem`, `AboutBuilder`, `ContactBuilder` (`ServicesBuilder` was already component-based). Bespoke leaves (video, contentBody, iframes, `.data(named:)` anchors, no-alt/class-first `<img>`, netlify `<form>`) kept as raw nodes embedded in components.
- **Part B (#67 TailwindKit):** modeled the documented v4 vocabulary from the 391 `@apply` directives; **excluded** every non-documented token (`btn`/`btn-normal`, all `*-bellow-*`, `w-5/12`, named `leading-*`, bare `filter`/`backdrop-filter`; note the v4 radius rename `rounded-xs`). 27 `.rendered` tests; module-only, not wired into markup.
- **Mermaid:** verified end-to-end (```mermaid``` → `<pre><code class="language-mermaid">` hook + `/js/main.js` transform + `mermaid.run()`); temp file removed, baseline unaffected.
- **Part C (#53):** flipped `HTMLFactory`/`Theme`/`HTMLGenerator`/`FoundationHTMLFactory`/`HTMLFactoryMock` + 3 inline test factories + `PiHTMLFactory` from `HTML` to `Component`. **Negative check:** a bare `HTML` return no longer compiles (`'HTML' does not conform to 'Component'`). Publish subrepo pushed (`git subrepo push --all` after `./fix-subrepo-parents.sh`).
- **Lint follow-up:** fixed `Sources/BrightDigitSite/**` house style (only the CI `lint` job / repo-root `Scripts/lint.sh` covers the main app; package lints don't). Output unchanged.

**Verification:** whole-repo `swift build`/`swift test` green (9 app + 86 Publish + 27 TailwindKit); repo-root + Publish + TailwindKit strict lint 0 violations; **both CI workflows green** on the final commit — `CI Pipeline` (build-linux, lint, package-linux, deploy) and `Packages CI` (Publish + TailwindKit on macOS + Ubuntu). **Do NOT merge — Leo reviews/merges.**

**Gotchas recorded** (in `.claude/agent-notes.md`): the repo-root `./Scripts/lint.sh` WITHOUT `CI=1` runs `header.sh`, which pollutes ALL vendored Publish files with a duplicate BrightDigit header — always use `CI=1 LINT_MODE=STRICT` to check; swift-format `[LineLength]` (90) is separate from SwiftLint `line_length` and needs the long string on its own line inside the call.

### Next up (after #157 merges)
Track B is then complete. Phase-5's remaining scope is `phase-05` → `main` integration (milestone end) plus the deferred follow-ups #152/#153 (post-phase-5) and the decoupled #31/#33 outbound sub-track (not scheduled).

### Key decisions since the original plan
- **Subrepos:** `git subrepo pull/push --all` works; recovery via `./fix-subrepo-parents.sh` (documented in `CLAUDE.md`).
- **#151 dropped 3 vendored Sundell libs** from the Publish stack: **CollectionConcurrencyKit** (→ serial loops), **Codextended** (→ internal `StringCodingKey` shim), **Sweep** (→ `NSRegularExpression`). Later also **removed Splash + SplashPublishPlugin** (syntax highlighting is client-side highlight.js). **Kept:** Files, Ink, Plot, Publish.
- **#151 made `PublishingContext` fully `Sendable`** (DateFormatter→`Date.ParseStrategy`, `TagCache`→`Mutex`, `Website: Sendable`, etc.) — **groundwork only; parallel generation NOT reintroduced** (see #153).
- **Platform baseline bumped macOS 13 → macOS 15** (`Synchronization.Mutex` requirement; cascaded to the 4 plugins). `CLAUDE.md` updated.
- **#151 typed throws:** Files public API `throws(FilesError<…>)`, Publish internal single-error helpers.
- **#151 scaffolding + lint:** standard BrightDigit setup added to the kept packages, lint enabled. **Originally** SwiftLint (`no_unchecked_sendable`) + build were the strict gates with swift-format/periphery advisory — **superseded by the review round below: the full house style is now strictly enforced** on Files/Ink/Plot/Publish. **Publish tests kept on XCTest** (not converted — per Leo).

### #151 Leo review-response round (2026-07-15)
Leo left 4 inline review comments on PR #151 (review `4704887635`) + 1 CI-fix ask; all resolved, committed, pushed, and replied to. 8 commits (`e6893532..c559d92e`). Whole-repo `swift build`/`swift test` green; each vendored package passes `CI=1 LINT_MODE=STRICT ./Scripts/lint.sh` with 0 violations.
- **ReadingTime "why a mutex?"** → the `Mutex` only guarded a **process-global cache** whose sole job was smuggling an install-time `wordsPerMinute` into the parameterless `Item.readingTime`. Removed the cache (and the plugin's caching role + the console `output` hook); `Item.readingTime` now **computes on demand**, stays synchronous, no consumer changed. No mutex, no actor. Dropped the public `Plugin.readingTime(wordsPerMinute:)` API + its `.installPlugin` call.
- **"remove command-line support in Publish"** → removed `PublishingPipeline.resolveStepKind()`/`--deploy` sniffing, `PublishRuntimeOverride`, and the whole now-unreachable **deployment machinery** (`DeploymentMethod`, `PublishingStep.deploy`, `deployedUsing:` params, `createDeploymentFolder`, `Step.Kind`). Pipeline just runs generation. First party was never using it (drives mode via its own `--mode`, deploys via Netlify).
- **LockIsolated "why Mutex not actors?"** → removed the **test-only** helper entirely. `HTMLFactoryMock` → **init-injection** (immutable `let` closures, no boxes); the 5 observer tests that only captured intermediate pipeline state from `@Sendable` step closures were deleted (framework-internal coverage). The actor route was rejected — it would force `HTMLFactory` + `DeploymentMethod.Body` async, cascading through the theme + Plot DSL.
- **"enforce everything we do at BrightDigit"** (`.swiftlint.yml`) → **replaced the relaxed `only_rules` config with the full house style + strict `lint.sh`** (swift-format now gating, not advisory) on **Files, Ink, Plot, Publish**; remediated **every** violation to zero (~1,600 fixes: explicit ACLs, docs, member ordering, bracket layout, `one_declaration_per_file`/`file_length` splits — Files.swift→18 files, Plot API→~50, Publish→~28). ~24 genuinely-known-safe force-unwrap/`try!` sites (HOME env, root folders, type-guarded `as!`, regex-from-literal) kept a scoped `swiftlint:disable` + reason per Leo's case-by-case call, rather than risk behavior changes in upstream code.
- **CI: flaky `Lint TransistorPublishPlugin`** → root cause was `mise` building the **advisory, never-run-in-CI periphery** tool from source and SIGSEGV-ing under parallel cold-build contention (failing job moved around run to run). Fixed with `MISE_DISABLE_TOOLS: "spm:peripheryapp/periphery"` on the lint job (single-point, deterministic; local dev keeps periphery).
- **"Why aren't we just using Swift Markdown?"** → we already are under the hood (#40 façade). Remaining Ink surface (`MarkdownParser` / `Modifier` / front-matter + HTML emitter) stays in-fence for #121; collapsing to raw swift-markdown HTML would be a separate follow-up.
- **"remove InkCLI"** → done; Ink is library-only.
- **Note on execution:** the lint remediation was delegated to per-package subagents; a session usage-limit hit mid-run killed them and one Plot agent's nested sub-agents **resurrected after reset and corrupted the tree** — recovered by stopping runaways, reverting, and redoing Files/Plot/Publish one at a time with **single non-nesting agents**, each verified with a real `swift build`/`swift test` (SourceKit diagnostics were repeatedly stale — do not trust them for large file-split refactors).
- **#147 ButtondownClient redesign (merged):** domain types `Email`/`EmailStatus`/`EmailPage` (no `Components.*` in public API); `UnderlyingClientProtocol` (**must be public**) + capability protocols `EmailListing`/`EmailDrafting`/`EmailRetrieving` implemented via `extension … where Self: UnderlyingClientProtocol`; `listAllEmails(status:pageLimit:)`.
- **#149 TailwindKit** is now a standalone package `Packages/BrightDigit/TailwindKit` (future subrepo); shade cases `_500`→`s500` (lint), e.g. `.bg(.blue, .s500)`.

### Standing directives (also in `.claude/agent-notes.md`)
- **Always Swift Testing** for NEW tests; do NOT bulk-convert existing vendored XCTest suites.
- Vendored/Publish-stack + TailwindKit use **plain standard Swift 6.4** (`tools-version:6.4` only) — no upcoming-feature `swiftSettings` flags.
- Phase-5 PRs target `phase-05`; **Leo reviews/merges every PR** (agents never merge).

### Transfer checklist (for the other computer)
- ✅ All merged work is on `origin/phase-05`; `phase5-publish-upgrade` (#151) is pushed.
- ⚠️ **Copy `brightdigit.com.env` manually** — it lives at the grove root, OUTSIDE the repo (MAILCHIMP/YOUTUBE/BUTTONDOWN keys), and does NOT travel via git.
- Merged worktree branches were auto-deleted on the remote; recreate worktrees with `grove add` as needed. `phase5-component-migration` still needs creating (after #151 merges).
- The `~/.claude/plans` scratch plan and private memory store are machine-local; the durable facts live in this doc + `CLAUDE.md` + `.claude/agent-notes.md` (all in-repo).

### Remaining work
- **Track A:** ✅ fully landed on `phase-05`.
- **Track B:** ✅ code complete — #121/#145/#69 merged; **#67 + #53 in review on PR #157** (CI green, awaiting Leo's merge). Nothing left to author.
- **After #157 merges:** integrate `phase-05` → `main` (milestone end). Deferred: #152/#153 (post-phase-5), #31/#33 (decoupled outbound, unscheduled).

---

## Context

**Goal:** Work through the code issues in [Milestone 5 — "Phase 5: Swift 6.4 Subrepos + Components"](https://github.com/brightdigit/brightdigit.com/milestone/5), organized into parallel tracks using **grove** worktrees and branches.

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
| 1 | `phase5-spinetail-openapi` | A | #146 (Spinetail read-path verify/finish) |
| 2 | `phase5-buttondown` | A | #124, #127, #122, #126 (one worktree, separate PRs) |
| 3 | `phase5-publish-upgrade` | B | #121 |
| 4 | `phase5-tailwind-upgrade` | B | #145 (Tailwind v2→v4 site migration) |
| 5 | `phase5-tailwindkit` | B | #69 |
| 6 | `phase5-component-migration` | B | #67 then #53 |

~10 PRs: #146, #124, #127, #122, #126, #121, #145, #69, #67, #53.

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
- **#146 Spinetail read path** — `phase5-spinetail-openapi`. `sentCampaigns`/`archiveHTML` already
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
- **#145 Tailwind v2 → v4 site migration** — `phase5-tailwind-upgrade`. **v4-only.** Rip out the
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
  #146 spinetail read-path ─┐
  #124 (P0) ────────────────┼─> #127 (archive one-shot → Buttondown only)
                            └─> #122 (import new/missing) [needs #124]
  #126 (independent)     #31/#33 (decoupled outbound; not scheduled)

TRACK B:
  #121 (fenced Publish/Plot) ─┐
  #145 Tailwind v2→v4 (site)  ┤
  #69 TailwindKit (v4 module) ┴─> #67 [reconcile → Node→component, byte-identical] ─> #53
```

Tracks A and B run in parallel.

---

## Grove command sequence

Run from inside the `phase-05` worktree so each branch bases on `phase-05`:

```sh
# Track A
grove add phase5-spinetail-openapi    # #146
grove add phase5-buttondown           # #124, #127, #122, #126

# Track B — foundational (parallel)
grove add phase5-publish-upgrade      # #121
grove add phase5-tailwind-upgrade     # #145 (v2 -> v4 site migration)
grove add phase5-tailwindkit          # #69

# Track B — migration (create after v4-upgrade + #69 merge into phase-05)
grove add phase5-component-migration  # #67 then #53
```

---

## Verification

- **#124:** unit-test `listEmails` paging against a recorded fixture.
- **#146 Spinetail:** build the worktree; confirm `sentCampaigns`/`archiveHTML` return usable data
  (verify-first — likely no code needed).
- **#127:** run the one-shot; spot-check early (2019) / mid / latest emails in the Buttondown
  archive for backfill + no content loss; confirm #114 present. Needs `BUTTONDOWN_API_KEY` and
  `MAILCHIMP_API_KEY` (env only, never committed).
- **#122:** run `import buttondown`; confirm only new issues create `Content/newsletters/NNN-*.md`
  with correct front matter + issueNo continuation.
- **#126:** staging deploy; submit each form → address lands in Buttondown list; footer/RSS links resolve.
- **#121:** `swift build` under 6.4 strict concurrency (macOS + CI container); zero new warnings.
- **#145 v4-upgrade:** Tailwind v4 build succeeds; **visual** equivalence vs pre-upgrade.
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
