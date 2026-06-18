# Phase 4 — OpenAPI Client Migration: Approach Note

Tracking: #82 (parent) · #37 (SwiftTube + Spinetail) · #45 (remove Prch) · #83 (ButtondownKit greenfield).

This is the durable reference the three parallel sub-tracks (`youtube`,
`mailchimp`, `buttondown`) work against. It records the toolchain decision, where
the specs come from, how they are filtered + generated, the migration order, and
the verification strategy.

### Scope (2026-06-17): all three tracks are greenfield

SwiftTube and Spinetail are old enough to be treated as **basically greenfield**,
exactly like ButtondownKit. We rebuild the clients **fresh from the OpenAPI
specs** with swift-openapi-generator and do **not** preserve the SwagGen/Prch
structure. The **byte-identical-output bar is dropped for all three tracks** —
already-imported markdown may legitimately change. Correctness is verified with
**contract tests against the specs**, not an output diff.

## 1. Toolchain — generator is a mise-managed CLI, output is committed

Adopt Apple's swift-openapi-generator stack, producing protocol-based async
clients (`APIProtocol` + generated `Client`). The key architectural decision:

- **The generator is a CLI tool installed via mise's SPM backend, NOT a SwiftPM
  build/command plugin and NOT a `Package.swift` dependency.** It is pinned in
  each package's `.mise.toml`:
  `"spm:apple/swift-openapi-generator" = "1.12.2"`.
- **Generated `Types.swift` + `Client.swift` are produced ahead of time and
  committed** to the repo under `Sources/<Target>/Generated/` — they are NOT
  generated into `.build` at build time. This keeps the build hermetic (no
  plugin sandbox, no per-build codegen) and makes the generated surface
  reviewable in PRs.

| Package | Repo | Role |
| --- | --- | --- |
| `swift-openapi-generator` | apple/swift-openapi-generator | **mise CLI tool** (`filter` + `generate` subcommands). Run via `Scripts/generate-openapi.sh`. Pinned 1.12.2. |
| `swift-openapi-runtime` | apple/swift-openapi-runtime | Runtime dependency of the generated code (`Operations`, `Components`, `ClientTransport`). |
| `swift-openapi-urlsession` | apple/swift-openapi-urlsession | `URLSessionTransport` — works on macOS **and** Linux (FoundationNetworking). |
| `swift-http-types` | apple/swift-http-types | Declared so the contract tests can name `HTTPRequest`/`HTTPResponse` in their mock transport. |

Each new client library targets the **latest Swift**: `swift-tools-version:6.4`
and Swift 6 language mode (`swiftSettings: [.swiftLanguageMode(.v6)]`).

## 2. Full spec → filter → generate

Each client ships the **complete** upstream OpenAPI document, then filters it
down to only the operations brightdigit.com uses before generating.

### YouTube (SwiftTube) — implemented

YouTube has no first-party OpenAPI document, so it is derived from Google's
official **Discovery Document**:

1. Fetch `https://youtube.googleapis.com/$discovery/rest?version=v3` →
   `Packages/BrightDigit/SwiftTube/openapi/youtube-discovery.json` (committed).
2. Convert Discovery → Swagger 2.0 (`google-discovery-to-swagger`) → OpenAPI 3.0
   (`swagger2openapi`), then post-process (strip OAuth security since the
   importer uses an API-key query param, normalise `*/*` response bodies to
   `application/json`, and rename the verbose dotted operationIds to short
   names). All of this lives in `Scripts/discovery-to-openapi.mjs`. Output:
   `openapi/youtube-openapi.json` (the **full** ~80-operation spec, committed).
3. **Filter** to the operations we use with the generator's `filter` subcommand
   driven by `openapi/openapi-filter.yaml`:
   - `listPlaylistItems` (playlistItems.list — paged video ids for a playlist)
   - `listVideos` (videos.list — batched video-detail lookup)
   The filter automatically pulls in every schema/parameter those operations
   depend on, so we don't carry the entire API surface.
4. **Generate** `Sources/SwiftTube/Generated/{Types,Client}.swift` from the
   filtered document using `openapi/openapi-generator-config.yaml`
   (`generate: [types, client]`, `accessModifier: public`,
   `additionalFileComments: [swift-format-ignore-file, "swiftlint:disable all"]`).

The hand-written async `YouTubeClient` (pagination + concurrent id batches via
`withThrowingTaskGroup`) wraps the generated `Client` and returns a flat,
`Sendable` `YouTubeVideo` model.

### Reproducible generation: `Scripts/generate-openapi.sh`

One parameterised script regenerates the committed output for any client:

```
Scripts/generate-openapi.sh SwiftTube            # filter + generate (default)
Scripts/generate-openapi.sh SwiftTube --refresh  # re-fetch discovery + reconvert first
Scripts/generate-openapi.sh SwiftTube --check     # regenerate to a temp dir + diff (drift check)
```

