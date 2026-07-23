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
deps to `main`. Dual-mode `ensure-remote-deps.sh` was removed from Wave 1/2 packages whose
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

Wave 0 is on `main`. Next: tag packages from the most independent wave to the least dependent wave,
and replace branch requirements with released `from:` versions. Untagged packages begin at
`1.0.0-alpha.1` (or ship the `v1.0.0` line when that is the release); existing stable releases
receive patch bumps, and existing prerelease lines advance.

The root PR remains unmerged until every direct and transitive first-party dependency uses a released
tag. After that merge, subsequent development rebases onto `main` and restores the subrepos for the
`v2.0.0-alpha.2` development cycle.
