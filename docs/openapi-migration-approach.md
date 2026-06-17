# Phase 4 — OpenAPI Client Migration: Approach Note

Tracking: #82 (parent) · #37 (SwiftTube + Spinetail) · #45 (remove Prch) · #83 (ButtondownKit greenfield).

This is the **spike-first**, multi-week track. This note records the toolchain
decision, where the specs come from, the migration order, and the verification
strategy. It is the durable reference the three parallel sub-tracks (`youtube`,
`mailchimp`, `buttondown`) work against.

### Scope (2026-06-17): all three tracks are greenfield

Per the updated scope on #82/#37, SwiftTube and Spinetail are old enough to be
treated as **basically greenfield**, exactly like ButtondownKit. We rebuild the
clients **fresh from the OpenAPI specs** with swift-openapi-generator and do
**not** preserve the SwagGen/Prch-generated structure. The
**byte-identical-output bar is dropped for all three tracks** — already-imported
markdown may legitimately change. Correctness is verified with
**contract/integration tests against the specs**, not an output diff against the
old content.

## 1. Toolchain

Adopt Apple's swift-openapi-generator stack, producing **protocol-based async
clients** (`APIProtocol` + generated `Client`):

| Package | Repo | Role |
| --- | --- | --- |
| `swift-openapi-generator` | apple/swift-openapi-generator | SwiftPM **build plugin**; generates `Types.swift` + `Client.swift` at build time. Latest: 1.12.x. |
| `swift-openapi-runtime` | apple/swift-openapi-runtime | Runtime types shared by generated code (`Operations`, `Components`, `ClientTransport`). |
| `swift-openapi-urlsession` | apple/swift-openapi-urlsession | `URLSessionTransport` — works on macOS **and** Linux (FoundationNetworking). |

Notes:
- Use the **build-tool plugin** (`.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")`)
  so generated code is never checked in and always tracks the spec. Each target
  needs `openapi.yaml` + `openapi-generator-config.yaml` in its source dir.
- `URLSessionTransport` is the single transport for all Apple+Linux builds (the CI
  gate is Ubuntu in `brightdigit/publish-xml:6.4`). `AsyncHTTPClientTransport` is
  **not** needed; avoid pulling in swift-nio unless a later track requires it.
- Generator config: `generate: [types, client]`, `accessModifier: public`.
- Minimum tools version for plugin host packages: the vendored packages are
  bumped to `swift-tools-version:6.0+` (they were 5.2).

## 2. Where the specs live / how to obtain them

- **SwiftTube (YouTube Data API v3)** — vendored already at
  `Packages/BrightDigit/SwiftTube/openapi.yaml` (OpenAPI 3.0.0, 9.4k lines, the
  full Google discovery doc). Upstream of record:
  `https://youtube.googleapis.com/$discovery/rest?version=v3` (via APIs.guru).
- **Spinetail (Mailchimp Marketing API)** — vendored at
  `Packages/BrightDigit/Spinetail/OpenAPI/openapi.yaml` (OpenAPI 3.0.1, ~207k
  lines) and `marketing.json`. Upstream of record:
  `https://github.com/mailchimp/mailchimp-client-lib-codegen` (`spec/marketing.json`).
- **ButtondownKit (greenfield)** — fetch Buttondown's official OpenAPI **3.0.2**
  spec from `https://github.com/buttondown/openapi` and vendor it into a new
  `Packages/BrightDigit/ButtondownKit/openapi.yaml`. API key via
  `BUTTONDOWN_API_KEY` env var only; **no** subscriber/audience data in the repo.

### Trimmed-spec strategy (important)

The vendored YouTube and Mailchimp specs are the **entire** Google/Mailchimp
APIs. The brightdigit.com importers each touch only **two** operations:

- YouTube: `youtube.playlistItems.list` + `youtube.videos.list`.
- Mailchimp: `getCampaigns` + `getCampaignsIdContent`.

Generating off the full specs produces tens of thousands of lines of unused
types and is slow/fragile (the Mailchimp doc alone is 207k lines and uses
constructs the generator warns on). For these two clients we therefore generate
from a **focused OpenAPI document** that defines only the operations and the
exact response fields each importer reads. This is safe because:

1. The importer field set is small, known, and fully covered by contract tests.
2. The focused doc is a faithful subset of the upstream spec; the full vendored
   spec is retained as the source of truth for the contract.

The trimmed doc lives beside the generated target as `openapi.yaml`. (For the
`youtube` slice this is `Sources/SwiftTubeOpenAPI/openapi.yaml`.)

## 3. Migration order

