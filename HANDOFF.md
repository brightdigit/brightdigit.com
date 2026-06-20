# Handoff — ButtondownKit subrepo + subrepo-push repair + standalone CI sweep

_Last updated: 2026-06-19. Resume point for continuing on another machine._

## Where the work lives
- **Monorepo branch:** `buttondownkit-subrepo-ci-sweep` (pushed to `origin`).
- **Monorepo PR:** brightdigit/brightdigit.com **#118** → `main`.
- **Plan file:** `~/.claude/plans/1-create-new-repo-cryptic-chipmunk.md` (local to original machine; superseded by this doc).
- All subrepos track branch **`brightdigit-com-260406`** (except ConfigKeyKit → `1-remove-need-for-extension`).
- Subrepo push parent recovery (after squash-merges): pattern in `fix-subrepo-parents.sh` — `git subrepo push` prints the recovery SHA; set `.gitrepo` `parent` to it, commit `[skip ci]`, retry. **Never force-push.**

## DONE ✅

### 1. ButtondownKit — new repo + subrepo + CI
- Created **public** repo `github.com/brightdigit/ButtondownKit` (default branch `main`).
- `git subrepo init` + push on `brightdigit-com-260406`.
- New standalone CI (`.github/workflows/ButtondownKit.yml`): Swift 6.4 nightly Linux build + lint. **Green.**
- **PR #1 → main** (the CI addition; `main` holds the package pre-CI).

### 2. Subrepo push repaired for all 10
All `Packages/BrightDigit/*` subrepos push cleanly; stale `.gitrepo` parents reset to git-subrepo's suggested ancestor SHAs.

### 3. Standalone CI (5 build-capable packages) — all green
| Package | CI | PR |
|---|---|---|
| ButtondownKit | new 6.4 template | #1 → main ✅ |
| Spinetail | replaced legacy Swift-5.x → 6.4 template | #29 → v1.0.0 ✅ |
| SwiftTube | replaced legacy Swift-5.x → 6.4 template | #12 → main ✅ |
| SyndiKit | lint → `jdx/mise-action` (was flaky inline curl) | #127 → v1.0.0 ✅ |
| ConfigKeyKit | unchanged (gold standard) | #3 → main ✅* |
| Contribute | now standalone (see SwiftSoup below) | #9 → v1.0.0 ✅ |

\*ConfigKeyKit package CI green; only its `claude-review` bot fails (needs `ANTHROPIC_API_KEY` repo secret — out of scope).

### 4. All 10 standalone PRs open (base = nearest version branch w/ COMMON history, else main)
ButtondownKit #1→main · ConfigKeyKit #3→main · SyndiKit #127→v1.0.0 · Contribute #9→v1.0.0 · Spinetail #29→v1.0.0 · SwiftTube #12→main · ContributeWordPress #18→main · NPMPublishPlugin #9→main · TransistorPublishPlugin #6→main · YoutubePublishPlugin #1→main

Note: Spinetail/SwiftTube `v2.0.0` is **unrelated history** (OpenAPI rebuild) — can't be a PR base.

### 5. SwiftSoup un-vendored → published fork
- Created fork **`github.com/brightdigit/SwiftSoup`**, branch **`fix/swift-6.4-inline-crash`** (commit `5d5d9ec` = upstream scinfu `f474b11` + the one `@inline(__always)` patch in `Sources/StringUtil.swift`).
- **Contribute/Package.swift** now uses `.package(url: "https://github.com/brightdigit/SwiftSoup.git", branch: "fix/swift-6.4-inline-crash")` instead of `../../scinfu/SwiftSoup`.
- Deleted the 144-file vendored `Packages/scinfu/SwiftSoup` tree.
- Verified: root resolves; Contribute builds standalone **debug + release** on Swift 6.4; Contribute CI green.

## REMAINING / NEXT

### Rel-dep packages still NOT standalone (build/test stays in monorepo `packages.yaml`)
Converting these is the agreed future-work track (create dep branches/tags, then repoint):
1. **ContributeWordPress** → `../../BrightDigit/Contribute`, `../../BrightDigit/SyndiKit`.
   - **Unblock next:** tag/publish **Contribute** (now URL-publishable) + SyndiKit, then repoint to URLs.
2. **NPMPublishPlugin** → `../../Publish/Publish`.
3. **TransistorPublishPlugin** → `../../Publish/Publish`, `../../Publish/Ink`.
4. **YoutubePublishPlugin** → `../../Publish/Publish`.
   - These need `Publish` (and `Ink`) published/tagged first.

