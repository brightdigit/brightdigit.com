# Branch Dependency Release Checkpoint

This checkpoint temporarily removes the root repository's `Packages/` subrepo tree so the package
repositories can move through their merge and tag sequence independently. The root consumes every
first-party package from a URL + branch pin; packages are not tagged yet. Living checklist:
[`MERGE-AND-TAG.md`](../../MERGE-AND-TAG.md).

## Working Branches (2026-07-27)

| Branch | Packages |
| --- | --- |
| `main` | Wave 0 (Plot, Files, Ink, SyndiKit, ButtondownKit, SwiftTube, Spinetail, Contribute) + Wave 1 (Publish, TailwindKit, ContributeButtondown, ContributeMailchimp, ContributeRSS, ContributeWordPress, ContributeYouTube) — release PRs merged; untagged |
| `brightdigit-com-260406` | YoutubePublishPlugin, ReadingTimePublishPlugin, NPMPublishPlugin, TransistorPublishPlugin (Wave 2 PR heads; each pins Publish to `main`) |
| `brightdigit-com-260717` | PublishType (Wave 2 PR head; pins Publish to `main`) |

Wave 0 and Wave 1 `brightdigit-com-*` working branches are **deleted** (2026-07-27). Root pins
every Wave 0/1 package to `branch: "main"`. Wave 2 packages remain on working branches until
their release PRs merge; after each merge, repin that package in the root to the repo default
(`main`, except ReadingTimePublishPlugin → `master`).

**Done (2026-07-27):** same-step Publish → `main` repin across the root and all five Wave 2
consumers (`swift package update` + committed lockfiles). Root smoke-builds clean.

Note: SwiftPM cannot mix two branch requirements for one package
(`error: … required using two different revision-based requirements`), so the root and every
Wave 2 consumer must move Publish to `main` together. After such a repin,
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

Wave 0 and Wave 1 are on `main` with working branches deleted. Root and Wave 2 consumers pin
Publish to `branch: "main"`. **Immediate next step: review/merge the five Wave 2 PRs**, then
repin each merged package in the root from its working branch to the repo default. Keep Wave 2
working branches until the root is repinned off them.

After that: tag packages from the most independent wave to the least dependent wave,
and replace branch requirements with released `from:` versions. Untagged packages begin at
`1.0.0-alpha.1` (or ship the `v1.0.0` line when that is the release); existing stable releases
receive patch bumps, and existing prerelease lines advance.

The root PR remains unmerged until every direct and transitive first-party dependency uses a released
tag. After that merge, subsequent development rebases onto `main` and restores the subrepos for the
`v2.0.0-alpha.2` development cycle.
