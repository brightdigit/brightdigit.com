# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

TailwindKit is a small, dependency-light Swift module that emits **type-safe
[Tailwind CSS v4](https://tailwindcss.com) utility class strings** for
brightdigit.com's component markup. Swift 6.4 tools version, Swift 6 language
mode; targets macOS 13+ and Linux. Tailwind **v4 only**.

## Commands

```bash
swift test                              # run the (offline, Plot-independent) tests
swift build --build-tests               # compile

# Single test: filter by suite/method
swift test --filter TailwindStyleTests/canonicalChain

# Lint/format/check (installs pinned tools via mise, formats in place locally, builds tests, runs periphery)
./Scripts/lint.sh
LINT_MODE=STRICT ./Scripts/lint.sh      # CI-style strict mode (no auto-fix; lint + build only when CI is set)

mise install                            # install pinned tools (swift-format, swiftlint, periphery)
```

Tooling (swift-format, SwiftLint, periphery) is pinned in `.mise.toml` and run
through `mise exec --`. `Scripts/lint.sh` auto-formats and rewrites file headers
only when `CI` is unset; in CI it lints and builds without mutating files.

## Architecture — the one design decision

`TailwindStyle` is an immutable value builder that is **Plot-independent**. The
core builder and its utility surface live in Plot-free files
(`TailwindStyle.swift`, the `TailwindStyle+*Tokens.swift` token files,
`TailwindStyle+Utilities.swift`, `TailwindStyle+Static.swift`,
`TailwindStyle+Arbitrary.swift`). The **only** file that imports Plot is
`Node+Tailwind.swift`, which adds the single sugar `.tailwind(_ style:)` →
`.class(style.rendered)` on `Node`/`Attribute`.

- Every fluent member returns a new `TailwindStyle`. Bare utilities are computed
  properties (`.flex`, `.gap`); parameterized ones are methods (`.gap(4)`,
  `.bg(.blue, .s500)`). Static mirrors in `TailwindStyle+Static.swift` let a
  chain start with a leading dot.
- To satisfy SwiftLint's `type_contents_order`, each of the utilities/static
  files is split into a **bare-utilities (properties)** extension and a
  **parameterized-utilities (methods)** extension.
- **Value tokens split by whether Tailwind v4 makes them customizable** (see
  `docs/tailwind-v4-value-model.md` for the per-family rationale, cited to the v4
  docs). The families backed by an extensible `@theme` namespace are modeled as a
  **protocol + `Default…` type (SwiftUI-`Style` shape)**: `Color`, `Spacing`,
  `Size`, `MaxWidth` (`--container-*`), `TextSize`, `FontWeight`, `Radius`,
  `Shadow`, `DropShadow`, `Tracking`, `Ease`. The fixed CSS-keyword families stay
  **closed enums** (custom values are meaningless): `Shade`, `Position`, `Flex`,
  `FlexDirection`, `ListStyle`, `Align`, `Justify`, `TextAlign`, `VerticalAlign`,
  `ObjectFit`, `BorderSide`. Token types live in `TailwindStyle+*Tokens.swift`
  (ColorTokens/SpacingTokens/TypographyTokens/EffectsTokens/LayoutTokens/Tokens),
  the base protocol in `TailwindToken.swift`.
- **The extensible-token pattern (Approach C):** each family is a marker
  `public protocol Foo: TailwindToken {}`; built-ins live on a `public struct
  DefaultFoo: Foo` whose init is **internal** (so it is *not constructible by
  name* — like SwiftUI's `DefaultButtonStyle`), exposed as static members via
  `extension Foo where Self == DefaultFoo { public static var … }` (the `where
  Self ==` constraint is required for leading-dot syntax, and forces `DefaultFoo`
  to be a public type). Fluent methods take `some Foo` so a downstream module can
  add a custom value by conforming its own type: `struct BrandColor:
  TailwindStyle.Color { let token = "brand" }` → `TW.bg(.brand, .s500)`. Literal
  families (`Spacing`/`Size`) instead take the concrete `DefaultSpacing`/`DefaultSize`
  so `.gap(4)`/`.p(2.5)` still work.
- Related bare utilities are still grouped into cohesive enum "sets" (e.g.
  `Position`, `Flex`, `FlexDirection`, `ListStyle`) rather than a flat wall of
  computed properties.
- For Tailwind v4 [arbitrary values](https://tailwindcss.com/docs/adding-custom-styles):
  each extensible token family carries a `.arbitrary(_:)` static (e.g.
  `.maxW(.arbitrary("48rem"))` → `max-w-[48rem]`, spaces→underscores), and a
  developer can also conform a token type whose `token` is the bracketed form.
  For a value on an **unmodeled** utility prefix, `TailwindStyle+Arbitrary.swift`
  provides `.arbitrary(_ prefix:value:)` (→ `prefix-[value]`),
  `.arbitrary(_ prefix:variable:)` (→ `prefix-(--var)`), and
  `.custom(property:value:)` (→ `[property:value]`). The removed
  `TailwindStyle+Custom.swift`/`Custom` type is gone. For any class not modeled at
  all, the escape hatch remains Plot's existing `.class("…")`.
- Shades are enum cases `.s50`…`.s950` (Swift disallows the `.500` spelling and
  leading underscores), e.g. `.bg(.blue, .s500)`. Shade is deliberately **not**
  extensible: in v4 `blue-500` is a single `--color-blue-500` variable, so a
  custom shade isn't a coherent concept — add a custom `Color` instead.

## Tests

Tests are offline and **Plot-independent**: they assert `.rendered` string
equality only (e.g. `TW.flex.gap(4).rendered == "flex gap-4"`), so nothing in
the test target imports Plot. Uses swift-testing (`@Suite`/`@Test`/`#expect`),
not XCTest.

## Conventions

- The MIT license header on every hand-written Swift file is managed by
  `Scripts/header.sh` (invoked from `lint.sh` locally). Don't hand-maintain
  headers.
- Strict concurrency is complete (Swift 6 mode). `@unchecked Sendable` is banned
  by a custom SwiftLint rule — fix Sendability properly.
