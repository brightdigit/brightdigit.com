#!/usr/bin/env node
//
//  check-content.js
//  BrightDigit
//
//  Report-only content-quality checker (issue #142).
//
//  Scans the built site (Output/) first — the ground truth of what ships —
//  then the Content/ markdown sources to locate where each defect originates.
//  Flags: raw/broken HTML tags, unescaped/broken HTML entities, and
//  smart-quote / apostrophe mojibake.
//
//  This is REPORT-ONLY: it prints findings grouped by file:line and a summary,
//  but always exits 0 (never gates a build). Pass --strict to exit non-zero
//  when findings exist (reserved for a future CI gate; off by default).
//
//  By default the imported MailChimp newsletter archive (Content/newsletters,
//  Output/newsletters) is SUPPRESSED — it is low-priority imported cruft (e.g.
//  literal <<First Name>> merge fields). The summary still reports how many
//  findings were suppressed; --newsletters includes them in full.
//
//  Usage:
//    node Scripts/check-content.js [--strict] [--quotes] [--newsletters] [root]
//
//    --strict        exit 1 when any HIGH-severity finding exists (default: 0)
//    --quotes        also report straight/curly quote INCONSISTENCY (INFO tier).
//                    Off by default: the corpus mixes straight and curly quotes,
//                    so this is noisy. Mojibake is ALWAYS reported regardless.
//    --newsletters   include the imported newsletter archive (suppressed by
//                    default).
//    root            repo root to scan (default: the script's parent directory)
//

"use strict";

const fs = require("fs");
const path = require("path");

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

const argv = process.argv.slice(2);
const opts = { strict: false, quotes: false, newsletters: false, root: null };
for (const a of argv) {
  if (a === "--strict") opts.strict = true;
  else if (a === "--quotes") opts.quotes = true;
  else if (a === "--newsletters") opts.newsletters = true;
  else if (a === "--help" || a === "-h") {
    console.log(
      [
        "Usage: node Scripts/check-content.js [--strict] [--quotes] [--newsletters] [root]",
        "",
        "  --strict        exit 1 when any actionable (HIGH) finding exists",
        "  --quotes        also report straight/curly quote inconsistency (noisy)",
        "  --newsletters   include the imported MailChimp newsletter archive,",
        "                  which is suppressed by default (low-priority cruft)",
        "  root            repo root to scan (default: the script's parent dir)",
      ].join("\n")
    );
    process.exit(0);
  } else if (!a.startsWith("-")) opts.root = a;
}

const REPO_ROOT = opts.root
  ? path.resolve(opts.root)
  : path.resolve(__dirname, "..");
const OUTPUT_DIR = path.join(REPO_ROOT, "Output");
const CONTENT_DIR = path.join(REPO_ROOT, "Content");
const CONTENT_SUBDIRS = ["episodes", "newsletters", "articles", "tutorials"];

// Severity tiers. HIGH = almost certainly a real defect that ships broken
// output; INFO = stylistic (only emitted with --quotes).
const HIGH = "HIGH";
const INFO = "INFO";

/** @type {{file:string, line:number, col:number, severity:string, kind:string, message:string, snippet:string}[]} */
const findings = [];

// Build a snippet centered on the match so long lines (e.g. minified newsletter
// HTML) show the actual defect, not the start of the line. matchIndex is the
// 0-based offset of the defect within `text`; omit for a from-start snippet.
function snippetAround(text, matchIndex) {
  if (typeof matchIndex !== "number") return text.trim().slice(0, 120);
  const WINDOW = 60;
  const start = Math.max(0, matchIndex - WINDOW);
  const end = Math.min(text.length, matchIndex + WINDOW);
  let s = text.slice(start, end).replace(/\s+/g, " ").trim();
  if (start > 0) s = "…" + s;
  if (end < text.length) s = s + "…";
  return s;
}

