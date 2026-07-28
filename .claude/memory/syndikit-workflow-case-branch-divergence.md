---
name: syndikit-workflow-case-branch-divergence
description: SyndiKit CI workflow filename case differs between main (syndikit.yml) and v1.0.0 (SyndiKit.yml); audit/fix against v1.0.0
metadata:
  type: project
---

SyndiKit's CI workflow **filename casing changed between branches**:
- `main`: `.github/workflows/syndikit.yml` (lowercase) — badge points here, renders "passing".
- `v1.0.0`: `.github/workflows/SyndiKit.yml` (PascalCase, matching the other Wave 0 repos) —
  but the `v1.0.0` README badge still says `syndikit.yml`, so on `v1.0.0` the CI badge is
  **case-broken** ("no status" on the exact-case CDN path).

**When auditing/fixing SyndiKit READMEs, use the `v1.0.0` branch, not `main`** — the README
badge audit (`.claude/docs/readme-badge-audit.md`) originally read `main` and drew the wrong
conclusion ("badge already correct, don't touch case"). On `v1.0.0` the fix is: badge
`syndikit.yml` → `SyndiKit.yml` (case) AND drop the stray `?` in `&?branch=main`. Do NOT
revert the `v1.0.0` file's PascalCase — it's the correct, consistent name.

Related: the v1.0.0 README badge unification work across ButtondownKit/SwiftTube/Contribute/
Spinetail/SyndiKit — all five ship on `v1.0.0`. See [[dependency-release-checkpoint]].
