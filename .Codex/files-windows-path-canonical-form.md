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
