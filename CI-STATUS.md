# Subrepo CI Status — nightly Swift 6.4 multi-platform sweep

_As of 2026-06-20 22:34 UTC. Branch: `buttondownkit-subrepo-ci-sweep` (monorepo) → subrepos on `brightdigit-com-260406`._

## TL;DR
- All five subrepos share one **byte-identical workflow** (except `name:`); the only per-package knob is the `ENABLE_WASM` repo variable.
- Workflows temporarily reference **`brightdigit/swift-build@sdk-url-checksum-nightly-6.4`** (PR [#116](https://github.com/brightdigit/swift-build/pull/116)) to test the new wasm/android SDK-bundle inputs. **Revert to `@v1` once #116 is merged + the `v1` tag moved.**
- **4 of 5 PRs run the full matrix and pass** (Android + watchOS legs fail but are non-blocking). **Spinetail runs nothing** — see below.

## CI status per repo

Legend: ✅ pass · ❌ fail (non-blocking, `continue-on-error`) · ⏭️ skipped (gated) · n/a (disabled) · — never ran

| Repo | PR → base | mergeable | Ubuntu | WASM¹ | macOS | iOS | watchOS | tvOS | Windows² | Android³ | Lint | Run |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ButtondownKit | #1 → main | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅✅ | ❌ | ✅ | **success** |
| SwiftTube | #12 → main | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅✅ | ❌ | ✅ | **success** |
| Contribute | #9 → v1.0.0 | ✅ | ✅ | n/a | ✅ | ✅ | ❌ | ✅ | ⏭️ | ❌ | ✅ | **success** |
| SyndiKit | #127 → v1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ❌ | ✅ | **success** |
| Spinetail | #29 → v1.0.0 | ❌ **CONFLICTING** | (stale) | — | (stale) | — | — | — | — | — | (stale) | **none (see below)** |

¹ WASM runs as a step inside `build-ubuntu`. Disabled on Contribute via `ENABLE_WASM=false` (Yams — see Contribute#10).
² Windows is **blocking** (no `continue-on-error`) and **green where it runs**. ⏭️ on semver-base PRs (`run-windows` tier excludes PRs into semver). Not yet exercised on Spinetail/Contribute/SyndiKit.
³ Android fails on all repos — swift-build passthrough gap (see Known Issues).

## Spinetail — why no CI, and how to fix

**Cause:** PR #29 (`brightdigit-com-260406` → `v1.0.0`) is **`mergeable=CONFLICTING`**. GitHub runs `pull_request` workflows against the test-merge commit (`refs/pull/29/merge`); with conflicts it can't create that commit, so **the PR run is skipped**. The push trigger is now main-only, so there's no fallback push run either → Spinetail gets nothing. (The other four PRs merge cleanly, so their runs fire.)

**Fix options:**
1. **`workflow_dispatch`** on `brightdigit-com-260406` — dispatch runs against the *branch ref* (not the merge ref), so the conflict is irrelevant; gated to `full-matrix + run-windows` so it runs everything. Fastest way to verify.
2. **Resolve the #29 conflict** (rebase/remerge `v1.0.0`) so the PR run fires on its own. Proper fix.

## Known issues (all non-blocking / `continue-on-error`)

- **Android — fails on every repo.** `skiptools/swift-android-action` requires `installed-sdk` alongside `custom-sdk-url`/`custom-sdk-id`, and rejects the `cache-avd` input. swift-build PR #116's android passthrough is incomplete — needs to also pass `installed-sdk` (and drop/condition `cache-avd`). **Action: fix on swift-build #116.**
- **watchOS — fails on the OpenAPI repos + Contribute, passes on SyndiKit.** Transitive deps `swift-http-types` / `swift-collections` declare `WATCHOS_DEPLOYMENT_TARGET=8.0`, below the watchOS-27 SDK floor (9.0). SyndiKit (XMLCoder only) has no such dep, so it passes. Not fixable in our repos; depends on the deps raising their watchOS minimums.
- **swift-build osVersion pin** — simulator destinations hardcode `OS={osVersion}` (no `latest`), so the self-hosted Apple-platform legs pin `osVersion: 27.0` and will rot when the runner's Xcode-beta bumps its runtime. (Not yet filed on swift-build.)

## Workflow design (shared across all 5)

- **Triggers:** `push` → `[main]` + tags; `pull_request`; `workflow_dispatch`.
- **Three tiers** (via the `configure` job):
  - **Small set** (always): `build-ubuntu` (+ wasm step), `build-macos` (self-hosted Xcode-beta), `lint`.
  - **`full-matrix`** (main / semver push, dispatch, PRs into main or semver): + `build-macos-platforms` (iOS/watchOS/tvOS, self-hosted), `build-android`.
  - **`run-windows`** (full-matrix MINUS PRs into semver — the most expensive leg): `build-windows`.
- **Runners:** all macOS/Apple-platform legs on `[self-hosted, macOS]` + `/Applications/Xcode-beta.app` (Xcode 27 / Swift 6.4); Linux + wasm in `swiftlang/swift:nightly-6.4.x-noble`; Windows on hosted `windows-2022`/`windows-2025` (swift.org snapshot `6.4.x-DEVELOPMENT-SNAPSHOT-2026-06-01-a`); Android on `ubuntu-latest`.
- **SDK snapshots:** wasm/android bundles `swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-06-15-a`. **Bump periodically** (swift.org GCs old dev snapshots) — Windows snapshot, wasm/android URLs+checksums, and simulator `osVersion`.

## Outstanding

- [ ] **Spinetail:** dispatch or resolve #29 conflict (above).
- [ ] **swift-build #116:** fix Android passthrough (`installed-sdk`), then merge + move `v1`.
- [ ] **Revert workflows from `@sdk-url-checksum-nightly-6.4` → `@v1`** after #116 ships.
- [ ] **Contribute#10:** fix Yams-on-wasm, then set `ENABLE_WASM=true` (or remove the var).
- [ ] Promote `continue-on-error` legs to blocking once consistently green (Windows already blocking).
- [ ] Consider filing the swift-build `osVersion: latest` gap.
