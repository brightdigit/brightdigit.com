# Plan: Fix template-era newsletter HTML→Markdown extraction (reconcile)

## Context

`buttondown reconcile` cleans Mailchimp archive HTML → Markdown for each issue and
writes it back to the Buttondown archive. A body-quality gate skips issues whose
cleaned body has < N meaningful words, to avoid overwriting archive bodies with
empty skeletons. The dry run shows **69 of 113 present issues skipped** — a clean
cutoff at issue **#48** (late 2021), when BrightDigit switched to a template-based
(Mailchimp drag-and-drop) newsletter format. Pre-#48 issues clean to 129–581 words;
#48+ clean to 4–50 words (images + empty links only).

Root cause hypothesis: `SwiftSoupMarkdownGenerator` (Import.markdownGenerator) drops
the text content of the newer template HTML structure. Fixing the extractor recovers
the modern archive (the majority of issues), which is the real goal — the gate is
correct and only protects against the bad output.

## Findings

### The content IS present in the source HTML — the extractor drops it
Fetched raw Mailchimp campaign HTML for a "good" issue (#1, campaign 5610c42826)
and a "thin" issue (#113, campaign 52900b7f71) via the `/campaigns/{id}/content`
endpoint (fields: plain_text, html, archive_html).

- #113 raw HTML is 61 KB and contains **all** the real prose (MilkDiary/Kaya
  Thomas/Swift Testing paragraphs — 49 rich 40+char text runs). It is NOT empty.
- Structure differs sharply:
  - **Old #1**: body text is bare text directly inside `<td>` with `<br>`,
    `<strong>`, `&nbsp;`. Flat, simple.
  - **New #48+ (#113)**: body text is wrapped as
    `<p class="whitespace-normal break-words" style="…huge inline style…">
    <span style="color:rgb(0,0,0);">…text…</span></p>`, nested inside `.mceText`
    / `.mcnTextContent` blocks inside table cells (#113 has 88 `<td>`, 58
    `<table>`, 73 `<span>`, 52 `<p>`).
- So the extractor receives full content but loses the `<p><span>`-wrapped,
  heavily-styled text inside the template table structure. The fix is in the
  HTML→Markdown node walk, not the source and not the gate.
- `plain_text` is also available from the same endpoint as a fallback (worth
  evaluating in the plan).

### Root cause in the extractor (confirmed by exploration)
`SwiftSoupMarkdownGenerator` lives in the **Contribute** package:
- `Packages/BrightDigit/Contribute/Sources/Contribute/SwiftSoupMarkdownGenerator.swift`
- `…/SwiftSoupMarkdownGenerator+Markup.swift` (block/inline dispatch)
- `…/SwiftSoupMarkdownGenerator+TableList.swift` (table + dl handling)

It walks `document.body()` recursively dispatching on tag name. No CSS selectors,
no class stripping. The table walk (`+TableList.swift` `rows(of:)` L114-127,
`ownCells(of:)` L101-110) assumes a strict `table → (tr|thead|tbody|tfoot) → (td|th)`
shape and **silently drops** any table whose direct children don't match. Mailchimp
drag-and-drop templates nest wrappers between those levels (role="presentation"
tables, `<div class="mcnTextContent">`, `<center>`, etc.), so real cell text is
discarded. Also `blockMarkup(for:)` (`+Markup.swift` L48-103) has **no case for
bare `tr`/`td`/`th`/`tbody`**, and its `default:` descent only iterates element
children (not text nodes), so a stray cell's text is lost. Old plain-HTML emails
keep body text in top-level `<p>`/`<div>` → handled fine. Existing table tests
(`Contribute/Tests/ContributeTests/SwiftSoupMarkdownGeneratorTests.swift`) are too
shallow to catch this; no Mailchimp fixture exists.

### Mailchimp `plain_text` is clean and complete — a simpler alternative
The `/campaigns/{id}/content` endpoint returns `plain_text` alongside `html`. For
#113 it is 7383 chars of well-formed, readable prose (links inline as `(url)`,
section headers, bullet lists) — Mailchimp's own authored plain-text version, no
template cruft, no zero-width spacers. Sampled meaningful word counts of `plain_text`
across the skipped set: #48=91, #52=182, #66=96, #78=220, #90=287, #100=746,
#110=583, #113=852, #115=842, #116=668, #117=552. **Nearly all clear the 100-word
gate** (only #48/#66 borderline). So a `plain_text` source recovers essentially the
entire skipped set with far less risk than rewriting the HTML table walk.

Tradeoff: `plain_text` loses rich Markdown (bold/headings become plain text; links
render as `text (url)` rather than `[text](url)`). Fixing the HTML walk preserves
formatting but is a more invasive change to a shared package used by all importers.

### `plain_text` cruft to strip (simple, line-based)
Inspecting #48/#66: even the short issues' plain_text is complete (their low word
count is genuine — short issues, not lost content). But plain_text carries its own
boilerplate that a light cleaner must remove:
- Mailchimp merge tags: `*|MC_PREVIEW_TEXT|*`, `*|ARCHIVE|*`, `*|CURRENT_YEAR|*`,
  `*|LIST:COMPANY|*`, `*|IFNOT:...|* … *|END:IF|*`, `*|UPDATE_PROFILE|*`, `*|UNSUB|*`.
