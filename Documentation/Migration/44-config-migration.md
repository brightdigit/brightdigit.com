# Issue #44 — Replace swift-argument-parser with swift-configuration

**Status:** Spike + first slice implemented (`url podcast`). The approach is
**validated for option-based commands**, with documented gaps for `--help`
parity, positional arguments, and nested subcommand dispatch.

> **DECISION REQUIRED — macOS platform floor raised to 15.**
> `ConfigKeyKit 1.0.0-beta.1` declares `platforms: [.macOS(.v15), .iOS(.v18), …]`.
> The project previously targeted `.macOS(.v13)`. SwiftPM rejects this on macOS
> (Linux is unaffected — swift-configuration has no platform floor and the deploy
> target is the Linux container). To keep local macOS builds/lint working,
> `Package.swift` now declares `.macOS(.v15)`. **This is a shared line and a real
> behavior change** (local dev now requires macOS 15+). If that floor is not
> acceptable, the alternative is to drop ConfigKeyKit and hand-roll the (small)
> command/key layer on top of swift-configuration alone, which has no platform
> floor. Flagging for sign-off.

## Approach

Pair two Foundation-only / Apple libraries to cover what
`swift-argument-parser` does today:

- **`brightdigit/ConfigKeyKit` (`1.0.0-beta.1`)** — the CLI/command layer.
  - `Command` protocol (`commandName`, `abstract`, `helpText`, `execute()`).
  - `CommandRegistry` actor for flat dispatch keyed on `commandName`.
  - `CommandLineParser` (thin: `parseCommandName()`, `commandArguments()`,
    `isHelpRequested()`).
  - `ConfigurationParseable` — async-throwing init from a `ConfigReader`.
  - `ConfigKey` / `OptionalConfigKey` — map ONE base name onto both a CLI flag
    (`.commandLine`) and an env var (`.environment`, `SCREAMING_SNAKE` with an
    optional prefix). Defaults live on `ConfigKey`; `OptionalConfigKey` has no
    default (used for required options).
- **`apple/swift-configuration` (`>= 1.0.0`, trait `CommandLineArguments`)** —
  the resolution layer.
  - `ConfigReader(providers:)` layers providers, **first provider wins**.
  - `CommandLineArgumentsProvider()` parses `--key value`, `--key=value`,
    `--flag`, repeated/comma arrays. **Opt-in trait** (`JSON` is the only
    default trait), so the dependency is declared
    `traits: [.defaults, "CommandLineArguments"]`.
  - `EnvironmentVariablesProvider()` reads env vars.
  - Read with `reader.string(forKey:default:)`, `reader.int(forKey:)`,
    `requiredString(forKey:)` (throws), etc. Keys are dotted/array components,
    kebab-cased for CLI matching.

Resolution precedence in this project: **CLI args > environment > per-key
default**, achieved by ordering providers `[CommandLineArgumentsProvider(),
EnvironmentVariablesProvider()]` and falling back to `ConfigKey.defaultValue`.

## Command / option mapping

`brightdigitwg` (root, ArgumentParser today) → subcommands:

### `publish`  (ArgumentParser → ConfigKeyKit Command)
| ArgumentParser | ConfigKey base | Type | Notes |
|---|---|---|---|
| `@Option mode` (required enum drafts/production) | `mode` | enum via `ExpressibleByConfigString` or string + validate | required → `OptionalConfigKey` + throw on nil |

### `import` (parent; subcommands `wordpress`, `podcast`, `mailchimp`)
`import wordpress`:
| ArgumentParser | ConfigKey base | Type | Notes |
|---|---|---|---|
| `@Argument wordpressExportsDirectory` (required, positional) | — | String | **GAP: positional args unsupported by CLI provider** (see below) |
| `@Option importAssetsDirectory?` | `import-assets-directory` | String? | `OptionalConfigKey` |
| `@Option assetRelativePath = "media/wp-images"` | `asset-relative-path` | String | `ConfigKey` default |
| `@Flag overwriteAssets` | `overwrite-assets` | Bool | `ConfigKey<Bool>` (default false) |
| `@Flag skipDownload` | `skip-download` | Bool | `ConfigKey<Bool>` |

`import podcast`:
| ArgumentParser | ConfigKey base | Type | Notes |
|---|---|---|---|
| `@Option playlistID = "PLmpJx…"` | `playlist-id` | String | default |
| `@Option youtubeAPIKey` (required) | `youtube-api-key` | String | required → `OptionalConfigKey` + throw; ideal env candidate `YOUTUBE_API_KEY` |
| `@Option rss = <transistor URL>` | `rss` | URL | default; parse from String |
| `@Option exportMarkdownDirectory` (required) | `export-markdown-directory` | String | required |
| `@Flag overwriteExisting` | `overwrite-existing` | Bool | |
| `@Flag includeMissingPrevious` | `include-missing-previous` | Bool | |

