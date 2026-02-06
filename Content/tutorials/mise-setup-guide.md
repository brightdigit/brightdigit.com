---
title: Mise Setup Guide for BrightDigit Projects
date: 2026-02-06 12:00
description: Complete guide to setting up Mise tool version management for BrightDigit Xcode projects and Swift Packages, with real-world examples and migration patterns.
tags: mise, tooling, swift, xcode, tuist, devops, ci-cd
---

This guide shows how to set up Mise for BrightDigit Xcode projects and Swift Packages, based on production implementations across Bitness, FOD-Web-iOS, and Bushel.

## What is Mise?

Mise (formerly rtx) is a polyglot tool version manager that replaces language-specific managers like nvm, rbenv, and Mint with a single unified solution. For BrightDigit projects, it manages everything from Tuist to Node.js to Swift tooling.

**Key Benefits:**
- Single tool replaces multiple version managers
- Same configuration works locally and in CI
- Eliminates hardcoded paths in CI/CD
- Team consistency through version control

---

## For Multi-Platform App Projects

These steps apply to iOS/macOS/watchOS/tvOS projects using Tuist for Xcode project generation.

### 1. Install Mise

```bash
# Via Homebrew (recommended)
brew install mise

# Configure shell activation (zsh)
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Create `.mise.toml` at Repository Root

```toml
[settings]
# CRITICAL: Disable mise's Swift management - use system Xcode
disable_tools = ["swift"]
# Enable SPM backend for Swift tools
experimental = true
# Allow .ruby-version coexistence
idiomatic_version_file_enable_tools = ["ruby"]

[tools]
# Core tools
tuist = "4.48.0"           # Xcode project generator
ruby = "3.3.0"             # For Fastlane
node = "20.19.4"           # For web frontend

# Swift tools via SPM
"spm:swiftlang/swift-format" = "601.0.0"
"spm:peripheryapp/periphery" = "3.1.0"
"spm:apple/swift-openapi-generator" = "1.7.0"

# Linting (via core or aqua)
swiftlint = "0.58.0"

# Binary tools via UBI
"ubi:git-lfs/git-lfs" = "latest"

[tasks]
# Define common tasks
tuist = "tuist"
swiftlint = "swiftlint"
swift-format = "swift-format"
git-lfs = "git-lfs"
```

**Critical Settings Explained:**

- `disable_tools = ["swift"]` - Uses Xcode's Swift instead of mise-managed Swift
- `experimental = true` - Enables SPM backend for Swift Package tools
- `idiomatic_version_file_enable_tools = ["ruby"]` - Allows `.ruby-version` to coexist

### 3. Update `.gitignore`

Add to `.gitignore`:
```
# Mise
.mise.local.toml

# Keep these if transitioning gradually
# .ruby-version
# .nvmrc
```

### 4. Create/Update `Makefile`

```makefile
.PHONY: setup install-dependencies xcodeproject

# Install all mise tools
install-dependencies:
	@mise install

# Generate Xcode project
xcodeproject: install-dependencies
	@mise exec tuist -- tuist generate

# Main setup
setup: xcodeproject
	@echo "Development environment ready!"
```

**How It Works:**
- `make install-dependencies` installs all tools from `.mise.toml`
- `make xcodeproject` generates the Xcode project using the correct Tuist version
- `mise exec tuist --` ensures the exact version specified in `.mise.toml` is used

### 5. Update GitHub Actions Workflow

Replace multiple tool setup actions with a single mise-action:

**Before:**
```yaml
- uses: actions/setup-node@v3
  with:
    node-version: '20.19.4'
- uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.3.0'
# ...more tool setups...
```

**After:**
```yaml
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true  # If using Git LFS

      # This replaces multiple tool setup actions
      - uses: jdx/mise-action@v2
        with:
          install: true
          cache: true

      # Tools now available in PATH
      - name: Generate Xcode Project
        run: tuist generate

      - name: Lint
        run: |
          swiftlint
          swift-format lint -r .
```

### 6. Test Locally

```bash
# Install tools
mise install

# Verify installations
mise list

# Run a tool explicitly (ensures correct version)
mise exec tuist -- tuist version

# Or just use it (mise auto-adds to PATH)
tuist version

# Generate project
make xcodeproject
```

---

## For Swift Packages

Swift Packages have simpler needs than app projects.

### Option A: Minimal Mise (Just Swift Tools)

For packages that only need Swift development tools:

```toml
[settings]
disable_tools = ["swift"]
experimental = true

[tools]
"spm:swiftlang/swift-format" = "601.0.0"
swiftlint = "0.58.0"
"spm:peripheryapp/periphery" = "3.1.0"

[tasks]
swift-format = "swift-format"
swiftlint = "swiftlint"
periphery = "periphery"
```

### Option B: Keep Mint (Hybrid Approach)

Many Swift packages can continue using Mint. Only migrate to Mise if:
- Adding Node.js dependency (e.g., documentation site)
- Adding Ruby dependency (e.g., Fastlane for XCFramework distribution)
- You want unified tooling across all repositories

**When to stick with Mint:**
- Pure Swift package with no polyglot dependencies
- Team already familiar with Mint
- No CI/CD portability issues

---

## Real-World Example: Bitness Project

Complete working `.mise.toml` from production:

```toml
[tools]
tuist = "4.48.0"
ruby = "3.3.0"
node = "20.19.4"
"ubi:git-lfs/git-lfs" = "latest"
"spm:apple/swift-openapi-generator" = "1.7.0"
"spm:swiftlang/swift-format" = "601.0.0"
swiftlint = "0.58.0"
"spm:peripheryapp/periphery" = "3.1.0"

