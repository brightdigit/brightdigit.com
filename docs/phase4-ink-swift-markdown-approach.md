# Phase 4 — Replace Ink with swift-markdown (Publish ecosystem)

Issue: brightdigit/brightdigit.com#40
Branch: `40-ink-swift-markdown`
Status: **SPIKE** (approach note + low-risk scaffolding slice). Not the full migration.

> Scope reminder: the Tagscriber emission half (`MarkdownGenerator` → swift-markdown) was
> split out into #84 / folded into #47. This issue is **Ink-only** (the markdown *parser*).
> Do **not** touch Tagscriber.

---

## 1. What Ink is and where it lives

Ink is John Sundell's pure-Swift CommonMark-ish parser, vendored at
`Packages/Publish/Ink`. Publish uses it as its **markdown parser** and re-exports a
slice of its API as **Publish's own public API**. Three site plugins register Ink
`Modifier`s to inject custom HTML for specific markdown fragments.

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

### 1.2 Where Publish surfaces Ink (the public contract to redesign)

All under `Packages/Publish/Publish/Sources/Publish`:

| File | Ink surface |
|---|---|
| `API/PublishingContext.swift` | `public var markdownParser = MarkdownParser()` — the central knob plugins mutate via `context.markdownParser.addModifier(...)`. Passed into `MarkdownContentFactory(parser: markdownParser, …)`. |
| `Internal/MarkdownContentFactory.swift` | `let parser: MarkdownParser`; calls `parser.parse(file.readAsString())`; reads `markdown.metadata`, `markdown.title`, `markdown.html` (typed as `Ink.Markdown`). |
| `API/PlotEnvironmentKeys.swift` | `EnvironmentKey where Value == MarkdownParser`, `static var markdownParser` (default `.init()`). |
| `API/PlotComponents.swift` | `Node.markdown(_:using parser: MarkdownParser)`; `public struct Markdown: Component` reads the parser from the environment and calls `parser.html(from:)`. |
| `API/PlotModifiers.swift` | `func markdownParser(_ parser: MarkdownParser) -> Component`. |

So `MarkdownParser`, `Modifier`, and `Modifier.Target` are **re-exported to Publish
consumers** by virtue of `import Ink` + public signatures. Removing Ink means these
symbols must be provided by Publish itself (or a new type) with the same names/shape,
or every consumer (the 3 plugins + this site) must change. To minimise blast radius we
keep the **names and call-sites stable** and swap the *implementation*.

### 1.3 The three live plugins

