# Memory Index

This is an **index only** — one line per memory in the form `- [Title](path) — hook`.
The actual memory content lives in the linked file: urgent/broad facts in `AGENTS.md`
(always loaded at launch), lower-urgency facts in a file under `.claude/memory/` (loaded on
demand). Never put full memory content here. See the "Memory & Corrections Convention"
section of `AGENTS.md` for the rules.

- [Memory & Corrections Convention](AGENTS.md) — how repo memory and the corrections log work
- [Branch dependency release checkpoint](.claude/memory/dependency-release-checkpoint.md) — Packages absent; Wave 0 on `v1.0.0` branches, Wave 1/2 on `brightdigit-com-*` until tags; see MERGE-AND-TAG.md
- [Files canonical path form](.claude/memory/files-windows-path-canonical-form.md) — Files stores paths as forward-slash internally, native only at FileManager boundary (Windows support); helpers in Sources/Path.swift are no-ops off Windows
- [Subrepo platform and OS support](.claude/memory/subrepo-platform-support.md) — all 20 package repositories' Apple deployment minimums, full CI OS/target versions, and disabled watchOS/Wasm/visionOS legs
- [README badge audit](docs/readme-badge-audit.md) — v1.0.0 dep README badges: only 5 repos have v1.0.0 branches; Spinetail codeql badge 404 + codecov "unknown", SyndiKit CI case typo; unified template from SyndiKit/MistKit/SundialKit
