# Merge & Tag Plan — De-vendoring the Package Graph

**Goal:** turn the 21 by-path (`.package(path:)`) packages in this repo into standalone,
versioned packages consumed by `.package(url:…, from:…)`. This is executed **wave by wave,
bottom-up**, exactly as [`PACKAGE-DEPENDENCIES.md`](PACKAGE-DEPENDENCIES.md) prescribes: a
package can only be tagged once every in-repo package it depends on already has a release to
point at.

## Current state (verified)

- **20 of 21 packages are already git-subrepos** with their own GitHub remotes under
  `github.com/brightdigit/*`. Each `Packages/**/` dir has a `.gitrepo` file. The lone
  non-subrepo node is the **root `BrightDigit` package** (this repo itself).
- All subrepos are currently pinned on a working branch (`brightdigit-com-260406` /
  `-260621` / `-260717`), **not** a tag, and are consumed **by path** from the root
  `Package.swift` (lines 25–43).
- **11 subrepos still declare `../../` cross-path deps** in their own manifests — these are
  the edges that must be rewritten to versioned `url:` deps as each target gets tagged:

  | Package | `../../` deps to rewrite | Rewrite after wave |
  |---|---|---|
  | `Publish` | `../Ink`, `../Plot`, `../Files` | 0 |
  | `PublishType` | `../../Publish/Publish` | 1 |
  | `YoutubePublishPlugin` | `../../Publish/Publish` | 1 |
  | `ReadingTimePublishPlugin` | `../../Publish/Publish` | 1 |
  | `NPMPublishPlugin` | `../../Publish/Publish` | 1 |
  | `TransistorPublishPlugin` | `../../Publish/Publish`, `../../Publish/Ink` | 1 |
  | `TailwindKit` | `../../Publish/Plot` | 0 |
  | `ContributeButtondown` | `../../BrightDigit/Contribute`, `…/ButtondownKit` | 0 |
  | `ContributeMailchimp` | `…/Contribute`, `…/Spinetail` | 0 |
  | `ContributeRSS` | `…/Contribute`, `…/SyndiKit` | 0 |
  | `ContributeWordPress` | `…/Contribute`, `…/SyndiKit` | 0 |
  | `ContributeYouTube` | `…/Contribute`, `…/SwiftTube` | 0 |

- **Tagging is not from zero.** These forks already have upstream tag histories — cut the
  *next* release of each fork, don't restart numbering. Sampled current tips:
  `Plot 0.14.0`, `Files 4.3.0`, `SyndiKit 0.8.1`, `Contribute 1.0.0-alpha.5`,
  `Spinetail 1.0.0-alpha.2`, `SwiftTube 0.2.0-beta.5`, **`ButtondownKit` has no tags yet**
  (start it at `0.1.0` or `1.0.0-alpha.1`). Confirm each package's actual latest tag before
  choosing its next version (`git ls-remote --tags`).

> **Update (2026-07-22):** `SwiftTube` and `Spinetail` have **finished** their OpenAPI-generator
> rebuild and are cut to a `v1.0.0` branch, so they are no longer excluded — they are back in the
> active Wave 0 set. Their rebuild renamed public types (Spinetail `MailchimpCampaign` → `Campaign`;
> SwiftTube Videos rename); consumers must adopt the new names. `TailwindKit` is still intentionally
> parked (do not pull). Deprecated modules (`ContributeMailchimp`, `ContributeYouTube`,
> `KannaMarkdownGenerator`) get tagged for graph-completeness only — no code changes.

## Step 0 — Standalone CI path rewrite (done in-tree; push with each subrepo)

Before tagging, every package with `.package(path:)` deps uses the **SundialKitStream /
setup-sundialkit dual-mode pattern** so its *own* GitHub Actions CI can resolve deps when
the package is checked out alone:

- `Package.swift` keeps named path deps (monorepo `packages.yaml` unchanged).
- `Scripts/ensure-remote-deps.sh` rewrites those paths to
  `.package(url:…, revision:<SHA>)` (branch pin via `git ls-remote`), then deletes
  `Package.resolved`.
- Standalone workflows call that script after `actions/checkout` and before
  `swift-build` / lint.

When a package is permanently switched to `from:` in a later wave, remove the script +
workflow step for that package (path deps are gone).

**Limit:** dual-mode only fixes a package whose deps are themselves path-free when fetched
by URL (Wave-0 leaves). SPM does not run `ensure-remote-deps.sh` inside a fetched
dependency.

**Done (early Wave 1):** `Publish` is permanently on `url:` + `revision:` pins for
Ink/Plot/Files (branch tips of `brightdigit-com-260406`). Its ensure script / CI rewrite
steps are removed. Wave-2 consumers keep dual-mode and can resolve Publish standalone;
swap those `revision:` pins to `from:` when Wave-0 leaf tags exist.

## The one repeatable unit of work: "release a package"

For each package, in wave order, do this loop. Steps 2–3 only apply to packages that have
`../../` deps (the table above); leaf packages skip straight to tag.

1. **Sync the subrepo** — `git subrepo push <path>` so the subrepo's own repo has the exact
   code that's building here. (Working tree must be clean.)
2. **Rewrite its in-repo deps** to versioned `url:` — inside the package's own repo, change
   each `.package(path: "../../…/Dep")` to
   `.package(url: "https://github.com/brightdigit/Dep.git", from: "<Dep's just-tagged version>")`.
   Every dep it references is already tagged because we work bottom-up. Remove
   `Scripts/ensure-remote-deps.sh` and its workflow calls for that package.
3. **Verify it builds standalone** — clone/checkout the package alone and `swift build`
   (without relying on the CI rewrite script).
