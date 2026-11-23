# AI Consulting landing page — mockups and copy options (issue #184)

`index.html` is the review board for issue #184: no Swift and no CSS has been changed yet.

The offer is **AI consulting for any business** (Leo, 2026-11-23). It covers AI workflows and tools plus strategy and readiness, and Apple-platform app teams get one optional Swift track. The issue's original "AI + Swift" title was narrower. The folder keeps its `ai-swift` name so the published artifact link stays stable.

The board contains:

- **Direction A**, Services-native, at desktop and 390px.
- **Direction B**, Pricing table, at desktop and 390px. This is the recommended direction.
- **Direction C**, Narrative / long-form, at desktop and 390px.
- **Panel 4**, which is Direction B re-skinned in the redesign's *Highlighter Editorial* language. It is low-fi and shown in light and dark. Its tokens come from `Main.dc.html` / `HomeDark.dc.html` on branch `claude/web-redesign-claude-design-y6zacq`.
- **Entry points**: the nav link, a Services-page banner, the mobile menu and the newsletter.
- **Copy options**, one group per open question. Picks build a Markdown summary to paste into the issue. They are saved in the viewer's browser only.
- A **build note** and a **recommendation**.

The board is an Artifact page body: the publish step wraps it in a document skeleton. To view it locally, wrap it in `<html><body>…</body></html>`.

## Honesty rules applied
- Fonts are Oxygen, Cardo and Oxygen Mono only. There is no hero video and no player chrome; episode embeds are labeled slots.
- Testimonials are verbatim substrings of `Sources/BrightDigitSite/Testimonials/Testimonial+*.swift`. The one shortened quote (Jody Burgess) marks its cut with ` … `.
  - Re-check with the script below, run from this directory. It should print `0 mismatches`.
  - Dave Mulder's source title reads "Product ManagerProduct Manager at Conferences i/o". The board displays it de-duplicated; fix the source string when building.
- No numbers are claimed other than episode numbers 208 and 210. Their slugs come from `Content/episodes/`.
- Only the audit (entry package) shows a price, as a fixed `$[X,XXX]` placeholder. Other packages say "quoted after the audit" (Leo's decision, 2026-11-23). Timelines are suggestions. FAQ answers marked "confirm" need Leo's sign-off.

```bash
node -e 'const fs=require("fs"),p="../../../Sources/BrightDigitSite/Testimonials/";const s=fs.readdirSync(p).map(f=>fs.readFileSync(p+f,"utf8")).join("\n");const h=fs.readFileSync("index.html","utf8");let b=0,n=0;for(const m of h.matchAll(/“([^”]+)”/g)){if(m[1].length<60)continue;n++;for(const x of m[1].split(" … "))if(!s.includes(x.trim()))b++}console.log(n,"quotes,",b,"mismatches")'
```

The logo is inlined as a data URI built from `Resources/media/brightdigit-logo.svg`.
