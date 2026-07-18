# Files package: canonical forward-slash path form (Windows support)

The `Packages/Publish/Files` package (fork of John Sundell's Files) stores **every
path in canonical forward-slash form** on all platforms. All internal path logic
(folder trailing-`/` invariant, `../` resolution, `makeParentPath`, child
concatenation via `parent.path + name`, `==`, `path(relativeTo:)`) operates on that
canonical form. Native separators (`\` on Windows) are used **only** at the
FileManager / `URL(fileURLWithPath:)` boundary.

Helpers live in `Sources/Path.swift`:
- `String.canonicalizedPath` — `\`→`/` (identity off Windows). Apply to every
  path INGESTED from Foundation (`currentDirectoryPath`, `homeDirectoryForCurrentUser`,
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
- `~` resolves via `FileManager.default.homeDirectoryForCurrentUser` (NOT the
  POSIX-only `HOME` env var).
- Tests stay XCTest here (existing vendored suite — see [[testing-swift-testing-only]]
  exception). Platform-aware expectations go through the `FilesTests.rootPath` /
  `canonical(_:)` helpers, never `#if os(Windows)` in test bodies. `PathTests.swift`
  (`@testable import Files`) covers the separator/drive math filesystem-free on all
  platforms.

Scope is pragmatic: UNC paths are best-effort. Windows CI (the Files.yml
`build-windows` leg on windows-2022/2025) is the ground truth — can't run Windows
locally. Related: [[reldep-packages-standalone-migration]], subrepo CI on
[[brightdigit-ci-template]].

## Status as of 2026-07-18 (WIP — resume here next time)

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

STILL RED on Windows — but NOT a path bug (separator work is done):
- `FilesTests.setUp` (`folder.empty()`→`delete()`) throws `deleteFailed` /
  `Win32Error(code: 32)` = "file in use by another process." Windows refuses to delete
  a directory whose handle is still open. This is Windows filesystem SEMANTICS
  (delete-while-open / handle lifetime), a deeper problem than separators.
- Likely need: retry-on-lock in `Storage.delete`/`empty`, and/or ensuring child-sequence
  enumeration handles are closed before delete. Investigate `contentsOfDirectory` handle
  lifetime and `removeItem` behavior on Windows. May also need `moveItem`/rename checks.
- Publish's Windows failures are downstream of Files; re-check Publish AFTER Files goes
  green (some may be Publish-only — separate follow-up).

Next steps: (1) fix the Windows delete-in-use semantics; (2) re-dispatch
`gh workflow run Files.yml -R brightdigit/Files --ref brightdigit-com-260406` (Windows
leg only runs on main/semver/dispatch); (3) re-dispatch Publish; (4) then the overall
`ci/ensure-remote-deps-path-rewrite` → `phase-05` PR (Leo owns).