1. **Toolchain + `youtube` slice (this PR).** Smallest viable end-to-end client;
   establishes the build-plugin pattern, the trimmed-spec pattern, the
   async/await client, and the contract-test harness. The `SwiftTubeOpenAPI`
   target builds + tests standalone here; rewiring ContributeYouTube and the
   `podcast` import command onto it is the next step on this track.
2. **`mailchimp` slice.** Same pattern; two operations; basic-auth transport
   middleware (`anystring:apikey`). Replaces `DispatchSemaphore`/`requestSync`.
3. **`buttondown` slice (#83).** Greenfield; vendored Buttondown 3.0.2 spec;
   contract tests (sandbox draft round-trip) — no prior output to diff.
4. **Remove Prch (#45).** Only once **both** SwiftTube and Spinetail no longer
   reference Prch. Drop the dep from both vendored `Package.swift` files and from
   the top-level manifest; delete the SwagGen-generated model/request trees.

The three client tracks are independent and parallelizable after step 1.

## 4. Async/await rewrite

- Generated clients are `async throws`. The Prch `requestSync` /
  `DispatchSemaphore` / `DispatchGroup` patterns are removed.
- Paged fetch (YouTube playlist pagination, per-50-id video batches) becomes
  `async` loops + `withThrowingTaskGroup` for the parallel video-detail batches.
- ArgumentParser `run()` becomes `func run() async throws` (ParsableCommand
  supports async run).

## 5. Verification (contract tests, not output diff)

The byte-identical bar is dropped. Every track is verified the same greenfield
way — **contract/integration tests** that exercise the generated client offline:

1. A fixture-replaying `ClientTransport` (`MockTransport`) returns recorded JSON
   bodies keyed by request path, so the generated client is driven
   deterministically and without network access (CI-safe).
2. Tests assert the client follows pagination, batches by the API's id limit,
   maps the response fields the importer reads, and surfaces non-200 responses
   as errors. (See `SwiftTubeOpenAPITests`.)
3. ButtondownKit: generated-client unit/contract tests against the spec
   (decode known payloads; a sandbox draft round-trip when a key is present).

The CI gate for every commit is the Ubuntu container build+test plus STRICT
lint — see the PR checklist.

## 6. Status (first slice landed)

**Done — `youtube` toolchain + client slice:**
- `SwiftTube/Package.swift` bumped to `swift-tools-version:6.0`; adds
  `swift-openapi-generator` (build plugin), `swift-openapi-runtime`,
  `swift-openapi-urlsession`, and `swift-http-types` (for the test transport).
- New `SwiftTubeOpenAPI` target: trimmed `openapi.yaml` + generator config drive
  the build plugin (generates `Types.swift`/`Client.swift` into `.build`), wrapped
  by a hand-written async `YouTubeClient` (pagination + concurrent id batches via
  `withThrowingTaskGroup`) returning a flat `YouTubeVideo` model.
- New `SwiftTubeOpenAPITests`: `MockTransport` (fixture-replaying `ClientTransport`)
  + contract tests for pagination, batching, field mapping, and non-200 handling.
  Green on Linux in `brightdigit/publish-xml:6.4`.
- The legacy SwagGen `SwiftTube` target is pinned to Swift 5 language mode and
  kept intact (ContributeYouTube still imports it); it is deleted with Prch (#45).

**Remaining on the `youtube` track:**
- Rewire `ContributeYouTube` (`YouTubeContent`/`Source`) and the `podcast` import
  command onto `SwiftTubeOpenAPI`; make `run()` async (drop the sync Prch path).
- Then drop `SwiftTube` (SwagGen) target + Prch dep from this package and the
  top-level manifest (#45) — only after Spinetail is also off Prch.

**`mailchimp` and `buttondown` tracks:** not started — same toolchain, independent.

### Lint note (vendored SwiftTube package)

The vendored `SwiftTube/.swiftlint.yml` is the original SwagGen-era config and is
incompatible with the repo's current SwiftFormat config / 6.4 toolchain: the
~261 generated SwagGen files produce ~1.7k strict violations independent of this
work (e.g. `discouraged_optional_boolean`, short identifier names), so package
STRICT SwiftLint was already red. Four opt-in rules that directly conflict with
the authoritative SwiftFormat output (`explicit_acl`, `explicit_top_level_acl`,
`type_contents_order`, `indentation_width`) were removed from the config so the
new greenfield target lints cleanly; the remaining legacy violations live only
in the SwagGen tree that #45 deletes. The new `SwiftTubeOpenAPI` sources/tests
pass `swiftlint --strict` and `swiftformat --lint` with zero violations.
