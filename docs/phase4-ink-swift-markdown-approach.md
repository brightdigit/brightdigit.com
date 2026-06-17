# Phase 4 — Replace Ink's parser with swift-markdown (keep Ink's emitter)

Issue: brightdigit/brightdigit.com#40
Branch: `40-ink-swift-markdown`
Status: **SPIKE** (approach note + low-risk scaffolding slice). Not the full migration.

> Scope reminder: the Tagscriber emission half (`MarkdownGenerator` → swift-markdown) was
> split out into #84 / folded into #47. This issue is **Ink-only** (the markdown *parser*).
> Do **not** touch Tagscriber.

> **Design revised after owner review.** The original spike proposed writing a brand-new
> Ink-compatible HTML emitter on top of swift-markdown. The owner reviewed that and chose a
> **lower-risk approach: keep Ink's HTML emitter and replace only Ink's parser.** This note
> reflects the revised plan. The accurate findings about the `(html, rawString)` modifier
> contract, the `dropFirst()` raw-source detail, swift-markdown shipping no HTML renderer,
> and the front-matter caveat all still hold and are retained below.

---

## 1. What Ink is and where it lives

Ink is John Sundell's pure-Swift CommonMark-ish parser/renderer, vendored at
`Packages/Publish/Ink/Sources/Ink` as **our editable fork**. Publish uses it as its
**markdown parser** and re-exports a slice of its API as **Publish's own public API**.
Three site plugins register Ink `Modifier`s to inject custom HTML for specific markdown
fragments.

### 1.0 Ink is internally separable into a parser half and an emitter half

This is the structural fact the revised approach hinges on. Ink's pipeline is two
cleanly separable stages:

1. **Parse** — `MarkdownParser.parse()` runs a `Reader` over the source and builds an
   **in-memory `[Fragment]` node list** (`Blockquote`, `CodeBlock`, `Heading`, `List`,
   `Paragraph`, `Table`, etc.). This is the front half.
2. **Render** — a separate reduce walks that node list and calls each node's
   `html(...)`. The renderer is **per-node `HTMLConvertible` conformance**; modifiers
   apply at emission via the `HTMLConvertible where Self: Modifiable` extension, which
   passes `(html, rawString)` to each registered modifier. This is the back half.

Because parse and render are separable, we can **discard the front half (the `Reader`)
and keep the back half (the node structs + their `html(...)` emitters + the modifier
plumbing)**, repurposing the node structs as a **rendering IR** populated by a different
front end. That is the revised approach.

### 1.1 Ink public API actually used by the ecosystem

From `Packages/Publish/Ink/Sources/Ink/API`:

| Type | Role |
|---|---|
| `MarkdownParser` (struct) | `init(modifiers:)`, `mutating addModifier(_:)`, `parse(_:) -> Markdown`, `html(from:) -> String` |
| `Markdown` (struct) | result value: `.html: String`, `.title: String?`, `.metadata: [String:String]` |
| `Modifier` (struct) | `init(target:closure:)`; `typealias Input = (html: String, markdown: Substring)`; `typealias Closure = (Input) -> String` |
| `Modifier.Target` (enum) | `.metadataKeys .metadataValues .blockquotes .codeBlocks .headings .horizontalLines .html .images .inlineCode .links .lists .paragraphs .tables` |

**Modifier contract (the load-bearing detail).** When Ink renders a fragment it calls
each registered modifier for that fragment's `Target` with:
- `html` — the HTML Ink already generated for the fragment, and
- `markdown` — the **complete raw markdown source substring** of that fragment.

The closure returns a replacement HTML string. See
`Ink/Internal/HTMLConvertible.swift`:

```swift
modifiers.applyModifiers(for: modifierTarget) { modifier in
    html = modifier.closure((html, rawString))
}
```

`rawString` is the verbatim source slice the `Reader` consumed for that fragment —
for a blockquote that is `> transistor https://…\n` (leading `>` included); for a
code block it is the entire ```` ```lang … ``` ```` block. This is why every plugin
begins with `markdown.dropFirst()` / `markdown.dropFirst("```".count)`.

> **Implication for the revised approach.** Since we keep the emitter and the modifier
> plumbing, we do **not** re-derive the modifier contract. We only need to hand the
> existing emitter a node list **plus the correct `rawString`** for each node. That
> `rawString` no longer comes from a `Reader` cursor; it is reconstructed from each
> swift-markdown node's `SourceRange` sliced against the original source (see 3.3).

