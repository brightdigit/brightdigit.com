---
title: Introducing swift-build: A Zero-Configuration GitHub Action for Swift Package Testing
date: 2025-09-03 00:00
description: Learn how swift-build simplifies Swift CI/CD with zero configuration, intelligent caching, and comprehensive platform support. A step-by-step breakdown of the composite GitHub Action that eliminates CI/CD complexity for Swift developers.
tags: swift, github-actions, ci-cd, swift-package-manager, xcode, testing
featuredImage: /media/tutorials/swift-build/swift-build-github-action-hero.png
subscriptionCTA: Want to stay up-to-date with the latest Swift development tools and CI/CD best practices? Sign up for our newsletter to get notified about new tutorials and tools.
---

# Introducing swift-build: A Zero-Configuration GitHub Action for Swift Package Testing

As Swift developers, we've all been there: setting up CI/CD pipelines that work across multiple platforms, managing different Swift versions, configuring caching strategies, and wrestling with platform-specific build requirements. After dealing with these challenges repeatedly across multiple projects, I decided to build something better: [`swift-build`](https://github.com/brightdigit/swift-build) - a comprehensive GitHub Action that handles all the complexity for you.

## The Problem with Existing Swift CI/CD Solutions

Before `swift-build`, Swift developers faced several pain points when setting up continuous integration:

1. **Platform fragmentation**: Testing on Ubuntu requires different setup than macOS/iOS testing
2. **Caching complexity**: Each platform needs different caching strategies for optimal performance
3. **Configuration overhead**: Every project required extensive YAML configuration
4. **Version management**: Supporting multiple Swift versions across different platforms
5. **Repetitive setup**: Copy-pasting similar workflows across multiple repositories

Existing solutions like `swift-actions/setup-swift` solved part of the problem but still required significant manual configuration for comprehensive testing scenarios.

## What Makes swift-build Different

`swift-build` is a **zero-configuration composite GitHub Action** that provides:

- **Complete platform coverage**: Ubuntu, iOS, watchOS, tvOS, visionOS, and macOS
- **Intelligent caching**: Platform-specific strategies that actually improve build times
- **Zero setup**: Works out-of-the-box with minimal configuration
- **Matrix testing support**: Easy testing across multiple Swift versions and platforms
- **Smart defaults**: Automatically chooses the best build approach for your scenario

## Architecture: Inside the Composite Action

Let's walk through each step of the `swift-build` composite action to understand how it works under the hood.

### Step 1: Environment Detection and Setup

```yaml
- name: Detect OS
  shell: bash
  run: |
    echo "RUNNER_OS=${{ runner.os }}" >> $GITHUB_ENV
```

The action starts by detecting the runner operating system. This determines the entire build strategy:

- **Ubuntu runners**: Use Swift Package Manager exclusively
- **macOS runners**: Can use either SPM or Xcode, depending on target platforms

### Step 2: Platform-Specific Xcode Configuration (macOS only)

```yaml
- name: Setup Xcode
  if: runner.os == 'macOS' && inputs.type != ''
  shell: bash
  run: |
    if [ -n "${{ inputs.xcode }}" ]; then
      sudo xcode-select -s "${{ inputs.xcode }}"
    fi
    echo "DEVELOPER_DIR=$(xcode-select -p)" >> $GITHUB_ENV
```

When targeting Apple platforms, the action configures the Xcode environment:

- Sets the developer directory for the specified Xcode version
- Configures platform-specific build settings
- Maps platform types (ios, watchos, tvos, visionos, macos) to their respective SDKs

This step is crucial because different Apple platforms require different SDK configurations and simulator setups.

### Step 3: Intelligent Caching Strategy

This is where `swift-build` really shines. It implements a two-tier caching strategy:

#### Tier 1: Xcode Derived Data Caching (macOS + Apple platforms)

```yaml
- name: Cache Xcode Derived Data
  if: runner.os == 'macOS' && inputs.type != ''
  uses: irgaly/xcode-cache@v1
  with:
    key: xcode-cache-deriveddata-${{ inputs.scheme }}-${{ inputs.type }}
    restore-keys: xcode-cache-deriveddata-${{ inputs.scheme }}-
```

**Why `irgaly/xcode-cache` over alternatives?**

I chose `irgaly/xcode-cache` because it addresses a critical issue that standard caching misses: **file modification time preservation**. Here's why this matters:

- Xcode's incremental build system relies heavily on file modification timestamps
- Standard caching (like `actions/cache`) doesn't preserve nanosecond-precision timestamps
- `irgaly/xcode-cache` captures and restores modification times with nanosecond resolution
- This enables true incremental builds, dramatically reducing compile times

The action caches two critical directories:
- `DerivedData`: Xcode's intermediate build artifacts
- `SourcePackages`: Swift Package Manager dependencies

#### Tier 2: Swift Package Manager Caching (All platforms)

```yaml
- name: Cache SPM Dependencies
  uses: actions/cache@v4
  with:
    path: |
      .build
      ~/.cache/org.swift.swiftpm
    key: ${{ runner.os }}-spm-${{ hashFiles('Package.swift', 'Package.resolved') }}
    restore-keys: |
      ${{ runner.os }}-spm-
```

For SPM builds, the action caches:
- `.build` directory: Contains compiled modules and build artifacts
- `~/.cache/org.swift.swiftpm`: Global SPM cache directory

The cache key uses `hashFiles()` to ensure cache invalidation when dependencies change.

### Step 4: Platform Download (Optional)

```yaml
- name: Download Platform
  if: inputs.download-platform == 'true' && runner.os == 'macOS'
  shell: bash
  run: |
    xcrun simctl list runtimes
    # Download missing simulator runtimes if needed
```