function record(file, line, col, severity, kind, message, text, matchIndex) {
  findings.push({
    file: path.relative(REPO_ROOT, file),
    line,
    col,
    severity,
    kind,
    snippet: snippetAround(text || "", matchIndex),
    message,
  });
}

// ---------------------------------------------------------------------------
// Shared detectors — operate on a single logical string plus a (file,line)
// anchor so both front-matter values and body lines can reuse them.
// ---------------------------------------------------------------------------

// Mojibake: UTF-8 bytes decoded as Latin-1 then re-encoded. The tell-tale
// lead bytes are Â (U+00C2) and Ã (U+00C3) followed by another high char, and
// the classic curly-quote corruption â€™ / â€œ / â€ / â€“.
const MOJIBAKE_RE =
  /\u00E2\u20AC[\u2122\u0153\u201C\u201D\u2013\u2014\u00A6\u2026]?|\u00C3[\u0080-\u00BF]|\u00C2[\u0080-\u00BF\u00A0-\u00BF]/;

function checkMojibake(file, lineNo, text, anchorCol = 1) {
  const m = MOJIBAKE_RE.exec(text);
  if (m) {
    record(
      file,
      lineNo,
      anchorCol + m.index,
      HIGH,
      "mojibake",
      "Mojibake / mis-decoded UTF-8 sequence in text",
      text,
      m.index
    );
    return true;
  }
  return false;
}