Adding Spinetail / ButtondownKit is a new `case` in the library table at the top
of the script (`PKG`, `TARGET`, `SPEC`, filter/generate config paths). The
`--check` mode is the CI/`make`-style drift guard: it regenerates and
`diff`s against the committed files, failing if they are stale.

### Spinetail (Mailchimp) / ButtondownKit — next

- **Spinetail (Mailchimp Marketing API)** — full spec from
  `mailchimp/mailchimp-client-lib-codegen` (`spec/marketing.json`). Filter to
  `getCampaigns` + `getCampaignsIdContent`. Basic-auth transport middleware
  (`anystring:apikey`). Already-vendored full spec stays as source of truth.
- **ButtondownKit (greenfield)** — Buttondown ships an official OpenAPI **3.0.2**
  doc (`github.com/buttondown/openapi`); commit it directly (no discovery
  conversion needed) and filter to the issue/draft operations #83 needs. API key
  via `BUTTONDOWN_API_KEY` env var only; no subscriber data in the repo.

## 3. Migration order

1. **YouTube / SwiftTube (this PR).** mise CLI toolchain + full-spec→filter→
   generate pipeline + committed generated code + async `YouTubeClient` + contract
   tests. `ContributeYouTube` and the `podcast` import command are rewired onto
   the async client; the SwagGen tree and SwiftTube's Prch dependency are deleted.
2. **Mailchimp / Spinetail.** Same recipe; Spinetail keeps Prch only until its own
   track lands, so the build is not broken in the meantime.
3. **ButtondownKit (#83).** Greenfield; same recipe.
4. **Finish removing Prch (#45).** Once Spinetail is also off Prch, drop it from
   the top-level manifest.

## 4. Async/await rewrite

- Generated clients are `async throws`; the Prch `requestSync` /
  `DispatchSemaphore` / `DispatchGroup` patterns are gone.
- YouTube playlist pagination is an `async` loop; per-50-id video batches run in
  parallel via `withThrowingTaskGroup`, reassembled in batch order.
- The `podcast` import command is now an `AsyncParsableCommand` with
  `func run() async throws` (the root `BrightDigitSiteCommand` already awaits
  `.main()`).

## 5. Verification (contract tests, not output diff)

Every track is verified the same greenfield way — **contract tests** that drive
the generated client offline:

1. A fixture-replaying `ClientTransport` (`MockTransport`, implemented as an
   `actor` so it is concurrency-safe without `@unchecked Sendable`) returns
   recorded JSON bodies keyed by request path — deterministic, no network, CI-safe.
2. Tests assert the client follows pagination, batches by the API's id limit,
   maps the response fields the importer reads, and surfaces non-200 responses as
   errors. (See `Tests/SwiftTubeTests`.)

The CI gate for every commit: Ubuntu container build+test in
`brightdigit/publish-xml:6.4` plus STRICT lint, plus the standalone package
matrix in `.github/workflows/packages.yaml`.

## 6. Lint / CI scaffolding

- **Generated code is excluded from lint** two ways: every generated file carries
  `// swift-format-ignore-file` + `// swiftlint:disable all` (injected via the
  generator's `additionalFileComments`), and `Sources/SwiftTube/Generated` is in
  the package `.swiftlint.yml` `excluded:` list. STRICT lint of the package is
  **clean** — deleting the ~261 SwagGen files also removes the legacy ~1.7k-
  violation problem. The package adopts the BrightDigit lint template
  (`.swiftlint.yml`, `.swift-format`, `.mise.toml`, `Scripts/lint.sh`,
  `Scripts/header.sh`) copied from SyndiKit.
- **packages.yaml matrix:** SwiftTube is in the `packages` list so it gets the
  macOS build (Swift 6.4 via Xcode) and the STRICT lint job (nightly-6.4
  container). It is excluded from `build-ubuntu` because that job pins the
  `swift:6.3-*` container, which cannot parse a `swift-tools-version:6.4` manifest.
- **Drift check:** `Scripts/generate-openapi.sh SwiftTube --check` regenerates and
  diffs against the committed output — wire into CI/make to catch spec drift.

## 7. Status

**Done — YouTube / SwiftTube under the new architecture:**
- mise CLI generator pinned in `.mise.toml`; no generator package dep, no plugin.
- Full discovery-derived spec committed; filtered to 2 ops; generated
  `Types.swift`/`Client.swift` committed under `Sources/SwiftTube/Generated`.
- `SwiftTube` rebuilt as a single `swift-tools-version:6.4` / Swift 6 library:
  async `YouTubeClient` + `YouTubeVideo` + contract tests. SwagGen tree (~261
  files) and Prch dependency deleted.
- `ContributeYouTube` de-Prch'd and rewired onto the async client; `podcast`
  command is async. Builds + tests green on Linux + macOS; STRICT lint clean
  (top-level and standalone).

**Remaining:**
- Mailchimp/Spinetail (#37) and ButtondownKit (#83) — same recipe.
- Final Prch removal (#45) once Spinetail is migrated.
