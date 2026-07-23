---
name: brightdigit-badge-service-integration
description: Status of qlty/Codecov/CodeFactor badge service integration across the 5 v1.0.0 dep repos, and how each is wired
metadata:
  type: project
---

Badge-service integration status for the five v1.0.0 dependency repos (as of 2026-07-22),
from the README badge unification work ([[syndikit-workflow-case-branch-divergence]],
[[buttondownkit-no-logo-brand-policy]]):

- **SPI** (Swift versions / platforms): live for all five. Dynamic, never stale.
- **qlty**: live for all five (`qlty.sh/gh/brightdigit/projects/<Repo>/maintainability.svg`).
  SwiftTube + Contribute were 404 until added as qlty projects on 2026-07-22.
- **Codecov**: only SyndiKit was live (83%). The four Wave-0 repos (ButtondownKit, SwiftTube,
  Contribute, Spinetail) showed "unknown" **even though their CI already runs
  `codecov/codecov-action@v7` with `token: ${{ secrets.CODECOV_TOKEN }}` (3 jobs each)**.
  Root cause: the org `CODECOV_TOKEN` secret existed but was wrong/stale. Fixed 2026-07-22 by
  setting the org-level Actions secret `CODECOV_TOKEN` (visibility=all) to the correct global
  upload token. Badges only refresh after CI RE-RUNS post-token-update — a token change does
  nothing until the next workflow run uploads with it.
- **CodeFactor**: live for Spinetail (B+) and SyndiKit (A). ButtondownKit/SwiftTube/Contribute
  show "not found". **This is a CodeFactor-side dashboard bug, NOT a GitHub permission issue** —
  verified: the CodeFactor App (install id 9285228) is unsuspended with `repository_selection:
  all`, the repos are public, and toggling repo access fired the webhook (install updated_at
  bumped) but did NOT auto-create the projects. CodeFactor's dashboard redirects org members to
  the GitHub install-settings page and all deep-links 404, so the "Add repository" UI can't be
  reached. Granting repo access is necessary but NOT sufficient — a repo must be explicitly added
  as a project in CodeFactor's UI, which is what's broken. Likely needs a CodeFactor support
  ticket. Decision: keep the CodeFactor badge on all repos for now (per Leo).

Setting org Actions secrets: `printf '%s' '<value>' | gh secret set NAME --org brightdigit
--visibility all --body -` (pipe via stdin so the secret never hits the command line / shell
history). Requires `admin:org` token scope.
