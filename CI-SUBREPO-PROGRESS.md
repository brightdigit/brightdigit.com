# CI / subrepo progress (Phase 5)

**Branch:** `ci/ensure-remote-deps-path-rewrite` (from `phase-05`; do not commit on `phase-05`)  
**Last updated:** 2026-07-18  
**Related:** [MERGE-AND-TAG-PLAN.md](MERGE-AND-TAG-PLAN.md), [PACKAGE-DEPENDENCIES.md](PACKAGE-DEPENDENCIES.md)

Working goal: every vendored subrepo’s **primary** workflow on its `.gitrepo` tip runs and succeeds. Autofix **build / lint / platform compile** (prefer `#if canImport`, else `#if os`; Package.swift floors when SPM product mins require it). Wait for Leo on infra / non-code blockers. Agents may open PRs to `phase-05` but never merge.

---

## Done

### Publish path-free for consumers (early Wave 1)

- [`Packages/Publish/Publish/Package.swift`](Packages/Publish/Publish/Package.swift) permanently uses `url:` + `revision:` for Ink / Plot / Files (no more nested `path:` when fetched by URL).
- Removed Publish’s `Scripts/ensure-remote-deps.sh` and CI rewrite steps.
- Subrepo-pushed; Wave-2 consumers (dual-mode ensure) can resolve Publish standalone.
- Nested-path SPM error (`depends on local package 'ink'`) is **gone**.

### SundialKitStream dual-mode (Step 0)

- Named `path:` deps kept for monorepo; `Scripts/ensure-remote-deps.sh` + `skip-package-resolved: true` on standalone CI for path-dep packages.
- Limit documented: ensure does not run inside a *fetched* dependency — Publish had to be path-free on the remote first.

### Wasm gated off

- Repo variable `ENABLE_WASM=false` set on tip packages that were scheduling wasm / wasm-embedded (Contribute already had it).
- Takes effect on the **next** workflow run.

### Former NO_RUNS → tip CI green

Tip commits had `[skip ci]` and push only targets `main`; sync PRs needed a non-skip empty commit.

| Package | Tip primary |
|---------|-------------|
| ButtondownKit | **success** |
| Contribute | **success** |
| Spinetail | **success** (dispatch after wasm off; earlier PR run still had wasm) |

### Platform floor autofixes (pushed)

| Change | Reason |
|--------|--------|
| Files → iOS 18 / tvOS 18 / watchOS 11 | `Synchronization.Mutex` availability |
| Publish platforms + Files `revision` pin bump | Match Files; consumers fetch path-free Publish |
| PublishType, Transistor / Youtube / ReadingTime plugins | Match Files via Publish |
| ContributeRSS / ContributeWordPress → iOS/tvOS 16 / watchOS 9 | Standalone CI product min vs declared floors |

---

## Snapshot (2026-07-18 tip primaries)

All 20 primary workflows were normalized and exercised with their full matrices.

| Status | Packages |
|--------|----------|
| **GREEN (20/20)** | ButtondownKit, Contribute, ContributeButtondown, ContributeMailchimp, ContributeRSS, ContributeWordPress, ContributeYouTube, NPMPublishPlugin, PublishType, Spinetail, SwiftTube, SyndiKit, TailwindKit, TransistorPublishPlugin, YoutubePublishPlugin, ReadingTimePublishPlugin, Files, Ink, Plot, Publish |

The preceding Transistor run was superseded after both Windows jobs exposed the
same revision conflict. Replacement full run `29657047493` is green. Every newest
exact-tip PR run is also green, including the MistKit-style lint action.

---

## Update (2026-07-18, later) — corrected root causes + fixes pushed

Live-log triage replaced the "PLAT" guesses above with exact causes, and the fixes
were committed on `ci/ensure-remote-deps-path-rewrite` and `git subrepo push`ed to
each public repo.

- **Self-hosted was NOT the cause.** Plot/Contribute/etc. build green on the same
  `[self-hosted, macOS]` runner. Per Leo (public repos → hosted), the Publish-stack
  macOS jobs were migrated to the **GitHub-hosted `xcode-27` runner label**
  (`/Applications/Xcode_27.0.app`, Xcode 27 beta = Swift 6.4-dev, 27.0 SDKs) with
  `download-platform: true` on sim legs. Applied to Files/Ink/Publish
  `build-macos` + `build-macos-platforms`.
- **Files macOS** red was a stale checked-in `Files.xcodeproj` (schemes
  `Files-iOS/-macOS/-tvOS`) shadowing swift-build's auto `Files` scheme →
  *"does not contain a scheme named Files"*. Removed the xcodeproj + the dead
  `buddybuild_postbuild.sh`. **Files primary now GREEN.**
- **Ink macOS** red was `Synchronization.Mutex` in `InkTests` needing iOS 18 /
  tvOS 18 / watchOS 11. Added those floors to Ink `Package.swift` (mirrors Files).
