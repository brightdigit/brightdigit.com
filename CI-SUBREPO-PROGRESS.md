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

Rough rollup from latest `Package.yml` run per `.gitrepo` tip (re-runs still in flight for several):

| Status | Packages |
|--------|----------|
| **GREEN** | ButtondownKit, Contribute, ContributeButtondown, ContributeMailchimp, ContributeYouTube, SwiftTube, SyndiKit, Plot |
| **In flight / queued** | ContributeRSS, PublishType, Spinetail (extra runs), TransistorPublishPlugin, YoutubePublishPlugin, ReadingTimePublishPlugin |
| **Still red** | ContributeWordPress (PLAT), NPMPublishPlugin (PLAT), TailwindKit (**Linting**), Files (PLAT), Ink (PLAT), Publish (Windows leg on one run) |

Exact job lists move as dispatches finish; re-survey before acting.

---

## Waiting on Leo

### NPMPublishPlugin + `swift-subprocess`

Apple platform jobs fail because Subprocess requires roughly **iOS 99.0** / tvOS·watchOS **27** (unavailable on those platforms). `canImport` does not fix a Package.swift product dependency.

Options to choose:

1. Declare **macOS-only** platforms for NPMPublishPlugin  
2. Drop / gate Subprocess so Apple targets don’t link it  
3. Skip iOS/tvOS/watchOS CI legs for this package only  

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
- **Monitor:** 10m loop armed during this work to survey tips and autofix; stop when greens settle or only Leo-blocked items remain.
- Parent branch has **no** workflow runs (expected for `ci/ensure-remote-deps-path-rewrite`). `phase-05` / `main` parent CI were green at last check.

---

## Next

1. Let in-flight platform re-runs finish; triage remaining PLAT / lint (TailwindKit lint is autofix-eligible).
2. Resolve NPMPublishPlugin per Leo.
3. When tips are green enough, open PR `ci/ensure-remote-deps-path-rewrite` → `phase-05` (Leo merges).
4. Resume MERGE-AND-TAG-PLAN waves (Wave-0 tags → `from:` pins; Wave-2 permanent consumer rewrites).
