# Wave 1 hygiene pass + Contribute 6.4 migration (2026-07-23/24)

Brought the seven Wave 1 package repos to the Wave 0 hygiene standard on their existing
working branches (CI hygiene, `.claude/` agent tooling, `AGENTS.md` + `CLAUDE.md` symlink,
unified README/badges, DocC + logo, `.spi.yml` `swift_version: "6.4"`, `.swift-version`
`6.4.x-snapshot`, `dependabot.yml`). PRs were left in their original draft state — **no
merges, no tags, no branch deletions, no root repin**. Then handled several follow-ups.

## Package-branch pushes (existing PRs, all CI green unless noted)

| Repo | PR / branch | Final HEAD | Notes |
| --- | --- | --- | --- |
| Publish | #1 draft `brightdigit-com-260406` | headers→2021 + hygiene | fork: README `+2/-0`, LICENSE untouched, no DocC, Sundell `header.sh` |
| TailwindKit | #1 draft `brightdigit-com-260717` | +LICENSE +.spi.yml | deleted DangerPR/TailwindKitTest (dead macos-12) → PR now green |
| ContributeButtondown | #1 draft `…260717` | standard | — |
| ContributeMailchimp | #1 draft `…260717` | un-deprecated | 7 `@available` removed, 17 tests added |
| ContributeRSS | #1 draft `…260717` | standard | fixed a real `write()` arg-forwarding bug |
| ContributeWordPress | #18 **ready** `…260406` | race fix | `.swift-version` 5.8→6.4.x-snapshot; `.spi.yml` target typo fixed |
| ContributeYouTube | #1 draft `…260717` | un-deprecated | 10 `@available` removed, 27 tests added |

## Publish copyright normalization
Source plan claimed PR #1 headers were already at 2021; they were not (78 files @2019,
2 @2020). `Scripts/lint.sh` invokes `header.sh -y 2021` (matching Plot), so every local
lint run produced an 80-file diff. Normalized all to 2021 (holder stays "John Sundell";
no BrightDigit/Leo Dion introduced). `lint.sh` is now idempotent on Publish.
Also fixed a real MIT-attribution hazard: `lint.sh` had shipped `-c "Leo Dion" -o
"BrightDigit"` for a Sundell fork, which would rewrite Sundell headers on any local run.

## Un-deprecation (Leo's rule: in active use ⇒ must be tested ⇒ not deprecated)
ContributeYouTube (10) and ContributeMailchimp (7) had blanket `@available(*, deprecated)`
added wholesale in commit `1e3a815` with no replacement, while the root actively compiles
both. Removed all 17; added real tests (27 / 17). swift-testing **hard-errors** on `@Suite`
/`@Test` applied to a deprecated declaration, so the deprecation had made real tests
impossible. Directive recorded in `.claude/agent-notes.md` in **both** repos.
⚠️ ContributeMailchimp's `AGENTS.md` had previously said "Do not remove the deprecation
annotations" — that stale directive was inverted.

## Contribute → Swift 6.4 (brightdigit/Contribute#19, open, unmerged)
Raised `swift-tools-version` 5.8→6.4 to match the stack. Fixed the resulting strict-
concurrency errors properly (Sendable conformances on `MarkdownContentBuilderOptions`,
`ImportError` payloads → `any Sendable`, and the `FileManagerProtocol`/`URLSessionable`/
`URLDownloader` download stack → `Sendable` with `@escaping @Sendable` completions).
No `swiftLanguageMode`, no relaxed flags, no `@unchecked Sendable` (repo SwiftLint bans it),
`NSLock`+`nonisolated(unsafe)` for the spy (Mutex needs macOS 15 vs the pkg's macOS 12
floor). Platform floors unchanged.

### Data race exposed (real bug, was hidden by Swift 5 mode)
`ContributeWordPress` `AssetDownloader.downloadUsingGroupDispatch` fanned downloads over a
`DispatchGroup` with every completion writing an unsynchronized `[URL: Error]`; with the real
`FileURLDownloader` those callbacks arrive concurrently on `URLSession`'s delegate queue.
`group.wait()` orders only the final read, not the writes. Fixed on ContributeWordPress #18
behind an `NSLock` (`AssetDownloadErrors`). Verified compiling against **both** Contribute
`main` and #19. **Contribute #19 and ContributeWordPress #18 must land together.**

## Stale CI-comment cleanup (comment-only PRs, all open/unmerged)
Two comments in the CI template described behavior the workflow no longer has: a "brightdigit
fork of swift-coverage-action … Pinned by SHA" (only in Contribute; the step is
`sersoft-gmbh/swift-coverage-action@v5`) and an `ENABLE_WATCHOS` gate that no repo actually
references. Removed from all 7 Wave 1 branches (in their hygiene commits) plus new PRs:
Contribute #18, Plot #5, Files #6, Ink #9, SwiftTube #23, Spinetail #36.

## Two items needing a human (cannot be done unattended)
1. **Plot, Files, Ink have no `CLAUDE_CODE_OAUTH_TOKEN` repo secret**, so `claude-review`
   fails on every PR there (`Either ANTHROPIC_API_KEY, CLAUDE_CODE_OAUTH_TOKEN, or workload
   identity federation is required`). SwiftTube/Spinetail/Contribute have it and pass —
   perfect correlation, unrelated to any change here. Add the secret (needs the token value
   + `admin:org` to inspect org secrets), or grant an org secret to those three repos.
2. **SyndiKit has no `build-macos-platforms` job at all** — the only repo with no iOS/tvOS/
   watchOS/visionOS simulator coverage. Its wide Swift matrix (5.10→6.3 + 6.4 nightly) is
   correct for its 5.10 floor. Adding a sim suite is substantive, not hygiene — left for Leo.

## Corrections to claims made earlier in the session
- Contribute **already had** the visionOS matrix row (line 186). Earlier "it's missing" was
  wrong (a truncated read).
- Contribute's README Requirements (Swift 5.8+ / macOS 12+) was **not** stale — it matched
  `Package.swift` exactly. (Now superseded by the 6.4 raise in #19.)

## Contribute logos (2026-07-26)

Replaced placeholder/wrong logos on ContributeMailchimp, ContributeRSS, ContributeYouTube,
and ContributeWordPress with the Pixelmator Contribute-family SVGs. README + DocC markdown
point at `*Logo.svg`; png/@2x/webp kept as companions only. ContributeButtondown still has
no Contribute-family mark (none provided). Pushed onto existing PR branches:
Mailchimp/RSS/YouTube `brightdigit-com-260717`, WordPress `brightdigit-com-260406`.

Follow-ups same day: presentation size set to ~200px tall (viewBox unchanged);
ContributeMailchimp Freddie outlines fixed (Pixelmator white evenodd strokes → black)
in `fb4a49c`.