// Broken HTML entities. A lone "&" used as the word "and" ("Air & Mac Mini",
// "Q&A", a query-string separator) is NOT a defect — it is valid text the SSG
// escapes on render. We flag only two unambiguous corruptions:
//
//   1. A *terminated* entity (& … ;) whose name is not valid — someone meant
//      an entity but mistyped it (e.g. &nsbp;, &amp ;). We require the ';' so
//      prose ampersands never match.
//   2. A *double-escaped* entity (&amp;amp; / &amp;lt; …) — the classic import
//      artifact where "&" was escaped twice and renders as visible "&amp;".
const DOUBLE_ESCAPE_RE = /&amp;(amp|lt|gt|quot|#\d+|#x[0-9a-fA-F]+);/g;
// A run "& … ;" with up to 31 name chars, then classify the name.
const TERMINATED_ENTITY_RE = /&(#x?[0-9a-zA-Z]{0,31}|[a-zA-Z][a-zA-Z0-9]{0,31});/g;
const VALID_ENTITY_RE = /^&(#[0-9]+|#x[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]{1,31});$/;

// Double-escape is a real defect anywhere it appears — including markdown
// source bodies (imported HTML) — because it renders literally as "&amp;…".
function checkDoubleEscape(file, lineNo, text, anchorCol = 1) {
  let m;
  DOUBLE_ESCAPE_RE.lastIndex = 0;
  while ((m = DOUBLE_ESCAPE_RE.exec(text)) !== null) {
    record(
      file,
      lineNo,
      anchorCol + m.index,
      HIGH,
      "bad-entity",
      "Double-escaped HTML entity (renders as visible '&amp;…')",
      text,
      m.index
    );
  }
}

// Full entity check (double-escape + malformed terminated entities). Safe for
// plain-text contexts (front-matter values, rendered <title>/<meta>, Output
// HTML) where a bare terminated-but-invalid entity is genuinely wrong. NOT run
// on markdown bodies, where '&' in prose/URLs is valid source.
function checkEntities(file, lineNo, text, anchorCol = 1) {
  let m;
  checkDoubleEscape(file, lineNo, text, anchorCol);
  TERMINATED_ENTITY_RE.lastIndex = 0;
  while ((m = TERMINATED_ENTITY_RE.exec(text)) !== null) {
    if (VALID_ENTITY_RE.test(m[0])) continue; // real entity — fine
    if (/^&amp;/.test(m[0])) continue; // already handled by double-escape pass
    record(
      file,
      lineNo,
      anchorCol + m.index,
      HIGH,
      "bad-entity",
      `Malformed HTML entity: ${m[0]}`,
      text,
      m.index
    );
  }
}

// HTML tags appearing inside a plain-text context (front-matter title/desc, or
// a rendered <title>/<meta> value). Matches an opening/closing tag shape.
const HTML_TAG_RE = /<\/?[a-zA-Z][a-zA-Z0-9]*(\s[^<>]*)?>/;

function checkTagInText(file, lineNo, text, where, anchorCol = 1) {
  const m = HTML_TAG_RE.exec(text);
  if (m) {
    record(
      file,
      lineNo,
      anchorCol + m.index,
      HIGH,
      "html-in-text",
      `Raw HTML tag inside ${where}`,
      text,
      m.index
    );
    return true;
  }
  return false;
}

// Literal escaped tag showing up as visible text, e.g. "&lt;p&gt;" that was
// double-escaped and will render the characters "<p>" to the reader.
const ESCAPED_TAG_RE = /&lt;\/?[a-zA-Z][a-zA-Z0-9]*(\s[^&]*)?&gt;/;

function checkEscapedTag(file, lineNo, text, anchorCol = 1) {
  const m = ESCAPED_TAG_RE.exec(text);
  if (m) {
    record(
      file,
      lineNo,
      anchorCol + m.index,
      HIGH,
      "escaped-tag",
      "Escaped tag/merge-field shows as literal text (e.g. <<First Name>>, <p>)",
      text,
      m.index
    );
  }
}

// Quote inconsistency (INFO): flag a straight ' or " used as an apostrophe /
// quote in prose. Only emitted with --quotes. We ignore code-ish contexts
// (lines inside fenced blocks are skipped by the caller).
const STRAIGHT_APOSTROPHE_RE = /[A-Za-z]'[A-Za-z]/; // don't, let's
function checkStraightQuotes(file, lineNo, text, anchorCol = 1) {
  const m = STRAIGHT_APOSTROPHE_RE.exec(text);
  if (m) {
    record(
      file,
      lineNo,
      anchorCol + m.index + 1,
      INFO,
      "straight-quote",
      "Straight apostrophe in prose (site elsewhere uses curly ’)",
      text,
      m.index + 1
    );
  }
}

// ---------------------------------------------------------------------------
// Markdown (Content/) scanning
// ---------------------------------------------------------------------------

// Minimal front-matter splitter. Returns {fm: {key: {value, line}}, bodyStart}.
// Handles simple `key: value` and YAML folded values that continue on indented
// following lines (Publish emits these for long descriptions).
function parseFrontMatter(lines) {
  const fm = {};
  if (lines[0] !== "---") return { fm, bodyStart: 0 };
  let i = 1;
  let lastKey = null;
  for (; i < lines.length; i++) {
    const line = lines[i];
    if (line === "---") {
      i++;
      break;
    }
    const kv = /^([A-Za-z][A-Za-z0-9_]*):\s?(.*)$/.exec(line);
    if (kv) {
      lastKey = kv[1];
      fm[lastKey] = { value: unquoteYaml(kv[2]), line: i + 1, raw: kv[2] };
    } else if (/^\s+\S/.test(line) && lastKey) {
      // Folded continuation line — append to the previous key's value.
      fm[lastKey].value += " " + line.trim();
    }
  }
  return { fm, bodyStart: i };
}

function unquoteYaml(v) {
  const t = v.trim();
  if (
    (t.startsWith("'") && t.endsWith("'") && t.length >= 2) ||
    (t.startsWith('"') && t.endsWith('"') && t.length >= 2)
  ) {
    return t.slice(1, -1);
  }
  return t;
}

function scanMarkdownFile(file) {
  const raw = fs.readFileSync(file, "utf8");
  const lines = raw.split("\n");
  const { fm, bodyStart } = parseFrontMatter(lines);

  // Front matter: title & description flow into <title>/<meta name="description">.
  for (const key of ["title", "description"]) {
    const entry = fm[key];
    if (!entry) continue;
    const val = entry.value;
    checkTagInText(file, entry.line, val, `front-matter '${key}'`);
    checkEntities(file, entry.line, val);
    checkMojibake(file, entry.line, val);
    if (opts.quotes) checkStraightQuotes(file, entry.line, val);
  }

  // Body: raw imported HTML lives here (episodes/newsletters). We do NOT flag
  // every HTML tag in the body — bodies are legitimately HTML — nor bare '&':
  // in *markdown source*, '&' in URLs and prose is valid and Publish escapes it
  // at render time (flagging it here produces hundreds of false positives on
  // query-string links). We only flag encoding defects that are wrong in the
  // source itself: mojibake and double-escaped tags that will ship as visible
  // literal markup. Bare-'&' / entity validity is checked in Output/ HTML,
  // where it genuinely indicates malformed output.
  let inFence = false;
  for (let i = bodyStart; i < lines.length; i++) {
    const line = lines[i];
    const lineNo = i + 1;
    if (/^\s*```/.test(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    checkMojibake(file, lineNo, line);
    checkEscapedTag(file, lineNo, line);
    checkDoubleEscape(file, lineNo, line); // &amp;amp; is wrong even in source
    if (opts.quotes) checkStraightQuotes(file, lineNo, line);
  }
}

// ---------------------------------------------------------------------------
// HTML (Output/) scanning — the rendered ground truth.
// ---------------------------------------------------------------------------

function extractTag(html, tagRe) {
  const m = tagRe.exec(html);
  return m ? { value: m[1], index: m.index } : null;
}

function lineOfIndex(html, index) {
  let line = 1;
  for (let i = 0; i < index && i < html.length; i++) {
    if (html[i] === "\n") line++;
  }
  return line;
}

function scanHtmlFile(file) {
  const html = fs.readFileSync(file, "utf8");

  // <title> — derived from front-matter title. Should be plain text.
  const title = extractTag(html, /<title[^>]*>([\s\S]*?)<\/title>/i);
  if (title) {
    const ln = lineOfIndex(html, title.index);
    checkEscapedTag(file, ln, title.value);
    checkTagInText(file, ln, decodeBasic(title.value), "<title>");
    checkMojibake(file, ln, title.value);
  }

  // <meta name="description"> — derived from front-matter description.
  const desc =
    extractTag(
      html,
      /<meta[^>]*name=["']description["'][^>]*content=["']([\s\S]*?)["'][^>]*>/i
    ) ||
    extractTag(
      html,
      /<meta[^>]*content=["']([\s\S]*?)["'][^>]*name=["']description["'][^>]*>/i
    );
  if (desc) {
    const ln = lineOfIndex(html, desc.index);
    checkEscapedTag(file, ln, desc.value);
    checkTagInText(file, ln, decodeBasic(desc.value), "<meta description>");
    checkMojibake(file, ln, desc.value);
  }

  // Whole-document sweep for mojibake and double-escaped entities/tags in
  // visible rendered text. Blank out <pre>/<code> regions first: escaped tags
  // there (e.g. a "&lt;p&gt;" code sample) are intentional, not defects.
  const lines = maskCodeRegions(html).split("\n");
  for (let i = 0; i < lines.length; i++) {
    checkMojibake(file, i + 1, lines[i]);
    checkEscapedTag(file, i + 1, lines[i]);
    checkDoubleEscape(file, i + 1, lines[i]);
  }
}

// Replace the inner text of <pre>…</pre> and <code>…</code> with spaces,
// preserving newlines (so line numbers stay accurate) and the tags themselves.
function maskCodeRegions(html) {
  return html.replace(
    /<(pre|code)\b[^>]*>[\s\S]*?<\/\1>/gi,
    (block) => block.replace(/[^\n]/g, " ")
  );
}

// Decode only the handful of entities that could hide a real tag, so that a
// legitimately-escaped &lt;p&gt; in an attribute is caught by checkEscapedTag
// while a genuinely raw <b> in a title is caught by checkTagInText.
function decodeBasic(s) {
  return s
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");
}

// ---------------------------------------------------------------------------
// Walking
// ---------------------------------------------------------------------------

function walk(dir, filterExt, out) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walk(full, filterExt, out);
    else if (e.isFile() && e.name.toLowerCase().endsWith(filterExt))
      out.push(full);
  }
}

// ---------------------------------------------------------------------------
// Reporting
// ---------------------------------------------------------------------------

// A finding belongs to the imported MailChimp newsletter archive if it lives in
// a Content/newsletters or Output/newsletters path.
function isNewsletter(f) {
  return /(^|\/)newsletters\//.test(f.file);
}

function report() {
  // Dedupe: the same defect can be seen twice (e.g. a <title> value is checked
  // both as an extracted field and again in the whole-document sweep). Collapse
  // findings that share file+line+kind, keeping the lowest column.
  const byKey = new Map();
  for (const f of findings) {
    const key = `${f.file}:${f.line}:${f.kind}`;
    const prev = byKey.get(key);
    if (!prev || f.col < prev.col) byKey.set(key, f);
  }
  let deduped = [...byKey.values()];

  // By default suppress the imported newsletter archive (low-priority MailChimp
  // cruft — merge fields like <<First Name>>). Count what we drop so the
  // suppression is never silent. --newsletters includes them.
  const newsletterCount = deduped.filter(isNewsletter).length;
  if (!opts.newsletters) deduped = deduped.filter((f) => !isNewsletter(f));

  const shown = deduped.filter((f) => f.severity === HIGH || opts.quotes);
  shown.sort(
    (a, b) => a.file.localeCompare(b.file) || a.line - b.line || a.col - b.col
  );

  let currentFile = null;
  for (const f of shown) {
    if (f.file !== currentFile) {
      currentFile = f.file;
      console.log(`\n${currentFile}`);
    }
    const tag = f.severity === HIGH ? "  ✗" : "  ·";
    console.log(
      `${tag} ${f.line}:${f.col} [${f.kind}] ${f.message}` +
        (f.snippet ? `\n        ↳ ${f.snippet}` : "")
    );
  }

  const high = deduped.filter((f) => f.severity === HIGH).length;
  const info = deduped.filter((f) => f.severity === INFO).length;

  console.log("\n" + "─".repeat(60));
  if (high === 0 && (info === 0 || !opts.quotes)) {
    console.log("Content check completed successfully (0 issues)");
  } else {
    const parts = [`${high} issue(s)`];
    if (opts.quotes) parts.push(`${info} style note(s)`);
    console.log(`Content check completed with ${parts.join(", ")}`);
  }
  if (!opts.newsletters && newsletterCount > 0) {
    console.log(
      `(${newsletterCount} finding(s) in the imported newsletter archive ` +
        `suppressed — re-run with --newsletters to include them.)`
    );
  }
  return { high, info };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function main() {
  // 1) Output/ first — the rendered ground truth of what ships.
  if (fs.existsSync(OUTPUT_DIR)) {
    const htmlFiles = [];
    walk(OUTPUT_DIR, ".html", htmlFiles);
    console.log(`Scanning Output/ (${htmlFiles.length} HTML file(s))…`);
    for (const f of htmlFiles) scanHtmlFile(f);
  } else {
    console.log(
      "Output/ not found — skipping rendered-HTML scan.\n" +
        "  Build it first with:  swift run brightdigitwg publish --mode production"
    );
  }

  // 2) Content/ sources — locate where defects originate.
  const mdFiles = [];
  for (const sub of CONTENT_SUBDIRS) {
    walk(path.join(CONTENT_DIR, sub), ".md", mdFiles);
  }
  console.log(`Scanning Content/ (${mdFiles.length} markdown file(s))…`);
  for (const f of mdFiles) scanMarkdownFile(f);

  const { high } = report();
  process.exit(opts.strict && high > 0 ? 1 : 0);
}

main();
