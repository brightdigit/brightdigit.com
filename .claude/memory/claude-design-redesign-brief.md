# Claude Design redesign — prompt + attachment kit

Prepared 2026-08-28 for the post-phases web redesign. When most PRD phases are done, run this
through **Claude Design** (the `/design` skill in Claude Code, or Design on claude.ai) using the
prompt and attachments below. Design work is code-free and can start anytime; **implementation**
is `code · this-repo` work (Components/, `Styling/styles/styles.css`, TailwindKit classes) — or
lands in `brightdigit/BrightDigitSite` if the #168 extraction has happened by then.

## Timing / sequencing notes

- **Do first or fold in:** Site Defects #163 (product links never render), #164 (double Transistor
  player), the invisible Contact social links (CSS scoped to footer only — see agent-notes
  2026-07-16); Phase 3 #129/#167 (real dates + `PageSEO`) shape the templates the redesign draws.
- **#168 decides where the implementation PR lands** (this repo vs. the extracted package repo).
- The current 1,471-line `styles.css` is descendant-selector CSS (`body > header > nav > ol …`) —
  the redesign is the natural moment to replace it with utility classes via TailwindKit instead
  of extending it.

## Decisions so far (2026-08-28)

- **Round-1 canvas is live:** https://claude.ai/code/artifact/2d5cbf3a-936a-43b7-b93b-a5bcc4778baf —
  leading direction "Highlighter Editorial" (Home desktop/mobile/dark, Article, Episode, Articles
  listing) plus low-fi "Terminal Mono" and "Warm Editorial" alternates.
- **Fonts: keep the existing set** — Oxygen (sans/UI), Cardo (serif prose), Oxygen Mono. No new
  type pairing. (Weight notes: Oxygen has no 500 → use 400/700; Cardo has no 600 → 700, and no
  real bold-italic.)
- **Hero background video retired** — Leo no longer wants the animated `iPhone.mov`/`iPhone.webm`
  background on the homepage. The redesigned hero is static (photo + type + yellow accents).
