---
title: Introducing [swift-build](https://github.com/brightdigit/swift-build): A GitHub Action for Swift
date: 2025-09-03 00:00
description: Learn how [swift-build](https://github.com/brightdigit/swift-build) simplifies Swift CI/CD with little configuration, intelligent caching, and comprehensive platform support. A step-by-step breakdown of the composite GitHub Action that eliminates CI/CD complexity for Swift developers.
tags: swift, github-actions, ci-cd, swift-package-manager, xcode, testing
featuredImage: /media/tutorials/swift-build/swift-build-github-action-hero.webp
subscriptionCTA: Want to stay up-to-date with the latest Swift development tools and CI/CD best practices? Sign up for our newsletter to get notified about new tutorials and tools.
---

I love [continuous integration](https://brightdigit.com/blog/2020/03/02/ios-continuous-integration-avoid-merge-hell/). It verifies every commit and pull request passes every check you put to it. Over the years I've used a combination of commands to ensure by Full Stack Swift packages work on a variety of platforms and OSes - whether it's a new Ubuntu distribution for hosting a server application or ensuring the last package won't break on a new Apple Vision Pro. I want my Swift code to work everywhere.

> transistor https://share.transistor.fm/s/a14f868f

Over the years I've found manually setting up different commands and checks for different platforms tedious. I've also found ways to take advantage of caching where I can. After dealing with these challenges repeatedly across multiple projects, I decided to build something any one can use: [`swift-build`](https://github.com/brightdigit/swift-build) - a comprehensive GitHub Action that handles all the complexity for you.

## Table of Contents

- [The Problem with Existing Swift CI/CD Solutions](#the-problem-with-existing-swift-cicd-solutions)
- [What Makes swift-build Different](#what-makes-swift-build-different)
- [🚀 Matrix Testing: The Game Changer](#-matrix-testing-the-game-changer)
- [What's a Composite Action](#whats-a-composite-action)
- [Real-World Usage Examples](#real-world-usage-examples)
- [Getting Started](#getting-started)
- [Troubleshooting Tips](#troubleshooting-tips)
- [Real-World Usage: How I Use swift-build](#real-world-usage-how-i-use-swift-build)
- [The Power of swift-build](#the-power-of-swift-build)
- [Learn More About Continuous Integration](#learn-more-about-continuous-integration)

## The Problem with Existing Swift CI/CD Solutions <a id="the-problem-with-existing-swift-cicd-solutions"></a>

Before [`swift-build`](https://github.com/brightdigit/swift-build), I've found issues when setting up continuous integration:

1. **Platform fragmentation**: Testing on Ubuntu requires different setup than macOS/iOS testing
2. **Caching complexity**: Each platform needs different caching strategies for optimal performance
3. **Configuration overhead**: Every project required extensive YAML configuration
4. **Version management**: Supporting multiple Swift versions across different platforms
5. **Repetitive setup**: Copy-pasting similar workflows across multiple repositories

## What Makes [swift-build](https://github.com/brightdigit/swift-build) Different <a id="what-makes-swift-build-different"></a>

[`swift-build`](https://github.com/brightdigit/swift-build) basically needs little configuration and provides:

- **Complete platform coverage**: Ubuntu, iOS, watchOS, tvOS, visionOS, and macOS
- **Intelligent caching**: Platform-specific strategies that actually improve build times
- **Zero setup**: Works out-of-the-box with minimal configuration
- **Smart defaults**: Automatically chooses the best build approach for your scenario
- **Cutting-edge support**: [Official Swift Docker images](https://hub.docker.com/r/_/swift) and [nightly builds](https://hub.docker.com/r/swiftlang/swift) for Swift 6.2 and Xcode beta testing

### Example: Real-World Matrix Testing

Here's the actual workflow from [SyntaxKit](https://github.com/brightdigit/SyntaxKit) showing how [`swift-build`](https://github.com/brightdigit/swift-build) handles comprehensive matrix testing:

```yaml
name: SyntaxKit
on: [push]

jobs:
  build-ubuntu:
    name: Build on Ubuntu
    runs-on: ubuntu-latest
    container: ${{ matrix.swift.nightly && format('swiftlang/swift:nightly-{0}-{1}', matrix.swift.version, matrix.os) || format('swift:{0}-{1}', matrix.swift.version, matrix.os) }}
    strategy:
      matrix:
        os: [noble, jammy]
        swift:
          - version: "6.0"
          - version: "6.1"
          - version: "6.1"
            nightly: true
          - version: "6.2"
            nightly: true
    steps:
    - uses: actions/checkout@v4
    - uses: brightdigit/swift-build@v1.2.1

  build-macos:
    name: Build on macOS
    runs-on: ${{ matrix.runs-on }}
    strategy:
      matrix:
        include:
          # SPM Build Matrix
          - runs-on: macos-15
            xcode: "/Applications/Xcode_26.0.app"
          - runs-on: macos-15
            xcode: "/Applications/Xcode_16.4.app"
          
          # macOS Build Matrix
          - type: macos
            runs-on: macos-15
            xcode: "/Applications/Xcode_26.0.app"
          - type: macos
            runs-on: macos-15
            xcode: "/Applications/Xcode_16.4.app"
          
          # iOS Build Matrix
          - type: ios
            runs-on: macos-15
            xcode: "/Applications/Xcode_26.0.app"
            deviceName: "iPhone 16 Pro"
            osVersion: "26.0"
            download-platform: true
          
          # watchOS Build Matrix
          - type: watchos
            runs-on: macos-15
            xcode: "/Applications/Xcode_26.0.app"
            deviceName: "Apple Watch Ultra 2 (49mm)"
            osVersion: "26.0"
            download-platform: true
          
          # tvOS Build Matrix
          - type: tvos
            runs-on: macos-15
            xcode: "/Applications/Xcode_26.0.app"
            deviceName: "Apple TV"
            osVersion: "26.0"
            download-platform: true
          
          # visionOS Build Matrix
          - type: visionos
            runs-on: macos-15
            xcode: "/Applications/Xcode_26.0.app"
            deviceName: "Apple Vision Pro"
            osVersion: "26.0"
            download-platform: true
    
    steps:
    - uses: actions/checkout@v4
    - uses: brightdigit/swift-build@v1.2.1
      with:
        scheme: "SyntaxKit-Package"
        type: ${{ matrix.type }}
        xcode: ${{ matrix.xcode }}
        deviceName: ${{ matrix.deviceName }}
        osVersion: ${{ matrix.osVersion }}
        download-platform: ${{ matrix.download-platform }}
```

This real-world configuration tests across:
- **4 Swift versions** (6.0, 6.1, 6.1-nightly, 6.2-nightly) on Ubuntu using Docker containers
- **2 Xcode versions** (16.4, 26.0) on macOS
- **5 Apple platforms** (macOS, iOS, watchOS, tvOS, visionOS)
- **Multiple simulators** (iPhone 16 Pro, Apple Watch Ultra 2, Apple TV, Apple Vision Pro)

All running in parallel with intelligent caching for maximum efficiency.

But the most powerful feature of [`swift-build`](https://github.com/brightdigit/swift-build) is its matrix testing capabilities.

## 🚀 Matrix Testing: The Game Changer <a id="-matrix-testing-the-game-changer"></a>

**Matrix testing is where [`swift-build`](https://github.com/brightdigit/swift-build) truly shines.** [`swift-build`](https://github.com/brightdigit/swift-build) makes it incredibly simple to test your Swift packages across multiple platforms simultaneously.

### Why Matrix Testing Matters

Modern Swift development requires testing across multiple platforms:
- **Cross-platform packages** need to work on both Linux and Apple platforms
- **Apple ecosystem apps** should be tested on multiple versions of macOS, iOS, watchOS, tvOS, and visionOS
- **Version compatibility** requires testing against multiple Swift and Xcode versions
- **Device diversity** demands testing on different simulators and devices

### The [swift-build](https://github.com/brightdigit/swift-build) Matrix Advantage

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

**What makes this powerful:**
- **Single configuration**: One action handles all platforms automatically
- **Parallel execution**: All platforms test simultaneously, not sequentially
- **Intelligent caching**: Each platform gets optimized caching strategies
- **Zero platform-specific setup**: No need to configure different commands per platform
- **Comprehensive coverage**: Test Linux compatibility AND Apple platform features in one workflow

This approach transforms what used to be hundreds of lines of complex YAML configuration across multiple workflows into a single, elegant configuration that runs faster and provides better coverage.

## What's a Composite Action <a id="whats-a-composite-action"></a>

A [composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) is a GitHub Actions feature that allows you to combine multiple workflow steps into a single, reusable action. Think of it as a "workflow within a workflow" - instead of writing the same sequence of steps repeatedly across different repositories, you can package them into a composite action that others can use with a single line.

[`swift-build`](https://github.com/brightdigit/swift-build) is built as a composite action, which means it encapsulates all the complexity of Swift CI/CD setup - from platform detection and caching strategies to build execution - into a single, easy-to-use action that you can drop into any workflow.

Let's walk through each step of the [`swift-build`](https://github.com/brightdigit/swift-build) composite action to understand how it works under the hood.

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

**What the `type` parameter does on macOS runners:**

The `type` parameter determines which Apple platform to target and triggers `xcodebuild` instead of `swift build`. When you specify a `type` (like "iOS", "watchOS", "tvOS", "visionOS", or "macOS"), the action uses Xcode's build system to run tests on the appropriate simulator or platform.

This step is crucial because different Apple platforms require different SDK configurations and simulator setups.

### Step 3: Intelligent Caching Strategy

This is where [`swift-build`](https://github.com/brightdigit/swift-build) really shines. It implements a two-tier caching strategy:

#### Tier 1: Xcode Derived Data Caching (xcodebuild)

```yaml
- name: Cache Xcode Derived Data
  if: runner.os == 'macOS' && inputs.type != ''
  uses: irgaly/xcode-cache@v1
  with:
    key: xcode-cache-deriveddata-${{ inputs.scheme }}-${{ inputs.type }}
    restore-keys: xcode-cache-deriveddata-${{ inputs.scheme }}-
```

We are using the [`irgaly/xcode-cache`](https://github.com/irgaly/xcode-cache) because it is especially built for caching with xcodebuild and preserves file modification timestamps with nanosecond precision, enabling true incremental builds. Standard caching doesn't preserve these timestamps, which Xcode's build system relies on for determining what needs recompilation.

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

For SPM builds, we use For Github's own [`actions/cache`](https://github.com/actions/cache) which caches:
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

This optional step handles missing Apple platform SDKs automatically. Github recently made changes to their runners which may require this.

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



## Real-World Usage Examples <a id="real-world-usage-examples"></a>

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

*See the dedicated "Matrix Testing: The Game Changer" section above for comprehensive matrix testing examples and benefits.*

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





## Getting Started <a id="getting-started"></a>

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

## Troubleshooting Tips <a id="troubleshooting-tips"></a>

### Common Issues and Solutions

1. **Scheme not found**: Ensure your scheme name matches exactly (case-sensitive). The scheme name could be the name of the Swift Package or it could be suffixed with `-Package`. You can list available schemes by running `xcodebuild -list` in your project directory.

2. **Platform issues**: Use `download-platform: true` for newer platforms like visionOS or when GitHub runners don't have the required simulators pre-installed. This will automatically download missing platform runtimes.

3. **Xcode version conflicts**: Specify explicit Xcode path with `xcode` parameter when you need a specific version. Available Xcode versions on [GitHub Actions macOS runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-software) are documented in the official GitHub documentation.

### Getting More Help

For detailed troubleshooting guides, configuration options, and community support, check out the [[swift-build](https://github.com/brightdigit/swift-build) README](https://github.com/brightdigit/swift-build#readme) on GitHub. The repository includes:

- Complete parameter reference
- Advanced configuration examples
- Known issues and workarounds
- Community discussions and bug reports

## Real-World Usage: How I Use [swift-build](https://github.com/brightdigit/swift-build) <a id="real-world-usage-how-i-use-swift-build"></a>

I use [`swift-build`](https://github.com/brightdigit/swift-build) across all my Swift packages and repositories. It's not just a tool I built for others—it's the foundation of my own development workflow. Here are some examples of how it's implemented in my projects:

### BrightDigit Swift Packages
- **[ThirtyTo](https://github.com/brightdigit/ThirtyTo)** - Encode, Decode and Generate Random String in Base32Crockford Format
- **[SyntaxKit](https://github.com/brightdigit/SyntaxKit)** - More Friendly SwiftSyntax API
- **[SyndiKit](https://github.com/brightdigit/SyndiKit)** - Swift Package for Decoding RSS Feeds
- **[Sublimation](https://github.com/brightdigit/Sublimation)** - Enable automatic discovery of your local development server on the fly. Turn your Server-Side Swift app from a mysterious vapor to a tangible solid server
- **[Bushel](https://apps.apple.com/app/bushel/id1234567890)** - Available on the Mac App Store

Each of these repositories uses [`swift-build`](https://github.com/brightdigit/swift-build) with matrix testing to ensure compatibility across:
- **Ubuntu** (for server-side Swift compatibility)
- **macOS** (for Apple platform development)
- **iOS** (for mobile app integration)
- **watchOS** (for Apple Watch support)

### The Result
By using [`swift-build`](https://github.com/brightdigit/swift-build) consistently across all my projects, I've eliminated the CI/CD maintenance burden while ensuring comprehensive testing coverage. Every package gets the same high-quality testing pipeline with zero additional configuration.

## The Power of [swift-build](https://github.com/brightdigit/swift-build) <a id="the-power-of-swift-build"></a>

[`swift-build`](https://github.com/brightdigit/swift-build) represents a new approach to Swift CI/CD: **convention over configuration**. By encoding best practices into a reusable action, it eliminates the cognitive overhead of managing complex build pipelines.

The goal is simple: let developers focus on writing great Swift code, not wrestling with CI/CD configuration.

## Learn More About Continuous Integration <a id="learn-more-about-continuous-integration"></a>

Continuous integration is a fundamental practice in modern software development. If you're new to CI/CD or want to deepen your understanding, here are some excellent resources from our content library:

### Articles on Continuous Integration

- **[iOS Continuous Integration: How To Avoid Merge Hell](https://brightdigit.com/articles/ios-continuous-integration-avoid-merge-hell/)** - A comprehensive introduction to continuous integration for iOS development, covering the benefits, challenges, and best practices for avoiding "merge hell"

- **[How to automate iOS development](https://brightdigit.com/articles/ios-automation/)** - Learn about 5 automation tools you can use right now to automate your iOS development, saving time and making your code more efficient and less repetitive

### Podcast Episodes on CI/CD and Automation

- **[Episode 24: Continuous Integration with Kyle Newsome](https://share.transistor.fm/s/a14f868f)** - Deep dive into continuous integration challenges and solutions for iOS development, including deployment issues and caching strategies

- **[Episode 91: Fastlane with Josh Holtz](https://share.transistor.fm/s/8505d100)** - Learn about Fastlane, the popular automation tool for iOS deployment, with insights from the lead maintainer

- **[Episode 84: Automation Fun with Jared Sorge](https://share.transistor.fm/s/bab83e8a)** - Exploring automation tools and practices that can streamline your development workflow

- **[Episode 80: A Tour of Software Testing with Christina Moulton](https://share.transistor.fm/s/00603d96)** - Comprehensive look at testing strategies that work well with CI/CD pipelines

These resources provide the foundation for understanding why [`swift-build`](https://github.com/brightdigit/swift-build) was created and how it fits into the broader ecosystem of Swift development tools and practices.

---

Ready to simplify your Swift CI/CD? Check out [[`swift-build`](https://github.com/brightdigit/swift-build) on GitHub](https://github.com/brightdigit/swift-build) and see how it can streamline your development workflow.

