# watchOS 27 SDK build failure — inferred deployment target clamped to 8.0

> Reference write-up for fixing this across the BrightDigit Swift package subrepos.
> The bug is in SwiftPM (the PIF layer), not in our packages and not in the SDK.

## TL;DR

On the watchOS 27 simulator SDK, `xcodebuild` fails to compile any dependency that
**does not declare an explicit watchOS deployment target**. SwiftPM's PIF layer infers
that package's watchOS target from its iOS target and lands on **8.0**, then fails to
clamp it to the SDK's oldest supported version (9.0). The watchOS 27 SDK rejects 8.0.

- **It is a SwiftPM bug**, fixed by [swift-package-manager#10188] (merged into the
  `release/6.4` branch on **2026-06-10**, closes [#10187]).
- **Proper fix:** build the watchOS leg with a Swift 6.4 toolchain / Xcode-beta that
  includes #10188.
- **Toolchain-independent workaround:** pass `WATCHOS_DEPLOYMENT_TARGET=9.0` as a
  command-line build setting to `xcodebuild` (overrides every target in the graph,
  including SPM dependency targets).

[swift-package-manager#10188]: https://github.com/swiftlang/swift-package-manager/pull/10188
[#10187]: https://github.com/swiftlang/swift-package-manager/issues/10187

## Symptom

CI: ButtondownKit, job `Build on macOS (Platforms) (watchos, Apple Watch Ultra 3 (49mm), 27.0)`
([run 27885283723](https://github.com/brightdigit/ButtondownKit/actions/runs/27885283723/job/82519569769)).

```
.../checkouts/swift-collections/Package.swift: error: The watchOS Simulator
deployment target 'WATCHOS_DEPLOYMENT_TARGET' is set to 8.0, but the range of
supported deployment target versions is 9.0 to 27.0.x. (in target 'DequeModule'
from project 'swift-collections')
.../checkouts/swift-http-types/Package.swift: error: ... is set to 8.0, but the
range of supported deployment target versions is 9.0 to 27.0.x. (in target
'HTTPTypes' from project 'swift-http-types')
...
Testing cancelled because the build failed.
** TEST FAILED **
Process completed with exit code 65.
```

Only **swift-collections** and **swift-http-types** error. The other dependencies do
not — that asymmetry is the diagnostic fingerprint (see below).

## Root cause

### The SwiftPM/PIF bug (#10187 → #10188)

From the PR description:

> When building a package where:
> - The manifest does not specify an explicit watchOS deployment target
> - The iOS deployment target is unspecified or explicitly set to iOS 15.0
> - The PIF client (Xcode) infers the watchOS deployment target based on the iOS
>   deployment target
>
> The watchOS deployment target will be incorrectly inferred as 8.0, which is not
> supported by the watchOS 27.0 SDK. The inferred deployment target needs to be
> clamped to the oldest supported deployment target for the target platform, similar
> to how this is already handled when it's derived by SwiftPM directly.

So the `8.0` is **inferred**, not declared. When a package leaves watchOS unspecified,
Xcode's PIF client derives it from the iOS target; that derivation produced 8.0 and was
**not clamped** to the SDK floor (9.0). #10188 adds the clamp.

### Why only some dependencies fail

The inference path only runs for packages that omit an explicit watchOS deployment
target. In ButtondownKit's graph:

| Dependency (resolved)            | watchOS declaration        | Hits the bug? |
|----------------------------------|----------------------------|---------------|
| swift-collections 1.6.0          | computed, **no explicit watchOS floor** | **Yes** |
| swift-http-types 1.6.0           | computed, **no explicit watchOS floor** | **Yes** |
| swift-openapi-runtime 1.12.0     | `.watchOS(.v6)` (explicit) | No            |
| swift-openapi-urlsession 1.3.0   | `.watchOS(.v6)` (explicit) | No            |

The openapi packages declare an explicit watchOS minimum, so the buggy inference never
runs for them — which is exactly why they're absent from the error output.

### Two common misreadings (avoid these)

1. **"Our package's minimum is too low."** No — the root `Package.swift` declares
   `.watchOS(.v9)`. SwiftPM does **not** propagate a consumer's platform floor down into
   its dependencies; each package compiles its own targets at its own (here, inferred)
   minimum. Raising the root does nothing.
2. **"Xcode-beta / the new SDK is broken."** No — an SDK raising its minimum deployment
   target across a major version is normal and intended. The bug is SwiftPM failing to
   clamp an *inferred* target to that new floor.

### Why it surfaced now

The Apple-platform suite moved to the self-hosted runner with `/Applications/Xcode-beta.app`
(Xcode 27 / Swift 6.4), which uses the **watchOS 27 simulator SDK**. That SDK raised the
oldest supported deployment target to 9.0, exposing the unclamped 8.0 inference. Earlier
SDKs accepted 8.0, so the bug was latent.

## Fixes

Pick **A** (correct) and/or **B** (stopgap). **C** is a per-dependency angle that only
helps for packages you control.

### A. Update the toolchain (proper fix)

Build the watchOS leg with a Swift 6.4 toolchain that includes #10188 (merged
2026-06-10):

- **macOS Apple-platform legs:** ensure the self-hosted runner's `/Applications/Xcode-beta.app`
  is a snapshot dated **after 2026-06-10**. Check the bundled SwiftPM:
  ```sh
  /Applications/Xcode-beta.app/Contents/Developer/usr/bin/swift --version
  xcodebuild -version
  ```
  If the SwiftPM predates the fix, install a newer Xcode-beta.
- No `Package.swift` or workflow changes are needed once the toolchain has the fix.

### B. `WATCHOS_DEPLOYMENT_TARGET` override (toolchain-independent workaround)

Pass the deployment target as a **command-line build setting** to `xcodebuild`. A
command-line build setting is a global override applied to *every* target in the build,
including the implicitly generated SPM dependency targets, so it pins the unclamped
inference to a valid value:

```sh
xcodebuild test \
  -scheme "<Pkg>-Package" \
  -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm),OS=27.0' \
  WATCHOS_DEPLOYMENT_TARGET=9.0
```

The general build-setting names per platform (use if other platforms ever regress):

| Platform  | Build setting                   |
|-----------|---------------------------------|
| iOS       | `IPHONEOS_DEPLOYMENT_TARGET`     |
| watchOS   | `WATCHOS_DEPLOYMENT_TARGET`      |
| tvOS      | `TVOS_DEPLOYMENT_TARGET`         |
| visionOS  | `XROS_DEPLOYMENT_TARGET`         |
| macOS     | `MACOSX_DEPLOYMENT_TARGET`       |

Currently only watchOS regresses; iOS/tvOS dependencies declare iOS 13 / tvOS 13, which
already satisfy their respective 27 SDK floors, so the override is unnecessary there.

#### Wiring B through the shared `brightdigit/swift-build` action

The watchOS leg builds via `brightdigit/swift-build` (branch
`sdk-url-checksum-nightly-6.4`). Its Apple-platform step builds the `xcodebuild` command
with no build-setting overrides (`action.yml`, ~line 2232–2247):

```sh
XCODEBUILD_CMD="xcodebuild test \
  -scheme \"$SCHEME_VALUE\" \
  -sdk ${{ env.SDK }} \
  -destination \"$DESTINATION\" \
  -enableCodeCoverage YES \
  -derivedDataPath ${{ env.DERIVED_DATA_PATH }}"
```

To support the override without breaking the byte-identical workflows:

1. Add an optional `deployment-target` input (default `''`) to `action.yml`.
2. When it's non-empty, map `inputs.type` → the build-setting name from the table above
   and append `<NAME>=<value>` to both the `xcodebuild build` and `xcodebuild test`
   command strings.
3. In each subrepo workflow, add `deploymentTarget` to the `build-macos-platforms`
   matrix and pass `deployment-target: ${{ matrix.deploymentTarget }}`. Because every
   subrepo shares the same matrix values, the five workflows stay byte-identical:

   ```yaml
   include:
     - { type: ios,     deviceName: "iPhone 17 Pro",                osVersion: "27.0", deploymentTarget: "16.0" }
     - { type: watchos, deviceName: "Apple Watch Ultra 3 (49mm)",   osVersion: "27.0", deploymentTarget: "9.0"  }
     - { type: tvos,    deviceName: "Apple TV 4K (3rd generation)", osVersion: "27.0", deploymentTarget: "16.0" }
   ```

> Alternative to editing the action: a workflow step can write an xcconfig and export
> `XCODE_XCCONFIG_FILE` before the build (xcodebuild applies it globally). It needs no
> action change but is per-repo and breaks the byte-identical-workflow invariant, so the
> action input is preferred.

### C. Declare an explicit watchOS minimum (only for packages you own)

For any first-party package in the graph that omits an explicit watchOS target, adding
one (e.g. `.watchOS(.v9)`) sidesteps the inference path for that package. This does
**not** help here because the affected packages (swift-collections, swift-http-types)
are third-party — but it's the durable fix for your own packages and worth doing where
applicable.

## Verification

1. Re-run the watchOS leg (push a branch or `workflow_dispatch`). With fix A, confirm
   the swift-collections / swift-http-types deployment-target errors are gone. With fix
   B, the `xcodebuild test` log should also show `WATCHOS_DEPLOYMENT_TARGET=9.0`.
2. Confirm iOS and tvOS legs still pass (the override, if used, is a no-op raise there).
3. Optional local check on the self-hosted Mac:
   ```sh
   xcodebuild test -scheme <Pkg>-Package -sdk watchsimulator \
     -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm),OS=27.0' \
     WATCHOS_DEPLOYMENT_TARGET=9.0
   ```

## Applying across the brightdigit.com subrepos

Every subrepo that (a) runs a watchOS leg on the watchOS 27 SDK and (b) depends on a
package without an explicit watchOS deployment target hits this. Sweep for it:

- Look for the `build-macos-platforms` watchOS matrix entry in each subrepo's
  `.github/workflows/*.yml`.
- Grep dependency graphs for the known offenders (swift-collections, swift-http-types)
  and any other package whose manifest omits a watchOS platform.
- Apply fix A once on the shared runner (covers all repos), and/or fix B once in the
  shared `brightdigit/swift-build` action plus the matrix passthrough (covers all repos
  while keeping the workflows byte-identical).

## References

- SwiftPM PR (the fix): https://github.com/swiftlang/swift-package-manager/pull/10188
- SwiftPM issue: https://github.com/swiftlang/swift-package-manager/issues/10187
- Failing CI run: https://github.com/brightdigit/ButtondownKit/actions/runs/27885283723/job/82519569769
- Shared action: `brightdigit/swift-build@sdk-url-checksum-nightly-6.4` (`action.yml`)
