---
title: Introducing swift-build: A Zero-Configuration GitHub Action for Swift Package Testing
date: 2025-09-03 00:00
description: Learn how swift-build simplifies Swift CI/CD with zero configuration, intelligent caching, and comprehensive platform support. A step-by-step breakdown of the composite GitHub Action that eliminates CI/CD complexity for Swift developers.
tags: swift, github-actions, ci-cd, swift-package-manager, xcode, testing
featuredImage: /media/tutorials/swift-build/swift-build-github-action-hero.png
subscriptionCTA: Want to stay up-to-date with the latest Swift development tools and CI/CD best practices? Sign up for our newsletter to get notified about new tutorials and tools.
---

I love continuous integration. It verifies every commit and pull request passes every check you put to it. Over the years I've used a combination of commands to ensure by Full Stack Swift packages work on a variety of platforms and OSes - whether it's a new Ubuntu distribution for hosting a server application or ensuring the last package won't break on a new Apple Vision Pro. I want my Swift code to work everywhere.

Over the years I've found manually setting up different commands and checks for different platforms tedious. I've also found ways to take advantage of caching where I can. After dealing with these challenges repeatedly across multiple projects, I decided to build something any one can use: [`swift-build`](https://github.com/brightdigit/swift-build) - a comprehensive GitHub Action that handles all the complexity for you.

## The Problem with Existing Swift CI/CD Solutions

Before `swift-build`, I've found issues when setting up continuous integration:

1. **Platform fragmentation**: Testing on Ubuntu requires different setup than macOS/iOS testing
2. **Caching complexity**: Each platform needs different caching strategies for optimal performance
3. **Configuration overhead**: Every project required extensive YAML configuration
4. **Version management**: Supporting multiple Swift versions across different platforms
5. **Repetitive setup**: Copy-pasting similar workflows across multiple repositories

## What Makes swift-build Different

`swift-build` basically needs little configuration and provides:

- **Complete platform coverage**: Ubuntu, iOS, watchOS, tvOS, visionOS, and macOS
- **Intelligent caching**: Platform-specific strategies that actually improve build times
- **Zero setup**: Works out-of-the-box with minimal configuration
- **Smart defaults**: Automatically chooses the best build approach for your scenario
- **Cutting-edge support**: [Official Swift Docker images](https://hub.docker.com/r/swiftlang/swift) for Swift 6.2 and Xcode beta testing

But the most powerful feature of `swift-build` is its matrix testing capabilities.

## 🚀 Matrix Testing: The Game Changer

**Matrix testing is where `swift-build` truly shines.** `swift-build` makes it incredibly simple to test your Swift packages across multiple platforms simultaneously.

### Why Matrix Testing Matters

Modern Swift development requires testing across multiple platforms:
- **Cross-platform packages** need to work on both Linux and Apple platforms
- **Apple ecosystem apps** should be tested on multiple versions of macOS, iOS, watchOS, tvOS, and visionOS
- **Version compatibility** requires testing against multiple Swift and Xcode versions
- **Device diversity** demands testing on different simulators and devices

### The swift-build Matrix Advantage

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

## What's a Composite Action

A [composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) is a GitHub Actions feature that allows you to combine multiple workflow steps into a single, reusable action. Think of it as a "workflow within a workflow" - instead of writing the same sequence of steps repeatedly across different repositories, you can package them into a composite action that others can use with a single line.

`swift-build` is built as a composite action, which means it encapsulates all the complexity of Swift CI/CD setup - from platform detection and caching strategies to build execution - into a single, easy-to-use action that you can drop into any workflow.

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

**What the `type` parameter does on macOS runners:**

The `type` parameter determines which Apple platform to target and triggers `xcodebuild` instead of `swift build`. When you specify a `type` (like "iOS", "watchOS", "tvOS", "visionOS", or "macOS"), the action uses Xcode's build system to run tests on the appropriate simulator or platform.

This step is crucial because different Apple platforms require different SDK configurations and simulator setups.

### Step 3: Intelligent Caching Strategy

This is where `swift-build` really shines. It implements a two-tier caching strategy:

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

### Common Issues and Solutions

1. **Scheme not found**: Ensure your scheme name matches exactly (case-sensitive). The scheme name could be the name of the Swift Package or it could be suffixed with `-Package`. You can list available schemes by running `xcodebuild -list` in your project directory.

2. **Platform issues**: Use `download-platform: true` for newer platforms like visionOS or when GitHub runners don't have the required simulators pre-installed. This will automatically download missing platform runtimes.

3. **Xcode version conflicts**: Specify explicit Xcode path with `xcode` parameter when you need a specific version. Available Xcode versions on GitHub runners can be found in the [GitHub Actions documentation](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-software).

### Getting More Help

For detailed troubleshooting guides, configuration options, and community support, check out the [swift-build README](https://github.com/brightdigit/swift-build#readme) on GitHub. The repository includes:

- Complete parameter reference
- Advanced configuration examples
- Known issues and workarounds
- Community discussions and bug reports

## Real-World Usage: How I Use swift-build

I use `swift-build` across all my Swift packages and repositories. It's not just a tool I built for others—it's the foundation of my own development workflow. Here are some examples of how it's implemented in my projects:

### BrightDigit Swift Packages
- **[ThirtyTo](https://github.com/brightdigit/ThirtyTo)** - Encode, Decode and Generate Random String in Base32Crockford Format
- **[SyntaxKit](https://github.com/brightdigit/SyntaxKit)** - More Friendly SwiftSyntax API
- **[SyndiKit](https://github.com/brightdigit/SyndiKit)** - Swift Package for Decoding RSS Feeds
- **[Sublimation](https://github.com/brightdigit/Sublimation)** - Enable automatic discovery of your local development server on the fly. Turn your Server-Side Swift app from a mysterious vapor to a tangible solid server
- **[Bushel](https://apps.apple.com/app/bushel/id1234567890)** - Available on the Mac App Store

Each of these repositories uses `swift-build` with matrix testing to ensure compatibility across:
- **Ubuntu** (for server-side Swift compatibility)
- **macOS** (for Apple platform development)
- **iOS** (for mobile app integration)
- **watchOS** (for Apple Watch support)

### The Result
By using `swift-build` consistently across all my projects, I've eliminated the CI/CD maintenance burden while ensuring comprehensive testing coverage. Every package gets the same high-quality testing pipeline with zero additional configuration.

## The Power of swift-build

`swift-build` represents a new approach to Swift CI/CD: **convention over configuration**. By encoding best practices into a reusable action, it eliminates the cognitive overhead of managing complex build pipelines.

The goal is simple: let developers focus on writing great Swift code, not wrestling with CI/CD configuration.

---

Ready to simplify your Swift CI/CD? Check out [`swift-build` on GitHub](https://github.com/brightdigit/swift-build) and see how it can streamline your development workflow.

