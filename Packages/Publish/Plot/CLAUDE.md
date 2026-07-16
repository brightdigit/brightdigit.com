# CLAUDE.md — Plot

Vendored package in the BrightDigit Publish stack (`Packages/Publish/Plot`),
maintained in-tree on plain Swift 6.4 (`// swift-tools-version:6.4`), macOS 15+.

- Strict concurrency is mandatory. Resolve every diagnostic properly
  (Sendable / isolation / `Synchronization.Mutex`); never use
  `@unchecked Sendable` — a SwiftLint `no_unchecked_sendable` rule enforces this.
- Lint: `LINT_MODE=STRICT ./Scripts/lint.sh` — full BrightDigit house style
  (swift-format + SwiftLint + build) gates; periphery is local-only (skipped
  when `$CI` is set).
- Tests use XCTest (kept as-is).