- **TailwindKit lint** (82→0): removed the superseded legacy 2022 `Tailwind.*` API
  (`TailwindKit.swift` struct + Flexbox/AspectRatio/Display/Breakpoints + their
  XCTest suites), excluded the Danger DSL from SwiftLint.
- **ReadingTimePublishPlugin lint** (0): doc-comments, fixtures split, explicit ACL,
  `ReadingTime.swift`→`ReadingTimeMetadata.swift` for `file_name`. 8 tests pass.

Pushed tips: Files `b075ae23`, Ink `1cec1bfe`, Publish `d0cabb07`,
ReadingTimePublishPlugin `02be3784`, TailwindKit `983b8e1d`. Files/Ink/Publish/
ReadingTime primaries auto-triggered on push; **TailwindKit only runs push on
main/tags**, so its run was started via `workflow_dispatch` on `brightdigit-com-260717`
(its subrepo tip commit also carried `[skip ci]` from the parent-reset). Re-survey
these five for green before opening the PR.

### Cross-platform workflow normalization

The durable per-repository platform, OS-version, deployment-minimum, and exclusion
inventory is in [`.Codex/subrepo-platform-support.md`](.Codex/subrepo-platform-support.md).

- All 20 primary workflows use hosted `xcode-27`,
  `/Applications/Xcode_27.0.app`, iOS/tvOS/watchOS 27.0 simulator destinations,
  and `download-platform: true` for simulator runtimes.
- Full dispatch matrices enable Ubuntu Noble, macOS, Windows Server 2022 + 2025,
  Android API 34, iOS 27, and tvOS 27 for every repo. watchOS 27 is enabled except
  where the live repository variable explicitly disables it: ButtondownKit,
  Contribute, Spinetail, and SwiftTube.
- `ENABLE_WASM=false` is set on all 20 repositories. visionOS is not configured.
- Root `.github/packages.json` and `.github/workflows/packages.yaml` cover all 20
  packages, including ReadingTimePublishPlugin and the Plugins paths.
- All 20 primary workflow files pass `actionlint`.

### MistKit-style lint tool setup

- Added a repo-local `.github/actions/setup-tools/action.yml` to each subrepo,
  adapted from MistKit's public workflow/composite action.
- Lint jobs cache `~/.local/share/mise/installs` by OS/architecture and `.mise.toml`
  hash. A cache hit runs `jdx/mise-action@v4` with `install: false`; a miss installs
  tools with mise caching disabled so the explicit cache owns persistence.
- The primary workflows no longer call `jdx/mise-action` directly.
- Parent Packages CI uses the same repo-local cache wrapper with a
  `working-directory` input for its 20-package lint matrix; neither the parent
  Packages workflow nor the primary subrepo workflows invoke `jdx/mise-action`
  directly.

---

## Update (2026-07-18, Files Windows support)

Fixed the Files-rooted Windows path bug (the source of Files' + most of Publish's
Windows failures). Root cause: Files hardcoded POSIX `/` while Foundation returns
native `\` on Windows; `makeParentPath` split via `URL.pathComponents` but rejoined
with `/`, so a folder's computed `parent.path` never string-`==` its stored path.

Fix (library-side, NO swift-system — its Windows support is "Unstable" and it'd
break the String public API): store paths in **canonical forward-slash** form; keep
all `/`-based internal logic; convert to native separators only at FileManager /
`URL(fileURLWithPath:)` boundaries. New `Sources/Path.swift` adds
`String.canonicalizedPath/.nativePath/.isDriveRoot` + `Path.rootPath/.nativeSeparator`,
all **no-ops off Windows** (macOS/Linux provably unchanged). `~` → `NSHomeDirectory()`
(drops a POSIX-only HOME force-unwrap; NOT `homeDirectoryForCurrentUser`, which is
unavailable on iOS/tvOS/watchOS); `Folder.root` → current volume root on Windows;
`makeParentPath` preserves the `C:` drive prefix. Tests stay XCTest: 3 assertions
platform-aware via a `rootPath`/`canonical` helper (no `#if` in test bodies) + a new
filesystem-free `PathTests` suite covering the separator/drive math on every platform.
Local: 71/71 tests pass on macOS, `CI=1 LINT_MODE=STRICT` clean. Pragmatic scope:
UNC best-effort, `==` stays case-sensitive on all platforms.

