# Package De-vendoring — Complete

De-vendoring is **done** (2026-07-28). The root repository no longer vendors the 20 first-party
packages under `Packages/`; it consumes each one as a released version pin
(`.package(url:…, from:…)`). No `branch:` or `revision:` requirements remain anywhere in the
graph — all 36 `Package.resolved` pins resolve to versions.

The root checkpoint PR ([#161](https://github.com/brightdigit/brightdigit.com/pull/161)) merged
2026-07-28. Shipped versions per package, the recut rationale, and the remaining cleanup items
live in [`MERGE-AND-TAG.md`](../../MERGE-AND-TAG.md) — that file is the source of truth for
release detail; this one records only the architectural state.

## Retained Subrepo Infrastructure

The absence of `Packages/` is a checkpoint state, not a change in repository architecture. These
files remain canonical and tracked so the subrepos can be restored for the `v2.0.0-alpha.2` cycle:

- `.github/packages.json`
- `.github/workflows/packages.yaml`
- `fix-subrepo-parents.sh`

The packages workflow detects an absent `Packages/` directory in its configure job
(`packages-present`) and succeeds without launching the build or lint matrices — so those jobs
showing as *skipped* is expected, not a failure.

## Gotchas Worth Keeping

- SwiftPM cannot mix two branch requirements for one package
  (`error: … required using two different revision-based requirements`). This is why the root and
  every consumer had to move a shared dependency in the same step. Now that everything is
  version-pinned this no longer bites, but it will again during the subrepo restore.
- After repinning a dependency, `swift package update` is required — plain `swift package resolve`
  reuses the revisions already recorded in `Package.resolved` and keeps reading the old manifests.
- A version-resolved package can only depend on other version-resolved packages. Tagging a release
  whose manifest still carries `branch:` pins produces a tag that is unconsumable via `from:`
  (this forced the Ink and Contribute recuts).
- `Scripts/ensure-remote-deps.sh` belongs in a package only while it still has `path:` deps; once
  on `url:` + `from:`, remove the script and its workflow steps.
