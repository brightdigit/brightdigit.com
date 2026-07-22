# Merge & Tag — Package Repos & PRs

Working checklist for the tag migration. Wave order from
[`PACKAGE-DEPENDENCIES.md`](PACKAGE-DEPENDENCIES.md); process from
[`MERGE-AND-TAG-PLAN.md`](MERGE-AND-TAG-PLAN.md). Pins from `Package.resolved`
on `release/branch-based-devendoring`.

**Root checkpoint PR (stays open until all waves are tagged):**
[brightdigit.com#161](https://github.com/brightdigit/brightdigit.com/pull/161)

Within a wave, packages can proceed in parallel. Do not tag a package until every
in-repo dependency it needs is already tagged.

---

## Wave 0 — leaves

| Package | Repo | Branch | Merge PR | Feedback fixes PR (→ merge-PR branch) |
| --- | --- | --- | --- | --- |
| Plot | https://github.com/brightdigit/Plot | `brightdigit-com-260406` | [#1](https://github.com/brightdigit/Plot/pull/1) | [#2](https://github.com/brightdigit/Plot/pull/2) |
| Files | https://github.com/brightdigit/Files | `brightdigit-com-260406` | [#1](https://github.com/brightdigit/Files/pull/1) | [#2](https://github.com/brightdigit/Files/pull/2) |
| Ink | https://github.com/brightdigit/Ink | `brightdigit-com-260406` | [#1](https://github.com/brightdigit/Ink/pull/1) | [#2](https://github.com/brightdigit/Ink/pull/2) |
| SyndiKit | https://github.com/brightdigit/SyndiKit | `brightdigit-com-260621` | [#129](https://github.com/brightdigit/SyndiKit/pull/129) | [#130](https://github.com/brightdigit/SyndiKit/pull/130) |
| ButtondownKit | https://github.com/brightdigit/ButtondownKit | `v1.0.0` (old `-260621` deleted) | [#4](https://github.com/brightdigit/ButtondownKit/pull/4) | [#5](https://github.com/brightdigit/ButtondownKit/pull/5) |
| SwiftTube | https://github.com/brightdigit/SwiftTube | `v1.0.0` (old `-260621` deleted) | [#18](https://github.com/brightdigit/SwiftTube/pull/18) | [#19](https://github.com/brightdigit/SwiftTube/pull/19) |
| Spinetail | https://github.com/brightdigit/Spinetail | `v1.0.0` (old `-260621` deleted) | [#31](https://github.com/brightdigit/Spinetail/pull/31) | [#32](https://github.com/brightdigit/Spinetail/pull/32) |
| Contribute | https://github.com/brightdigit/Contribute | `v1.0.0` (old `-260621` deleted) | [#14](https://github.com/brightdigit/Contribute/pull/14) → `v1.0.0` | [#15](https://github.com/brightdigit/Contribute/pull/15) |

Highest-leverage starts: **Plot** and **Contribute**.

> **Wave 0 → `v1.0.0` (2026-07-22):** ButtondownKit, SwiftTube, Spinetail, and Contribute have been
> merged to a `v1.0.0` branch and now carry only two branches (`v1.0.0` + `main`); their old
> `brightdigit-com-260621` working branches are **deleted**. SwiftTube/Spinetail completed their
> OpenAPI rebuild, which renamed public types (Spinetail `MailchimpCampaign` → `Campaign`, SwiftTube
> Videos rename). **SyndiKit is intentionally held on `brightdigit-com-260621`** so the Wave-1
> `Contribute*` satellites (which still pin SyndiKit there) keep resolving. Plot/Files/Ink remain on
> `brightdigit-com-260406`. **Note:** the root and every Wave-1 `Contribute*` satellite must pin
> Contribute/Spinetail/ButtondownKit/SwiftTube to `v1.0.0` *together* — a fresh resolve fails if any
> consumer still points at the deleted `-260621` branches.

> **Wave 0 review-feedback fixes (2026-07-21):** each *Feedback fixes PR* above branches from and
> targets its package's merge-PR branch (`…-feedback-fixes` → `brightdigit-com-260406`/`-260621`),
> applying the reviewer feedback (CI `fail-fast: true`; Ubuntu coverage → `sersoft-gmbh/swift-coverage-action@v5`;
> codecov cleanup; ungate watchOS + add visionOS; `.spi.yml` normalized; devcontainer → standard
> Swift 6.4 image; add `RELEASE_NOTES.md`, `.claude/agent-notes.md`, Memory & Corrections Convention,
> `.claude/skills/`). Plot/Files/Ink additionally preserve John Sundell's MIT attribution (NOTICE +
> README fork note + the Sundell-fork `header.sh`, see below). None merged — pending review.