### Open follow-ups
- [ ] **Merge** the 10 subrepo PRs + monorepo PR #118 (pending review).
- [ ] **SwiftSoup fork:** currently a **mutable branch** pin. Cut an immutable tag (e.g. `2.x-bd.1`) when the Swift 6.4 toolchain stabilizes; optionally add CI to `brightdigit/SwiftSoup`. Restore upstream `scinfu/SwiftSoup` once the optimizer bug is fixed upstream.
- [x] **macOS + Apple-platform + Windows CI legs added** to all 5 standalone subrepos (ButtondownKit/Spinetail/SwiftTube/Contribute/SyndiKit). **All macOS/Apple-platform work runs on the self-hosted runner with `/Applications/Xcode-beta.app` (Xcode 27 / Swift 6.4)** — `build-macos` (plain SPM) + `build-macos-platforms` (iOS/watchOS/tvOS on the 27.0 simulators). Contribute's `Package.swift` gained iOS/tvOS/watchOS so it builds for all platforms. Windows runs on hosted windows-2022/2025 with a swift.org nightly snapshot (`6.4.x-DEVELOPMENT-SNAPSHOT-2026-06-01-a`). Contribute & SyndiKit migrated 6.3→nightly-6.4. **Bump the Windows snapshot id + the simulator deviceName/osVersion periodically** (snapshots GC'd; runtimes move with Xcode-beta).
- [x] **Three CI tiers** via `configure`: small set (build-ubuntu/build-macos/lint, always) < `full-matrix` (macOS-platforms/wasm/android — main/semver/dispatch/PRs into main or semver) < `run-windows` (the most expensive leg — same as full-matrix MINUS PRs into semver branches). Apple-platform + Windows + wasm + android legs are `continue-on-error` (simulator/cross-platform on nightly is fragile); promote to blocking once green.
- [x] **WASM + Android CI legs wired** (`continue-on-error`, full-matrix-gated) into ButtondownKit/Spinetail/SwiftTube/SyndiKit (WASM+Android) and Contribute (Android only — WASM permanently N/A, Yams on Musl/wasm). They use **swift.org `swift-6.4.x-branch` snapshot SDK bundles** (WASM + Android `_*.artifactbundle`, snapshot `2026-06-15-a`) via new `brightdigit/swift-build` inputs (`wasm-sdk-url`/`wasm-sdk-checksum`, `android-sdk-url`/`android-sdk-id`).
- [ ] **Release `brightdigit/swift-build` PR [#116](https://github.com/brightdigit/swift-build/pull/116)** (the new SDK-bundle inputs; refs [#115](https://github.com/brightdigit/swift-build/issues/115)) and **move the `v1` tag** — the WASM/Android legs above are `continue-on-error` and inert until `@v1` includes it. After release: confirm each leg goes green, then drop `continue-on-error` (start with SyndiKit). Bump the snapshot SDK URLs/checksums periodically (swift.org GCs old dev snapshots).
  - [ ] **After #116 ships: merge `build-wasm` into `build-ubuntu`** (same nightly-6.4.x-noble container — one spin-up instead of two), for ButtondownKit/Spinetail/SwiftTube/SyndiKit. Resolve the gating mismatch (build-ubuntu always+blocking vs build-wasm full-matrix+continue-on-error), likely a `continue-on-error` wasm step gated on full-matrix.
  - [ ] **swift-build gap (not yet filed):** simulator destination hardcodes `OS={osVersion}` — no `latest`/auto, so the self-hosted Apple-platform legs pin `osVersion: "27.0"` and rot when the runner's Xcode-beta bumps its runtime. Consider filing + fixing in swift-build, then switch the legs to `latest`.
- [ ] **ConfigKeyKit `claude-review`** bot failing — add `ANTHROPIC_API_KEY` secret or drop the workflow (out of scope).
- [ ] **After squash-merging branch `buttondownkit-subrepo-ci-sweep` to main:** run `./fix-subrepo-parents.sh` to reset all `.gitrepo` parents to the new HEAD, then `git push`.

## Quick verification commands
```bash
# subrepo push state (all should show a current Upstream Ref)
git subrepo status | grep -A6 "Packages/BrightDigit"
# CI per repo
for r in brightdigit/ButtondownKit brightdigit/SyndiKit BrightDigit/Contribute \
         BrightDigit/Spinetail BrightDigit/SwiftTube brightdigit/ConfigKeyKit; do
  echo "== $r =="; gh pr list --repo "$r" --state open
done
# Contribute standalone build (Swift 6.4 toolchain)
cd Packages/BrightDigit/Contribute && swift build && swift build -c release
```
