# Agent Notes — Corrections & Standing Directives

This file is the running log of Leo's corrections and standing **always/never** directives
for this repo. It is the source of truth for *how* to work here.

**Read this file at the start of every work session, before doing any work.**

**Append one line per directive, proactively (without being asked), whenever Leo makes a
correction or gives an always/never instruction.** Newest lines go at the bottom. Keep each
entry to a single line; if a directive supersedes an earlier one, update or remove the stale line
rather than leaving both.

---

<!-- Append directives below, one per line. Example:
- Always run ./Scripts/lint.sh before committing; never call swiftlint directly.
-->
- Phase 5: `phase-05` is the integration BASE branch — all Phase 5 worktrees branch from it and all Phase 5 PRs target it; never commit directly on `phase-05`.
- TailwindKit (#69) targets Tailwind v4 ONLY; the v2→v4 site migration is a separate worktree done before #67 so #67 stays a byte-identical structural refactor.
- Newsletter archive fixes go to Buttondown ONLY via the #127 one-shot (source = Mailchimp through the rebuilt Spinetail, NOT deprecated ContributeMailchimp); do not rewrite local Content/newsletters/*.md.
- Phase 5 source of truth: `docs/phase5-worktree-plan.md` OVERRIDES the GitHub issue/milestone/PRD bodies wherever they disagree (several are stale, e.g. "Swift 6.3" refs — toolchain is 6.4).
- Phase 5 PRs: worktree agents may push their branch and open a PR with base `phase-05`, but NEVER merge — Leo reviews, approves, and merges every PR himself.
- Subrepos: pull/push everything with `git subrepo pull --all` / `git subrepo push --all` (tree must be clean). `--all` aborts on the first failure — the usual cause is a stale `.gitrepo` parent after a squash-merge/rebase; recover by running `./fix-subrepo-parents.sh` (resets all parents to HEAD, commits), then re-run.
