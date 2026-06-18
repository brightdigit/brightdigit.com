# Phase 4 — Ink → swift-markdown content-rendering triage

> Analysis only. No source/parser code was changed by this document. Relates to #40 (parser migration) and #93 (content bold typos).

## How this was produced

A golden-diff harness was rebuilt **natively on the macOS arm64 host** (no Docker/QEMU):

- **Old-Ink baseline**: the hand-written `Reader` parser, built from commit `da3e8da~1` (`b0115b7`, the commit immediately before the swap in #40 / PR #85) via `swift build --product ink-cli`.
- **New-Ink**: the swift-markdown-backed parser on this branch (`p4-ink-finalize-40`, `615ea6d`), same `ink-cli` target.
- Every one of the **436** `Content/**/*.md` files was rendered through both CLIs (`ink-cli <file>`; both parsers strip the YAML front matter as metadata natively) and the HTML compared byte-for-byte.

**Result: 265 of 436 files render differently** — identical to the count in the #40 spike report. swift-markdown is CommonMark/GFM-correct (via cmark-gfm); old-Ink was not, so virtually every diff is the new parser being *more* spec-correct.

## Summary table

Each file is assigned one **primary** category (priority order top-to-bottom), so the primary counts sum to the 265 distinct differing files. Many files exhibit more than one effect; the **tagged** column counts every file in which the effect appears (overlapping).

| Category | Primary (distinct) | Tagged (overlapping) |
|---|---:|---:|
| Stray-`**text. **` bold typos (issue #93) | 22 | 22 |
| Raw-HTML-block detection (`<span>` / `<font>`) | 115 | 118 |
| Lone-image paragraph-wrap | 15 | 50 |
| Emphasis / inline-HTML CommonMark (`<strong>`/`<em>`, `<br>`) | 11 | 39 |
| Non-breaking-space (`&nbsp;`) emission | 19 | 39 |
| Whitespace (inter-block newline insertion) | 68 | 76 |
| List-structure CommonMark (loose/tight, merged `<ol>` blocks) | 2 | 25 |
| Other CommonMark (nested lists, ref-link/code-span paragraphs, blockquote `>` escaping) | 13 | 13 |
| **Total distinct differing files** | **265** | — |

> **GFM tables (delimiter-row requirement): 0 files.** The earlier ~112 estimate conflated the newsletters' raw `<table data-…>` HTML blocks (which are raw-HTML, counted under raw-HTML detection) with Markdown pipe tables. Only **one** file (`tutorials/rebuilding-mistkit-claude-code-part-1.md`) contains a real Markdown pipe table, and it has a valid delimiter row, so old and new render it **identically**. No file shows any `<th>`/`<thead>` rendering difference. There is no GFM-table regression.

> **Reconciliation vs. the earlier estimate:** the earlier numbers were rough. The accurate figures are: raw-HTML ~115 (was ~122), #93 bold typos exactly **22** (was ~3–21, issue says ~22), lone-image **15 primary / 50 tagged** (was ~50 — most lone-image files are also raw-HTML/newsletter and get a higher-priority primary), whitespace+nbsp **87 combined** (was ~76), other-CommonMark buckets (emphasis/list/other) **26 primary** (was ~43). GFM tables collapses to 0 as explained above.

## Per-category detail (representative before → after)

`OLD` = old-Ink (hand-written parser) · `NEW` = new swift-markdown parser. `\n` shown literally. Fragments trimmed to the differing region.

### Raw-HTML-block detection (`<span>` / `<font>`) — 115 files (primary)

**`articles/vapor-swift-backend-review.md`**
```
OLD: … the function with Fluent’s API:</p><p>let columnId = PostgreSQLColumnIdenti…
NEW: … the function with Fluent’s API:</p><pre><code>let columnId = PostgreSQLColumnIdenti…
```
**`newsletters/001-brightdigit-newsletter-january-2019.md`**
```
OLD: …<span class="mcnPreviewText"\nstyle="di…
NEW: …<p><span class="mcnPreviewText"\nstyle="di…
```
**`newsletters/002-brightdigit-newsletter-february-2019-batch-1.md`**
```
OLD: …<span class="mcnPreviewText"\nstyle="di…
NEW: …<p><span class="mcnPreviewText"\nstyle="di…
```
**`newsletters/003-brightdigit-newsletter-march-2019.md`**
```
OLD: …<span class="mcnPreviewText"\nstyle="di…
NEW: …<p><span class="mcnPreviewText"\nstyle="di…
```
**Accept as correctness improvement.** These are the Mailchimp-derived newsletters (and a few articles) that open a block with a raw inline element (`<span class="mcnPreviewText">`, `<font>`, a bare `<img>`/`<a>`). CommonMark only treats a leading tag as a raw HTML *block* when it is a recognised block-level tag; an inline tag like `<span>` starts a paragraph, so swift-markdown wraps it in `<p>…</p>`. This is spec-correct and harmless (it produces *more* well-formed HTML). Worth a quick visual spot-check of one rendered newsletter, but no action expected.

### Lone-image paragraph-wrap — 15 files (primary)

**`articles/best-backend-for-your-ios-app.md`**
```
OLD: …nd restore the data to their phones.</p><img src="/media/wp-images/brightdig…
NEW: …nd restore the data to their phones.</p><p><img src="/media/wp-images/brightdig…
```
**`articles/bushel-launch-part-2.md`**
```
OLD: …apshot-api">New Snapshot API</a></li><li><strong><a href="#observation">Obse…
NEW: …apshot-api">New Snapshot API</a></li></ul></li><li><strong><a href="#observation">Obse…
```
**`articles/bushel-launch-part-3.md`**
```
OLD: …ing the Crust</a></li><li><em>Part 3 - Design, Architecture, and Automation<…
NEW: …ing the Crust</a></li><li><em>Part 3 -  Design, Architecture, and Automation<…
```
**`articles/in-app-purchases.md`**
```
OLD: …urchase may be best for your app.</p><img src="/media/articles/in-app-purcha…
NEW: …urchase may be best for your app.</p><p><img src="/media/articles/in-app-purcha…
```
**Accept as correctness improvement.** A standalone image on its own line is a paragraph in CommonMark, so `<img>` is now wrapped in `<p><img …></p>`. This is the spec-correct behaviour and matches every other CommonMark renderer. No action.

### Emphasis / inline-HTML CommonMark (`<strong>`/`<em>`, `<br>`) — 11 files (primary)

**`articles/app-store-review-guidelines.md`**
```
OLD: …s official line is:</p><blockquote><p>*Don’t use protected third-party materi…
NEW: …s official line is:</p><blockquote><p><em>Don’t use protected third-party materi…
```
**`articles/do-i-need-a-website.md`**
```
OLD: …gncenter" width="1280" height="854" /><p>It is incredibly difficult for a busin…
NEW: …gncenter" width="1280" height="854" />\nIt is incredibly difficult for a busin…
```
**`articles/machine-learning-business-applications-with-kevin-scott.md`**
```
OLD: …made me decide I had to get involved.<br><br>I come from a design background, and …
NEW: …made me decide I had to get involved.</p><p>I come from a design background, and …
```
**`articles/upgrading-old-ios-apps.md`**
```
OLD: … looked forward to, and often avoided.</p><p>It is true that app upgrades ar…
NEW: … looked forward to, and often avoided. </p><p>It is true that app upgrades ar…
```
**Mostly accept; brief owner eyeball.** `<strong>`/`<em>` counts shift because swift-markdown applies CommonMark emphasis-flanking and nesting rules (and normalises stray `<br> <br>` → `<br><br>`, literal `*…*` in blockquotes → `<em>`). Most are improvements identical in spirit to #93 but where the bold/italic was *recovered* correctly. A few (where emphasis count drops) overlap with #93. Eyeball the handful that are not already in the #93 list.

### Non-breaking-space (`&nbsp;`) emission — 19 files (primary)

**`articles/4-things-apple-ios-2020.md`**
```
OLD: …p><p><strong>Imperative</strong></p><p>webpage.drawTitle(“Title”) webpage.dr…
NEW: …p><p><strong>Imperative</strong></p><pre><code>webpage.drawTitle(“Title”)\nwebpage.dr…
```
**`articles/apple-september-event-2018.md`**
```
OLD: …of a <strong>new Apple Watch</strong>.</p><h2>6.1 inch iPhone 9</h2><p>Rumor…
NEW: …of a <strong>new Apple Watch</strong>. </p><h2>6.1 inch iPhone 9</h2><p>Rumor…
```
**`articles/apple-watch-series-6.md`**
```
OLD: …’s latest operating system, WatchOS 7.</p><p>This is a big deal for Apple ap…
NEW: …’s latest operating system, WatchOS 7. </p><p>This is a big deal for Apple ap…
```
**`articles/avoid-ios-app-failure-with-tdd.md`**
```
OLD: …r better software for their customers.</p><p>We’ll be explaining what TDD is…
NEW: …r better software for their customers. </p><p>We’ll be explaining what TDD is…
```
**Accept as correctness improvement.** swift-markdown preserves a literal non-breaking space (`&nbsp;` / U+00A0) that the author put in the source where old-Ink dropped or collapsed it. The output is closer to the source intent. No action.

### Whitespace (inter-block newline insertion) — 68 files (primary)

**`articles/dependency-management-swift.md`**
```
OLD: … needed to mock access to a network – then it’s easier and simpler to pass t…
NEW: … needed to mock access to a network –  then it’s easier and simpler to pass t…
```
**`articles/macos-development-ios-developers.md`**
```
OLD: …0" alt="cross apple communication" /> Companion App</h3><p>By building a mac…
NEW: …0" alt="cross apple communication" />  Companion App</h3><p>By building a mac…
```
**`episodes/141-swift-package-index-with-dave-verwer-and-sven-schmidt.md`**
```
OLD: …ecommons.org/licenses/by/4.0/)</a></p><strong>\n  <a href="https://www.patreo…
NEW: …ecommons.org/licenses/by/4.0/)</a></p>\n<strong>\n  <a href="https://www.patreo…
```
**`episodes/142-mobile-system-design-with-tjeerd-in-t-veen.md`**
```
OLD: …g/licenses/by/4.0/)</a></p><p><br></p><strong>\n  <a href="https://www.patreo…
NEW: …g/licenses/by/4.0/)</a></p><p><br></p>\n<strong>\n  <a href="https://www.patreo…
```
**Accept as correctness improvement (cosmetic).** The only difference is a single `\n` newline inserted between adjacent block elements (e.g. `</p><ul>` → `</p>\n<ul>`). This is invisible in the rendered page and is just swift-markdown's pretty-printing. No action.

### List-structure CommonMark (loose/tight, merged `<ol>` blocks) — 2 files (primary)

**`tutorials/asset-catalogs-image-sets-app-icons.md`**
```
OLD: …contain several pieces of information.</p><img src="/media/wp-images/learningswi…
NEW: …contain several pieces of information. <img src="/media/wp-images/learningswi…
```
**`tutorials/swift-build.md`**
```
OLD: …code> in your project directory.</li></ol><ol start="2"><li><strong>Platform issues</strong>: U…
NEW: …code> in your project directory.</li><li><strong>Platform issues</strong>: U…
```
**Accept as correctness improvement.** Old-Ink emitted multiple sibling `<ol start="n">` blocks for what is one continuous list, and split tight lists oddly; swift-markdown merges them into one correctly-numbered list. Spec-correct; no action.

### Other CommonMark (nested lists, ref-link/code-span paragraphs, blockquote `>` escaping) — 13 files (primary)

**`articles/bushel-launch-part-4.md`**
```
OLD: …a bug that users may or may not notice as opposed to letting people out ther…
NEW: …a bug that users may or may not notice  as opposed to letting people out ther…
```
**`articles/learn-how-to-build-an-app-on-june-1st.md`**
```
OLD: …ft development as well as its journey. In this session, Leo will cover the ba…
NEW: …ft development as well as its journey.<br>In this session, Leo will cover the ba…
```
**`articles/podcasting-getting-started-whys-and-hows.md`**
```
OLD: …odcast</strong> let’s discuss the why. <a href="https://leogdion.name/2019/06…
NEW: …odcast</strong> let’s discuss the why.</p><p><a href="https://leogdion.name/2019/06…
```
**`articles/swiftdata-considerations.md`**
```
OLD: …f guidance when it comes to testing</a></li><li>Missing unclear definitions …
NEW: …f guidance when it comes to testing</a></li></ul></li><li>Missing unclear definitions …
```
**Needs a quick owner eyeball.** A grab-bag of genuine CommonMark fixes: correct nested-`<ul>`/`<li>` structure, code-span lines no longer split into spurious `<p>` paragraphs, `<br>`/blank-line paragraph handling, and a blockquote where old-Ink HTML-escaped a literal `>` (`Getting &gt; Started` → `Getting Started`). All look like improvements, but worth eyeballing the 13 listed files once since the structural change is larger than the other buckets.

## Issue #93 — exact stray-`**text. **` bold subset (22 files)

**Candidate to fix in content (issue #93).** These are genuine authoring typos: a stray space (or `&nbsp;`) immediately before a closing `**`. CommonMark's right-flanking rule refuses to close the emphasis, so the literal `**` now renders on the page. Old-Ink silently bolded them anyway. Fix by deleting the stray space so the closing `**` hugs the text (`done. **` → `done.**`). Pure content edit; do before the phase-04 line reaches production.

For each file, the fragment(s) below are the **literal `**` text that now leaks into the rendered HTML** (this is exactly what a reader sees on the page). Fix = remove the space before the closing `**`.

- **`articles/2020-apple-watch.md`**
  - `**this article is for you. **`
  - source line(s): L24, L133
- **`articles/4-mistakes-design-ios-app-ui.md`**
  - `**creating UIs that look great on other platforms, but end up looking messy and buggy when ported to iOS. **`
  - source line(s): L15
- **`articles/5-things-macos-mojave-developers.md`**
  - `**Mojave will be the final OS to support 32-bit. **`
  - `**camera, microphone, or any automation** (i.e. AppleScript and Apple Events). This means if your app uses any of those functionalities, **`
- **`articles/building-icons-xcode-introducing-speculid.md`**
  - `**creates the appropiate png or pdf files for your Image Set or App Icon Set.** based what is setup in the Asset Library **`
  - `**. For more details take a look at the **`
  - `** and join us on **`
- **`articles/bushel-launch-part-1.md`**
  - `**`
  - `**Libraries and more so Machines, there are components which are very large but more so I only had control over through th`
  - `**took a back seat. However`
- **`articles/how-to-become-iOS-developer.md`**
  - `**know **`
- **`articles/humane-code.md`**
  - `**While comments may not be needed, they can be really helpful for adding context to your code when they’re done thoughtfully and without creating too much ‘noise.’ **`
- **`articles/ios-software-architecture.md`**
  - `** If you do it well, you save lots of time and money over the lifecycle of your app.`
  - `**`
- **`articles/ios-team-management.md`**
  - `**Namely, they need to share their thoughts while actively asking the team to shoot them down. **`
  - source line(s): L172
- **`articles/mac-developers-learn-swift-2019.md`**
  - `***With the **`
  - `***recent spate of keyboard issues **`
- **`articles/scale-ios-app.md`**
  - `**Asking your teams for multiple ideas when dealing with big issues and giving them the time and resources to do so can pay huge dividends. **`
- **`articles/scriptingbridge-with-swift-communicating-with-apps-using-applescript-and-swift.md`**
  - `**AppleScript** is a great technology on macOS for both developers and power users. It allows users to create automated processes which work other apps. As a developer though, sometimes you want a **`
- **`articles/swiftui-everything-is-possible-if-you-think-like-apple.md`**
  - `**Declarative programming expresses what the result the software must achieve, but doesn’t describe how this must be done. **`
  - source line(s): L68
- **`articles/want-to-hire-ios-developer.md`**
  - `** It should not be a failure or weakness if a developer needs to Google or use Stack Overflow to figure things how. **`
- **`articles/working-remotely-ios-development.md`**
  - `**have them be a part in creating it. **`
  - source line(s): L89
- **`newsletters/057-brightdigit-newsletter-issue-57-22-05-18.md`**
  - `**`
  - `**Have any questions for us about getting started? Let me know!`
  - source line(s): L98
- **`tutorials/independent-watch-app-healthkit-permissions.md`**
  - `**, that is the messages display to the user when access permission is asked for health information.`
  - `**`
- **`tutorials/integrating-c-plus-plus-swift.md`**
  - `**Link With Libraries - **`
  - source line(s): L85, L86, L88
- **`tutorials/mac-developers-learn-swift-2019.md`**
  - `***With the **`
  - `***recent spate of keyboard issues **`
- **`tutorials/scriptingbridge-applescript-swift.md`**
  - `**AppleScript **`
  - `**AppleScript, **`
  - `**Write a separate AppleScript file **`
- **`tutorials/swift-6-async-await-actors-fixes.md`**
  - `**`
  - source line(s): L275
- **`tutorials/understanding-optionals-in-swift.md`**
  - `**how can you signify null while still containing that information and not using pointers. **`
  - source line(s): L40

## Complete list of distinct differing files, grouped by primary category

(265 files. `(also: …)` lists the other effects each file exhibits.)

### Stray-`**text. **` bold typos (issue #93) — 22 files

- `articles/2020-apple-watch.md`  (also: emphasis_cm)
- `articles/4-mistakes-design-ios-app-ui.md`  (also: emphasis_cm, nbsp)
- `articles/5-things-macos-mojave-developers.md`  (also: emphasis_cm, nbsp, rawhtml)
- `articles/building-icons-xcode-introducing-speculid.md`  (also: emphasis_cm)
- `articles/bushel-launch-part-1.md`  (also: emphasis_cm, loneimg)
- `articles/how-to-become-iOS-developer.md`  (also: emphasis_cm)
- `articles/humane-code.md`  (also: emphasis_cm, loneimg)
- `articles/ios-software-architecture.md`  (also: emphasis_cm)
- `articles/ios-team-management.md`  (also: emphasis_cm)
- `articles/mac-developers-learn-swift-2019.md`  (also: emphasis_cm)
- `articles/scale-ios-app.md`  (also: emphasis_cm, loneimg)
- `articles/scriptingbridge-with-swift-communicating-with-apps-using-applescript-and-swift.md`  (also: emphasis_cm)
- `articles/swiftui-everything-is-possible-if-you-think-like-apple.md`  (also: emphasis_cm, nbsp)
- `articles/want-to-hire-ios-developer.md`  (also: emphasis_cm, loneimg)
- `articles/working-remotely-ios-development.md`  (also: emphasis_cm, nbsp)
- `newsletters/057-brightdigit-newsletter-issue-57-22-05-18.md`  (also: emphasis_cm, loneimg, rawhtml)
- `tutorials/independent-watch-app-healthkit-permissions.md`  (also: emphasis_cm)
- `tutorials/integrating-c-plus-plus-swift.md`  (also: emphasis_cm, rawhtml)
- `tutorials/mac-developers-learn-swift-2019.md`  (also: emphasis_cm)
- `tutorials/scriptingbridge-applescript-swift.md`  (also: emphasis_cm)
- `tutorials/swift-6-async-await-actors-fixes.md`  (also: emphasis_cm, loneimg)
- `tutorials/understanding-optionals-in-swift.md`  (also: emphasis_cm, nbsp)

### Raw-HTML-block detection (<span>/<font>) — 115 files

- `articles/vapor-swift-backend-review.md`  (also: emphasis_cm)
- `newsletters/001-brightdigit-newsletter-january-2019.md`
- `newsletters/002-brightdigit-newsletter-february-2019-batch-1.md`
- `newsletters/003-brightdigit-newsletter-march-2019.md`
- `newsletters/004-brightdigit-newsletter-april-2019.md`
- `newsletters/005-brightdigit-newsletter-may-2019.md`
- `newsletters/006-brightdigit-newsletter-july-2019.md`
- `newsletters/007-brightdigit-newsletter-june-2019.md`
- `newsletters/008-brightdigit-newsletter-august-2019.md`
- `newsletters/009-brightdigit-newsletter-september-2019.md`
- `newsletters/010-brightdigit-newsletter-october-2019.md`
- `newsletters/011-brightdigit-newsletter-november-2019.md`
- `newsletters/012-brightdigit-newsletter-december-2019.md`
- `newsletters/013-brightdigit-newsletter-january-2020.md`
- `newsletters/014-brightdigit-newsletter-issue-14-20-13-02.md`
- `newsletters/015-brightdigit-newsletter-issue-15-20-02-05.md`
- `newsletters/016-brightdigit-newsletter-issue-16-20-02-17.md`
- `newsletters/017-brightdigit-newsletter-issue-17-20-03-03.md`
- `newsletters/018-brightdigit-newsletter-issue-18-20-03-13.md`
- `newsletters/019-brightdigit-newsletter-issue-19-20-04-01.md`
- `newsletters/020-brightdigit-newsletter-issue-20-20-04-13.md`
- `newsletters/021-brightdigit-newsletter-issue-21-20-05-01.md`
- `newsletters/022-brightdigit-newsletter-issue-22-20-05-21.md`
- `newsletters/024-brightdigit-newsletter-issue-24-20-06-16.md`
- `newsletters/025-brightdigit-newsletter-issue-25-20-06-23.md`
- `newsletters/026-brightdigit-newsletter-issue-26-20-07-16.md`
- `newsletters/027-brightdigit-newsletter-issue-27-20-08-11.md`
- `newsletters/028-brightdigit-newsletter-issue-28-20-08-26.md`
- `newsletters/029-brightdigit-newsletter-issue-29-20-09-15.md`
- `newsletters/030-brightdigit-newsletter-issue-30-20-10-07.md`
- `newsletters/031-brightdigit-newsletter-issue-31-20-10-13.md`
- `newsletters/031-brightdigit-newsletter-issue-32-20-11-10.md`
- `newsletters/033-brightdigit-newsletter-issue-33-20-11-18.md`
- `newsletters/034-brightdigit-newsletter-issue-34-20-12-09.md`
- `newsletters/035-brightdigit-newsletter-issue-35-21-01-10.md`
- `newsletters/036-brightdigit-newsletter-issue-36-21-01-25.md`
- `newsletters/037-brightdigit-newsletter-issue-37-21-02-09.md`
- `newsletters/038-brightdigit-newsletter-issue-38-21-02-25.md`
- `newsletters/039-brightdigit-newsletter-issue-39-21-03-05.md`
- `newsletters/040-brightdigit-newsletter-issue-40-21-03-30.md`
- `newsletters/041-brightdigit-newsletter-issue-41-20-04-20.md`
- `newsletters/042-brightdigit-newsletter-issue-42-21-05-05.md`
- `newsletters/043-brightdigit-newsletter-issue-43-21-05-27.md`
- `newsletters/044-brightdigit-newsletter-issue-44-20-06-08.md`
- `newsletters/045-brightdigit-newsletter-issue-45-21-06-21.md`
- `newsletters/046-brightdigit-newsletter-issue-46-21-07-02.md`
- `newsletters/047-brightdigit-newsletter-issue-47-21-08-03.md`
- `newsletters/048-brightdigit-newsletter-issue-48-21-08-23.md`
- `newsletters/049-brightdigit-newsletter-issue-49-21-09-13.md`
- `newsletters/050-brightdigit-newsletter-issue-50-21-09-21.md`
- `newsletters/051-brightdigit-newsletter-issue-51-21-10-19.md`
- `newsletters/052-brightdigit-newsletter-issue-52-22-01-03.md`  (also: list_cm)
- `newsletters/053-brightdigit-newsletter-issue-53-22-03-01.md`  (also: list_cm)
- `newsletters/054-brightdigit-newsletter-issue-54-22-03-22.md`  (also: list_cm)
- `newsletters/055-brightdigit-newsletter-issue-55-22-04-06.md`  (also: list_cm)
- `newsletters/056-brightdigit-newsletter-issue-56-22-05-04.md`  (also: list_cm)
- `newsletters/058-brightdigit-newsletter-issue-58-22-06-02.md`  (also: list_cm)
- `newsletters/059-brightdigit-newsletter-issue-59-22-06-08.md`  (also: emphasis_cm, list_cm, loneimg)
- `newsletters/060-brightdigit-newsletter-issue-60-22-07-07.md`  (also: list_cm, loneimg)
- `newsletters/061-brightdigit-newsletter-issue-61-22-07-14.md`
- `newsletters/062-brightdigit-newsletter-issue-62-22-07-25.md`  (also: loneimg)
- `newsletters/063-brightdigit-newsletter-issue-63-22-08-18.md`  (also: loneimg)
- `newsletters/064-brightdigit-newsletter-issue-64-22-08-24.md`  (also: list_cm, loneimg)
- `newsletters/065-brightdigit-newsletter-issue-65-22-09-02.md`  (also: list_cm, loneimg)
- `newsletters/066-brightdigit-newsletter-issue-66-22-09-12.md`  (also: loneimg)
- `newsletters/067-brightdigit-newsletter-issue-67-22-09-20.md`  (also: loneimg)
- `newsletters/068-brightdigit-newsletter-issue-68-22-10-13.md`  (also: loneimg)
- `newsletters/069-brightdigit-newsletter-issue-69-22-11-17.md`  (also: loneimg)
- `newsletters/070-brightdigit-newsletter-issue-70-22-12-06.md`  (also: list_cm, loneimg)
- `newsletters/071-brightdigit-newsletter-issue-71-22-02-02.md`  (also: list_cm, loneimg)
- `newsletters/072-brightdigit-newsletter-issue-72-22-02-15.md`  (also: list_cm, loneimg)
- `newsletters/073-brightdigit-newsletter-issue-73-23-03-02.md`  (also: loneimg)
- `newsletters/074-brightdigit-newsletter-issue-74-23-03-27.md`
- `newsletters/075-brightdigit-newsletter-issue-75-23-04-25.md`  (also: list_cm)
- `newsletters/076-brightdigit-newsletter-issue-76-23-05-16.md`
- `newsletters/077-brightdigit-newsletter-issue-77-23-05-30.md`  (also: list_cm)
- `newsletters/078-brightdigit-newsletter-issue-78-22-07-03.md`  (also: list_cm, loneimg)
- `newsletters/079-brightdigit-newsletter-issue-79-23-07-18.md`  (also: emphasis_cm, list_cm, loneimg)
- `newsletters/080-brightdigit-newsletter-issue-80-23-07-27.md`  (also: loneimg)
- `newsletters/081-brightdigit-newsletter-issue-81-23-08-17.md`  (also: list_cm, loneimg)
- `newsletters/082-brightdigit-newsletter-issue-82-22-09-19.md`  (also: loneimg)
- `newsletters/083-brightdigit-newsletter-issue-83-23-10-10.md`  (also: loneimg)
- `newsletters/084-brightdigit-newsletter-issue-84-23-11-10.md`  (also: list_cm, loneimg)
- `newsletters/085-brightdigit-newsletter-issue-85-23-08-28.md`  (also: loneimg)
- `newsletters/086-brightdigit-newsletter-issue-86-23-12-07.md`  (also: loneimg)
- `newsletters/087-brightdigit-newsletter-issue-87-23-12-15.md`  (also: loneimg)
- `newsletters/088-brightdigit-newsletter-issue-88-24-01-17.md`  (also: loneimg)
- `newsletters/089-brightdigit-newsletter-issue-89-24-02-01.md`  (also: loneimg)
- `newsletters/090-brightdigit-newsletter-issue-90-24-03-01.md`  (also: loneimg)
- `newsletters/091-brightdigit-newsletter-issue-91-24-04-15.md`  (also: loneimg)
- `newsletters/092-brightdigit-newsletter-issue-92-24-05-01.md`  (also: loneimg)
- `newsletters/093-brightdigit-newsletter-issue-93-24-05-16.md`  (also: list_cm)
- `newsletters/094-brightdigit-newsletter-issue-94-24-05-31.md`
- `newsletters/095-brightdigit-newsletter-issue-95-24-06-05.md`
- `newsletters/096-brightdigit-newsletter-issue-96-24-06-19.md`
- `newsletters/097-brightdigit-newsletter-issue-97-24-07-02.md`
- `newsletters/098-brightdigit-newsletter-issue-98-24-07-11.md`
- `newsletters/099-brightdigit-newsletter-issue-99-24-08-02.md`
- `newsletters/100-brightdigit-newsletter-issue-100-24-10-03.md`
- `newsletters/101-brightdigit-newsletter-issue-101-24-10-23.md`
- `newsletters/102-brightdigit-newsletter-issue-102-24-11-20.md`
- `newsletters/103-brightdigit-newsletter-issue-103-24-11-27.md`
- `newsletters/104-brightdigit-newsletter-issue-104-24-12-12.md`
- `newsletters/105-brightdigit-newsletter-issue-105-24-12-23.md`  (also: nbsp)
- `newsletters/106-brightdigit-newsletter-issue-106-25-01-30.md`  (also: nbsp)
- `newsletters/107-brightdigit-newsletter-issue-107-25-03-11.md`  (also: nbsp)
- `newsletters/108-brightdigit-newsletter-issue-108-25-04-15.md`  (also: nbsp)
- `newsletters/109-brightdigit-newsletter-issue-109-25-05-20.md`  (also: nbsp)
- `newsletters/110-brightdigit-newsletter-issue-110-25-05-27.md`  (also: nbsp)
- `newsletters/112-brightdigit-newsletter-issue-112-25-07-18.md`  (also: nbsp)
- `newsletters/113-brightdigit-newsletter-issue-113-25-08-12.md`  (also: nbsp)
- `tutorials/codable-4-ways-improve-decode-json.md`  (also: emphasis_cm)
- `tutorials/swift-development-tips-speculid-tryswift.md`  (also: nbsp)
- `tutorials/vapor-heroku-ubuntu-setup-deploy.md`
- `tutorials/vapor-swift-backend-review.md`

### Lone-image paragraph-wrap — 15 files

- `articles/best-backend-for-your-ios-app.md`
- `articles/bushel-launch-part-2.md`
- `articles/bushel-launch-part-3.md`
- `articles/in-app-purchases.md`
- `articles/ios-app-localization.md`
- `articles/microapps-architecture.md`
- `articles/new-api-swift-app.md`
- `articles/new-apple-watch-4.md`  (also: nbsp)
- `articles/server-driven-ui-ios.md`  (also: emphasis_cm)
- `articles/server-side-swift-workout.md`
- `articles/wwdc-swift-developer-guide.md`
- `tutorials/asynchronous-multi-threaded-parallel-world-of-swift.md`  (also: emphasis_cm)
- `tutorials/rebuilding-mistkit-claude-code-part-1.md`  (also: list_cm)
- `tutorials/swiftdata-crud-operations-modelactor.md`  (also: list_cm)
- `tutorials/syntaxkit-swift-code-generation.md`  (also: list_cm)

### Emphasis / inline-HTML CommonMark (strong/em, <br>) — 11 files

- `articles/app-store-review-guidelines.md`  (also: nbsp)
- `articles/do-i-need-a-website.md`  (also: nbsp)
- `articles/machine-learning-business-applications-with-kevin-scott.md`
- `articles/upgrading-old-ios-apps.md`  (also: nbsp)
- `articles/watchos-10.md`
- `tutorials/app-icon-templates-graphics-xcode.md`
- `tutorials/combine-corelocation-publishers-delegates.md`
- `tutorials/combine-corelocation-receiving-handling-events.md`
- `tutorials/flatmap-double-optionals-functional-programming.md`
- `tutorials/objective-c-and-swift-being-friendly.md`  (also: nbsp)
- `tutorials/swift-5-0-xcode-10-1.md`  (also: nbsp)

### Whitespace / nbsp — 19 files

- `articles/4-things-apple-ios-2020.md`
- `articles/apple-september-event-2018.md`
- `articles/apple-watch-series-6.md`
- `articles/avoid-ios-app-failure-with-tdd.md`
- `articles/businesses-wwdc-2018-top-5-changes.md`
- `articles/chips-clips-widgets-apple-wwdc-2020.md`  (also: whitespace)
- `articles/freelancing-prepare-started.md`  (also: whitespace)
- `articles/ios-continuous-integration-avoid-merge-hell.md`
- `articles/iphreaks-podcast-guest.md`
- `articles/native-app-development-advantages.md`  (also: whitespace)
- `articles/project-budget-ios-app.md`  (also: whitespace)
- `articles/swift-error-handling.md`
- `episodes/014-ios-app-architecture-with-rene-cacheaux-and-josh-berlin.md`
- `episodes/204-actually-really-useful.md`  (also: whitespace)
- `episodes/205-who-s-wendy-with-joannis-orlandos.md`  (also: whitespace)
- `episodes/206-platforms-state-of-the-union-2026-with-peter-witham.md`  (also: whitespace)
- `tutorials/freelancing-prepare-started.md`  (also: whitespace)
- `tutorials/healthkit-getting-started.md`
- `tutorials/iphreaks-podcast-guest.md`

### Whitespace (inter-block newline) — 68 files

- `articles/dependency-management-swift.md`
- `articles/macos-development-ios-developers.md`
- `episodes/141-swift-package-index-with-dave-verwer-and-sven-schmidt.md`
- `episodes/142-mobile-system-design-with-tjeerd-in-t-veen.md`
- `episodes/143-datatile-for-simulator-with-marin-todorov.md`
- `episodes/144-yak-shaving-with-tim-mitra.md`
- `episodes/145-reality-and-architecture-with-mohammad-azam.md`
- `episodes/146-apples-glasses-and-hal-oh-my.md`
- `episodes/147-going-pro-with-sean-allen.md`
- `episodes/148-pizza-playpen-and-fastlane-funding-with-josh-holtz.md`
- `episodes/149-how-to-wwdc-with-peter-witham.md`
- `episodes/150-my-taylor-deep-dish-swift-heroes-world-tour.md`
- `episodes/151-platforms-state-of-union-2023-with-peter-witham.md`
- `episodes/152-spatial-experiences-of-the-wild-with-adrian-eves.md`
- `episodes/153-arm-sling-for-apple-watch-developers-with-hidde-van-der-ploeg.md`
- `episodes/154-supercharged-with-pedro-pinera.md`
- `episodes/155-macos-indie-deep-cuts-with-aaron-vegh.md`
- `episodes/156-now-you-know-what-i-m-doing-this-summer.md`
- `episodes/157-swift-server-workgroup-with-joannis-orlandos.md`
- `episodes/158-edge-of-concurrency-with-matt-massicotte.md`
- `episodes/159-it-depends-with-brandon-williams.md`
- `episodes/160-revisiting-third-party-apis-with-christian-selig.md`
- `episodes/161-action-button-for-ring-tones-with-evan-stone.md`
- `episodes/162-building-a-video-sdk-with-marc-schwieterman.md`
- `episodes/163-swiftly-tooling-with-pol-piella-abadia.md`
- `episodes/164-the-making-of-callsheet-with-casey-liss.md`
- `episodes/165-learning-judo-with-sean-rucker.md`
- `episodes/166-empowering-accessibility-with-via-fairchild.md`
- `episodes/167-calm-intentions-with-alaina-kafkes.md`
- `episodes/168-we-have-all-the-heroes-with-stefano-mondino.md`
- `episodes/169-the-bushel-holiday-special.md`
- `episodes/170-pixelblitz-in-public-with-martin-lasek.md`
- `episodes/171-chatgptovski-with-kris-slazinski.md`
- `episodes/172-apple-s-app-vision-with-kyle-lee.md`
- `episodes/173-what-s-next-with-adam-rush.md`
- `episodes/174-triple-glazed-apple-development-with-malin-sundberg-and-kai-dombrowski.md`
- `episodes/175-swiftui-tips-and-tricks-with-craig-clayton.md`
- `episodes/176-hacking-with-ignite-with-paul-hudson.md`
- `episodes/177-plinky-with-joe-fabisevich.md`
- `episodes/178-sotu-2024-with-peter-witham.md`
- `episodes/179-wwdc-notes-with-cihat-gunduz.md`
- `episodes/180-swift-student-challenge-with-dezmond-blair.md`
- `episodes/181-can-you-vision-pro-in-objective-c-with-danielle-lewis.md`
- `episodes/182-swiftui-field-guide-with-chris-eidhof.md`
- `episodes/183-voice-in-a-can-with-damian-mehers.md`
- `episodes/184-the-case-of-the-crimson-test-suite-with-daniel-steinberg.md`
- `episodes/185-the-great-swiftui-migration-part-1-with-ben-scheirman.md`
- `episodes/186-the-great-swiftui-migration-part-2-with-ben-scheirman.md`
- `episodes/187-debugging-your-job-search-with-jaim-zuber.md`
- `episodes/188-ludicrous-types-with-nick-lockwood.md`
- `episodes/189-full-stack-lyriq-with-adegboyega-olusunmade.md`
- `episodes/190-swift-toolkit-with-natan-rolnik.md`
- `episodes/191-swift-server-side-serverless-with-sebastien-stormacq.md`
- `episodes/192-practical-year-part-1-with-donny-wals.md`
- `episodes/193-practical-year-part-2-with-donny-wals.md`
- `episodes/194-fear-of-the-main-thread-with-matt-masicotte.md`
- `episodes/195-moving-forward-2025.md`
- `episodes/196-swift-on-android-with-marc-prud-hommeaux.md`
- `episodes/197-swiftui-fundamentals-with-natalia-panferova.md`
- `episodes/198-full-stack-things-with-werner-jainek-and-vojtech-rylko.md`
- `episodes/199-v26-0-with-peter-witham.md`
- `episodes/200-live-from-communitykit-wwdc-2025-with-matt-massicotte.md`
- `episodes/201-deconstructing-xcode-with-xtool-with-kabir-oberai.md`
- `episodes/202-swift-testing-with-rachel-brindle.md`
- `episodes/203-milk-diary-with-kaya-thomas.md`
- `tutorials/migrating-objective-c-swift.md`
- `tutorials/observation-binding-swiftui.md`
- `tutorials/signin-apple-watchos-simulator.md`

### List-structure CommonMark — 2 files

- `tutorials/asset-catalogs-image-sets-app-icons.md`
- `tutorials/swift-build.md`

### Other CommonMark (nested lists, ref-links, blockquote escaping) — 13 files

- `articles/bushel-launch-part-4.md`
- `articles/learn-how-to-build-an-app-on-june-1st.md`
- `articles/podcasting-getting-started-whys-and-hows.md`
- `articles/swiftdata-considerations.md`
- `tutorials/combine-corelocation-swiftui-delegates.md`
- `tutorials/healthkit-apple-watch-data-authorization.md`
- `tutorials/hkliveworkoutbuilder-healthkit-workout-session.md`
- `tutorials/mise-setup-guide.md`
- `tutorials/rebuilding-mistkit-claude-code-part-2.md`
- `tutorials/swift-on-arm-supporting-arm-in-swift-package-ci.md`
- `tutorials/swift-openapi-generator.md`
- `tutorials/swift-package-manifest-file.md`
- `tutorials/swiftdata-modelactor.md`