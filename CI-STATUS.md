# Subrepo CI Status — nightly Swift 6.4 multi-platform sweep

_As of 2026-06-20 (updated). Branch: `buttondownkit-subrepo-ci-sweep` (monorepo) → subrepos on `brightdigit-com-260406`._

## TL;DR
- All five subrepos share one **byte-identical workflow** (except `name:`); the only per-package knob is the `ENABLE_WASM` repo variable.
- Workflows temporarily reference **`brightdigit/swift-build@sdk-url-checksum-nightly-6.4`** (PR [#116](https://github.com/brightdigit/swift-build/pull/116)) to test the new wasm/android SDK-bundle inputs. **Revert to `@v1` once #116 is merged + the `v1` tag moved.**
- **`continue-on-error` has been removed from all 5 workflows** (2026-06-20): the WASM step, the Apple-platforms job (iOS/watchOS/tvOS), and the Android job are now **blocking**. ⚠️ This means the **watchOS** failure (transitive-dep floor, not fixable in-repo — see Known Issues) now **blocks** the 4 repos where it fails; revisit if that's undesirable.
- **Android fix landed on swift-build #116** (forward `installed-sdk`, drop `cache-avd`) — **confirmed green**.
- **Spinetail #29 conflict resolved** via rebase onto `v1.0.0`; PR is now `MERGEABLE` and CI fires.
- **`build-ubuntu` is now a `[standard, wasm, wasm-embedded]` matrix** (mirrors MistKit; `configure` emits `ubuntu-type`, gated by `ENABLE_WASM`). The OpenAPI subrepos (ButtondownKit/SwiftTube/Spinetail) guard `OpenAPIURLSession` behind `#if !os(WASI)` + a conditional dep so the wasm/embedded legs build — see Known Issues. Under validation on the next runs.

## CI status per repo

Legend: ✅ pass · ❌ fail (blocking) · 🚫 disabled via repo variable · ⏭️ skipped (gated) · n/a (disabled) · — never ran · ⏳ re-running

| Repo | PR → base | mergeable | Ubuntu | WASM¹ | macOS | iOS | watchOS | tvOS | Windows² | Android³ | Lint | Run |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ButtondownKit | #1 → main | ✅ | ✅ | ✅ | ✅ | ✅ | 🚫⁴ | ✅ | ✅✅ | ✅ | ✅ | ✅ |
| SwiftTube | #12 → main | ✅ | ✅ | ✅ | ✅ | ✅ | 🚫⁴ | ✅ | ✅✅ | ✅ᵉ | ✅ | ✅ |
| Contribute | #9 → v1.0.0 | ✅ | ✅ | n/a | ✅ | ✅ | 🚫⁴ | ✅ | ⏭️ | ✅ᵉ | ✅ | ✅ |
| SyndiKit | #127 → v1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏭️ | ✅ᵉ | ✅ | ✅ |
| Spinetail | #29 → v1.0.0 | ✅ **resolved** | ⏳ | ⏳ | ⏳ | 🚫⁴ | ⏳ | ⏳ | ⏭️ | ✅ | ⏳ | ⏳ |

¹ WASM column now covers **both** `wasm` and `wasm-embedded` legs of the `build-ubuntu` matrix. Disabled on Contribute via `ENABLE_WASM=false` (Yams — see Contribute#10). OpenAPI repos build these only because `OpenAPIURLSession` is guarded out on WASI (Known Issues).
² Windows is **blocking** and **green where it runs**. ⏭️ on semver-base PRs (`run-windows` tier excludes PRs into semver). Not yet exercised on Spinetail/Contribute/SyndiKit.
³ Android passthrough fixed on swift-build #116 (forward `installed-sdk`, drop `cache-avd`). **Confirmed green** on ButtondownKit (main base) + Spinetail (semver base); now **blocking**.
⁴ watchOS **disabled** via `ENABLE_WATCHOS=false` on the 4 repos where it fails (SwiftPM #10188, watchOS-27 deployment-target clamp — not fixable in-repo). Tracked in [brightdigit.com#119](https://github.com/brightdigit/brightdigit.com/issues/119); SyndiKit (unaffected) still runs watchOS. See `watchos-27-deployment-target-issue.md`.
ᵉ Android expected-green — identical action+inputs to the two confirmed repos; not yet individually re-confirmed.

## Spinetail — #29 conflict resolved

**Was:** PR #29 (`brightdigit-com-260406` → `v1.0.0`) was `mergeable=CONFLICTING` — GitHub couldn't build `refs/pull/29/merge`, so the PR run was skipped (push trigger is main-only → no fallback).

**Fix applied (2026-06-20):** rebased `brightdigit-com-260406` onto `v1.0.0` (`-X theirs`, branch's OpenAPI architecture wins), then capped the branch with a commit whose tree is **byte-identical to the original branch** so no superseded-Prch2 files leaked in (`git diff <orig> HEAD` empty). `v1.0.0` is now an ancestor → PR is **`MERGEABLE`/`CLEAN`** (fast-forward) and the `pull_request` run fires.

**Follow-up:** the force-rebase rewrote the upstream branch, so the monorepo's `Packages/BrightDigit/Spinetail/.gitrepo` `commit` pointer is stale — re-sync with `git subrepo pull` (parent-recovery) before the next Spinetail subrepo push.

## Known issues

- **Android — fixed and confirmed green.** `skiptools/swift-android-action@v2` exits 1 when `custom-sdk-url` is set but `installed-sdk` is empty, and does not accept `cache-avd`. swift-build #116 now forwards `installed-sdk` (via a new `android-sdk-target` input, default `aarch64-unknown-linux-android28` when a custom SDK URL is set) and no longer passes `cache-avd`. The default triple matched the 2026-06-15 bundle — `build-android` is green on ButtondownKit + Spinetail.
- **watchOS — disabled on the 4 failing repos (SwiftPM bug).** The watchOS-27 SDK rejects deps that omit an explicit watchOS floor (`swift-collections`, `swift-http-types`): SwiftPM's PIF layer infers their target as `8.0` and fails to clamp it to the SDK's `9.0` floor. This is **SwiftPM #10187 → #10188** (merged `release/6.4` 2026-06-10), not fixable in our repos. **Now gated** on the `ENABLE_WATCHOS` repo variable (`=false` on ButtondownKit/SwiftTube/Contribute/Spinetail); SyndiKit (no offending dep) still runs it. **Re-enable** once the self-hosted runner's Xcode-beta SwiftPM includes #10188 (or wire the `WATCHOS_DEPLOYMENT_TARGET=9.0` override into swift-build) — tracked in [brightdigit.com#119](https://github.com/brightdigit/brightdigit.com/issues/119). Full write-up: `watchos-27-deployment-target-issue.md`.
- **swift-build osVersion pin** — simulator destinations hardcode `OS={osVersion}` (no `latest`), so the self-hosted Apple-platform legs pin `osVersion: 27.0` and will rot when the runner's Xcode-beta bumps its runtime. (Not yet filed on swift-build.)
- **wasm / wasm-embedded on OpenAPI repos — fixed via the MistKit pattern.** `swift-openapi-urlsession` (URLSession transport) can't build for WASI. ButtondownKit/SwiftTube/Spinetail now make the `OpenAPIURLSession` product conditional (`.when(platforms: Platform.withoutWASI)`) and guard every `import OpenAPIURLSession` + `URLSessionTransport`-based initializer (and matching tests) behind `#if !os(WASI)`; WASI callers pass an explicit transport. Mirrors [brightdigit/MistKit](https://github.com/brightdigit/MistKit/tree/v1.0.0-beta.3) (whose wasm-embedded leg is green). Host builds verified locally; wasm/embedded legs under validation.

## Workflow design (shared across all 5)

- **Triggers:** `push` → `[main]` + tags; `pull_request`; `workflow_dispatch`.
- **Three tiers** (via the `configure` job):
  - **Small set** (always): `build-ubuntu` (a `[standard, wasm, wasm-embedded]` matrix via `configure → ubuntu-type`, gated by `ENABLE_WASM`), `build-macos` (self-hosted Xcode-beta), `lint`.
  - **`full-matrix`** (main / semver push, dispatch, PRs into main or semver): + `build-macos-platforms` (iOS/watchOS/tvOS, self-hosted), `build-android`.
  - **`run-windows`** (full-matrix MINUS PRs into semver — the most expensive leg): `build-windows`.
- **Runners:** all macOS/Apple-platform legs on `[self-hosted, macOS]` + `/Applications/Xcode-beta.app` (Xcode 27 / Swift 6.4); Linux + wasm in `swiftlang/swift:nightly-6.4.x-noble`; Windows on hosted `windows-2022`/`windows-2025` (swift.org snapshot `6.4.x-DEVELOPMENT-SNAPSHOT-2026-06-01-a`); Android on `ubuntu-latest`.
- **SDK snapshots:** wasm/android bundles `swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-06-15-a`. **Bump periodically** (swift.org GCs old dev snapshots) — Windows snapshot, wasm/android URLs+checksums, and simulator `osVersion`.

## Outstanding

- [x] **Spinetail:** #29 conflict resolved via rebase (now `MERGEABLE`).
- [x] **swift-build #116:** Android passthrough fixed (forward `installed-sdk`, drop `cache-avd`). Still to do: confirm green, then **merge #116 + move `v1`**.
- [x] **Promote `continue-on-error` legs to blocking** — removed from all 5 workflows (WASM, Apple-platforms, Android now blocking).
- [x] **watchOS disabled** on the 4 failing repos via `ENABLE_WATCHOS=false`; SyndiKit keeps it. Tracked in [#119](https://github.com/brightdigit/brightdigit.com/issues/119).
- [ ] **Re-enable watchOS** once SwiftPM #10188 reaches the runner's Xcode-beta (fix A) or the `WATCHOS_DEPLOYMENT_TARGET` override is wired into swift-build (fix B) — then flip `ENABLE_WATCHOS` on the 4 repos. (#119)
- [x] **Confirm Android green** — `build-android` passes on ButtondownKit + Spinetail with the default `aarch64-unknown-linux-android28` triple.
- [ ] **Revert workflows from `@sdk-url-checksum-nightly-6.4` → `@v1`** after #116 ships.
- [ ] **Spinetail `.gitrepo` resync** (`git subrepo pull`) — upstream branch was rewritten by the rebase.
- [ ] **Contribute#10:** fix Yams-on-wasm, then set `ENABLE_WASM=true` (or remove the var).
- [ ] Consider filing the swift-build `osVersion: latest` gap.
