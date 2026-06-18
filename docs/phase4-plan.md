# Phase 4 — OpenAPI & Dependency Migration: consolidated plan & status

> **This is the live, current source of truth for Phase 4.** It consolidates four earlier
> notes written at different points in the migration:
> - `../PHASE4-OPENAPI-MIGRATION-PLAN.md` — the original parallel-worktree orchestration plan
>   (lives outside the repo; historical record of how the work was split into waves).
> - [`openapi-migration-approach.md`](./openapi-migration-approach.md) — OpenAPI toolchain
>   reference (mise CLI generator, full-spec→filter→generate, committed codegen). **Shipped.**
> - [`phase4-ink-swift-markdown-approach.md`](./phase4-ink-swift-markdown-approach.md) — the
>   #40 "keep Ink's emitter, replace only its parser" design. **Shipped.**
> - [`phase4-ink-content-triage.md`](./phase4-ink-content-triage.md) — the 265-file golden-diff
>   triage feeding the #104 content follow-up.
>
> Those four remain as reference detail; this doc is what to read first.

## 1. Status

Phase 4 swaps stale dependencies across the `brightdigit.com` monorepo: SwagGen+Prch →
swift-openapi-generator, Ink → swift-markdown, ShellOut → swift-subprocess, Kanna → SwiftSoup,
MarkdownGenerator → swift-markdown, and swift-argument-parser → swift-configuration. **The code
migration is essentially complete and merged**; what remains is one content follow-up, one
import-output verification, and end-to-end checks before the `phase-04` line reaches production.

| Issue | Scope | State | Landed via |
|---|---|---|---|
| #37 | OpenAPI: SwiftTube (YouTube) + Spinetail (Mailchimp) | ✅ done | #88, #91, #97 |
| #45 | Remove Prch | ✅ done | (folded into #37 tracks) |
| #82 | OpenAPI parent (YouTube/Mailchimp/Buttondown) | ✅ done | #88/#90/#91/#97 |
| #83 | ButtondownKit greenfield client | ✅ done | #90 |
| #46 | ShellOut → swift-subprocess (Publish + NPMPublishPlugin) | ✅ done | #89 |
| #47 / #84 | Kanna → SwiftSoup **and** MarkdownGenerator → swift-markdown (Tagscriber) | ✅ done | #86 |
| #40 | Ink parser → swift-markdown (Publish ecosystem) | ✅ done | #85, #101 |
| #44 | swift-argument-parser → ConfigKeyKit + swift-configuration | ✅ done | #87, #102 |
| #95 | per-ref deploy concurrency | ✅ done | #100 |
| #96 | single-source packages CI manifest | ✅ done | #100 |
| #104 | content fixes for reader-visible Ink→swift-markdown changes | ✅ done | #106 (close issue) |
| **#94** | **verify SwiftSoupMarkdownGenerator import output (dl/table)** | 🟡 **remaining** | code in #103 |
| #92 | restore Linux coverage upload under Swift 6.4 | ⏭️ **deferred → Phase 8** | — |
| #105 | verify `import wordpress` end-to-end | ⏭️ **deferred** (WordPress out of scope) | — |
| #108 | mailchimp import aborts on a campaign's 503 archive content | ⏭️ **out of Phase 4** | — |

## 2. What shipped

