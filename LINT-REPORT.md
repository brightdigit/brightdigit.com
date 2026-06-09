# Lint Migration — Failure Report (Issue #54)

Generated against the **pristine codebase** with the newly migrated configs
(`.swiftlint.yml`, `.swift-format`). No source fixes have been applied — the source tree
is untouched; only the config/script/CI deliverables are in the working tree.

- **Tooling:** swiftlint `0.63.2`, swift-format `604.0.0-prerelease-2025-12-17` (via mise)
- **Scope linted:** `Sources/` + `Tests/` (vendored `Packages/` excluded). 104 Swift files.

## Headline numbers

| Tool | Total findings | Errors | Warnings | Files affected |
|------|---------------:|-------:|---------:|---------------:|
| SwiftLint | **1097** | 206 | 891 | 104 / 104 |
| swift-format (lint) | **522** | 0 | 522 | 91 / 104 |

The two tools overlap heavily (whitespace, indentation, imports, line length, force-unwrap,
ACL-on-extension). Running `swift-format format` first collapses most of both counts.

## Where the SwiftLint findings live (per module)

| Module | Findings |
|--------|---------:|
| BrightDigitSite | 697 |
| BrightDigitArgs | 97 |
| PublishType | 85 |
| BrightDigitPodcast | 54 |
| ContributeYouTube | 51 |
| ContributeMailchimp | 51 |
| ContributeRSS | 39 |
| Tagscriber | 10 |
| brightdigitwg | 4 |
| Tests | 5 |

---

## SwiftLint findings by rule

### A. Library-API rules (the bulk — 556 findings, all manual)
These fire because the app's SPM modules expose ~351 `public`/`open` declarations to cross
module boundaries. They are the standard for a *published library*; this is an internal app.

| Rule | Count | Sev | What it wants | Note |
|------|------:|-----|---------------|------|
| `explicit_acl` | 362 | warn | explicit `internal`/`private`/`public` on every decl | add modifiers to ~362 decls |
| `missing_docs` | 158 | warn | doc comment on every `public`/`open` decl | author ~158 doc comments |
| `explicit_top_level_acl` | 30 | error | explicit ACL on top-level decls | subset of the ACL work |
| `lower_acl_than_parent` | 6 | warn | members ≤ parent's ACL | all in `BrightDigitArgs/URLCommand.swift` |

### B. Member ordering (manual, high churn)
| Rule | Count | Sev | Note |
|------|------:|-----|------|
| `type_contents_order` | 126 | warn | reorder members (cases → props → init → methods, etc.) |
| `file_types_order` | 5 | warn | reorder top-level types within a file |

### C. Line length (177 — partly mechanical)
| Rule | Count | Sev | Note |
|------|------:|-----|------|
| `line_length` | 177 | mixed | limit 90. **Config tension:** swift-format wraps at **100**, so after formatting, lines of 91–100 chars still fail SwiftLint. Resolve by aligning the two (set swift-format `lineLength: 90`, or SwiftLint `line_length: 100`). |

### D. Mechanical / auto-correctable (≈ 115 — fixed by `swift-format format` + `swiftlint --fix`)
| Rule | Count | Rule | Count |
|------|------:|------|------:|
| `trailing_whitespace` | 34 | `closure_end_indentation` | 2 |
| `indentation_width` | 26 | `multiline_literal_brackets` | 2 |
| `sorted_imports` | 21 | `comma` | 1 |
| `colon` | 18 | `comment_spacing` | 1 |
| `vertical_whitespace_closing_braces` | 8 | `collection_alignment` | 1 |
| `vertical_whitespace` | 8 | `closure_spacing` | 1 |
| `vertical_whitespace_opening_braces` | 3 | `implicit_return` | 1 |
| `number_separator` | 3 | `joined_default_parameter` | 1 |

(`multiline_arguments_brackets` 30 and `multiline_function_chains` 5 are formatting-style but
**not** SwiftLint-autocorrectable; swift-format addresses most via `AddLines`/wrapping.)

### E. Real correctness / structure signal (manual — worth fixing regardless of strategy)
| Rule | Count | Sev | Detail |
|------|------:|-----|--------|
| `force_unwrapping` | 10 | warn | 10 `!` force-unwraps — see list below |
| `function_body_length` | 10 | mixed | functions 37–59 lines (limit 35/50) |
| `identifier_name` | 9 | warn | short names: `h1`, `p1`, `p2`, `p3`, `me` (Plot DSL helpers) |
| `type_body_length` | 4 | warn | `PodcastItem` 332, `PostItem` 173, `ProductItem` 140, `NewsletterItem` 130 |
| `one_declaration_per_file` | 3 | warn | multiple top-level types in one file |
| `cyclomatic_complexity` | 2 | error | `ContributeRSS/Source.swift` (9), `Mailchimp.swift` (7) |
| `empty_count` / `empty_string` | 2 / 2 | warn | prefer `.isEmpty` |
| `implicitly_unwrapped_optional` | 1 | warn | `ContributeYouTube/Prch.APIClient.Podcast.swift:19` |
| `file_length` | 1 | error | `PodcastItem.swift` = 374 lines (limit 300) |
| `convenience_type` | 1 | warn | caseless enum recommended over struct |
| `blanket_disable_command` | 3 | warn | pre-existing blanket disables in **`Package.swift`** (see note) |

