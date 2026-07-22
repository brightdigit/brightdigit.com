# README Badge Audit — BrightDigit v1.0.0 Dependencies

_Audit date: 2026-07-22. Verified against the remote `v1.0.0` branch of each repo
(SyndiKit against `main`), with every badge URL tested live._

## Scope

Of all BrightDigit dependencies in `Package.swift`, only **five have a `v1.0.0`
branch** cut so far. These are "the new v1.0.0" and the subject of this report:
**ButtondownKit, Contribute, Spinetail, SwiftTube, SyndiKit**.

The remaining deps (ContributeWordPress, NPMPublishPlugin, TransistorPublishPlugin,
YoutubePublishPlugin, TailwindKit, PublishType, ReadingTimePublishPlugin, the other
Contribute\* modules, ConfigKeyKit) have **no `v1.0.0` branch** yet — out of scope,
but flagged at the end since they carry dead badges to clean up on migration.

> ⚠️ The **local vendored subrepo copies are stale**. `Contribute`'s local copy is
> a 2-line stub while its remote `v1.0.0` README has a full header. Any change must
> land on the source repos, not just the vendored copies.

## Per-repo badge inventory & working condition

| Repo (`v1.0.0`) | Header style | Badges | Status |
|---|---|---|---|
| **ButtondownKit** | `#H1`, no logo | **none** | inconsistent — no badges at all |
| **SwiftTube** | centered logo + markdown `#H1` | **none** | inconsistent — logo but no badges |
| **Contribute** | centered logo + `<h1>` + tagline | 3 **static** | render OK, but content stale-prone |
| **Spinetail** | centered logo + `<h1>` | 9 mixed | **2 defects** (below) |
| **SyndiKit** | bare left `<img>` + `#H1` | 9 dynamic | all render, 2 nits |

### Confirmed defects (tested)

1. **Spinetail — `codeql.yml` CI badge → HTTP 404 (broken).** No such workflow
   exists in the repo (only `Spinetail.yml`).
2. **Spinetail — `codecov` badge renders "unknown".** No coverage is uploaded; the
   badge is misleading.
3. **Spinetail — Twitter badge `http://twitter.com/brightdigit`.** Dead service
   (Twitter→X) over `http://`.
4. **SyndiKit — CI badge points at `syndikit.yml` (lowercase)** while the file is
   `SyndiKit.yml`. Currently renders "passing" but is case-fragile (exact-case URL
   returns "no status"); query also has a malformed `&?branch=main` (stray `?`).
5. **Contribute — static `Swift-5.8+` badge** (tools-version is now 6.4) and a
   **platforms badge that omits Linux** (which the package supports). Static badges
   never self-correct.

### Working correctly

All SPI swift-versions/platforms badges, GitHub license, qlty.sh maintainability,
Codecov (where data exists — SyndiKit 83%), CodeFactor (A), SyndiKit's static docc +
Source-Compatibility badges.

## Consistency assessment

Effectively **four different house styles across five repos**: logo markup (centered
`<p>` vs bare `<img>` vs none), H1 (HTML vs markdown), and badge philosophy (none /
static trio / grouped-dynamic) all differ. There is no shared header. **SyndiKit's
grouped-dynamic set is the most mature** (comment-grouped, modern qlty.sh, docc),
making it the best badge basis.

## Reference headers (candidate "optimal" set)

All three render cleanly. Each is strongest at a different thing:

| Aspect | MistKit | SundialKit | SyndiKit |
|---|---|---|---|
| Header layout | left logo + left `#H1` | ✅ **centered logo + `<h1>` + one-line description** | bare left `<img>` |
| Badge grouping | flat block | flat, blank-line split | ✅ **grouped w/ HTML comments** |
| CI badge | ✅ **correct-case `MistKit.yml`** (`passing`) | github-native `.yml/badge.svg` | ⚠️ lowercase + `&?branch` typo |
| Quality | qlty ✅ + CodeFactor ✅ | CodeFactor only | qlty ✅ + CodeFactor ✅ |
| Docs | docc ✅ | ❌ none | docc ✅ + Source-Compat |
| Dead/noisy badges | none ✅ | ⚠️ Twitter (dead) + GitHub-issues | none ✅ |

Live results: MistKit CI `passing` / codecov 75% / CodeFactor A / qlty renders;
SundialKit codecov 65% / CodeFactor A / SPI works; SyndiKit qlty renders. Both qlty
URL forms work (MistKit's per-repo UUID path and SyndiKit's `gh/projects` path).

## Recommended unified template

**SundialKit's centered header shell** + **SyndiKit's grouped badge rows** +
**MistKit's correct-case shields CI badge**, dropping dead/noisy badges:

```markdown
<p align="center">
    <img alt="<Name>" title="<Name>" src="<logo path>" height="200">
</p>
<h1 align="center"><Name></h1>

<p align="center">One-line description of the package.</p>

<!-- Platform Compatibility -->
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2F<Repo>%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/<Repo>)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2F<Repo>%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/<Repo>)

<!-- Documentation & License -->
[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/<Repo>/documentation)
[![License](https://img.shields.io/github/license/brightdigit/<Repo>)](LICENSE)

<!-- CI/CD & Code Quality -->
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/<Repo>/<Repo>.yml?label=actions&logo=github&branch=main)](https://github.com/brightdigit/<Repo>/actions)
[![Maintainability](https://qlty.sh/gh/brightdigit/projects/<Repo>/maintainability.svg)](https://qlty.sh/gh/brightdigit/projects/<Repo>)
[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/<Repo>)](https://codecov.io/gh/brightdigit/<Repo>)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/<Repo>)](https://www.codefactor.io/repository/github/brightdigit/<Repo>)
```

### Rules baked in

- **SPI dynamic badges** for Swift versions + platforms (never go stale; replaces the
  static `SwiftPM` / `Swift-5.8+` badges).
- **One shields.io CI badge**, **exact-case `<Repo>.yml`**, clean `&branch=main`
  (fixes both SyndiKit's and MistKit's stray-`?` typo). Chosen over SundialKit's
  github-native style for a uniform look.
- **qlty** via the `qlty.sh/gh/brightdigit/projects/<Repo>` path (no per-repo UUID
  lookup).
- **Drop Twitter** (dead, `http://`) and **GitHub-issues** (noisy).
- **Codecov only where coverage is actually uploaded** (else it renders "unknown"
  like Spinetail).

## Fix list for the five v1.0.0 repos

| Repo | Needed changes |
|---|---|
| **SyndiKit** | fix CI badge to exact-case `SyndiKit.yml`; remove `&?branch` stray `?`. Otherwise the reference standard. |
| **Spinetail** | remove `codeql.yml` badge (404); remove Twitter badge; drop Codecov unless wired up; regroup to template. |
| **Contribute** | replace static `Swift-5.8+` and platforms badges with SPI dynamic badges. |
| **ButtondownKit** | add badge block (has none); confirm a logo asset exists before adding a centered header. |
| **SwiftTube** | add badge block (has logo, no badges). |

## Note on the not-yet-v1.0.0 repos

When ContributeWordPress, NPMPublishPlugin, TransistorPublishPlugin, and
YoutubePublishPlugin get their v1.0.0, they should adopt this template and **shed
their dead badges**: Code Climate (service sunset), codebeat, "Reviewed by Hound"
(discontinued), and Twitter — all present in their current legacy badge walls.
YoutubePublishPlugin additionally has no badges and an outdated install URL pointing
at a `tanabe1478` fork.