- **OpenAPI clients (#37/#45/#82/#83).** SwiftTube, Spinetail, and the greenfield ButtondownKit
  are rebuilt on Apple's swift-openapi-generator. The generator is a **mise-managed CLI**
  (`spm:apple/swift-openapi-generator`), not a SwiftPM plugin; each client ships the full
  upstream spec, filters to the operations we use, and **commits** generated `Types.swift` /
  `Client.swift` under `Sources/<Target>/Generated/`. Clients are `async`/`await`; Prch and the
  SwagGen trees are deleted. Verified by offline contract tests (mock `ClientTransport`), not an
  output diff. Detail: [`openapi-migration-approach.md`](./openapi-migration-approach.md).
- **Ink → swift-markdown (#40).** Kept Ink's HTML **emitter** + modifier plumbing and replaced
  only its `Reader`-based **parser** with a swift-markdown front end that builds Ink's node IR.
  `MarkdownParser` is now a façade over the retained emitter, so `PublishingContext`,
  `MarkdownContentFactory`, and the three plugins (Splash/Transistor/YouTube) compile unchanged.
  Output is intentionally **not** byte-identical — swift-markdown is CommonMark/GFM-correct.
  Detail: [`phase4-ink-swift-markdown-approach.md`](./phase4-ink-swift-markdown-approach.md).
- **ShellOut → swift-subprocess (#46).** NPMPublishPlugin's `npm ci`/`npm run publish` moved to
  swift-subprocess; the unused Publish CLI/git-deploy code was stripped. ShellOut is gone.
- **Tagscriber (#47/#84).** `KannaMarkdownGenerator` → `SwiftSoupMarkdownGenerator` (Kanna →
  SwiftSoup, XPath → CSS) and the markdown-emission half moved MarkdownGenerator → swift-markdown.
  Now lives in the **Contribute** package, pure-Swift, no `pandoc` binary.
- **CLI (#44).** The swift-argument-parser tree is removed; commands are ConfigKeyKit
  `Command`s resolved through swift-configuration. Each command layers
  `[CommandLineArgumentsProvider(), EnvironmentVariablesProvider()]`, so **every flag also works
  as an env var** (uppercase the key, `-`→`_`, e.g. `--youtube-api-key` → `YOUTUBE_API_KEY`).
- **CI (#95/#96).** Per-ref deploy concurrency stops false-red PRs; the packages matrix derives
  from `.github/packages.json`.

## 3. Reader-visible content follow-up (#104, supersedes #93)

The new parser is correct and ships as-is. A golden diff of old-Ink vs new over all 441 rendered
pages found **267 differ**, but the overwhelming majority are **invisible** (inter-block `\n`,
preserved `&nbsp;`, lone-`<img>` `<p>`-wrap, newsletter `<span class="mcnPreviewText">`
`display:none` wrap). Do not spend review time on those.

**The one genuine reader-visible regression:** ~23 files have a stray space before a closing `**`
(e.g. `for you. **`). CommonMark's right-flanking rule refuses to close the emphasis, so the
literal `**` now renders. Old-Ink bolded it anyway. **Fix = pure content edit:** delete the stray
space so the closing `**` hugs the text (`for you. **` → `for you.**`). The 23-file checklist and
per-file leaked fragments are in #104 and
[`phase4-ink-content-triage.md`](./phase4-ink-content-triage.md) §"Issue #93". Exclude the three
code-glob false positives (`bushel-launch-part-3.md`, `tuist-xcode-project-setup.md`,
`objective-c-and-swift-being-friendly.md`) where `**` is inside code. A small secondary set
(emphasis/list/other CommonMark improvements) warrants a quick eyeball, no edits expected.

## 4. Remaining work

### #104 — content fixes ✅ done (#106)
The 25 files were edited and merged in #106; verified 0 literal `**` in rendered body prose
across all 441 published pages. Re-run the acceptance grep over `Output/**/index.html` after a
fresh publish, then close the issue.

### #94 — verify SwiftSoupMarkdownGenerator import output (highest priority; keep open)
dl + layout-`<table>` handling merged (#103). Remaining: spot-check real import output for
tables / definition lists, decide which gaps matter, add regression tests for any gap closed.
Folds into the import verification below. Files:
`Packages/BrightDigit/Contribute/Sources/Contribute/SwiftSoupMarkdownGenerator.swift` and its
tests under `…/Contribute/Tests/ContributeTests/`.

### #92 — deferred to Phase 8
Linux coverage conversion fails under Swift 6.4's `.build/out/Products` layout; CI is green via
the `fail-on-empty-output: false` mitigation. Restoring real coverage is CI-only and does not
block shipping Phase 4 — moved to **Phase 8: Final Cleanup**.

### Out of Phase 4 scope (do not block shipping)
- **#108** — `import mailchimp` aborts on a campaign's 503 archive content (Spinetail decode + no
  per-campaign skip). A standalone import-robustness bug, **not** a Phase-4 migration item. For
  the §5.3 mailchimp verification, work around it (skip the offending campaign) rather than
  blocking on a fix.
- **#105** — `import wordpress` end-to-end verification: WordPress import is deferred.

## 5. Verification (imports + publish)

Per CLAUDE.md, Linux-in-Docker is the CI gate; these also run locally.

1. **Build:** `swift build` and `swift build -c release --product brightdigitwg`.
2. **Tests:** `swift test` (top-level) + changed vendored packages (Contribute, SwiftTube,
   Spinetail, ButtondownKit).
3. **Imports — podcast + mailchimp only** (WordPress deferred). Secrets come from the owner's
   shared file `../brightdigit.com.env` (`MAILCHIMP_API_KEY`, `MAILCHIMP_LIST_ID`,
   `YOUTUBE_API_KEY`). Copy it in (`cp ../brightdigit.com.env .env`, gitignored) and run in one
   shell (env doesn't persist across processes), writing to temp dirs so committed `Content/`
   isn't churned:
   ```sh
   set -a; source .env; set +a
   EXPORT_MARKDOWN_DIRECTORY=/tmp/imp-episodes    swift run brightdigitwg import podcast
   EXPORT_MARKDOWN_DIRECTORY=/tmp/imp-newsletters swift run brightdigitwg import mailchimp
   ```
   Spot-check the generated markdown — doubles as #94's import-output check (tables/dl).
4. **Publish:** `swift run brightdigitwg publish --mode drafts` then `--mode production`;
   confirm `Output/` generates. After #104 edits, re-run the #104 acceptance grep.
5. **CI parity gate:** Docker `swift build && swift test` + `LINT_MODE=STRICT CI=true
   ./Scripts/lint.sh` (see `../PHASE4-OPENAPI-MIGRATION-PLAN.md` §Verification).

## 6. Conventions
- Agents/automation **open PRs; the owner squash-merges.** No direct pushes to `main`; no
  `git subrepo push` (vendored-package upstreaming is a later release step).
- The `phase-04` line must not reach production with the #104 `**` leaks unfixed.
