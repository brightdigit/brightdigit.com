# Redesign canvas — source artboards

The round-1 redesign of brightdigit.com, drafted 2026-08-28 with Claude Design
(the `/design` skill). Live canvas:
<https://claude.ai/code/artifact/2d5cbf3a-936a-43b7-b93b-a5bcc4778baf>

These are the **sources** the canvas is built from. Each `*.dc.html` is one artboard
(a Design Component: plain HTML/CSS inside `<x-dc>`, no build step). Open any of them
directly in a browser to view it — `LogoAnimation.dc.html` and the nav marks in
`Main`/`HomeDark` animate on load.

| File | Artboard |
|---|---|
| `Main.dc.html` | Home — desktop 1440 |
| `HomeMobile.dc.html` | Home — mobile 390 |
| `HomeDark.dc.html` | Home — dark mode |
| `Article.dc.html` | Article detail (the AI-CITE template) |
| `Episode.dc.html` | Podcast episode detail |
| `Articles.dc.html` | Section listing (articles/tutorials/newsletters) |
| `LogoAnimation.dc.html` | Animated logo, light + dark (CSS/SVG port of `../logo-drop.jsx`) |
| `DirectionB.dc.html` | Alternate direction — "Terminal Mono" (low-fi) |
| `DirectionC.dc.html` | Alternate direction — "Warm Editorial" (low-fi) |

`canvas.json` is the canvas layout (frame positions, sizes, sticky notes).
`renders/` holds a flat PNG of each artboard for quick reference — the sources are the
truth. Renders are captured with the real Google Fonts loading (Oxygen, Cardo,
Oxygen Mono), at 2x, by screenshotting each artboard's root element.

`before/` holds full-page captures of the **live** brightdigit.com for old-vs-new
comparison — 7 pages (home, articles listing, one article, one episode, products,
about-us, contact-us) at desktop 1440 and mobile 390, named `<page>-<viewport>.png`.
The article and episode captured are the same ones the artboards depict
(`best-backend-for-your-ios-app`, episode 210), so the pairs compare like for like.

Both sets are regenerated with Playwright (the cached install under
`~/.npm/_npx`, browsers in `~/Library/Caches/ms-playwright`); the scripts live in
the session scratchpad. Note the live site has a real mobile overflow bug: the
article page lays out at 396px and the episode page at 591px inside a 390px
viewport.

Design decisions (fonts kept, hero video retired, vendor-iframe rule, animated-logo
provenance) are recorded in [`../../memory/claude-design-redesign-brief.md`](../../memory/claude-design-redesign-brief.md)
and `../../agent-notes.md`.

## Rebuilding the canvas

The canvas is assembled by the `/design` skill's `seed-canvas.mjs` helper, which packs
these files into a published artifact. From a session with the skill available:

```bash
node "<design skill dir>/seed-canvas.mjs" \
  --template "<design skill dir>/payload.template.html" \
  --out brightdigit-redesign.html --title "BrightDigit Redesign" \
  --artboard Main.dc.html --artboard HomeMobile.dc.html --artboard HomeDark.dc.html \
  --artboard Article.dc.html --artboard Episode.dc.html --artboard Articles.dc.html \
  --artboard DirectionB.dc.html --artboard DirectionC.dc.html --artboard LogoAnimation.dc.html \
  --image swift-heroes.jpg --image brightdigit-logo.svg --image brightdigit-logo-dark.svg \
  --canvas canvas.json
```

Then publish `brightdigit-redesign.html` to the artifact URL above (pass it as `url` to
update in place rather than creating a second canvas).