| Plugin | File | Target | Behaviour |
|---|---|---|---|
| `SplashPublishPlugin` | `Packages/Publish/SplashPublishPlugin/Sources/.../SplashPublishPlugin.swift` | `.codeBlocks` | Strips ```` ``` ````; if first line is `no-highlight`, returns Ink's HTML unchanged; otherwise runs Splash `SyntaxHighlighter` and returns `"<pre><code>" + highlighted + "\n</code></pre>"`. |
| `TransistorPublishPlugin` | `Packages/BrightDigit/TransistorPublishPlugin/Sources/.../Modifier.swift` | `.blockquotes` | If blockquote (after `dropFirst()`) starts with `transistor `, parses the URL and emits a Transistor embed; else returns Ink's HTML. |
| `YoutubePublishPlugin` | `Packages/BrightDigit/YoutubePublishPlugin/Sources/.../Modifier.swift` | `.blockquotes` | If blockquote starts with `youtube `, parses the URL and emits a YouTube embed; else returns Ink's HTML. |

All three are registered in `BrightDigitSite` via `context.markdownParser.addModifier(...)`
(or a `Plugin` wrapper, as Splash does).

---

## 2. Why the model mismatch is the hard part

Ink's modifier model is **string-rewrite at render time**: "here is the HTML I made and
the raw source; hand me back a string." swift-markdown is an **AST + visitor** library
(`Markdown.Document`, `Markup` nodes, `MarkupVisitor`, `MarkupRewriter`,
`MarkupWalker`). swift-markdown does **not ship an HTML renderer** — it parses to an AST
and lets you walk/rewrite it; you produce output yourself. Key consequences:

1. **No drop-in `html(from:)`.** We must write our own AST → HTML emitter, OR keep
   Ink purely as the base HTML generator and layer swift-markdown only where modifiers
   need structured access. (Decision below: we own the emitter — keeping Ink defeats
   the purpose.)
2. **Identical-output bar is strict and brittle.** Ink's HTML has specific quirks
   (`<blockquote><p>…</p></blockquote>`, code-block escaping rules, attribute ordering,
   exact whitespace/newline placement, smart-quote behaviour, metadata/front-matter
   `---` handling done *outside* CommonMark). swift-markdown + a fresh emitter will not
   byte-match Ink by default. The migration must be validated by a **golden-file diff
   over real `Content/`**, not just unit tests.
3. **Front matter.** Ink parses leading `---` YAML-ish metadata itself
   (`Ink/Internal/Metadata.swift`) and exposes `Markdown.metadata`/`Markdown.title`.
   swift-markdown/cmark treats `---` as a thematic break and has no front-matter
   concept. The metadata reader (and `metadataKeys`/`metadataValues` modifier targets)
   must be reimplemented as a pre-parse pass that strips and decodes front matter
   before handing the body to swift-markdown.
4. **Modifier targets don't all map to one node type.** `.paragraphs`, `.headings`,
   `.lists`, `.tables`, `.links`, `.images`, `.inlineCode`, `.html`, `.horizontalLines`
   each map to a swift-markdown `Markup` subtype, but `.metadataKeys/.metadataValues`
   map to the front-matter pass, and `.codeBlocks` maps to both fenced and indented
   code. The currently-*used* targets are only `.codeBlocks` and `.blockquotes`, so the
   first cut only needs those two — but the public `Modifier.Target` enum must keep all
   cases to preserve source compatibility.
5. **Name collision.** swift-markdown's library product/module is **`Markdown`**, which
   clashes with (a) Publish's `public struct Markdown: Component` and (b) `Ink.Markdown`.
   `import Markdown` into Publish will create ambiguity with Publish's own `Markdown`
   component. Mitigation: import swift-markdown **only inside a new internal
   parser/emitter module or file** and refer to its types as `Markdown.Document` etc.,
   keeping Publish's public `Markdown` component name unchanged; or use a module
   typealias. This must be settled before wiring (tracked in sub-issue 40-B).

---

## 3. Proposed replacement design

Goal: **keep Publish's public symbol names and call-sites stable**
(`MarkdownParser`, `Modifier`, `Modifier.Target`, `PublishingContext.markdownParser`,
the `Markdown` component, `Node.markdown`) while replacing the engine underneath, so the
three plugins compile with the **smallest possible diff** and the site output is
byte-identical.

### 3.1 New `Modifier` semantics on top of swift-markdown

Keep `Modifier`'s **public shape identical**: `init(target:closure:)`,
`Input = (html: String, markdown: Substring)`, `Closure = (Input) -> String`,
and the full `Modifier.Target` enum. This is the contract the three plugins depend on,
and keeping it means **zero changes to the plugin closures**.

Under the hood, a new Publish-owned engine does:

1. **Front-matter pass** (port of `Ink/Internal/Metadata.swift`): strip leading
   `---…---`, decode into `[String:String]`, apply `.metadataKeys`/`.metadataValues`
   modifiers. Produces `metadata` + `title` (first level-1 heading) + the body string.
2. **Parse** the body with `Markdown.Document(parsing: body, options: …)`.
3. **Emit HTML** by walking the AST with a `MarkupVisitor` ("InkCompatHTMLRenderer")
   tuned to reproduce Ink's exact HTML. For each node whose `Modifier.Target` has a
   registered modifier, generate the base HTML for that node, also reconstruct the
   node's **raw markdown substring** (from the node's `range` against the source, so
   `markdown.dropFirst()` etc. still behave), and run the modifier closure — mirroring
   `HTMLConvertible.html(rawString:applyingModifiers:)`.
   - The raw-substring reconstruction is the crux: swift-markdown nodes expose
     `range: SourceRange?` (enable `parseBlockDirectives`/source-tracking via
     `ParseOptions`), letting us slice the original source. This keeps the plugins'
     `dropFirst()`-style assumptions valid.
4. Return a `Markdown` *value* (rename internally to avoid the component clash — e.g.
   `ParsedMarkdown` internally, but `MarkdownContentFactory` only needs `.html`,
   `.title`, `.metadata`).

`MarkdownParser` becomes a thin Publish type wrapping `[Modifier]` +
the engine, preserving `init(modifiers:)`, `addModifier`, `parse`, `html(from:)`.

### 3.2 Mapping table — Ink `Modifier(target:)` → swift-markdown node + pass

| `Modifier.Target` | swift-markdown node / pass | Used today? |
|---|---|---|
| `.blockquotes` | `BlockQuote` (visit, reconstruct `> …` raw range) | **yes** (Transistor, YouTube) |
| `.codeBlocks` | `CodeBlock` (fenced) + `CodeBlock`/indented | **yes** (Splash) |
| `.metadataKeys` / `.metadataValues` | front-matter pre-pass (not cmark) | no (port for parity) |
| `.headings` | `Heading` | no |
| `.links` | `Link` | no |
| `.images` | `Image` | no |
| `.inlineCode` | `InlineCode` | no |
| `.lists` | `UnorderedList` / `OrderedList` | no |
| `.tables` | `Table` (GFM) | no |
| `.html` | `HTMLBlock` / `InlineHTML` | no |
| `.horizontalLines` | `ThematicBreak` | no |
| `.paragraphs` | `Paragraph` | no |

Only `.blockquotes` and `.codeBlocks` are exercised by live plugins, so the emitter +
modifier-dispatch can ship for those two first; the rest only need correct base-HTML
emission (no live modifiers) to keep `Content/` rendering identical.

### 3.3 Identical-output validation harness

The single most important deliverable of the real migration (not this spike):
a test that, for every file under `Content/`, asserts
`NewEngine.html(from: src) == Ink.html(from: src)` (run Ink and the new engine
side-by-side during the transition; the dependency stays until parity is proven). Any
diff is a bug or a documented, intentional normalization. This is what gates removing
Ink from `Package.swift`.

---

## 4. Proposed sub-issue breakdown under #40 (per package / per concern)

| Sub-issue | Title | Package(s) | Risk |
|---|---|---|---|
| **40-A** | Add swift-markdown dependency + golden-output harness (Ink vs new engine over `Content/`) | top `Package.swift`, `Publish` | low — additive, no behaviour change. **(scaffolding started in this PR)** |
| **40-B** | Resolve `Markdown` name collision; introduce internal `ParsedMarkdown` + engine skeleton behind unchanged `MarkdownParser`/`Markdown`-component API | `Publish` | medium — public-API-preserving plumbing |
| **40-C** | Port front-matter/metadata pre-pass (`Metadata.swift`) + `.metadataKeys/.metadataValues`; reproduce `title` inference | `Publish` | medium |
| **40-D** | Ink-compatible HTML emitter (`MarkupVisitor`) for all non-modifier node types; pass golden harness on `Content/` with **no** modifiers registered | `Publish` | **high** — exact-output reproduction |
| **40-E** | Wire `Modifier` dispatch + raw-range reconstruction for `.codeBlocks` & `.blockquotes`; migrate `SplashPublishPlugin` (`.codeBlocks`) | `Publish`, `SplashPublishPlugin` | high |
| **40-F** | Migrate `TransistorPublishPlugin` (`.blockquotes`) + tests | `BrightDigit/TransistorPublishPlugin` | medium |
| **40-G** | Migrate `YoutubePublishPlugin` (`.blockquotes`) + tests | `BrightDigit/YoutubePublishPlugin` | medium |
| **40-H** | Remove Ink dependency from `Publish` + 3 plugins + top `Package.swift`; delete vendored `Packages/Publish/Ink` if no consumer remains | all | low (once D–G land + golden harness green) |

Suggested order: A → B → C → D → (E, then F & G in parallel) → H. D is the long pole.

---

## 5. This PR (spike scaffolding)

- This approach note.
- 40-A first slice: add the `swift-markdown` package dependency so it resolves in the
  Swift 6.4 container, **without** removing Ink and **without** rewiring any code paths
  (Ink remains the live engine; identical-output bar untouched).

See PR body for verification status.
