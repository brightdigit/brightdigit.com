# Subrepo platform and OS support

Last verified: 2026-07-18, after the all-subrepo CI repair recorded in
[`CI-SUBREPO-PROGRESS.md`](../CI-SUBREPO-PROGRESS.md).

This inventory separates two different meanings of “support”:

- **Declared Apple minimums** are the deployment targets explicitly listed in each
  package's `Package.swift`. The CI builds do not prove that every package still runs
  on its minimum version; they prove compilation and tests against the newer SDK and
  simulator versions below.
- **CI profile** is the operating-system and target-platform matrix exercised by the
  primary GitHub Actions workflow. Android is build-only; the other enabled legs use
  `brightdigit/swift-build` to build and test where the platform permits it.

An Apple platform omitted from `Package.swift` is not necessarily unsupported. SwiftPM
uses its default deployment target when a manifest does not declare one explicitly.

## CI profiles

| Profile | Enabled operating systems and target versions |
|---|---|
| **Full** | Ubuntu 24.04 Noble; macOS 26.5 on hosted `xcode-27`; Windows Server 2022 and 2025; Android API 34; iOS 27.0; tvOS 27.0; watchOS 27.0 |
| **No-watch** | Everything in **Full** except that the watchOS 27.0 job is skipped through `ENABLE_WATCHOS=false` |

Additional toolchain details:

- macOS and Apple simulator jobs select `/Applications/Xcode_27.0.app` and use the
  Swift 6.4 development toolchain. The iOS, tvOS, and watchOS 27.0 simulator runtimes
  are downloaded by the workflow when needed.
- Windows uses the Swift 6.4 development snapshot dated 2026-06-01.
- Android uses API 34 and the Swift 6.4 Android SDK snapshot dated 2026-06-15. It is
  compile-only (`android-run-tests: false`).
- `ENABLE_WASM=false` is set on all 20 repositories, so both Wasm and embedded-Wasm
  workflow variants are disabled everywhere.
- visionOS is not present in the manifests or CI matrices and is therefore not
  currently declared or tested.
- The expensive Windows, Apple simulator, and Android legs are event-gated. The
  profiles describe the full matrix used by workflow dispatches and qualifying pull
  requests, not necessarily every lightweight push event.

## Per-subrepo inventory

| Subrepo | Declared Apple minimum deployment targets | CI profile | Disabled or not configured |
|---|---|---|---|
| ButtondownKit | macOS 13; iOS 16; tvOS 16; watchOS 9 | **No-watch** | watchOS CI; Wasm; embedded Wasm; visionOS |
| Contribute | macOS 12; iOS 13; tvOS 13; watchOS 6 | **No-watch** | watchOS CI; Wasm; embedded Wasm; visionOS |
| ContributeButtondown | macOS 15; iOS 16; tvOS 16; watchOS 9 | **Full** | Wasm; embedded Wasm; visionOS |
| ContributeMailchimp | macOS 15; iOS 16; tvOS 16; watchOS 9 | **Full** | Wasm; embedded Wasm; visionOS |
| ContributeRSS | macOS 15; iOS 16; tvOS 16; watchOS 9 | **Full** | Wasm; embedded Wasm; visionOS |
| ContributeWordPress | macOS 15; iOS 16; tvOS 16; watchOS 9 | **Full** | Wasm; embedded Wasm; visionOS |
| ContributeYouTube | macOS 15; iOS 16; tvOS 16; watchOS 9 | **Full** | Wasm; embedded Wasm; visionOS |
| NPMPublishPlugin | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |
| PublishType | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |
| Spinetail | macOS 13; iOS 16; tvOS 16; watchOS 9 | **No-watch** | watchOS CI; Wasm; embedded Wasm; visionOS |
| SwiftTube | macOS 13; iOS 16; tvOS 16; watchOS 9 | **No-watch** | watchOS CI; Wasm; embedded Wasm; visionOS |
| SyndiKit | macOS 13; iOS 13; tvOS 13; watchOS 6 | **Full** | Wasm; embedded Wasm; visionOS |
| TailwindKit | macOS 13; other Apple minimums not explicitly declared | **Full** | Wasm; embedded Wasm; visionOS |
| TransistorPublishPlugin | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |
| YoutubePublishPlugin | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |
| ReadingTimePublishPlugin | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |
| Files | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |
| Ink | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |
| Plot | No Apple minimums explicitly declared | **Full** | Wasm; embedded Wasm; visionOS |
| Publish | macOS 15; iOS 18; tvOS 18; watchOS 11 | **Full** | Wasm; embedded Wasm; visionOS |

The four **No-watch** repositories still declare watchOS support in their manifests.
Only their watchOS 27 CI jobs are disabled, due to the current SwiftPM deployment-target
issue tracked in brightdigit.com issue #119.

NPMPublishPlugin intentionally retains macOS, iOS, tvOS, and watchOS. Its `Subprocess`
product dependency is conditional to macOS, Linux, Windows, and Android, while the
Subprocess-backed source, tests, and `.npm` publishing-step API use
`#if canImport(Subprocess)`. This lets the non-Subprocess Apple targets compile without
linking that product.
