# Memory Index

This is an **index only** — one line per memory in the form `- [Title](path) — hook`.
The actual memory content lives in the linked file: urgent/broad facts in `AGENTS.md`
(always loaded at launch), lower-urgency facts in a file under `.claude/memory/` (loaded on
demand). Never put full memory content here. See the "Memory & Corrections Convention"
section of `AGENTS.md` for the rules.

- [Memory & Corrections Convention](AGENTS.md) — how repo memory and the corrections log work
- [Branch dependency release checkpoint](.claude/memory/dependency-release-checkpoint.md) — Packages absent; Wave 0 on `main` (all consumers repinned), Wave 1/2 on `brightdigit-com-*` until merged/tagged; see MERGE-AND-TAG.md
- [Files canonical path form](.claude/memory/files-windows-path-canonical-form.md) — Files stores paths as forward-slash internally, native only at FileManager boundary (Windows support); helpers in Sources/Path.swift are no-ops off Windows
- [Subrepo platform and OS support](.claude/memory/subrepo-platform-support.md) — all 20 package repositories' Apple deployment minimums, full CI OS/target versions, and disabled watchOS/Wasm/visionOS legs
- [README badge audit](.claude/docs/readme-badge-audit.md) — v1.0.0 dep README badges: only 5 repos have v1.0.0 branches; Spinetail codeql badge 404 + codecov "unknown", SyndiKit `v1.0.0` CI badge case-broken (points at `syndikit.yml`, file is `SyndiKit.yml`); unified template from SyndiKit/MistKit/SundialKit
- [SyndiKit workflow case branch divergence](.claude/memory/syndikit-workflow-case-branch-divergence.md) — SyndiKit CI workflow file is `syndikit.yml` on `main` but `SyndiKit.yml` on `v1.0.0`; audit/fix READMEs against the ship branch (`v1.0.0`)
- [ButtondownKit no-logo brand policy](.claude/memory/buttondownkit-no-logo-brand-policy.md) — ButtondownKit README/DocC has NO logo FOR NOW (Buttondown brand guidelines forbid their mark); interim, pending a compliant original mark
- [BrightDigit badge service integration](.claude/memory/brightdigit-badge-service-integration.md) — qlty/Codecov/CodeFactor status across 5 v1.0.0 repos; org CODECOV_TOKEN fixed 2026-07-22; CodeFactor onboarding blocked on their dashboard bug (not GitHub)
- [Wave 1 hygiene pass + Contribute 6.4](.claude/memory/wave1-hygiene-pass.md) — 2026-07-23/24: 7 Wave 1 repos to Wave 0 standard; un-deprecated YouTube/Mailchimp + tests; Contribute→6.4 (#19) exposed a real ContributeWordPress data race (#18, must land together); Plot/Files/Ink missing CLAUDE_CODE_OAUTH_TOKEN secret; SyndiKit has no macOS-platforms job