### 1.2 Where Publish surfaces Ink (the public contract to preserve)

All under `Packages/Publish/Publish/Sources/Publish`:

| File | Ink surface |
|---|---|
| `API/PublishingContext.swift` | `public var markdownParser = MarkdownParser()` — the central knob plugins mutate via `context.markdownParser.addModifier(...)`. Passed into `MarkdownContentFactory(parser: markdownParser, …)`. |
| `Internal/MarkdownContentFactory.swift` | `let parser: MarkdownParser`; calls `parser.parse(file.readAsString())`; reads `markdown.metadata`, `markdown.title`, `markdown.html` (typed as `Ink.Markdown`). |
| `API/PlotEnvironmentKeys.swift` | `EnvironmentKey where Value == MarkdownParser`, `static var markdownParser` (default `.init()`). |
| `API/PlotComponents.swift` | `Node.markdown(_:using parser: MarkdownParser)`; `public struct Markdown: Component` reads the parser from the environment and calls `parser.html(from:)`. |
| `API/PlotModifiers.swift` | `func markdownParser(_ parser: MarkdownParser) -> Component`. |

So `MarkdownParser`, `Modifier`, and `Modifier.Target` are **re-exported to Publish
consumers**. The revised approach keeps **all of these public symbols and call-sites
unchanged**: `MarkdownParser` becomes a thin **façade** over the retained emitter, so
`PublishingContext`, `MarkdownContentFactory`, `PlotComponents`, etc. compile untouched,
and the three plugins compile **unchanged**.

### 1.3 The three live plugins

