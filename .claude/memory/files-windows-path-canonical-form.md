# Files package: canonical forward-slash path form (Windows support)

Note: `Packages/Publish/Files` is absent from the root since de-vendoring — Files is now
consumed as a released version pin (`5.0.0-alpha.1`). The path below is its canonical
location when the subrepos are restored.

The `Packages/Publish/Files` package (fork of John Sundell's Files) stores **every
path in canonical forward-slash form** on all platforms. All internal path logic
(folder trailing-`/` invariant, `../` resolution, `makeParentPath`, child
concatenation via `parent.path + name`, `==`, `path(relativeTo:)`) operates on that
canonical form. Native separators (`\` on Windows) are used **only** at the
FileManager / `URL(fileURLWithPath:)` boundary.

Helpers live in `Sources/Path.swift`:
- `String.canonicalizedPath` — `\`→`/` (identity off Windows). Apply to every
  path INGESTED from Foundation (`currentDirectoryPath`, `NSHomeDirectory()`,
  `NSTemporaryDirectory`, move/create outputs) and to public-API path arguments.
- `String.nativePath` — `/`→`\` (identity off Windows). Apply at EVERY
  `FileManager`/`URL(fileURLWithPath:)` call (create/exists/move/copy/remove/
  contentsOfDirectory/attributes).
- `String.isDriveRoot` (`C:/`/`C:` on Windows), `Path.rootPath` (volume root on
  Windows, `/` elsewhere), `Path.nativeSeparator`.

Every helper is a no-op off Windows (`#else` returns `self`), so **macOS/Linux
behavior is provably unchanged** — don't "simplify" them to unconditional string ops.

Gotchas:
- `makeParentPath` splits off any `X:` drive prefix before `URL.pathComponents`
  (which drops the trailing slash) and re-prefixes it on the `/`-rejoin, so the
  parent of `C:/Users/foo/` stays `C:/Users/`. Its drive-root guard is Windows-only.
- `Location.==` is separator-canonical but **case-sensitive on all platforms** by
  design (do NOT make it case-insensitive — it changes macOS/Linux semantics).
- `~` resolves via `NSHomeDirectory()` (NOT `homeDirectoryForCurrentUser`, which
  is unavailable on iOS/tvOS/watchOS, and not the POSIX-only `HOME` env var).
- Tests stay XCTest here (existing vendored suite — see [[testing-swift-testing-only]]
  exception). Platform-aware expectations go through the `FilesTests.rootPath` /
  `canonical(_:)` helpers, never `#if os(Windows)` in test bodies. `PathTests.swift`
  (`@testable import Files`) covers the separator/drive math filesystem-free on all
  platforms.

Scope is pragmatic: UNC paths are best-effort. Windows CI (the Files.yml
`build-windows` leg on windows-2022/2025) is the ground truth — can't run Windows
locally. Related: [[reldep-packages-standalone-migration]], subrepo CI on
[[brightdigit-ci-template]].

## Status as of 2026-07-18 (complete)

Done + pushed (branch `ci/ensure-remote-deps-path-rewrite`, Files subrepo tip on
`brightdigit-com-260406`):
- Canonical-forward-slash path fix is IMPLEMENTED and WORKS. Windows CI confirmed
  paths are now clean canonical (`C:/Users/runneradmin/.filesTest/folder/`), Foundation
  maps them to native `C:\…` at the boundary. The old hybrid `C:\…\folder/` and the
  `makeParentPath` `/C:/…` vs `C:\…` inconsistency are GONE.
- 71/71 tests pass on macOS; `CI=1 LINT_MODE=STRICT` clean; iOS-simulator build green.

Regression fixed: `~` first used `FileManager.homeDirectoryForCurrentUser`, which is
UNAVAILABLE on iOS/tvOS/watchOS — it broke those (green) Apple builds. Now uses
`NSHomeDirectory()` (available on ALL Apple platforms + Windows-aware). Verified with a
real `xcodebuild -scheme Files -sdk iphonesimulator` build, not just `swift test`.
**Lesson: availability regressions need a cross-platform BUILD, not just macOS tests.**

The apparent delete-in-use symptom had two concrete causes:
- `Storage` tried to split a Windows drive before resolving an empty path to
  `FileManager.currentDirectoryPath`. Empty paths now resolve to cwd first.
- `FilesTests` deleted the shared fixture while the process cwd was still inside it.
  The suite now captures and restores the original cwd before fixture cleanup.

A regression assertion covers empty-path/current-directory resolution. Local Files
suite is 72/72 green. Full Files dispatch `29653202558` is green on Windows Server
2022 and 2025 plus macOS/iOS/tvOS/watchOS, Ubuntu, and Android. Downstream Publish
full dispatch `29653222856` is also green, including Windows. Windows CI remains the
ground truth for future changes.
