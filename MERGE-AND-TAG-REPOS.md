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
| ButtondownKit | https://github.com/brightdigit/ButtondownKit | `brightdigit-com-260621` | [#4](https://github.com/brightdigit/ButtondownKit/pull/4) | [#5](https://github.com/brightdigit/ButtondownKit/pull/5) |
| SwiftTube | https://github.com/brightdigit/SwiftTube | `brightdigit-com-260621` | [#18](https://github.com/brightdigit/SwiftTube/pull/18) | [#19](https://github.com/brightdigit/SwiftTube/pull/19) |
| Spinetail | https://github.com/brightdigit/Spinetail | `brightdigit-com-260621` | [#31](https://github.com/brightdigit/Spinetail/pull/31) | [#32](https://github.com/brightdigit/Spinetail/pull/32) |
| Contribute | https://github.com/brightdigit/Contribute | `brightdigit-com-260621` | [#14](https://github.com/brightdigit/Contribute/pull/14) → `v1.0.0` | [#15](https://github.com/brightdigit/Contribute/pull/15) |

Highest-leverage starts: **Plot** and **Contribute**.

> **Wave 0 review-feedback fixes (2026-07-21):** each *Feedback fixes PR* above branches from and
> targets its package's merge-PR branch (`…-feedback-fixes` → `brightdigit-com-260406`/`-260621`),
> applying the reviewer feedback (CI `fail-fast: true`; Ubuntu coverage → `sersoft-gmbh/swift-coverage-action@v5`;
> codecov cleanup; ungate watchOS + add visionOS; `.spi.yml` normalized; devcontainer → standard
> Swift 6.4 image; add `RELEASE_NOTES.md`, `.claude/agent-notes.md`, Memory & Corrections Convention,
> `.claude/skills/`). Plot/Files/Ink additionally preserve John Sundell's MIT attribution (NOTICE +
> README fork note + `header.sh` guard). None merged — pending review.

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

> `MERGE-AND-TAG-PLAN.md` previously said skip re-tagging SwiftTube/Spinetail and use
> existing published tags — confirm before cutting new ones.

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
