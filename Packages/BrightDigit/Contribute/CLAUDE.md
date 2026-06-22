# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Contribute is a Swift library (SPM package, product `Contribute`) that converts existing sources — primarily HTML — into Markdown files with YAML front matter, for importing into static-site generators. There is no executable target; it is consumed as a library.

## Commands

This package builds with the **Swift 6.4 toolchain** (`.swift-version` → `6.4.x-snapshot`; tools-version 5.8). Use the matching snapshot/`Xcode-beta` toolchain locally.

- Build: `swift build` (release crashes the optimizer on stock SwiftSoup — see "Toolchain pins" below)
- Build incl. tests: `swift build --build-tests`
- Run all tests: `swift test`
- Run one test class: `swift test --filter SwiftSoupMarkdownGeneratorTests`
- Run one test: `swift test --filter ContributeTests.SwiftSoupMarkdownGeneratorTests/testHeadings`

### Linting

Lint tooling is pinned via **mise** (`.mise.toml`). The canonical entry point is `Scripts/lint.sh`, which bootstraps tools with `mise install` then runs swift-format, SwiftLint, a build check, and (locally only) periphery.

- Full lint + autofix (local): `Scripts/lint.sh`
- Format only: `FORMAT_ONLY=1 Scripts/lint.sh`
- CI/strict mode (no autofix, fails on warnings): `LINT_MODE=STRICT CI=1 Scripts/lint.sh`
- Individual tools: `mise exec -- swift-format ...`, `mise exec -- swiftlint`, `mise exec -- periphery scan -- --build-system native`

Notes: in CI (`CI` set) the script skips autofix, the license-header rewrite (`Scripts/header.sh`), and periphery. Periphery requires `--build-system native` because Swift 6.4's default `swiftbuild` writes its index store to a location periphery 3.7.4 doesn't find. SwiftLint config is strict and opinionated (`explicit_acl`, `force_unwrapping`, `file_length` warning at 225 lines, etc.) — keep files small and ACLs explicit.

## Architecture

The pipeline is **protocol-oriented and generic over a `SourceType`** (the user's content model). A source flows: front-matter exporting + markdown extraction → combined into a Markdown-with-front-matter document → written to a generated destination URL. The four moving parts are each a protocol so callers swap implementations while keeping the `SourceType` consistent (associated-type constraints tie them together).

Core protocols (`Sources/Contribute/Protocols/`):
- `MarkdownContentBuilder` — top-level: `content(from:using:)` builds the full document. Its extension adds `write(from:atContentPathURL:basedOn:using:shouldOverwrite:)`, which generates the destination URL and writes the file. **`MarkdownContentYAMLBuilder` is the concrete builder**, composing a `FrontMatterExporter` + a `MarkdownExtractor` (both pinned to the same `SourceType`) and joining them with `SimpleFrontMatterMarkdownFormatter`.
- `MarkdownExtractor` — produces the markdown body from a source. `FilteredHTMLMarkdownExtractor<SourceType: HTMLSource>` pulls `source.html` and runs the HTML→Markdown closure.
- `FrontMatterExporter` — produces front-matter text. Typically backed by a `FrontMatterTranslator` (source → `Encodable` front-matter struct) serialized by a `FrontMatterFormatter` (e.g. YAML via Yams → `FrontMatterYAMLExporter`).
- `ContentURLGenerator` — maps a source to its output file URL (`BasicContentURLGenerator`, `FileNameGenerator`).

**HTML→Markdown conversion** is itself abstracted by `MarkdownGenerator` (`markdown(fromHTML:)`), passed through the pipeline as an `@escaping (String) throws -> String` closure:
- `SwiftSoupMarkdownGenerator` is the real, in-process converter — SwiftSoup parses HTML, swift-markdown emits CommonMark. No external `pandoc` binary (it replaced a removed `PandocMarkdownGenerator`), so it runs on Linux/CI. Rendering logic is split across `SwiftSoupMarkdownGenerator.swift`, `+Markup.swift`, and `+TableList.swift`. Read the doc comment at the top of `SwiftSoupMarkdownGenerator.swift` for coverage and deliberate lossiness (`<dl>`/`<table>` flattened to prose; no GFM data tables; links/images nested inside inline emphasis are dropped — these are documented limitations, not bugs).
- `HTMLtoMarkdown` is a thin closure-wrapping `MarkdownGenerator` adapter.
- `PassthroughMarkdownGenerator` returns input unchanged (for already-markdown sources / testing).

When adding a feature, find the protocol it belongs to first; concrete types are small and generic, so changes usually mean a new conforming type rather than editing existing ones.

## Tests

XCTest-based (`Tests/ContributeTests/`). The suite leans on hand-written **Spies** (`Spies/` — `FileManagerSpy`, `FrontMatterExporterSpy`, etc.) and **Mocks** (`Mock/`) for the protocol seams, plus `XCTestCase+Extension.swift` helpers for the `FileURLDownloader` flow. Match this spy/mock style rather than introducing a mocking framework.

## Toolchain pins (why dependencies point at branches)

`Package.swift` deliberately pins two deps to branches and uses a fork — keep these in mind before "fixing" them:
- **SwiftSoup → `brightdigit/SwiftSoup@fix/swift-6.4-inline-crash`**: upstream's `@inline(__always)` crashes the Swift 6.4 nightly optimizer under `swift build -c release`. Switch back to `scinfu/SwiftSoup` (tagged) once the toolchain stabilizes.
- **swift-markdown → `swiftlang/swift-markdown@main`**: tracks the `gfm` cmark branch used with Swift 6.4; URL standardized on `swiftlang` so SPM resolves a single identity.

## CI

A single workflow, `.github/workflows/Contribute.yml` (a shared BrightDigit template). It builds on Ubuntu (nightly-6.4 container, plus wasm/wasm-embedded variants gated by the `ENABLE_WASM` repo variable), self-hosted macOS + Apple platforms (Xcode 27/Swift 6.4), Windows, and Android. Matrix scope tiers up by ref: small set always; full matrix + Windows on `main`/semver tags/dispatch/PRs into `main`. Skip CI with `ci skip` in the commit message. Code is `#if canImport(FoundationNetworking)`-guarded for non-Apple platforms — preserve those guards.
