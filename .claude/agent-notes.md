# Agent Notes — Corrections & Standing Directives

This file is the running log of Leo's corrections and standing **always/never** directives
for this repo. It is the source of truth for *how* to work here.

**Read this file at the start of every work session, before doing any work.**

**Append one line per directive, proactively (without being asked), whenever Leo makes a
correction or gives an always/never instruction.** Newest lines go at the bottom. Keep each
entry to a single line; if a directive supersedes an earlier one, update or remove the stale line
rather than leaving both.

---

<!-- Append directives below, one per line. Example:
- Always run ./Scripts/lint.sh before committing; never call swiftlint directly.
-->
- Phase 5: `phase-05` is the integration BASE branch — all Phase 5 worktrees branch from it and all Phase 5 PRs target it; never commit directly on `phase-05`.
- TailwindKit (#69) targets Tailwind v4 ONLY; the v2→v4 site migration is a separate worktree done before #67 so #67 stays a byte-identical structural refactor.
- Newsletter archive fixes go to Buttondown ONLY via the #127 one-shot (source = Mailchimp through the rebuilt Spinetail, NOT deprecated ContributeMailchimp); do not rewrite local Content/newsletters/*.md.
- Phase 5 source of truth: `docs/phase5-worktree-plan.md` OVERRIDES the GitHub issue/milestone/PRD bodies wherever they disagree (several are stale, e.g. "Swift 6.3" refs — toolchain is 6.4).
- Phase 5 PRs: worktree agents may push their branch and open a PR with base `phase-05`, but NEVER merge — Leo reviews, approves, and merges every PR himself.
- Subrepos: pull/push everything with `git subrepo pull --all` / `git subrepo push --all` (tree must be clean). `--all` aborts on the first failure — the usual cause is a stale `.gitrepo` parent after a squash-merge/rebase; recover by running `./fix-subrepo-parents.sh` (resets all parents to HEAD, commits), then re-run.
- Testing: ALWAYS use Swift Testing (`import Testing` / `@Suite` / `@Test` / `#expect`), NEVER XCTest, for all NEW tests, repo-wide. Model on `Packages/BrightDigit/ButtondownKit/Tests` house style. Exception: do NOT bulk-convert existing vendored XCTest suites (e.g. the `Packages/Publish/*` stack) — leave them on XCTest.
- Swift settings: vendored Publish-stack packages and TailwindKit use plain standard Swift 6.4 (`// swift-tools-version:6.4` only) — do NOT add the `swift6Features` upcoming-feature `swiftSettings` array (ExistentialAny/InternalImportsByDefault/etc.) or a `Package@swift-6.0.swift` dual manifest to them. (First-party BrightDigit packages like SyndiKit still use the upcoming-feature array.)
- Use `.claude/agent-notes.md` as this repo's corrections log.
- Never pass Markdown-native Buttondown email bodies through the HTML-to-Markdown converter; copy their Markdown directly, while retaining HTML conversion for Mailchimp imports.
- Lint (SwiftLint) rules: ONE top-level type per file (`one_declaration_per_file`), filename must match its type (`file_name`), members ordered subtype→type_property→type_method→instance_method (`type_contents_order`), file ≤300 lines / type body ≤125 (STRICT promotes the warning to an error). So splitting a big file to fix `file_length` needs each new file to be one correctly-ordered type — reorder members and give tests their own per-type files + a shared fixtures type.
- Reproduce CI lint locally with `LINT_MODE=STRICT CI=1 ./Scripts/lint.sh` (per package too); `swift-format` and SwiftLint can disagree on borderline multiline calls — put the closing `)` on its own line to satisfy both, and shorten name aliases so calls fit ≤90 cols.
- Grove gotcha: `grove add <name>` from inside the `phase-05` worktree still branches the new worktree from `main`, NOT `phase-05`. After `grove add`, verify the base and `git reset --hard origin/phase-05` (safe while the branch has 0 unique commits) before starting work.
- TailwindKit: only model officially DOCUMENTED Tailwind v4 utility classes — nothing custom/non-documented (no `btn`, `bg-bellow-*`, typos, or v2/v3-only names). Excluded tokens stay as raw CSS / `.class("…")`.
- #67 Node→Component migration is verified by SEMANTIC (whitespace-normalized) equivalence, NOT strict byte-identical: Plot renders an embedded `.component(...)` via a sub-renderer spliced in as raw text, so nested closing tags lose the parent's 2-space indentation. Output stays structurally identical (same tags/attrs/text/order); only pretty-print whitespace of component subtrees changes. Verify with `diff <(tr -d '[:space:]' <baseline) <(tr -d '[:space:]' <new)` per file (excluding timestamped *.rss AND sitemap.xml, which carry build dates).
- #67 component-fidelity gotchas: (1) `Image(url:).class(x)` emits `src` BEFORE `class`, but the original `.img(.class,.src)` nodes usually put class first — use a raw `Node.img(.class,.src)` for any classed image. (2) `.attribute(named:).class()` DOES respect call order (match the original). (3) `Link(url:)` needs a `URLRepresentable` — pass `path.absoluteString` for a Publish `Path`. (4) A bare `<a>text</a>` (no href) needs a raw `Node.a`, not `Link(_,url:"")`. (5) Keep bespoke leaves (iframes with odd attrs, `.data(named:)`, `.raw(...)`) as raw nodes embedded in the component (Node: Component).