Pushed Files tip `bd520a8a`; dispatched full-matrix `workflow_dispatch` on Files +
Publish (`brightdigit-com-260406`) to exercise the Windows legs. Windows CI is the
ground truth (can't run Windows locally).

### Windows CI RESULT (2026-07-18) — GREEN

- **Path canonicalization CONFIRMED working on Windows.** Paths are now clean
  canonical (`C:/Users/runneradmin/.filesTest/folder/`); Foundation maps them to
  native `C:\…` at the boundary. Hybrid `C:\…\folder/` + `makeParentPath`
  inconsistency GONE.
- **Regression found + fixed:** `homeDirectoryForCurrentUser` is unavailable on
  iOS/tvOS/watchOS → broke those (green) Apple builds. Switched to `NSHomeDirectory()`
  (all Apple platforms + Windows-aware); verified with a real `xcodebuild
  -sdk iphonesimulator` build. Pushed (Files tip now newer than `bd520a8a`).
- **Final Files root cause:** an empty path reached Windows drive splitting before
  it was resolved to `FileManager.currentDirectoryPath`. Resolve the current
  directory first, then split/canonicalize the drive. Tests also now restore the
  original current working directory before deleting their fixture, so Windows has
  no live cwd handle inside the directory being removed.
- Files full dispatch `29653202558` is green on Windows 2022 + 2025 and every Apple
  platform. Local Files suite: 72/72.
- Publish full dispatch `29653222856` is green, including both Windows jobs.

---

## NPMPublishPlugin Apple platforms — GREEN

Per Leo, macOS/iOS/tvOS/watchOS support was retained. `Subprocess` is now a
conditional SwiftPM product dependency for macOS/Linux/Windows/Android, and the
Subprocess-backed implementation, tests, and `.npm` PublishingStep API use
`#if canImport(Subprocess)`. The non-Subprocess Apple targets compile without linking
that product. Full dispatch `29653222816` is green on iOS 27, tvOS 27, watchOS 27,
macOS, Ubuntu, Windows 2022/2025, and Android.

## Transistor revision alignment

Transistor directly pins the current Ink branch tip during standalone CI and also
fetches Publish. After the all-subrepo push advanced Ink, Publish still pinned the
preceding Ink revision, which SwiftPM rejects as two revision requirements for one
identity. Publish and NPMPublishPlugin now pin Ink
`443d80e352ec3cdd07eed54bd84a9789378d8665`; Publish 86/86 and NPMPublishPlugin
31/31 tests pass locally. Publish was subrepo-pushed at
`7648facf2aeea2b7c2bcb678cc5bc71629997f4a`; final Transistor full run
`29657047493` is green. NPMPublishPlugin's final exact-tip full run `29657044615`
is green too.

## Parent Packages CI lockfiles

The expanded parent Packages CI runs every one of the 20 packages on Ubuntu and
macOS using `--force-resolved-versions`. Its first PR #160 run exposed stale
`Package.resolved` files in TransistorPublishPlugin, YoutubePublishPlugin,
PublishType, and ReadingTimePublishPlugin: their local path to Publish now
introduces Publish's remote Files, Ink, and Plot pins, but the consumer lockfiles
predated those transitive pins.

Regenerated all four lockfiles from their monorepo manifests and subrepo-pushed
them. The exact parent-CI mode is green locally: Transistor 3/3,
YoutubePublishPlugin 2/2, PublishType 1/1, and ReadingTimePublishPlugin 8/8 with
`swift test --force-resolved-versions`. Standalone subrepo workflows continue to
use `skip-package-resolved: true` after their remote-dependency rewrite, so these
monorepo lockfiles do not constrain standalone resolution.

## Final parent verification

PR #160's parent workflows completed successfully at commit `ad21adae`:

- CI Pipeline `29659746540`: all 6 jobs successful/skipped, including strict lint,
  Linux build/test, release packaging, and draft deployment.
- Packages CI `29659746531`: all 62 jobs successful/skipped, covering Ubuntu and
  macOS builds plus MistKit-style lint setup for all 20 packages.

Every `.gitrepo` tip also has an exact-SHA successful primary workflow run. PR #160
remains open against `phase-05`; it has not been merged.

---

## Autofix policy (standing)

From [`.claude/agent-notes.md`](.claude/agent-notes.md):

- Prefer `#if canImport(...)`; fall back to `#if os(...)`.
- Do **not** default to `ENABLE_WATCHOS=false` or unilateral floor bumps unless SPM product mins / Mutex-class APIs require it (as with Files).
- Autofix build + lint; commit on CI branch + `git subrepo push`.
- Infra / secrets / Windows·Android runner oddities → report and wait.

---

## Ops notes

- **git-subrepo:** Homebrew bash first on `PATH` (`/opt/homebrew/bin` before `/bin`). Tree must be clean for pull/push; stale `.gitrepo` `parent` → `./fix-subrepo-parents.sh`.
- **TailwindKit** subrepo push sometimes needs manual clone → commit → push → `git subrepo pull` if “doesn’t contain upstream HEAD”.

---

## Next

1. Review PR #160: `ci/ensure-remote-deps-path-rewrite` → `phase-05`.
2. Do not merge automatically; Leo owns review and merge.