- Footer boilerplate: "View this email in your browser", "Copyright (C) …",
  "Our mailing address is:", "Want to change how you receive these emails?",
  update-preferences / unsubscribe lines, bare social URLs, "Logo".
This is straightforward line/regex stripping — much simpler and lower-risk than
rewriting the shared table walk.

### `plain_text` is a free sibling field — no new API call
Spinetail's `archiveHTML(forCampaignID:)` (`Packages/BrightDigit/Spinetail/Sources/
Spinetail/MailchimpClient.swift:164`) calls `GET /campaigns/{id}/content` and returns
`body.archive_html`. The **same decoded response** also carries `body.plain_text`
(`SpinetailOpenAPI/Types.swift:3746/3754`). So adding a `plainText(forCampaignID:)`
method is a trivial Spinetail addition — same request, read the other field.

### publish_date requires a one-property spec edit + regen (documented workflow)
- `update_email` is already in the generator `filter:` — filter is NOT the problem.
- swift-openapi-generator 1.12.2 silently drops `publish_date` because its
  `anyOf[{date-time},{const:"none"},{null}]` shape is unsupported (it drops the
  single property, not the whole run). Plain date-time (e.g. `Email.creation_date`)
  generates fine as `Foundation.Date?`.
- Fix: in the vendored `openapi.json`, reshape `EmailUpdateInput.publish_date` to a
  plain nullable date-time `{"type":"string","format":"date-time"}`, then run
  `./Scripts/generate-openapi-buttondown.sh`. That is a **spec edit + regenerate**
  (the documented model), not a hand-edit of generated code. Lose only the `"none"`
  sentinel (irrelevant — reconcile only ever sets a real date from `sendTime`).
- Tooling: `mise` is installed (2026.3.10); the generator is `spm:` pinned 1.12.2 —
  a cold build needs network + a SwiftPM compile; warm cache runs offline. No API
  key needed (input is the committed spec).
- Then hand-edit `ButtondownClient.updateEmail(...)` to accept/pass `publishDate`
  and reconcile to pass `campaign.sendTime`.

## Approach (recommended, approved)

Two independent tracks, both feeding the same `--execute`: recover the 69 skipped
bodies (select authored HTML fragments + plain_text fallback), and sync metadata
(publish_date + description + image). Body + metadata are updated together and
gated together (an issue must clear the word gate to be touched at all).

### Track 1 — Recover body content

> **Implementation revision:** after reviewing the real #113 markup, recovery
> targets Mailchimp's authored content blocks rather than traversing the layout
> tables. Modern `.mceText` children and non-logo `.mceImageBlockContainer`
> images are converted in document order; legacy campaigns keep the existing
> whole-document conversion path.

**1a. Select authored fragments with `SwiftSoupMarkdownGenerator`**
- Add selector-based fragment conversion to the shared generator without changing
  its existing whole-document or table behavior.
- For modern Mailchimp HTML, select direct `.mceText` children plus non-logo images
  beneath `.mceImageBlockContainer`; omit presentation tables, preview text,
  spacers, social chrome, and logos.
- If the modern selector matches nothing, use the existing whole-document path so
  already-working legacy campaigns remain unchanged.
- Add a reduced #113-style fixture proving prose, links, headings, and content
  images retain document order while template chrome is excluded.

**1b. plain_text fallback** for anything still thin after 1a
- Add `plainText(forCampaignID:)` to Spinetail `MailchimpClient`
  (`Packages/BrightDigit/Spinetail/Sources/Spinetail/MailchimpClient.swift`) — same
  `GET /campaigns/{id}/content` call as `archiveHTML`, returning `body.plain_text`
  (already decoded, sibling of `archive_html`). No generator work.
- Add a light plain_text cleaner (in reconcile, or a small Contribute helper):
  strip Mailchimp merge tags (`*|…|*`, incl. `*|IFNOT:…|* … *|END:IF|*`), footer
  boilerplate ("View this email in your browser", "Copyright (C) …", "Our mailing
  address is:", update-preferences/unsubscribe lines), stray "Logo", and collapse
  bare social-URL runs. Unit-test the cleaner.
- In `resolveUpdates` (Buttondown.ReconcileCommand.swift), when the HTML-cleaned body
  is under `--min-body-words`, fetch + clean plain_text and use it if it clears the
  gate. Only if BOTH are thin does the issue stay skipped. Record which source won
  (html vs plain_text) for the dry-run report.

### Track 2 — Metadata sync (publish_date + description + image)

**2a. Regenerate ButtondownKit for `publish_date`**
- Edit vendored spec `Packages/BrightDigit/ButtondownKit/Sources/ButtondownKit/OpenAPI/openapi.json`:
  reshape `EmailUpdateInput.publish_date` from its `anyOf[{date-time},{const:"none"},
  {null}]` to plain nullable date-time `{"type":"string","format":"date-time"}`
  (generates as `Foundation.Date?`, like `Email.creation_date`). Spec edit, not a
  generated-code hand-edit.
- Run `./Scripts/generate-openapi-buttondown.sh` (via mise; cold run needs network +
  SwiftPM build of the pinned generator 1.12.2). `git diff` the generated output to
  confirm only `publish_date` was added.

**2b. Extend `updateEmail`** (`ButtondownKit/Sources/ButtondownKit/EmailUpdating.swift`)
- Add `image`, `publishDate: Date?` params (description already supported), pass into
  `EmailUpdateInput`. Default `nil` = unchanged. Add contract-test assertions
  (EmailUpdatingTests) that these serialize.

**2c. Carry metadata through the plan** (reconcile)
- `NumberedCampaign` / `PlanItem` already carry the campaign; extend to keep
  `previewText`, `socialCardImageURL`, `sendTime` (sendTime already present).
  Populate from the campaign in `numberedCampaigns`.
- In `runExecute`, for each gated-in issue call
  `updateEmail(id:, body: chosenBody, description: previewText, image: socialCardImageURL,
  publishDate: sendTime)`. Empty previewText/image → pass `nil` (never overwrite with
  blank). Dry run prints the metadata each writable issue would set.

## Critical files
- `Packages/BrightDigit/Contribute/Sources/Contribute/SwiftSoupMarkdownGenerator.swift` (+ tests)
- `Packages/BrightDigit/Spinetail/Sources/Spinetail/MailchimpClient.swift` (plainText method)
- `Packages/BrightDigit/ButtondownKit/Sources/ButtondownKit/OpenAPI/openapi.json` (spec edit) + regenerated `Generated/{Types,Client}.swift`
- `Packages/BrightDigit/ButtondownKit/Sources/ButtondownKit/EmailUpdating.swift` (+ EmailUpdatingTests)
- `Sources/BrightDigitArgs/Config/Buttondown.ReconcileCommand.swift`, `…+Plan.swift` (fallback + metadata wiring) + `Tests/BrightDigitArgsTests/ButtondownReconcilePlanTests.swift`

Already committed on this branch (`buttondown-reconcile-updates-only`, commit
74c68770): updates-only, re-send dedup, imported-only guard, slug matching, word-gate.
This plan builds on top; new work lands as follow-up commits on the same branch.

## Verification
1. `swift test` in `Packages/BrightDigit/Contribute` — the selected-content fixture
   extracts prose and content images without layout chrome; existing
   table/plain-HTML tests still pass.
2. `swift test` in `Packages/BrightDigit/ButtondownKit` — updateEmail serializes
   image/publish_date; regen `git diff` shows only publish_date added.
3. `swift test --filter ButtondownReconcilePlanTests` (main pkg) — plain_text
   cleaner + fallback classification + metadata-carrying plan items.
4. Live preview (`swift run brightdigitwg buttondown reconcile
   --preview-directory <path>`, env keys) — inspect the generated Markdown index and confirm
   the skip count collapses from 69 toward ~0-2, each recovered issue shows its body
   source (html/plain_text) and word count, and the metadata (date/desc/image) each
   issue would set. Spot-check a few recovered bodies (#100, #113, #117) for quality.
5. Only after the preview looks right: `--execute` (user-initiated) to write the
   ~113 imported archive emails (body + metadata), with #114 still skipped as absent.
