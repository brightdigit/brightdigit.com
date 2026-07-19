# Memory Index

This is an **index only** — one line per memory in the form `- [Title](path) — hook`.
The actual memory content lives in the linked file: urgent/broad facts in `AGENTS.md`
(always loaded at launch), lower-urgency facts in a file under `.Codex/` (loaded on demand).
Never put full memory content here. See the "Memory & Corrections Convention" section of
`AGENTS.md` for the rules.

- [Memory & Corrections Convention](AGENTS.md) — how repo memory and the corrections log work
- [Files canonical path form](.Codex/files-windows-path-canonical-form.md) — Files stores paths as forward-slash internally, native only at FileManager boundary (Windows support); helpers in Sources/Path.swift are no-ops off Windows
- [Subrepo platform and OS support](.Codex/subrepo-platform-support.md) — all 20 packages' Apple deployment minimums, full CI OS/target versions, and disabled watchOS/Wasm/visionOS legs
