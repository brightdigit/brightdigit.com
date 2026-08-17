# CI deploy: netlify-cli decoupled from the build image

## The outage (2026-08-05 → 2026-08-17)

Every scheduled CI run failed for ~13 days. Exactly one job failed — `deploy` — at
exactly one step, `Deploy to Netlify`:

```
/__w/_temp/….sh: 1: netlify: not found
##[error]Process completed with exit code 127.
```

Everything else was green. The site generated fine (`✅ Successfully published
BrightDigit`, all 13 steps); only the upload to Netlify failed. Production was not
deployed for the whole window.

## Root cause

`netlify-cli` was never installed by the workflow. It came from the last layer of
`Dockerfile` (`RUN npm i -g --unsafe-perm=true netlify-cli`), so the deploy silently
depended on the build image. `brightdigit/publish-xml:6.4` was rebuilt and pushed
**without that layer**, and deploys died from the next run on.

Timeline — no repo commit is involved; `main` sat at `32f5ce1` from 2026-07-28:

| Event | UTC |
|---|---|
| Last green run (30944916240) | 2026-08-04 19:47:56 |
| `publish-xml:6.4` pushed to Docker Hub | 2026-08-04 21:09:10 |
| First red run (30972128856) | 2026-08-05 03:23:41 |

Confirmed by registry layer inspection: `6.3` (working era) has 5 post-base `RUN`
layers ending in a **212 MB** netlify-cli layer; `6.4` has only **4** and no netlify
layer at all. At the time of diagnosis the committed `Dockerfile` still had the line —
only the pushed image had lost it.

## Fix

Install a pinned CLI in the workflow instead, with `~/.npm` cached:

```yaml
- uses: actions/cache@v5
  with: { path: ~/.npm, key: netlify-cli-27-${{ runner.os }} }
- run: |
    npm i -g netlify-cli@27
    netlify deploy --site … --auth … $PROD_FLAG
```

The deploy no longer depends on the image shipping a CLI, so a base-image rebuild
cannot take the site down this way again.

`RUN npm i -g --unsafe-perm=true netlify-cli` was then **deleted from both
`Dockerfile` and `Dockerfile.arm64v8`** (replaced by a comment saying why), so the
images no longer claim to provide a CLI nothing consumes. **Do not add it back** —
that is what coupled deploys to the image in the first place. Node/npm stay in the
images: the publish pipeline's final step shells out to npm to build `Styling/`.

`PUBLISHING_MODE`/`PROD_FLAG` were also hoisted from a per-job `$GITHUB_ENV` step to
workflow-level `env:`, derived from `github.ref_name` with a ternary. `$GITHUB_ENV`
is job-scoped, so the old step had to be repeated in any job needing the values.

## Alternatives investigated and rejected

Do not re-litigate these without new information:

- **`netlify/actions/cli`** (Netlify's own action) — `cli/Dockerfile` is
  `FROM node:22-alpine` + **unpinned** `npm install -g netlify-cli`, with no image
  published to any registry, so GitHub **builds it on every run** (users report
  +30–50s). `entrypoint.sh` still uses the deprecated `::set-output`, and
  `cli/action.yml` 404s. Unmaintained; `LABEL version="2.0.0"` vs. CLI 27.x.
- **A Netlify Docker image** — there isn't one. Docker Hub has no official
  `netlify/cli`; `netlify/build` is Netlify's internal SHA-tagged build image, and
  every other `*/netlify` match is a 0-star personal image last pushed 2019–2022.
- **Our own `brightdigit/netlify-cli` image** — viable, but recreates the exact
  mutable-tag drift that caused this outage unless pinned by digest, for ~20s saved.
- **`nwtgck/actions-netlify`** (v3.0.0, maintained) — fastest option (JS action, no
  install), but a third-party action would hold `NETLIFY_AUTH_TOKEN`. Pin by commit
  SHA if ever adopted.
- **`runs-on: ubuntu-22.04`** — has Netlify CLI 27.1.1 preinstalled, but 24.04
  (`ubuntu-latest`) does **not**; pinning to the older image just defers the problem.
- **Netlify zip REST API** — no node needed, but uploads all ~110 MB every run,
  losing the CLI's digest-diff. Usually *slower* end-to-end for content-only changes.

## Known remaining structural issue

`deploy` still runs in `brightdigit/publish-xml:6.4` because the preceding
`Run Brightdigitwg` step executes a dynamically-linked Swift binary (no
`--static-swift-stdlib`; see the issue #65 ABI-drift segfault noted at
`main.yaml:249`). The job therefore does two unrelated things. Splitting it —
`generate` in the container uploading `Output/` as an artifact, `deploy` on bare
`ubuntu-latest` — would remove the container from deploy entirely, at the cost of a
~110 MB artifact round-trip. The `env:` hoist above already removed the one blocker
that split would otherwise have hit.

## Note

All container jobs use the mutable tag `brightdigit/publish-xml:6.4`. `detect-changes`
already resolves the image digest, but only for **cache keys** — nothing pins the
container itself. That is why an out-of-band image rebuild broke CI with zero repo
changes.
