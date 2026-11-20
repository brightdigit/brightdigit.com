# Redirects and hosts

- `Resources/_redirects` is the file that ships to `Output/_redirects` (copied by the
  copy-resources step). `Content/_redirects` is NOT published; it's a stale, larger copy
  (139 vs. ~110 lines) and several of its targets no longer exist. Edit `Resources/_redirects`.
- `learningswift.brightdigit.com` (the retired WordPress blog) serves this Netlify site as
  well. Search Console reported `learningswift.brightdigit.com/episodes/215-…` as
  "Duplicate without user-selected canonical" (2026-11). Leo: it's a really old host, so
  don't redirect it in `_redirects`; the fix is dropping the host (Netlify domain alias/DNS).
  Pages' self-canonicals already point at brightdigit.com.
- Newsletter pages meta-refresh to mailchi.mp / Buttondown, so Search Console lists them as
  "Alternate page with proper canonical tag" or "Blocked by robots.txt" (mailchi.mp blocks
  crawlers). That's expected.
- Raw HTML in a front-matter `description` (Transistor imports) breaks `<head>`: the quotes
  aren't escaped in `<meta content>`, so the canonical ends up in `<body>`. Run
  `node Scripts/check-content.js` after imports.