4. **Tag & release** — cut the next semver tag on the package's own repo and push it.
5. **Bump consumers** — anything in a later wave that depends on this package now points at
   the new tag (handled when that later wave runs).

Then, once **all** waves are tagged, do the **root cutover** (below).

## Release waves

Topological levels from `PACKAGE-DEPENDENCIES.md §Release order`. Everything in a wave depends
only on earlier waves, so a whole wave can be released in parallel.

### Wave 0 — leaves (no in-repo deps)
`Plot` · `Files` · `Ink` · `SyndiKit` · `ButtondownKit` · `SwiftTube`* · `Spinetail`* · `Contribute`

- Pure leaf-tag — no manifest rewrite needed (they have zero in-repo deps).
- `Ink` → external `swift-markdown` only; `Contribute` → external Yams/SwiftSoup/swift-markdown.
- \*`SwiftTube`/`Spinetail`: **skip re-tagging**, use existing published tag.
- **Highest-leverage start:** `Plot` (unblocks `TailwindKit` + whole Publish stack) and
  `Contribute` (unblocks all five importers).

### Wave 1 — depend only on Wave 0
`Publish` · `TailwindKit` · `ContributeButtondown` · `ContributeMailchimp` · `ContributeRSS` · `ContributeWordPress` · `ContributeYouTube`

- `Publish` → **done early** with `url:` + `revision:` (not yet `from:`); remaining work is
  bump pins to tagged Wave-0 urls once leaves are tagged.
- `TailwindKit` → rewrite `../../Publish/Plot` → tagged `Plot` url. (Parked — do only if unparking.)
- Each `Contribute*` importer → rewrite its two `../../` deps → `Contribute` + its Wave-0 client.

### Wave 2 — the Publish plugin/type layer (depend on `Publish`, tagged in Wave 1)
`PublishType` · `YoutubePublishPlugin` · `ReadingTimePublishPlugin` · `TransistorPublishPlugin` · `NPMPublishPlugin`

- Each rewrites `../../Publish/Publish` (and `TransistorPublishPlugin` also `../../Publish/Ink`)
  → tagged urls from Waves 1/0.

### Wave 3 — root cutover (the hub)
`BrightDigit` (this repo)

- After every dependency is tagged, rewrite **all 16** `.package(path:)` lines in the root
  `Package.swift` (lines 25–43) to `.package(url:…, from:…)` at the versions just cut.
- `swift build && swift test`, then `swift run brightdigitwg publish --mode drafts` to confirm
  a full site build against the versioned graph.
- Once green, the `Packages/**` subrepo working copies are no longer needed to build; decide
  separately whether to remove them from the tree (a follow-up, not part of tagging).

## Ordering constraints (do-not-violate)

1. **Never tag a package before all its in-repo deps are tagged.** The wave table encodes this;
   within a wave, order doesn't matter.
2. **Rewrite deps → then build standalone → then tag.** Tagging a package whose manifest still
   has `../../` paths ships a broken release.
3. **Root is always last.** It depends on all 16 first-party packages.
4. Subrepo pushes require a **clean working tree**; if `git subrepo push --all` aborts on a
   stale `.gitrepo parent`, run `./fix-subrepo-parents.sh` then retry (per AGENTS.md).

## Progress tracker

Mark each as: ☐ todo · ◐ deps-rewritten · ✅ tagged `vX.Y.Z`

⚠ = open milestoned GitHub issue work remains on this package (does not block tagging unless noted).

**Wave 0:** ☐ Plot ☐ Files ☐ Ink ☐ SyndiKit ◐ ButtondownKit `v1.0.0` ⚠ [#31](https://github.com/brightdigit/brightdigit.com/issues/31) [#33](https://github.com/brightdigit/brightdigit.com/issues/33) [#140](https://github.com/brightdigit/brightdigit.com/issues/140) ◐ Contribute `v1.0.0` ◐ SwiftTube `v1.0.0` ◐ Spinetail `v1.0.0`
(ButtondownKit / SwiftTube / Spinetail / Contribute merged to a `v1.0.0` branch — only `v1.0.0` + `main` remain, old `-260621` deleted; SwiftTube/Spinetail rebuild renames done. SyndiKit stays on `brightdigit-com-260621`. Not yet cut as `v`-less semver tags.)

> **Root (phase-05) consumption (2026-07-22):** the root `Package.swift` now pins Contribute,
> Spinetail, and ButtondownKit to `branch: "v1.0.0"`; SyndiKit stays on `brightdigit-com-260621`.
> **Blocker:** a full resolve additionally requires every Wave-1 `Contribute*` satellite
> (`brightdigit-com-260717`) to repin its Contribute/Spinetail/ButtondownKit/SwiftTube deps to
> `v1.0.0` — they currently still pin the deleted `-260621` branches, which conflicts with the root.

**Wave 1:** ☐ Publish ☐ ContributeButtondown ☐ ContributeMailchimp ☐ ContributeRSS ☐ ContributeWordPress ☐ ContributeYouTube
(⏭ TailwindKit — parked)

**Wave 2:** ☐ PublishType ⚠ [#135](https://github.com/brightdigit/brightdigit.com/issues/135) ☐ YoutubePublishPlugin ☐ ReadingTimePublishPlugin ☐ TransistorPublishPlugin ☐ NPMPublishPlugin

**Wave 3:** ☐ BrightDigit (root cutover) ⚠ [#129](https://github.com/brightdigit/brightdigit.com/issues/129) [#50](https://github.com/brightdigit/brightdigit.com/issues/50) [#70](https://github.com/brightdigit/brightdigit.com/issues/70) [#135](https://github.com/brightdigit/brightdigit.com/issues/135) [#140](https://github.com/brightdigit/brightdigit.com/issues/140) [#92](https://github.com/brightdigit/brightdigit.com/issues/92)