This optional step handles missing Apple platform SDKs automatically. It's particularly useful for:
- New platform versions (like early visionOS support)
- Specific iOS versions not pre-installed on GitHub runners
- Custom simulator configurations

### Step 5: Build and Test Execution

The action implements two distinct build paths:

#### Path 1: Swift Package Manager (Cross-platform)

```yaml
- name: Build and Test (SPM)
  if: inputs.type == ''
  shell: bash
  working-directory: ${{ inputs.working-directory }}
  run: |
    swift build --build-tests
    swift test
```

Used when no `type` parameter is specified. This path:
- Works on both Ubuntu and macOS
- Tests Linux compatibility
- Uses standard SPM commands
- Ideal for cross-platform Swift packages

#### Path 2: Xcode Build (Apple platforms)

```yaml
- name: Build and Test (Xcode)
  if: inputs.type != '' && runner.os == 'macOS'
  shell: bash
  working-directory: ${{ inputs.working-directory }}
  run: |
    xcodebuild test \
      -scheme "${{ inputs.scheme }}" \
      -destination "platform=${{ inputs.type }} Simulator,name=${{ inputs.deviceName }},OS=${{ inputs.osVersion }}" \
      -enableCodeCoverage YES
```

Used when targeting specific Apple platforms. This path:
- Runs tests on simulators
- Supports all Apple platforms (iOS, watchOS, tvOS, visionOS, macOS)
- Enables code coverage collection
- Handles device-specific testing scenarios

## Third-Party Actions: Deep Dive

### irgaly/xcode-cache@v1: The Game Changer

This action solves a fundamental problem with Xcode caching that most developers don't even know exists. Here's the technical breakdown:

**The Problem**: Standard file caching doesn't preserve modification timestamps with sufficient precision. Xcode's incremental build system uses these timestamps to determine what needs recompilation.

**The Solution**: `irgaly/xcode-cache` captures and restores file modification times with nanosecond precision, enabling true incremental builds.

**Performance Impact**: In my testing, this can reduce build times from 5-10 minutes down to 30 seconds for incremental builds.

### actions/cache@v4: The Foundation

For SPM dependencies, `actions/cache` provides reliable caching with these key benefits:

- **Cross-branch caching**: Caches from main branch are available to feature branches
- **Intelligent key strategies**: Uses `hashFiles()` for automatic cache invalidation
- **Segment downloading**: Optimizes cache restoration performance

## Real-World Usage Examples

### Basic Swift Package Testing

```yaml
name: Test Swift Package
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: brightdigit/swift-build@v1
      with:
        scheme: "MyPackage"
```

### Multi-Platform Matrix Testing

```yaml
name: Comprehensive Testing
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        include:
          # Ubuntu testing
          - os: ubuntu-latest
            scheme: "MyPackage"
          # iOS testing
          - os: macos-latest
            scheme: "MyPackage"
            type: "iOS"
            deviceName: "iPhone 15"
          # watchOS testing
          - os: macos-latest
            scheme: "MyPackage"
            type: "watchOS"
            deviceName: "Apple Watch Series 9 (45mm)"
    
    runs-on: ${{ matrix.os }}
    steps:
    - uses: actions/checkout@v4
    - uses: brightdigit/swift-build@v1
      with:
        scheme: ${{ matrix.scheme }}
        type: ${{ matrix.type }}
        deviceName: ${{ matrix.deviceName }}
```

### Advanced Configuration

```yaml
- uses: brightdigit/swift-build@v1
  with:
    working-directory: "SubPackage"
    scheme: "MyFramework"
    type: "visionOS"
    deviceName: "Apple Vision Pro"
    osVersion: "1.0"
    xcode: "/Applications/Xcode_15.2.app"
    download-platform: "true"
```

## Performance Benefits and Benchmarks

Based on testing across multiple projects:

### Without Caching (Cold Builds)
- Ubuntu SPM builds: 3-5 minutes
- iOS Xcode builds: 8-12 minutes
- Multi-platform matrix: 20-30 minutes total

### With swift-build Caching (Warm Builds)
- Ubuntu SPM builds: 30-60 seconds
- iOS Xcode builds: 1-3 minutes  
- Multi-platform matrix: 5-8 minutes total

The intelligent caching provides **70-80% reduction** in build times for typical Swift projects.

## Getting Started

### Minimal Setup

1. Add a `.github/workflows/test.yml` file to your repository
2. Use the basic configuration:

```yaml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: brightdigit/swift-build@v1
      with:
        scheme: "YourPackageName"  # Replace with your scheme
```

### Common Configuration Patterns

**Cross-platform testing**:
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
runs-on: ${{ matrix.os }}
```

**Apple platform specific**:
```yaml
- uses: brightdigit/swift-build@v1
  with:
    scheme: "MyApp"
    type: "iOS"  # or watchOS, tvOS, visionOS, macOS
```

## Troubleshooting Tips

1. **Scheme not found**: Ensure your scheme name matches exactly (case-sensitive)
2. **Platform issues**: Use `download-platform: true` for newer platforms
3. **Xcode version conflicts**: Specify explicit Xcode path with `xcode` parameter
4. **Cache issues**: Cache keys include scheme and type, so changes require new builds

## The Future of swift-build

`swift-build` represents a new approach to Swift CI/CD: **convention over configuration**. By encoding best practices into a reusable action, it eliminates the cognitive overhead of managing complex build pipelines.

Future enhancements planned:
- Swift 6 compatibility improvements  
- Enhanced logging and diagnostics
- Custom test result reporting
- Integration with Swift Package Index

The goal is simple: let developers focus on writing great Swift code, not wrestling with CI/CD configuration.

---

Ready to simplify your Swift CI/CD? Check out [`swift-build` on GitHub](https://github.com/brightdigit/swift-build) and see how it can streamline your development workflow.