- **Animated logo exists** in Claude Design: project `0341f74c-e242-45f1-b894-e9136a630fb1`,
  file `BrightDigit Logo Animation v4.dc.html`
  (https://claude.ai/design/p/0341f74c-e242-45f1-b894-e9136a630fb1?file=BrightDigit+Logo+Animation+v4.dc.html&via=share). Not in this repo,
  and not reachable from a remote session (DesignSync needs a one-time `/design-login` from an
  interactive session, and the share page 403s through the sandbox proxy). To hand it to a
  session: use "Send to Claude Code Web" from the Design project, run `/design-login` once on a
  local interactive session, or export it (SVG/CSS/HTML, Lottie, GIF, or video) into
  `Resources/media/`. Intended placement: nav mark / hero brand moment.

## The prompt (paste into Claude Design)

> Redesign **brightdigit.com** — the static site of BrightDigit, a one-person Swift / Apple-platforms
> consultancy run by Leo Dion, who also hosts the EmpowerApps.Show podcast (200+ episodes), writes a
> newsletter, and ships open-source Swift apps and packages (Bushel, MistKit, SyndiKit, 15 products
> total). Current tagline: "Your Experts in Swift App Development."
>
> **Audience & goal.** Two audiences: (1) decision-makers evaluating Swift expertise for hire,
> (2) Swift developers arriving from search and AI-assistant citations to articles, podcast
> episodes, and newsletter issues. The redesign should feel modern, fast, and credible, and make
> the content library (articles, podcast, newsletter, tutorials, products) first-class — today it
> reads as an agency brochure with a blog bolted on.
>
> **Brand — fixed:** the BrightDigit logo (SVGs attached) and the signature yellow
> `#F9ED32` (full scale in the attached token sheet), currently paired with near-black text on
> white. **Open to evolve:** typography (today: Oxygen sans, Cardo serif headings, Oxygen Mono
> code), the neutral/secondary palette, and a proper **dark mode — the site has none today;
> propose light + dark for every artboard.**
>
> **Implementation constraints** (it ships as server-rendered static HTML styled with Tailwind CSS
> v4 utilities):
> - Stick to standard Tailwind v4 design tokens — default spacing scale, standard text sizes,
>   radii, shadows — plus the custom yellow scale. Avoid bespoke pixel values that don't map to
>   documented v4 utilities.
> - Article/episode/newsletter bodies are rendered from Markdown with **no per-element classes** —
>   include a "prose" typography spec (headings, links, lists, blockquotes, tables, images, code
>   blocks with syntax highlighting, Mermaid diagrams) stylable via element selectors.
> - Real embeds to accommodate: Transistor audio player iframe + YouTube video on episode pages;
>   Buttondown subscribe form (email input + button) on newsletter pages and article footers.
> - Static site, minimal JS: the mobile nav toggle is essentially the only interactive chrome. No
>   carousels or scroll-jacking.
>
> **Content/SEO requirements to bake into the templates** (we optimize for AI citation):
> - Every article/episode/newsletter template shows a real publish date, an "updated" date, author
>   byline, and reading time — visible near the top, not buried in a footer.
> - The article template opens with an **answer-first summary block** (TL;DR / key-takeaways box)
>   above the fold, before the body.
> - Heading styles that keep long, question-style H2/H3s scannable; comparison tables and lists
>   must look designed, not default.
>
> **Artboards** (desktop 1440 + mobile 390 for the starred ones; use the attached screenshots as
> the "before" state and the attached markdown as real copy — no lorem ipsum):
> 1. ★ **Home** — hero (headline + CTA; today it uses a background video — show a variant with and
>    without), services (4 items), testimonials (3 of the attached quotes), latest articles,
>    newsletter CTA.
> 2. ★ **Article detail** — the most important template: header with dates + reading time, TL;DR
>    box, prose body including a code block, a table, and an image, share links, subscribe CTA,
>    related-content footer.
> 3. **Section listing** (shared by Articles / Tutorials / Newsletters) — featured card + card
>    grid with dates.
> 4. ★ **Podcast episode detail** — episode art / YouTube embed, Transistor player (once), show
>    notes, guest links.
> 5. **Episodes listing** — featured episode + grid.
> 6. **Newsletter issue detail** + subscribe form.
> 7. **Products** — grid of 15 open-source apps/packages: icon, one-line blurb, App Store /
>    GitHub / Press Kit links.
> 8. **About** — bio with photo (attached), podcast/community highlights.
> 9. **Contact** — contact methods + social links (visible!), simple form.
> 10. **Global chrome** — header/nav (desktop + mobile menu open state) and footer (nav columns,
>    social icons, RSS links, copyright).
>
> Keep it fast-feeling — restrained imagery, generous whitespace, the yellow used as accent rather
> than flood.

## Attachments checklist

**Brand / identity**
- `Resources/media/brightdigit-logo.svg`, `Resources/media/brightdigit-logo-dark.svg`,
  `Resources/media/brightdigit-name.svg`, `Resources/favicon.svg`
- Token sheet: the `@theme` block from `Styling/styles/styles.css` (fonts + the bellow yellow
  scale `#958e1e / #f9ed32 / #fbf484 / #fdf8ad / #fdfbd6`) — paste as text or attach as a small
  file.
- `Resources/media/leo-pic.jpeg` (About page photo)

**"Before" screenshots** — yes, attach these: they are the only attachment that *shows* the
current site (Claude Design cannot render brightdigit.com; everything else in the kit merely
describes it). Curate instead of dumping the full page × viewport matrix — every extra tall
full-page capture dilutes attention:

- **Core set (~7):** `/` (desktop full-page + mobile), one article detail full-page
  (`/articles/best-backend-for-your-ios-app/`), one episode detail (e.g.
  `/episodes/210-practical-agents-with-donny-wals/` — verify slug), `/articles/` listing (stands
  in for the tutorials/newsletters listings too), `/contact-us/`, and the mobile menu open.
- **Optional extras** if attachment budget allows: `/products/`, `/about-us/`, one newsletter issue.
- **Capture fresh at prompt time**, not in advance — content churns via the 6-hourly
  automate-content job and defects may be fixed by then; the script below takes about a minute.
  If the redesign runs as `/design` inside a Claude Code session on this repo, skip manual
  attaching: have the session capture and read the screenshots itself in the same conversation.
- **Anchoring trade-off:** screenshots gravity-pull the design toward the current layout. The
  prompt already frames them as the "before" state, not a template; if round 1 comes back hugging
  the current site too closely, re-run the ★ artboards withholding them.

Playwright capture (Chromium is preinstalled in CCR sessions):

```js
// screenshots.mjs — node screenshots.mjs   (npm i playwright-core)
import { chromium } from "playwright-core";
const base = "https://brightdigit.com";
const pages = [["home","/"],["articles","/articles/"],
  ["article","/articles/best-backend-for-your-ios-app/"],["episodes","/episodes/"],
  ["episode","/episodes/210-practical-agents-with-donny-wals/"],["newsletters","/newsletters/"],
  ["products","/products/"],["about","/about-us/"],["contact","/contact-us/"]];
const browser = await chromium.launch({ executablePath: process.env.PW_CHROMIUM ?? undefined });
for (const [w,h,tag] of [[1440,900,"desktop"],[390,844,"mobile"]]) {
  const ctx = await browser.newContext({ viewport: { width: w, height: h } });
  const page = await ctx.newPage();
  for (const [name, path] of pages) {
    await page.goto(base + path, { waitUntil: "networkidle" });
    await page.screenshot({ path: `shots/${name}-${tag}.png`, fullPage: true });
  }
  await ctx.close();
}
await browser.close();
```

**Real copy** (so artboards use real content):
- Tier-1 articles: `Content/articles/best-backend-for-your-ios-app.md` and the Mise setup guide
  (#21); optionally `dependency-management-swift.md` (#130 will have split it by then — attach the
  post-split version).
- One episode: e.g. `Content/episodes/210-practical-agents-with-donny-wals.md`
- One newsletter issue: e.g. `Content/newsletters/119-the-honest-ai-conversation.md`
- One product: `Content/products/bushel.md`
- Testimonial quotes: extract from `Sources/BrightDigitSite/Testimonials/Testimonial+*.swift`
  (9 exist; pick 3–4 with names/companies).

**Optional:** 2–3 screenshots/links of sites whose feel Leo wants (personal pick — not in repo).

## After the canvas round

1. Iterate on the canvas (Claude Design supports select-and-edit refinement) until the ★ artboards
   are approved; export PNG/PDF for the record.
2. Implementation phase translates approved artboards into Plot `Component`s + TailwindKit classes
   (documented v4 utilities only — agent-notes rules apply; anything non-documented stays raw CSS
   in `styles.css` `@utility`/element selectors, e.g. the prose spec).
3. New palette/fonts land in the `@theme` block; dark mode via `dark:` variants (first use on the
   site) or CSS `prefers-color-scheme` for the prose styles.
4. Verify with `swift run brightdigitwg publish --mode drafts` + `node Scripts/check-content.js`,
   and screenshot-diff the rebuilt pages against the approved artboards.
