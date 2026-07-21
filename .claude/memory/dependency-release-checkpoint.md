# Branch Dependency Release Checkpoint

This checkpoint temporarily removes the root repository's `Packages/` subrepo tree so the package
repositories can move through their merge and tag sequence independently. The root consumes every
first-party package from its existing working branch; no package is merged or tagged in this phase.

## Working Branches

| Branch | Packages |
| --- | --- |
| `brightdigit-com-260406` | ContributeWordPress, NPMPublishPlugin, TransistorPublishPlugin, YoutubePublishPlugin, ReadingTimePublishPlugin, Files, Ink, Plot, Publish |
| `brightdigit-com-260621` | ButtondownKit, Contribute, Spinetail, SwiftTube, SyndiKit |
| `brightdigit-com-260717` | ContributeButtondown, ContributeMailchimp, ContributeRSS, ContributeYouTube, PublishType, TailwindKit |

`Package.swift` declares the 16 direct dependencies. `Package.resolved` records those packages plus
the four first-party transitive dependencies, producing the complete 20-package branch graph.

## Retained Subrepo Infrastructure

The absence of `Packages/` is temporary, not a change in repository architecture. These files remain
canonical and tracked:

- `.github/packages.json`
- `.github/workflows/packages.yaml`
- `fix-subrepo-parents.sh`

The standalone package repositories retain their `Scripts/ensure-remote-deps.sh` helpers. The
packages workflow detects an absent `Packages/` directory in its configure job and succeeds without
launching build or lint matrices.

## Next Release Gate

The next phase merges and tags packages from the most independent wave to the least dependent wave,
replacing branch requirements with released `from:` versions as it proceeds. Untagged packages begin
at `1.0.0-alpha.1`; existing stable releases receive patch bumps, and existing prerelease lines
advance.

The root PR remains unmerged until every direct and transitive first-party dependency uses a released
tag. After that merge, subsequent development rebases onto `main` and restores the subrepos for the
`v2.0.0-alpha.2` development cycle.