| Plugin | File | Target | Behaviour |
|---|---|---|---|
| `SplashPublishPlugin` | `Packages/Publish/SplashPublishPlugin/Sources/.../SplashPublishPlugin.swift` | `.codeBlocks` | Strips ```` ``` ````; if first line is `no-highlight`, returns Ink's HTML unchanged; otherwise runs Splash `SyntaxHighlighter` and returns `"<pre><code>" + highlighted + "\n</code></pre>"`. |
| `TransistorPublishPlugin` | `Packages/BrightDigit/TransistorPublishPlugin/Sources/.../Modifier.swift` | `.blockquotes` | If blockquote (after `dropFirst()`) starts with `transistor `, parses the URL and emits a Transistor embed; else returns Ink's HTML. |
| `YoutubePublishPlugin` | `Packages/BrightDigit/YoutubePublishPlugin/Sources/.../Modifier.swift` | `.blockquotes` | If blockquote starts with `youtube `, parses the URL and emits a YouTube embed; else returns Ink's HTML. |

All three are registered in `BrightDigitSite` via `context.markdownParser.addModifier(...)`
(or a `Plugin` wrapper, as Splash does). Because the revised approach keeps the emitter
and modifier plumbing, **the goal is that these three plugins compile and behave
unchanged.**

---

## 2. The revised approach — "keep Ink's emitter, replace only its parser"

Instead of writing a fresh HTML emitter, we **keep Ink's back half (the emitter +
modifier plumbing) and replace only its front half (the `Reader`-based parser)** with a
swift-markdown front end that produces the same node structs.

### 2.1 What gets DELETED (Ink's parser layer)

The reader/tokenizer front half is removed entirely:

- `Reader` (`Ink/Internal/Reader.swift`) and **every `read(using:)` / `readOrRewind`**
  static parsing method on the node types.
- `fragmentType` dispatch (the per-character fragment classification).
- Reader-support files: `Character+Classification.swift`, `Character+Escaping.swift`,
  `Substring+Trimming.swift`, `Readable.swift`, `Require.swift`.

### 2.2 What gets KEPT (what Publish requires + the emitter)

- **Public API, unchanged:** `MarkdownParser` (now a **façade**), `Markdown`, `Modifier`,
  `Modifier.Target`.
- **The emitter + modifier plumbing:** the `.html()` methods on every node, plus
  `HTMLConvertible`, `Modifiable`, `ModifierCollection`, `NamedURLCollection`.
- **The node structs themselves** (`Blockquote`, `CodeBlock`, `Heading`, `List`,
  `Paragraph`, `Table`, `FormattedText`, `Image`, `Link`, `InlineCode`,
  `HorizontalLine`, `HTML`, …) — **repurposed as a rendering IR**: no longer built by a
  `Reader`, but constructed directly from the swift-markdown AST.
- Ink's small **front-matter (`---`) and `[name]: url` reference pre-passes**, because
  cmark/swift-markdown does neither (see 2.4).

### 2.3 What gets WRITTEN (new work)

1. A swift-markdown **`MarkupVisitor`/`MarkupWalker`** that converts swift-markdown's
   `Document` AST into Ink's node structs (the retained IR), then feeds the **existing
   emitter**. This is the heart of the new work — and it is *smaller* than writing a
   fresh emitter, because emission/escaping/whitespace behaviour is reused from Ink.
2. **`SourceRange` → `rawString` reconstruction** so the modifier contract keeps working:
   each swift-markdown node exposes a `SourceRange?`; slicing the original source by that
   range reproduces the verbatim fragment substring the modifier closures expect, keeping
   the plugins' `dropFirst()`-style assumptions valid (see 3.3).
3. Keeping Ink's **front-matter** and **reference-link** pre-passes (port/retain, not
   rewrite).

### 2.4 Why the pre-passes stay (front matter + reference links)

- **Front matter.** Ink parses leading `---` YAML-ish metadata itself
  (`Ink/Internal/Metadata.swift`) and exposes `Markdown.metadata`/`Markdown.title`.
  swift-markdown/cmark treats `---` as a thematic break and has **no front-matter
  concept**. So the metadata reader (and `.metadataKeys`/`.metadataValues` targets) is
  kept as a pre-parse pass that strips and decodes front matter before handing the body
  to swift-markdown.
- **Reference links.** Ink's `[name]: url` reference declarations
  (`NamedURLCollection` / `URLDeclaration`) are likewise a small Ink pre-pass that is
  retained, feeding the emitter's link resolution.

### 2.5 swift-markdown ships no HTML renderer (still true — and now irrelevant)

swift-markdown is an **AST + visitor** library (`Markdown.Document`, `Markup` nodes,
`MarkupVisitor`, `MarkupRewriter`, `MarkupWalker`) and **does not ship an HTML
renderer** — it parses to an AST and lets you walk/rewrite it; you produce output
yourself. In the *original* plan this forced us to write a fresh emitter. In the
**revised** plan this is no longer a cost: we don't ask swift-markdown to render, we only
ask it to **parse to an AST**, then translate that AST into Ink's node IR and let **Ink's
emitter** produce the HTML.

### 2.6 The `Markdown` module name collision is NOT a blocker

swift-markdown's library product/module is **`Markdown`**, which clashes with (a)
Publish's `public struct Markdown: Component` and (b) `Ink.Markdown`. This is resolvable
several ways and is **not** a design risk:

- **Preferred: SwiftPM `moduleAliases:`** — rename swift-markdown's module in the build
  graph (e.g. alias to `CMarkdown`/`SwiftMarkdown`) so it never collides with the
  Publish/Ink `Markdown` names.
- **Swift 6.4 module selectors** — refer to `Markdown::Document` to disambiguate.
- **Selective imports + `typealias`** — import swift-markdown only in the new front-end
  file and alias its types.

Tracked in 40-B.

### 2.7 Output is intentionally NOT byte-identical to old Ink

swift-markdown is **CommonMark/GFM-correct** where Ink is **quirky** (Ink's blockquote
nesting, code-block escaping rules, smart-quote behaviour, attribute ordering, exact
whitespace placement, and `---` handling diverge from spec). So the new front end will
**not** byte-match old Ink, **by design** — many diffs are spec-correct *improvements*,
not regressions. We therefore gate with a **golden diff over real `Content/`**: it
surfaces every change so we can triage genuine regressions while **accepting** the
spec-correct improvements. (This replaces the original plan's strict byte-identical bar.)

---

## 3. Mechanics

### 3.1 `MarkdownParser` as a façade

`MarkdownParser` keeps `init(modifiers:)`, `addModifier`, `parse(_:) -> Markdown`,
`html(from:) -> String`. Internally `parse` now:

1. Runs the **front-matter pre-pass** (retained `Metadata.swift`) → `metadata`, `title`,
   body string.
2. Runs the **reference-link pre-pass** (retained `NamedURLCollection`).
3. Parses the body via swift-markdown (`Document(parsing:options:)` with source-range
   tracking enabled).
4. Walks the AST with the new `MarkupVisitor`, **constructing Ink's node IR**.
5. Reduces the node IR through the **retained Ink emitter** (which applies modifiers via
   the existing `(html, rawString)` plumbing) to produce `.html`.
6. Returns the existing `Markdown` value (`.html`, `.title`, `.metadata`) — unchanged
   shape, so `MarkdownContentFactory` is untouched.

### 3.2 Mapping table — swift-markdown node → retained Ink node IR

| swift-markdown node | Ink node IR (retained) | `Modifier.Target` | Used by live plugin? |
|---|---|---|---|
| `BlockQuote` | `Blockquote` | `.blockquotes` | **yes** (Transistor, YouTube) |
| `CodeBlock` (fenced + indented) | `CodeBlock` | `.codeBlocks` | **yes** (Splash) |
| `Heading` | `Heading` | `.headings` | no |
| `Paragraph` | `Paragraph` | `.paragraphs` | no |
| `UnorderedList` / `OrderedList` | `List` | `.lists` | no |
| `Table` (GFM) | `Table` | `.tables` | no |
| `Link` | `Link` | `.links` | no |
| `Image` | `Image` | `.images` | no |
| `InlineCode` | `InlineCode` | `.inlineCode` | no |
| `ThematicBreak` | `HorizontalLine` | `.horizontalLines` | no |
| `HTMLBlock` / `InlineHTML` | `HTML` | `.html` | no |
| (front-matter pre-pass) | `Metadata` | `.metadataKeys` / `.metadataValues` | no (retained for parity) |

Only `.blockquotes` and `.codeBlocks` are exercised by live plugins. Because the emitter
is reused, the non-modifier targets need only **correct AST→IR translation**; their HTML
emission is already implemented by Ink.

### 3.3 `SourceRange` → `rawString` reconstruction (the modifier crux)

The one genuinely new piece of the modifier path. The `Reader` used to record the
verbatim slice it consumed; now there is no `Reader`. Instead, enable source-range
tracking in swift-markdown's `ParseOptions`, read each node's `range: SourceRange?`, and
**slice the original source** by that range to reconstruct the fragment substring. Hand
that substring to the retained emitter as `rawString`, so the existing modifier plumbing
calls each closure with `(html, rawString)` exactly as before — and the plugins'
`markdown.dropFirst()` / `markdown.dropFirst("```".count)` assumptions remain valid.

---

## 4. Revised sub-issue breakdown under #40

| Sub-issue | Title | Risk | Notes |
|---|---|---|---|
| **40-A** | swift-markdown dep + golden Ink-vs-new harness over `Content/` | low | **done** — additive; Ink remains live |
| **40-B** | Resolve `Markdown` module collision via `moduleAliases`; façade skeleton behind unchanged public API | medium | public-API-preserving plumbing |
| **40-C** | Front-matter/metadata + reference-link pre-passes preserved | medium | retain Ink's `Metadata` + `NamedURLCollection` pre-passes |
| **40-D** | swift-markdown AST → Ink-node `MarkupVisitor` | medium | **shrunk** vs original "write fresh emitter" — Ink's emitter is reused |
| **40-E** | `SourceRange` → `rawString` reconstruction so existing modifier dispatch keeps working; verify Splash/Transistor/YouTube plugins compile **unchanged** | medium | **was high** — mostly evaporates since emitter + modifier plumbing are reused |
| **40-F** | Delete Ink's parser layer (`Reader` etc.); keep nodes + emitter | low | remove `read(using:)`, `fragmentType`, reader-support files |
| **40-G** | Golden harness green over real `Content/` with all 3 plugins | high | **the real correctness gate** — triage regressions vs spec-correct improvements |
| **40-H** | Remove the Ink package dependency / rename to the retained-emitter module; update top manifest + 3 plugins | low | |

**Order: A → B → C → D → E → F → G → H.**

What changed from the original breakdown: the old 40-D ("write a fresh Ink-compatible
HTML emitter") is gone — there is no fresh emitter. 40-D is now "AST → Ink-node visitor"
(medium, not high), and 40-E (modifier dispatch + raw-range) drops from high to medium
because the emitter and modifier plumbing are reused rather than rebuilt. The strict
byte-identical bar is replaced by a golden-diff triage gate (40-G).

---

## 5. This PR (spike scaffolding)

- This approach note (revised to "keep Ink's emitter, replace only its parser").
- 40-A first slice: add the `swift-markdown` package dependency so it resolves in the
  Swift 6.4 container, **without** removing Ink and **without** rewiring any code paths
  (Ink remains the live engine; output is untouched, so identical-output is trivially
  preserved for this slice).
- The dependency is pinned to **`branch: "main"`** (standardizing with PR #86): swift-markdown
  has no semver tags compatible with the pre-release Swift 6.4 toolchain, so the project
  tracks `main` until a compatible tagged release exists.

See PR body for verification status.