### F. `file_name` (19 errors) — file name ≠ declared type
The repo uses a dotted `Outer.Inner.swift` convention that the rule rejects. Either rename the
files, or configure the rule. Affected files:
```
BrightDigitSite/SectionItem.Content.swift
BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift
BrightDigitSite/Plugins/YAMLStringFix.swift
BrightDigitSite/Testimonials/{AssetHealth.HR, AssetHealth.TG, CMC.Ed, CMC.Flick,
  ArborMoon.Dave, ConferencesIO.Dave, Jody, DavidSmit, DerekDeJonghe}.swift
BrightDigitArgs/Import/PodcastCommand.swift
BrightDigitArgs/Import/WordPress.Settings.swift
ContributeYouTube/{Prch.APIClient.Podcast, ContributeYouTube+Write}.swift
ContributeMailchimp/{Source.Campaign, Prch.APIClient.Newsletter}.swift
ContributeRSS/ContributeRSS+Write.swift
```

### `force_unwrapping` locations (10)
```
PublishType/ItemContent.swift:7
BrightDigitSite/Nodes/Social/SocialQueryItemsShare.swift:12
BrightDigitSite/Nodes/Social/TwitterSocialShare.swift:6
BrightDigitSite/Nodes/Social/BufferSocialShare.swift:5
BrightDigitSite/Nodes/Social/EmailSocialShare.swift:5
BrightDigitSite/Nodes/Social/LinkedInSocialShare.swift:5
BrightDigitSite/Nodes/Section/ProductItem.swift:17
BrightDigitSite/Nodes/Section/PodcastItem.swift:297
BrightDigitArgs/Import/PodcastCommand.swift:39
ContributeMailchimp/Newsletter.swift:15
```

### `function_body_length` / `type_body_length` / `cyclomatic_complexity` offenders
```
PodcastItem.swift            file 374 / type body 332          (file_length, type_body_length)
PostItem.swift               type body 173
ProductItem.swift            type body 140 / init 47
NewsletterItem.swift         type body 130
PiHTMLFactory.HTML.swift     funcs 54, 53, 37
ServicesBuilder.swift        func 58
SectionElement.swift         init 59
ContactBuilder.swift         func 44
KannaMarkdownGenerator.swift func 58
YouTubeContent.swift         func 38
Prch.APIClient.Podcast.swift func 39
ContributeRSS/Source.swift   complexity 9
Import/Mailchimp.swift       complexity 7
```

---

## swift-format findings by rule (all auto-fixed by `swift-format format`)
| Rule | Count | Rule | Count |
|------|------:|------|------:|
| `LineLength` | 138 | `RemoveLine` | 8 |
| `Indentation` | 130 | `URLQueryItem`* | 8 |
| `AddLines` | 57 | `AlwaysUseLiteralForEmptyCollectionInit` | 4 |
| `NoAccessLevelOnExtensionDeclaration` | 56 | `YouTubeVideo`* | 3 |
| `TrailingWhitespace` | 33 | `OneVariableDeclarationPerLine` | 2 |
| `Spacing` | 32 | `ReplaceForEachWithForLoop` | 1 |
| `TrailingComma` | 20 | `NeverUseImplicitlyUnwrappedOptionals` | 1 |
| `OrderedImports` | 19 | `BeginDocumentationCommentWithOneLineSummary` | 1 |
| `NeverForceUnwrap` | 10 | `DoNotUseSemicolons` | 10 |

\* `URLQueryItem` / `YouTubeVideo` here are type-name tokens picked up by the rule grouping,
not rule names — included for completeness.

Note `NoAccessLevelOnExtensionDeclaration` (56): swift-format wants `public` *moved off the
extension onto each member*, which directly increases the `explicit_acl` surface — another
reason categories A and the formatter interact.

---

## Auto-fixable vs manual (summary)

- **Auto-fixable now** (`swift-format format --in-place` + `swiftlint --fix`): essentially all
  522 swift-format findings and ~115+ SwiftLint findings (whitespace, indentation, imports,
  colons, semicolons, trailing commas, ordering of imports). This is deterministic and safe.
- **Manual** (~720 SwiftLint findings): the ACL block (A ≈ 398), docs (158),
  `type_contents_order` (126), residual `line_length` after formatting, `file_name` renames
  (19), and the correctness/structure items in section E (~50).

## Config observations worth deciding before any fix pass
1. **`line_length` 90 vs swift-format `lineLength` 100** conflict — they must be aligned or the
   two tools will fight indefinitely.
2. **`Package.swift` is being linted** (3 `blanket_disable_command` findings come from it). The
   reference `MistKit` config excludes `Package.swift`; consider adding it to `excluded`.
3. The largest categories (`explicit_acl`, `missing_docs`, `explicit_top_level_acl`,
   `type_contents_order` ≈ 676) are the library-grade rules. Whether to fully comply, relax for
   an app, or split the difference is the main open decision (no fix applied pending that call).

## Reproduce
```bash
mise install
mise exec -- swiftlint lint --quiet
mise exec -- swift-format lint --configuration .swift-format --recursive Sources Tests
```
