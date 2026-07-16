# CLAUDE.md — Publish

Vendored package in the BrightDigit Publish stack (`Packages/Publish/Publish`),
maintained in-tree on plain Swift 6.4 (`// swift-tools-version:6.4`), macOS 15+.

- Strict concurrency is mandatory. Resolve every diagnostic properly
  (Sendable / isolation / `Synchronization.Mutex`); never use
  `@unchecked Sendable` — a SwiftLint `no_unchecked_sendable` rule enforces this.
- Lint: `LINT_MODE=STRICT ./Scripts/lint.sh` — full BrightDigit house style
  (swift-format + SwiftLint + build) gates; periphery is local-only (skipped
  when `$CI` is set).
- `PublishingContext` is fully `Sendable`. Front-matter dates use
  `dateParseStrategy: Date.ParseStrategy` (not `DateFormatter`). HTML
  generation is serial; parallelism is a separate follow-up (#153).
- Command-line / `DeploymentMethod` support was removed — generation only;
  first-party drives mode via ArgumentParser and deploys via Netlify.
- Syntax highlighting is client-side (highlight.js in the site `Styling`
  bundle); Splash / SplashPublishPlugin are not part of this stack.
- Tests use XCTest (kept as-is).
