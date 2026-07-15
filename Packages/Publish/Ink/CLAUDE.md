# CLAUDE.md — Ink

Vendored package in the BrightDigit Publish stack (`Packages/Publish/Ink`),
maintained in-tree on plain Swift 6.4 (`// swift-tools-version:6.4`), macOS 15+.

- Strict concurrency is mandatory. Resolve every diagnostic properly
  (Sendable / isolation / `Synchronization.Mutex`); never use
  `@unchecked Sendable` — a SwiftLint `no_unchecked_sendable` rule enforces this.
- Lint: `LINT_MODE=STRICT ./Scripts/lint.sh` (SwiftLint + build are strict gates;
  swift-format / periphery are advisory for this vendored code).
- Tests use XCTest (kept as-is).
