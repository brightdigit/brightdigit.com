---
title: "Swift Package Build and Test: A Comprehensive Guide to Cross-Platform CI"
description: "Learn how to set up robust CI/CD for Swift packages across macOS and Linux platforms, handle platform-specific code, and optimize build times with caching."
date: 2024-03-28 12:00
---

# Swift Package Build and Test: A Comprehensive Guide to Cross-Platform CI

In this tutorial, you'll learn how to set up a robust GitHub Action for building and testing Swift packages across different platforms. We'll walk through each step of creating a cross-platform CI pipeline and explore best practices for handling platform-specific code.

## Prerequisites

Before starting this tutorial, make sure you have:

- A Swift package hosted on GitHub
- Basic understanding of GitHub Actions
- Access to both macOS and Linux environments for testing

## Step 1: Understanding Cross-Platform Challenges

Before we dive into the implementation, let's understand what makes cross-platform Swift development challenging:

- Platform-specific APIs and features
- Different build systems (SPM vs. Xcode)
- Various testing environments
- Platform-specific dependencies

## Step 2: Creating the GitHub Action

First, create a new file in your repository at `.github/workflows/swift-build-test.yml`. This will contain our GitHub Action configuration.

### Basic Action Structure

```yaml
name: 'Swift - Build and Test'
description: 'Builds and tests a Swift package on the current platform'
```

### Configure Action Inputs

Add these input parameters to make the action flexible:

```yaml
inputs:
  working-directory:
    description: 'Directory containing the Swift package'
    required: false
    default: '.'
  scheme:
    description: 'The scheme to build and test'
    required: true
  type:
    description: 'Build type for Apple platforms'
    required: false
  xcode:
    description: 'Xcode version path'
    required: false
  deviceName:
    description: 'Simulator device name'
    required: false
  osVersion:
    description: 'Simulator OS version'
    required: false
```

## Step 3: Implementing Platform Detection

Add this script to detect the running platform:

```bash
if [[ "$RUNNER_OS" == "macOS" ]]; then
  echo "os=macos" >> $GITHUB_OUTPUT
  echo "DERIVED_DATA_PATH=$RUNNER_TEMP/DerivedData" >> $GITHUB_ENV
else
  echo "os=ubuntu" >> $GITHUB_OUTPUT
fi
```

## Step 4: Setting Up Platform-Specific Code

### Conditional Compilation

Learn how to use Swift's conditional compilation features:

1. Using the `#if` compiler directive:
```swift
#if os(macOS)
    // macOS-specific code
#elseif os(Linux)
    // Linux-specific code
#endif
```

2. Using `canImport`:
```swift
#if canImport(UIKit)
    import UIKit
    // iOS/tvOS/watchOS specific code
#elseif canImport(AppKit)
    import AppKit
    // macOS specific code
#endif
```

3. Using `@available`:
```swift
@available(macOS 11.0, *)
func macOSSpecificFunction() {
    // Function only available on macOS 11.0 and later
}
```

## Step 5: Implementing Test Handling

Add platform-specific test handling:

```swift
#if os(Linux)
    XCTSkipIf(true, "This test only runs on macOS")
#endif

// Or using test suite availability
@available(macOS 11.0, *)
class MacOSSpecificTests: XCTestCase {
    // Tests that only run on macOS 11.0 and later
}
```

## Step 6: Setting Up Caching

### SPM Cache Setup

Add this to your workflow:

```yaml
- name: Cache swift package modules
  uses: actions/cache@v4
  with:
    path: .build
    key: spm-${{ runner.os }}-${{ env.XCODE_NAME }}-${{ hashFiles('Package.resolved') }}
```

### Xcode Cache Setup

For Apple platform builds:

```yaml
- uses: irgaly/xcode-cache@v1
  with:
    key: xcode-deriveddata-${{ runner.os }}-${{ env.XCODE_NAME }}-${{ hashFiles('Package.resolved') }}
    deriveddata-directory: ${{ env.DERIVED_DATA_PATH }}
```

## Step 7: Implementing Build and Test Commands

### Linux Build Command

```bash
swift build
swift test --enable-code-coverage
```

### macOS SPM Build Command

```bash
swift build
swift test --enable-code-coverage
```

### Apple Platforms Build Command

```bash
xcodebuild test
-scheme ${{ inputs.scheme }}
-sdk ${{ env.SDK }}
-destination 'platform=${{ env.PLATFORM }},name=${{ inputs.deviceName }},OS=${{ inputs.osVersion }}'
-enableCodeCoverage YES
```

## Step 8: Implementing Best Practices

1. **Cross-Platform Testing**
   - Set up CI workflows for all target platforms
   - Create test matrices in GitHub Actions
   - Validate platform-specific code paths

2. **Platform Abstraction**
   - Create protocol-based interfaces
   - Implement platform-specific details behind common protocols
   - Use dependency injection for platform-specific components

3. **Code Organization**
   - Keep platform-specific code in separate files
   - Use clear naming conventions for platform-specific components
   - Document platform requirements in code comments

4. **Build Optimization**
   - Configure caching for all platforms
   - Minimize platform-specific code
   - Use modular architecture to speed up builds

## Testing Your Setup

1. Commit the workflow file to your repository
2. Push to GitHub to trigger the workflow
3. Check the Actions tab to monitor the build
4. Verify that tests run on all platforms
5. Review build times and cache effectiveness

## Troubleshooting Common Issues

- **Cache Not Working**: Verify cache keys and paths
- **Platform Detection Issues**: Check environment variables
- **Build Failures**: Review platform-specific dependencies
- **Test Failures**: Ensure proper test conditioning

## Next Steps

Now that you have a working cross-platform CI setup:

1. Add more platforms to your test matrix
2. Implement code coverage reporting
3. Add performance testing
4. Set up deployment workflows

## Conclusion

You've now set up a comprehensive cross-platform CI pipeline for your Swift package. This setup ensures your code works reliably across all supported platforms while maintaining efficient build times through caching.

Remember that cross-platform development is an ongoing process. Regularly review and update your CI configuration as new platforms and Swift versions become available.

## Additional Resources

- [Swift Package Manager Documentation](https://www.swift.org/package-manager/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Swift Evolution Proposals](https://apple.github.io/swift-evolution/)
- [Swift Forums - Cross Platform Development](https://forums.swift.org/c/development/1) 