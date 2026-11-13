# Content repos: homes, seams and ownership

This is the contract for where BrightDigit content lives and what crosses between repos ([#169](https://github.com/brightdigit/brightdigit.com/issues/169)). The design and its reasoning are in [`.claude/docs/content-ops-plan.md`](../.claude/docs/content-ops-plan.md); this file is the short, enforceable version that the portable `/content-plan` skill ([#139](https://github.com/brightdigit/brightdigit.com/issues/139)) reads in every repo.

## The homes

| Repo | Visibility | Owns |
|---|---|---|
| [`brightdigit/content`](https://github.com/brightdigit/content) | private | Planning and drafts: topic and campaign **records**, per-medium **drafts** (social, newsletter, articles, video, podcast, talks), voice and pillar guides, `/content-topic-mining`, episode release packages. Also consulting, business development and the job search, which never cross a seam. |
| `brightdigit/BrightDigitSite` *(planned, [#168](https://github.com/brightdigit/brightdigit.com/issues/168))* | public | Swift packages and the **`ItemMetadata` / `PublishType` contract** |
| [`brightdigit/brightdigit.com`](https://github.com/brightdigit/brightdigit.com) | public | Finished `Content/*.md` and site config. Consumes the contract as a dependency (today the Swift code still lives here, under `Sources/`). |
| [`brightdigit/Swift-App-Template`](https://github.com/brightdigit/Swift-App-Template) | private | **New tutorials and templates.** They don't go in `brightdigit.com`. |

`brightdigit/content` was split out of `leogdion/year-in-review` on 2026-11-13 with its history. `leogdion/year-in-review` now holds only Leo's yearly review post and goals, and takes no part in the content pipeline.

## Ownership by artifact

| Artifact | Owner | Crosses a seam? |
|---|---|---|
| Topic / campaign record ([#137](https://github.com/brightdigit/brightdigit.com/issues/137)) | `brightdigit/content` | No. Records stay private. |
| Per-medium brief ([#138](https://github.com/brightdigit/brightdigit.com/issues/138)) | `brightdigit/content` | No |
| Draft copy (article, newsletter, social, video, podcast) | `brightdigit/content` | Only when finished, as a `Content/*.md` item |
| Voice and pillar guides (`professional/social-posts/README.md`, `professional/newsletters/README.md`, `professional/planning/content-strategy-2026.md`) | `brightdigit/content` | No |
| `/content-topic-mining` skill | `brightdigit/content` | No |
| `ItemMetadata` / `PublishType` (front-matter contract) | `BrightDigitSite` (today: `brightdigit.com/Sources/`) | Contract seam |
| Companion spec generated from the contract ([#136](https://github.com/brightdigit/brightdigit.com/issues/136)) | Generated from the contract | Contract seam, into both content repos |
| Cross-media link fields on an item ([#135](https://github.com/brightdigit/brightdigit.com/issues/135)) | Field definitions: the contract. Values: the published item. | Content seam, with the item |
| Finished item (`Content/<type>/*.md`) | `brightdigit.com` | Content seam (arrives here) |
| Tutorial or template | `Swift-App-Template` | None. It's published from there. |

## The two seams

1. **Contract seam (package → everywhere).** The spec generator (#136) reads the latest released `ItemMetadata` / `PublishType` and emits the companion spec. The spec goes to `brightdigit.com` (validated at publish time) and to `brightdigit/content` (drafts are written against the current fields). Until #168 lands, "released package" means `brightdigit.com/Sources/`.
2. **Content seam (`brightdigit/content` → `brightdigit.com`).** Only finished items plus their #135 link fields cross into `Content/`. Topic records, briefs, drafts in progress and voice guides never do.

## What `/content-plan` may read and write

| Repo | Reads | Writes |
|---|---|---|
| `brightdigit/content` | Topic records, briefs, drafts, voice guides, the companion spec | Topic records, briefs, drafts |
| `brightdigit.com` | The companion spec, published `Content/*.md` (to link related items) | Finished items in `Content/`, and their link fields only |
| `BrightDigitSite` | — | Nothing. The contract changes only through a normal PR to the package. |
| `Swift-App-Template` | — | Nothing |

The skill runs the same rules in both content repos; only the read/write columns above differ.

## Drafts on the site

`brightdigit.com` has no `draft:` flag. An item is a draft when its `date` is in the future: the production build filters it out with `item.date > now` (`Sources/BrightDigitSite/BrightDigitSite.swift:196`), and it goes live on the first build after that date. To stage something without publishing it, keep it in `brightdigit/content`, or give it a future date here.