[tasks]
swift-format = "swift-format"
swiftlint = "swiftlint"
swift-openapi-generator = "swift-openapi-generator"
periphery = "periphery"
tuist = "tuist"
git-lfs = "git-lfs"

[settings]
disable_tools = ["swift"]
idiomatic_version_file_enable_tools = ["ruby"]
experimental = true
```

**Makefile integration:**
```makefile
install-dependencies:
	@mise install

xcodeproject: install-dependencies
	@./Scripts/packages.sh
	@mise exec tuist -- tuist generate --no-open
```

**GitHub Actions:**
```yaml
- uses: jdx/mise-action@v2
  with:
    install: true
    cache: true
- run: mise exec git-lfs -- git lfs pull
- run: tuist generate
```

---

## Key Patterns from Production

### ✅ Always Do This

1. **Disable Swift compiler management**: `disable_tools = ["swift"]`
2. **Enable experimental**: `experimental = true` (for SPM backend)
3. **Pin exact versions**: `tuist = "4.48.0"` not `"4.48"`
4. **Use mise-action@v2 in CI**: Replaces 5+ setup actions

### ❌ Common Pitfalls

1. **Forgetting Git LFS setup**: Add `"ubi:git-lfs/git-lfs" = "latest"` if using LFS
2. **Node version drift**: Pin exact: `node = "20.19.4"` not `"20"`
3. **Docker not ready**: Add health checks to `docker-compose.yml`
4. **Tuist mismatch**: Remove global Tuist, rely on mise version

### Backend Selection Guide

| Tool Type | Backend | Example |
|-----------|---------|---------|
| Project generators | `core` | `tuist = "4.48.0"` |
| Swift tools | `spm` | `"spm:swiftlang/swift-format" = "601.0.0"` |
| GitHub releases | `ubi` | `"ubi:git-lfs/git-lfs" = "latest"` |
| Fast binaries | `aqua` | `"aqua:realm/SwiftLint" = "0.58.0"` |

**When to use which backend:**
- **core**: First choice for popular tools (Node, Ruby, Tuist)
- **spm**: Swift Package Manager tools (swift-format, periphery)
- **ubi**: Tools distributed as GitHub releases (git-lfs, gh)
- **aqua**: Fast alternative for tools in Aqua registry

---

## Migration Checklist

- [ ] Install mise locally: `brew install mise`
- [ ] Configure shell: Add activation to `.zshrc`
- [ ] Create `.mise.toml` with critical settings
- [ ] Run `mise install` to test
- [ ] Update `.gitignore`
- [ ] Create/update `Makefile` with `install-dependencies` target
- [ ] Update GitHub Actions with `mise-action@v2`
- [ ] Test CI build
- [ ] Document in README

---

## Quick Reference Commands

```bash
# Install all tools from .mise.toml
mise install

# List installed tools
mise list

# Update a specific tool
mise install tuist@4.48.0

# Run tool explicitly (ensures correct version)
mise exec tuist -- tuist generate

# Check mise setup
mise doctor

# Clear cache if issues
rm -rf ~/.mise/cache && mise install

# Show tool versions in current directory
mise current

# Upgrade mise itself
brew upgrade mise
```

---

## Troubleshooting

### Tool Not Found After Installation

**Problem:** Installed a tool but it's not in PATH

**Solution:**
```bash
# Ensure mise is activated in your shell
mise doctor

# Manually activate mise in current session
eval "$(mise activate zsh)"

# Or use explicit exec
mise exec tuist -- tuist version
```

### SPM Tools Failing to Install

**Problem:** Swift Package tools fail to build

**Solution:**
```bash
# Ensure experimental is enabled
grep "experimental = true" .mise.toml

# Clear SPM cache
rm -rf ~/.mise/installs/spm

# Reinstall
mise install
```

### Version Mismatch in CI

**Problem:** CI uses different version than local

**Solution:**
```bash
# Commit .mise.toml
git add .mise.toml
git commit -m "Pin tool versions with mise"

# Ensure mise-action@v2 is used in workflow
grep "jdx/mise-action@v2" .github/workflows/*.yml
```

### Git LFS Files Not Downloading

**Problem:** LFS files show as pointers

**Solution:**
```bash
# Install git-lfs via mise
mise install "ubi:git-lfs/git-lfs"

# Pull LFS files
mise exec git-lfs -- git lfs pull
```

---

## Next Steps

1. **Read the comprehensive guide**: For deep-dive implementation details, see [Mise Implementation Guide for BrightDigit Repositories](/articles/mise-implementation-guide)

2. **Review production examples**: Check the Bitness, FOD-Web-iOS, or Bushel repositories for complete working configurations

3. **Join the discussion**: Share your mise setup in the BrightDigit team channel

---

## Resources

- **Mise Official Docs**: [mise.jdx.dev](https://mise.jdx.dev)
- **GitHub Action**: [jdx/mise-action](https://github.com/jdx/mise-action)
- **Comprehensive Implementation Guide**: [/articles/mise-implementation-guide](/articles/mise-implementation-guide)
- **Mise Registry**: [mise.jdx.dev/registry.html](https://mise.jdx.dev/registry.html)

---

This guide is based on production implementations across BrightDigit's app projects. For repository-specific questions or issues, consult the comprehensive implementation guide or reach out to the development team.