### `header.sh` — two versions

`Scripts/header.sh` is a local-only (never-CI) lint step that strips the leading license comment
from every `*.swift` file and re-prepends a fresh one. There are **two versions of the file**
(both named `header.sh`, both using the same skeleton — `-d -c -o -p -y` args, `find` loop,
`/Generated/` + `swift-format-ignore` skips, idempotent prepend). The **only** difference is the
header text:

| Version | Repos | Emits | Invocation (in `Scripts/lint.sh`) |
| --- | --- | --- | --- |
| **BrightDigit** | every non-fork package (SyndiKit, ButtondownKit, SwiftTube, Spinetail, Contribute, …) | `//` block: filename + package, `Created by Leo Dion / Copyright © <year> BrightDigit`, full inline MIT | `header.sh -d Sources -c "Leo Dion" -o "BrightDigit" -p "<Package>"` |
| **Sundell forks** | Plot, Files, Ink | John Sundell's compact `/**` block (`*  <Package>` / `*  Copyright (c) John Sundell <year>` / `*  MIT license, see LICENSE file for details`) | `header.sh -d Sources -c "John Sundell" -o "John Sundell" -p "<Package>" -y <year>` |

The fork version differs mechanically in one place — its `awk` strips a leading `/* … */` block
(not just `//` lines) so it stays idempotent and converts Files' longer `//` header to the compact
block. Copyright year = the **latest year in each fork's original headers**, passed via `-y`:
**Plot → 2021, Ink → 2020, Files → 2019.** Canonical fork script:
[`reference/sundell-fork/Scripts/header.sh`](reference/sundell-fork/Scripts/header.sh) — copy it to
each fork repo's `Scripts/header.sh` and update that repo's `Scripts/lint.sh` header line.

### Other open PRs (Wave 0)