`import mailchimp` (DEPRECATED — recommend deleting rather than migrating):
`export-markdown-directory`, `mailchimp-api-key`, `mailchimp-list-id` (all
required), `overwrite-existing`, `include-missing-previous` flags.

### `url` (parent; subcommand `podcast`) — **MIGRATED THIS SLICE**
| ArgumentParser | ConfigKey base | Type | Notes |
|---|---|---|---|
| `@Option baseURL = SiteInfo.url` | `base-url` | URL | `ConfigKey` default; parsed from String |
| `@Option basePath = SectionID.episodes` | `base-path` | String | `ConfigKey` default |
| `@Option episodeNumber` (required) | `episode-number` | Int | `OptionalConfigKey<Int>` + throw on nil |
| `@Option episodeTitle` (required) | `episode-title` | String | `OptionalConfigKey<String>` + throw on nil |

All `url podcast` inputs are `--key value` options with no positional args, so
this subcommand migrates cleanly and was chosen as the first slice. Each option
also gains an env var (`EPISODE_NUMBER`, etc.) for free.

## `--help` / usage-text parity — VERDICT

**Parity is NOT automatic. ArgumentParser auto-generates usage, option lists,
value names, and validation messages; neither ConfigKeyKit nor
swift-configuration generate ANY of that.**

What the new stack provides:
- ConfigKeyKit `Command` carries hand-written `abstract` + `helpText` strings
  and a `printHelp()` that just `print(helpText)`.
- `CommandLineParser.isHelpRequested()` returns a `Bool` for `--help`/`-h`/`help`
  (it prints nothing itself).
- swift-configuration has no help/usage concept at all.

**Consequences / gap-closing plan (decide before completing the full migration):**

1. **Hand-written help per command.** Acceptable for this small, internal CLI
   (used in CI + by the maintainer). Each migrated `Command` ships a `helpText`
   string mirroring ArgumentParser's format. Implemented for `url podcast`.
   *Risk:* help text can drift from the actual keys since it is not derived from
   them. Mitigation: keep keys + help in the same file; optionally add a test
   that asserts every `ConfigKey` base name appears in `helpText`.

2. **Positional `@Argument` is unsupported** by `CommandLineArgumentsProvider`
   (it only understands `--flag`/`--key value`). `import wordpress` takes a
   positional `wordpressExportsDirectory`. Options to close the gap:
   - Promote it to a named option `--wordpress-exports-directory` (behavior
     change for callers — needs sign-off), **or**
   - Pre-parse the leading positional from argv in the dispatcher and inject it
     via an `InMemoryProvider` layered into the `ConfigReader`.

3. **Nested subcommands.** ConfigKeyKit's registry is flat (one level keyed by
   `commandName`); the current tree is 2–3 levels (`import wordpress`,
   `url podcast`). Plan: encode the full path as the command name
   (`commandName = "url podcast"`) and dispatch on the joined argv prefix. This
   slice's `ConfigCommandDispatcher` does exactly that (matches argv `["url",
   "podcast"]`). A small custom dispatcher replaces ArgumentParser's automatic
   tree; top-level `--help` listing all subcommands must also be hand-written.

4. **No automatic "missing required option" / type-mismatch diagnostics.** We
   throw `URLPodcastError.missingRequiredOption("--episode-number")` etc.
   manually. Acceptable, but every required option needs an explicit guard.

**Overall verdict:** the approach is sound and worth pursuing for this CLI.
Option resolution (incl. env-var fallback, which ArgumentParser did NOT provide)
is strictly better. The cost is hand-written help + a hand-written dispatcher +
handling positional args specially. None of these block the migration; they are
mechanical. Recommend proceeding subcommand-by-subcommand, deleting deprecated
`mailchimp`, and resolving the `wordpress` positional via the named-option route
(pending maintainer sign-off).

## First slice implemented

- `Sources/BrightDigitArgs/Config/URLPodcastCommand.swift` — `url podcast` as a
  ConfigKeyKit `Command` + swift-configuration `ConfigReader`.
- `Sources/BrightDigitArgs/Config/ConfigCommandDispatcher.swift` — argv router;
  handles `url podcast` (incl. `--help`), else returns false to fall back.
- `Sources/brightdigitwg/BrightDigitWG.swift` — tries the dispatcher first.
- `Package.swift` — adds `ConfigKeyKit` + `swift-configuration`
  (`CommandLineArguments` trait) to `BrightDigitArgs`. `swift-argument-parser`
  is RETAINED because `publish`, `import`, and the `url` parent still use it.

The legacy `URLCommand.Podcast` ArgumentParser definition is intentionally left
in place during the incremental migration; the dispatcher intercepts `url
podcast` before ArgumentParser runs, so the two do not conflict. It is removed
once the full `url` subtree is migrated.
