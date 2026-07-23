# Branch Dependency Release Checkpoint

This checkpoint temporarily removes the root repository's `Packages/` subrepo tree so the package
repositories can move through their merge and tag sequence independently. The root consumes every
first-party package from a URL + branch pin; packages are not tagged yet. Living checklist:
[`MERGE-AND-TAG.md`](../../MERGE-AND-TAG.md).

## Working Branches (2026-07-23)

| Branch | Packages |
| --- | --- |
| `main` | Plot, Files, Ink, SyndiKit, ButtondownKit, SwiftTube, Spinetail, Contribute (Wave 0; release PRs merged; untagged) |
| `brightdigit-com-260406` | Publish, ContributeWordPress, NPMPublishPlugin, TransistorPublishPlugin, YoutubePublishPlugin, ReadingTimePublishPlugin |
| `brightdigit-com-260717` | ContributeButtondown, ContributeMailchimp, ContributeRSS, ContributeYouTube, PublishType, TailwindKit |

Wave 0 `brightdigit-com-*` / `v1.0.0` working branches are obsolete for consumers — pin Wave 0
deps to `main`. **Done (2026-07-23):** the root and all eight Wave 1/2 packages that consume a
Wave 0 package now declare `branch: "main"` for those deps. The stale `v1.0.0` branches still
exist on the Wave 0 remotes; delete them only after tagging.

Wave 1/2 packages remain pinned to their `brightdigit-com-*` working branches, which are **not
merged to `main`** — each repo's `main` is behind its working branch and missing essential
commits, so repinning them to `main` would resolve to old code.

Note: SwiftPM cannot mix two branch requirements for one package
(`error: … required using two different revision-based requirements`), so the root and every
Wave 1/2 consumer must move a given Wave 0 dep to `main` together. After such a repin,
`swift package update` is required — plain `swift package resolve` reuses the revisions already
recorded in `Package.resolved` and keeps reading the old manifests.

Dual-mode `ensure-remote-deps.sh` was removed from Wave 1/2 packages whose
manifests already use `url:` + `branch:`.

`Package.swift` declares the 16 direct dependencies. `Package.resolved` records those packages plus
the four first-party transitive dependencies, producing the complete 20-package branch graph.

## Retained Subrepo Infrastructure

The absence of `Packages/` is temporary, not a change in repository architecture. These files remain
canonical and tracked:

- `.github/packages.json`
- `.github/workflows/packages.yaml`
- `fix-subrepo-parents.sh`

Standalone package repos may still keep `Scripts/ensure-remote-deps.sh` only while they have
`path:` deps; once on `url:` + `branch:`/`from:`, remove the script and workflow steps. The
packages workflow detects an absent `Packages/` directory in its configure job and succeeds without
launching build or lint matrices.

## Next Release Gate

Wave 0 is on `main`, and every Wave 1/2 consumer now pins its Wave 0 deps to `branch: "main"` with
a refreshed `Package.resolved` and green CI. **Immediate next step: merge the seven Wave 1 working
branches into their default branch** via the already-open, MERGEABLE PRs — merge Publish first
(Wave 2 depends on it), then the rest in parallel. Keep the working branches until the root is
repinned. Per-repo checklist, merge order, and the two open decisions (Publish's default branch is
`master` not `main`; `.swift-version` 5.8 drift in TransistorPublishPlugin + ContributeWordPress)
are in [`MERGE-AND-TAG.md`](../../MERGE-AND-TAG.md).

After that: tag packages from the most independent wave to the least dependent wave,
and replace branch requirements with released `from:` versions. Untagged packages begin at
`1.0.0-alpha.1` (or ship the `v1.0.0` line when that is the release); existing stable releases
receive patch bumps, and existing prerelease lines advance.

The root PR remains unmerged until every direct and transitive first-party dependency uses a released
tag. After that merge, subsequent development rebases onto `main` and restores the subrepos for the
`v2.0.0-alpha.2` development cycle.