| Package | PR | Notes |
| --- | --- | --- |
| SyndiKit | [#128](https://github.com/brightdigit/SyndiKit/pull/128) `v1.0.0` → `main` | release PR |
| SyndiKit | [#126](https://github.com/brightdigit/SyndiKit/pull/126) | dependabot |
| ButtondownKit | [#3](https://github.com/brightdigit/ButtondownKit/pull/3) `v1.0.0` → `main` | release PR |
| SwiftTube | [#16](https://github.com/brightdigit/SwiftTube/pull/16) `v1.0.0` → `main` | release PR |
| Spinetail | [#28](https://github.com/brightdigit/Spinetail/pull/28) `v1.0.0` → `main` | release PR |
| Contribute | [#5](https://github.com/brightdigit/Contribute/pull/5) `v1.0.0` → `main` | release PR |
| Contribute | [#13](https://github.com/brightdigit/Contribute/pull/13) | docs → `v1.0.0` |
| Contribute | [#12](https://github.com/brightdigit/Contribute/pull/12) | docs → working branch |

> ~~`MERGE-AND-TAG-PLAN.md` previously said skip re-tagging SwiftTube/Spinetail and use existing
> published tags~~ — superseded: SwiftTube/Spinetail finished their OpenAPI rebuild and are now cut
> to `v1.0.0` (with the public renames above), so they are back in the active Wave 0 set.

---

## Wave 1 — depend only on Wave 0

| Package | Repo | Branch | Merge PR |
| --- | --- | --- | --- |
| Publish | https://github.com/brightdigit/Publish | `brightdigit-com-260406` | [#1](https://github.com/brightdigit/Publish/pull/1) |
| TailwindKit | https://github.com/brightdigit/TailwindKit | `brightdigit-com-260717` | [#1](https://github.com/brightdigit/TailwindKit/pull/1) |
| ContributeButtondown | https://github.com/brightdigit/ContributeButtondown | `brightdigit-com-260717` | [#1](https://github.com/brightdigit/ContributeButtondown/pull/1) |
| ContributeMailchimp | https://github.com/brightdigit/ContributeMailchimp | `brightdigit-com-260717` | [#1](https://github.com/brightdigit/ContributeMailchimp/pull/1) |
| ContributeRSS | https://github.com/brightdigit/ContributeRSS | `brightdigit-com-260717` | [#1](https://github.com/brightdigit/ContributeRSS/pull/1) |
| ContributeWordPress | https://github.com/brightdigit/ContributeWordPress | `brightdigit-com-260406` | [#18](https://github.com/brightdigit/ContributeWordPress/pull/18) |
| ContributeYouTube | https://github.com/brightdigit/ContributeYouTube | `brightdigit-com-260717` | [#1](https://github.com/brightdigit/ContributeYouTube/pull/1) |

### Other open PRs (Wave 1)

| Package | PR | Notes |
| --- | --- | --- |
| ContributeWordPress | [#11](https://github.com/brightdigit/ContributeWordPress/pull/11) | docs |

---

## Wave 2 — Publish plugins / type layer

| Package | Repo | Branch | Merge PR |
| --- | --- | --- | --- |
| PublishType | https://github.com/brightdigit/PublishType | `brightdigit-com-260717` | [#1](https://github.com/brightdigit/PublishType/pull/1) |
| YoutubePublishPlugin | https://github.com/brightdigit/YoutubePublishPlugin | `brightdigit-com-260406` | [#1](https://github.com/brightdigit/YoutubePublishPlugin/pull/1) |
| ReadingTimePublishPlugin | https://github.com/brightdigit/ReadingTimePublishPlugin | `brightdigit-com-260406` | [#1](https://github.com/brightdigit/ReadingTimePublishPlugin/pull/1) |
| TransistorPublishPlugin | https://github.com/brightdigit/TransistorPublishPlugin | `brightdigit-com-260406` | [#6](https://github.com/brightdigit/TransistorPublishPlugin/pull/6) |
| NPMPublishPlugin | https://github.com/brightdigit/NPMPublishPlugin | `brightdigit-com-260406` | [#9](https://github.com/brightdigit/NPMPublishPlugin/pull/9) |

---

## Wave 3 — root cutover

| Package | Repo | Branch / PR |
| --- | --- | --- |
| BrightDigit (root) | https://github.com/brightdigit/brightdigit.com | [`release/branch-based-devendoring`](https://github.com/brightdigit/brightdigit.com/tree/release/branch-based-devendoring) · [#161](https://github.com/brightdigit/brightdigit.com/pull/161) |

After every Wave 0–2 package is tagged, rewrite root `Package.swift` branch pins to
`from:` versions, verify build/test/publish, then merge #161.

---

## Quick clone list (HTTPS)

```text
https://github.com/brightdigit/Plot.git
https://github.com/brightdigit/Files.git
https://github.com/brightdigit/Ink.git
https://github.com/brightdigit/SyndiKit.git
https://github.com/brightdigit/ButtondownKit.git
https://github.com/brightdigit/SwiftTube.git
https://github.com/brightdigit/Spinetail.git
https://github.com/brightdigit/Contribute.git
https://github.com/brightdigit/Publish.git
https://github.com/brightdigit/TailwindKit.git
https://github.com/brightdigit/ContributeButtondown.git
https://github.com/brightdigit/ContributeMailchimp.git
https://github.com/brightdigit/ContributeRSS.git
https://github.com/brightdigit/ContributeWordPress.git
https://github.com/brightdigit/ContributeYouTube.git
https://github.com/brightdigit/PublishType.git
https://github.com/brightdigit/YoutubePublishPlugin.git
https://github.com/brightdigit/ReadingTimePublishPlugin.git
https://github.com/brightdigit/TransistorPublishPlugin.git
https://github.com/brightdigit/NPMPublishPlugin.git
```

PR links captured 2026-07-21; re-check with `gh pr list -R brightdigit/<repo>` if stale.
