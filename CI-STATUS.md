# Subrepo CI Status — nightly Swift 6.4 multi-platform sweep

_As of 2026-06-20 (updated). Branch: `buttondownkit-subrepo-ci-sweep` (monorepo) → subrepos on `brightdigit-com-260406`._

## TL;DR
- All five subrepos share one **byte-identical workflow** (except `name:`); the only per-package knob is the `ENABLE_WASM` repo variable.
- Workflows temporarily reference **`brightdigit/swift-build@sdk-url-checksum-nightly-6.4`** (PR [#116](https://github.com/brightdigit/swift-build/pull/116)) to test the new wasm/android SDK-bundle inputs. **Revert to `@v1` once #116 is merged + the `v1` tag moved.**
- **`continue-on-error` has been removed from all 5 workflows** (2026-06-20): the WASM step, the Apple-platforms job (iOS/watchOS/tvOS), and the Android job are now **blocking**. ⚠️ This means the **watchOS** failure (transitive-dep floor, not fixable in-repo — see Known Issues) now **blocks** the 4 repos where it fails; revisit if that's undesirable.
- **Android fix landed on swift-build #116** (forward `installed-sdk`, drop `cache-avd`) — leg under validation on the next runs.
- **Spinetail #29 conflict resolved** via rebase onto `v1.0.0`; PR is now `MERGEABLE` and CI fires.

## CI status per repo

Legend: ✅ pass · ❌ fail (**now blocking** — `continue-on-error` removed) · ⏭️ skipped (gated) · n/a (disabled) · — never ran · ⏳ re-running

| Repo | PR → base | mergeable | Ubuntu | WASM¹ | macOS | iOS | watchOS | tvOS | Windows² | Android³ | Lint | Run |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ButtondownKit | #1 → main | ✅ | ✅ | ✅ | ✅ | ✅ | ❌⁴ | ✅ | ✅✅ | ⏳ | ✅ | ⏳ |
| SwiftTube | #12 → main | ✅ | ✅ | ✅ | ✅ | ✅ | ❌⁴ | ✅ | ✅✅ | ⏳ | ✅ | ⏳ |
| Contribute | #9 → v1.0.0 | ✅ | ✅ | n/a | ✅ | ✅ | ❌⁴ | ✅ | ⏭️ | ⏳ | ✅ | ⏳ |
| SyndiKit | #127 → v1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ⏳ | ✅ | ⏳ |
| Spinetail | #29 → v1.0.0 | ✅ **resolved** | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏭️ | ⏳ | ⏳ | ⏳ |

¹ WASM runs as a step inside `build-ubuntu`. Disabled on Contribute via `ENABLE_WASM=false` (Yams — see Contribute#10).
² Windows is **blocking** and **green where it runs**. ⏭️ on semver-base PRs (`run-windows` tier excludes PRs into semver). Not yet exercised on Spinetail/Contribute/SyndiKit.
³ Android passthrough fixed on swift-build #116 (forward `installed-sdk`, drop `cache-avd`); re-running to confirm green. Now **blocking**.
⁴ watchOS still fails (transitive-dep floor, not fixable in-repo) and is **now blocking** these PRs — see Known Issues.

## Spinetail — #29 conflict resolved

**Was:** PR #29 (`brightdigit-com-260406` → `v1.0.0`) was `mergeable=CONFLICTING` — GitHub couldn't build `refs/pull/29/merge`, so the PR run was skipped (push trigger is main-only → no fallback).

**Fix applied (2026-06-20):** rebased `brightdigit-com-260406` onto `v1.0.0` (`-X theirs`, branch's OpenAPI architecture wins), then capped the branch with a commit whose tree is **byte-identical to the original branch** so no superseded-Prch2 files leaked in (`git diff <orig> HEAD` empty). `v1.0.0` is now an ancestor → PR is **`MERGEABLE`/`CLEAN`** (fast-forward) and the `pull_request` run fires.

**Follow-up:** the force-rebase rewrote the upstream branch, so the monorepo's `Packages/BrightDigit/Spinetail/.gitrepo` `commit` pointer is stale — re-sync with `git subrepo pull` (parent-recovery) before the next Spinetail subrepo push.

## Known issues

- **Android — fix applied, validating.** `skiptools/swift-android-action@v2` exits 1 when `custom-sdk-url` is set but `installed-sdk` is empty, and does not accept `cache-avd`. swift-build #116 now forwards `installed-sdk` (via a new `android-sdk-target` input, default `aarch64-unknown-linux-android28` when a custom SDK URL is set) and no longer passes `cache-avd`. Confirm the default triple matches the bundle's registered triple on the first green run; adjust if needed.
- **watchOS — fails on the OpenAPI repos + Contribute, passes on SyndiKit. NOW BLOCKING.** Transitive deps `swift-http-types` / `swift-collections` declare `WATCHOS_DEPLOYMENT_TARGET=8.0`, below the watchOS-27 SDK floor (9.0). SyndiKit (XMLCoder only) has no such dep, so it passes. Not fixable in our repos; depends on the deps raising their watchOS minimums. **Since `continue-on-error` was removed, this now blocks the affected PRs** — re-add `continue-on-error: true` to `build-macos-platforms` (or exclude the watchOS matrix leg) if these PRs must stay green before the deps are fixed.
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

- [x] **Spinetail:** #29 conflict resolved via rebase (now `MERGEABLE`).
- [x] **swift-build #116:** Android passthrough fixed (forward `installed-sdk`, drop `cache-avd`). Still to do: confirm green, then **merge #116 + move `v1`**.
- [x] **Promote `continue-on-error` legs to blocking** — removed from all 5 workflows (WASM, Apple-platforms, Android now blocking).
- [ ] **watchOS now blocks** the 4 affected PRs — decide whether to re-add `continue-on-error` to `build-macos-platforms` / drop the watchOS leg until the transitive deps raise their watchOS minimums.
- [ ] **Confirm Android green** on the next runs; adjust `android-sdk-target` default if the bundle registers a different triple.
- [ ] **Revert workflows from `@sdk-url-checksum-nightly-6.4` → `@v1`** after #116 ships.
- [ ] **Spinetail `.gitrepo` resync** (`git subrepo pull`) — upstream branch was rewritten by the rebase.
- [ ] **Contribute#10:** fix Yams-on-wasm, then set `ENABLE_WASM=true` (or remove the var).
- [ ] Consider filing the swift-build `osVersion: latest` gap.
