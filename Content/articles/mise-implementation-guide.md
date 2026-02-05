---
date: 2026-02-05 10:00
description: Comprehensive guide for adopting Mise tool version management across BrightDigit repositories, including current state analysis, implementation guides, and CI/CD integration strategies.
tags: mise, tooling, swift, nodejs, devops, ci-cd, version-management
---

# Mise Implementation Guide for BrightDigit Repositories

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current State: Zero Mise Adoption](#2-current-state-zero-mise-adoption)
3. [What is Mise?](#3-what-is-mise)
4. [Mise Fundamentals](#4-mise-fundamentals)
5. [Repository-Specific Implementation Guides](#5-repository-specific-implementation-guides)
6. [Migration Strategy](#6-migration-strategy)
7. [CI/CD Integration](#7-cicd-integration)
8. [Best Practices](#8-best-practices)
9. [Tool Ecosystem Mapping](#9-tool-ecosystem-mapping)
10. [Complete Configuration Examples](#10-complete-configuration-examples)
11. [Troubleshooting Guide](#11-troubleshooting-guide)
12. [Future Roadmap](#12-future-roadmap)
13. [Resources and References](#13-resources-and-references)
14. [Appendix](#14-appendix)

---

## 1. Executive Summary

### Why Adopt Mise?

**Mise** (formerly rtx) is a polyglot tool version manager that provides a unified approach to managing development tool versions across multiple languages and environments. For BrightDigit's diverse repository ecosystem spanning Swift packages, Node.js tooling, and polyglot projects, Mise offers significant benefits:

**Key Benefits:**
- **Unified Management**: Single tool replaces nvm, Mint, rbenv, and language-specific version managers
- **Polyglot Support**: Manage Swift, Node.js, Python, Ruby, and 500+ other tools from one configuration
- **Zero Hardcoded Paths**: Eliminates brittle absolute paths like `/Users/leo/.nvm/versions/node/v16.14.0/bin/npm`
- **CI/CD Portability**: Same configuration works locally, in Docker, on macOS runners, and Linux build agents
- **Task Automation**: Built-in task runner for common development workflows
- **Team Consistency**: `.mise.toml` in version control ensures all developers use identical tool versions

**Current Pain Points Mise Solves:**
1. Hardcoded npm paths in `dev-server.sh` break portability
2. Multiple version files (`.swift-version`, `.nvmrc`, `Mintfile`) lack cohesion
3. Tool version drift between local development and CI environments
4. No unified approach across BrightDigit repositories
5. nvm requires shell integration; Mint downloads duplicate binaries per project

### What This Guide Covers

This comprehensive guide serves dual purposes:
1. **Current State Documentation**: Detailed analysis of existing tool version management across BrightDigit repositories
2. **Implementation Roadmap**: Step-by-step migration guides for adopting Mise organization-wide

You'll learn how to migrate three repository types:
- **brightdigit.com** (Polyglot: Swift + Node.js)
- **Swift Package Repositories** (MistKit, SyndiKit, BushelKit, etc.)
- **Organization Templates** (brightdigit/.github)

---

## 2. Current State: Zero Mise Adoption

### 2.1 Current Tool Version Management Landscape

**IMPORTANT**: As of February 2026, **no BrightDigit repositories use Mise**. This section documents the fragmented approaches currently in use.

#### brightdigit.com (Polyglot Repository)

**Location**: Primary website static site generator
**Languages**: Swift (Publish framework) + Node.js (webpack, development tooling)

**Current Version Management:**
```bash
# Swift version specification
$ cat .swift-version
5.3

# Node.js version specification
$ cat Styling/.nvmrc
16

# No Mintfile (tools not externalized)
# Hardcoded path in dev-server.sh (line 9):
NPM_PATH=/Users/leo/.nvm/versions/node/v16.14.0/bin/npm swift run brightdigitwg publish
```

**Pain Points:**
- Absolute npm path breaks on different machines, Docker containers, or CI environments
- Requires nvm installed and configured in shell profile
- No mechanism to verify webpack/webpack-cli versions
- Swift version only enforced by CI image selection

**CI/CD Configuration**:
- GitLab CI with macOS and Linux (Ubuntu Jammy) runners
- Linux jobs use `brightdigit/publish-xml` Docker image
- macOS jobs rely on host-installed Swift toolchain
- No automated tool version verification

---

#### Swift Package Repositories

**Repositories**: MistKit, SyndiKit, BushelKit, CelestraKit, RadiantKit, Spinetail, Sublimation, and 15+ others

**Current Version Management:**
```bash
# Typical Swift package structure
$ cat .swift-version
5.9

$ cat Mintfile
yonaskolb/Mint@0.17.0
nicklockwood/SwiftFormat@0.50.4
realm/SwiftLint@0.50.3
peripheryapp/periphery@2.11.0
```

**How It Works:**
- **Swift Version**: `.swift-version` read by swiftenv (if installed) or used in CI for image selection
- **Development Tools**: Mint manages SwiftFormat, SwiftLint, Periphery
  - Mint downloads binaries to `~/.mint/bin/`
  - Tools installed per-project in `.mint/` (unless global flag used)
  - Each repository duplicates tool downloads

**Pain Points:**
- Mint requires separate installation and management
- Tool binaries duplicated across projects (storage inefficiency)
- No single source of truth for all tool versions
- Mint doesn't handle Swift compiler versions
- GitHub Actions requires separate setup actions for each tool

**CI/CD Configuration**:
- GitHub Actions using `swift-actions/setup-swift` for compiler
- Mint tools installed via `mint bootstrap` in workflow
- Caching strategy required for Mint directory

---

#### brightdigit/.github (Organization Repository)

**Purpose**: Organization-wide templates, workflows, and shared configurations

**Current State:**
- No Mise templates or configuration examples
- No unified tool version management guidance
- Individual repositories implement ad-hoc solutions

**Opportunity:**
- Create standard `.mise.toml` templates for common repository types
- Provide migration guides for teams
- Establish organization-wide conventions

---

### 2.2 Tool Inventory Across Repositories

| Tool | Current Manager | Repositories Using | Version Specification |
|------|----------------|-------------------|---------------------|
| **Swift Compiler** | `.swift-version` | All Swift repos | `.swift-version` file |
| **SwiftFormat** | Mint | Swift packages | `Mintfile` |
| **SwiftLint** | Mint | Swift packages | `Mintfile` |
| **Periphery** | Mint | Swift packages (some) | `Mintfile` |
| **Node.js** | nvm | brightdigit.com | `Styling/.nvmrc` |
| **npm packages** | npm (via nvm) | brightdigit.com | `package.json` only |
| **webpack** | npm | brightdigit.com | Implicit via `package.json` |
| **netlify-cli** | Homebrew/manual | brightdigit.com CI | Not version-managed |

**Key Insight**: No single tool provides coverage across the tool matrix. Mise can unify all of these under one configuration format.

---

### 2.3 CI/CD Current State Analysis

#### GitLab CI (brightdigit.com)

**Configuration**: `.gitlab-ci.yml` with 6 stages (automate-content, build, package, deploy, test)

**Current Tool Setup:**
```yaml
# Linux jobs (Ubuntu Jammy)
build jammy:
  image: brightdigit/publish-xml  # Pre-baked Swift toolchain
  script:
    - swift build
    - swift test

# macOS jobs
build macos:
  tags:
    - macos
  script:
    - swift build  # Uses host Swift installation
    - swift test

# Deployment (macOS runner with nvm/Swift pre-installed)
deploy:
  tags:
    - macos
  script:
    - BIN_PATH=`swift build -c release --product brightdigitwg --show-bin-path`
    - ./brightdigitwg-`uname`-`arch` --mode $PUBLISHING_MODE
    - netlify deploy --site $NETLIFY_PRODUCTION_SITE_ID --auth $NETLIFY_AUTH_TOKEN $PROD_FLAG
```

**Pain Points:**
- Docker image `brightdigit/publish-xml` must be manually updated for Swift version changes
- macOS runner requires pre-configuration of Swift, nvm, Node.js
- No automated verification of tool versions matching repository specifications
- Deployment step assumes netlify-cli available on runner

---

#### GitHub Actions (Swift Packages)

**Typical Workflow**:
```yaml
name: Build and Test
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Swift setup
      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: "5.9"

      # Mint setup
      - name: Cache Mint
        uses: actions/cache@v3
        with:
          path: ~/.mint
          key: ${{ runner.os }}-mint-${{ hashFiles('**/Mintfile') }}

      - name: Install Mint
        run: |
          brew install mint
          mint bootstrap

      # Build and test
      - run: swift build
      - run: swift test

      # Linting
      - run: mint run swiftlint
      - run: mint run swiftformat --lint .
```

**Pain Points:**
- Multiple setup actions required (Swift, Mint, caching)
- Mint installation via Homebrew adds 1-2 minutes to workflow
- Each tool requires separate cache configuration
- No single source of truth for tool versions

---

### 2.4 Developer Experience Pain Points

**Local Development Issues:**

1. **Environment Setup Friction**
   - New developers must install: nvm, Mint, swiftenv (or manually manage Swift versions)
   - Each tool has different installation instructions (Homebrew, curl script, source compilation)
   - Shell profile configuration required for nvm

2. **Version Drift**
   - Developer's local Swift version may differ from CI
   - Node.js version may be newer/older than `.nvmrc` specifies
   - Mint tools may be global versions instead of project-specified versions

3. **Portability Issues**
   - Hardcoded paths in `dev-server.sh` break immediately on different machines
   - Scripts assume tools installed in specific locations
   - No easy way to replicate CI environment locally

4. **Tooling Fragmentation**
   - Different commands to activate versions: `nvm use`, `swiftenv local`, `mint run`
   - No unified way to see all tool versions at a glance
   - Each tool has separate caching and installation logic

**Team Onboarding Impact:**
- Estimated 1-2 hours to configure all tools correctly
- Common issues: nvm shell integration, Mint PATH configuration, Swift version mismatches
- No automated verification step to confirm environment correctness

---

## 3. What is Mise?

### 3.1 Introduction to Mise

**Mise** (pronounced "meez", formerly known as rtx) is a polyglot tool version manager and task runner written in Rust. It provides a unified interface for managing development tool versions across multiple languages and platforms.

**Official Description**:
> "Mise is a development environment setup tool that manages runtime versions, environment variables, and project-specific tasks. It combines the functionality of tools like nvm, rbenv, pyenv into a single fast binary."

**Key Characteristics:**
- **Polyglot**: Supports 500+ tools via backends (core, asdf, aqua, cargo, npm, vfox)
- **Fast**: Written in Rust; instant activation (no shell script overhead like nvm)
- **Cross-Platform**: Works on macOS, Linux (x86_64, aarch64), Windows (experimental)
- **ASDF-Compatible**: Can use existing asdf plugins as fallback
- **Task Runner**: Built-in Makefile/npm scripts alternative
- **Environment Management**: Set environment variables per-project

**Project Maturity** (as of Q1 2026):
- **Version**: 2024.x.x series (stable)
- **GitHub Stars**: 10k+ (rapidly growing community)
- **Maintainer**: [@jdx](https://github.com/jdx) (creator of Heroku Buildpacks)
- **Production Users**: Shopify, various YC startups, open source projects

---

### 3.2 Why Mise for BrightDigit?

#### Alignment with BrightDigit Needs

| Requirement | Current Solution | Mise Solution |
|-------------|------------------|---------------|
| Manage Swift versions | `.swift-version` + manual install | `mise install swift@5.3` |
| Manage Node.js versions | nvm + `.nvmrc` + shell integration | `mise install node@16` (instant) |
| Development tools (SwiftFormat, SwiftLint) | Mint + `Mintfile` | `mise install swiftformat@0.50.4` |
| npm CLI tools (webpack) | npm global install | `mise install npm:webpack@5` |
| CI portability | Docker images + runner pre-config | `mise install` in CI |
| Task automation | Shell scripts (`dev-server.sh`) | `mise run dev-server` |
| Environment variables | Shell export + .env files | `.mise.toml` `[env]` section |

#### Swift-Specific Considerations

**Mise Swift Support Status**:
- ✅ Swift compiler installation via core plugin
- ✅ Version specification: `swift@5.9`, `swift@latest`
- ✅ macOS and Linux support (uses official Swift.org toolchains)
- ⚠️ Limitation: Cannot install pre-release/snapshot builds (requires manual setup)

**Mint vs. Mise for Swift Tools**:

| Aspect | Mint | Mise |
|--------|------|------|
| SwiftFormat/SwiftLint | ✅ Native Swift packages | ✅ Via `cargo:` or `asdf:` plugins |
| Installation speed | Compiles from source (slow) | Pre-built binaries when available |
| Storage efficiency | Per-project `.mint/` copies | Shared `~/.mise/installs/` |
| Version locking | `Mintfile` format | `.mise.toml` or `.tool-versions` |
| CI caching | Cache `~/.mint` | Cache `~/.mise` |

**Recommendation**: Hybrid approach during transition:
1. Start by managing Swift compiler and Node.js with Mise
2. Continue using Mint for SwiftFormat/SwiftLint initially
3. Migrate Swift tools to Mise once team validates workflow

---

### 3.3 Mise vs. Alternatives

#### Comparison Matrix

| Feature | Mise | asdf | nvm + Mint + swiftenv | direnv + custom scripts |
|---------|------|------|----------------------|------------------------|
| **Languages Supported** | 500+ (core + plugins) | 600+ plugins | Node.js, Swift, Ruby (separate tools) | Any (manual scripting) |
| **Performance** | ⚡ Instant (Rust binary) | 🐢 Slow (bash scripts) | 🐢 nvm slow (shell integration) | ⚡ Fast |
| **Configuration Format** | TOML or `.tool-versions` | `.tool-versions` | Multiple formats | Custom `.envrc` |
| **Task Runner** | ✅ Built-in | ❌ External (Makefile) | ❌ External | ✅ Via scripts |
| **Environment Variables** | ✅ Built-in | ❌ Use direnv | ❌ Use direnv | ✅ Native |
| **Swift Support** | ✅ Core plugin | ✅ asdf-swift plugin | ✅ Native (swiftenv) | ⚠️ Manual setup |
| **CI/CD Friendly** | ✅ Single binary install | ⚠️ Requires setup | ❌ Multiple tools | ⚠️ Custom scripting |
| **Windows Support** | ⚠️ Experimental | ❌ WSL only | ❌ WSL only | ❌ WSL only |

**Why Not asdf?**
- asdf is mature and has larger plugin ecosystem
- However: slower performance (bash-based), less active development
- Mise is asdf-compatible (can use asdf plugins as fallback)
- Recommendation: **Choose Mise** for better performance and active development

**Why Not Continue with Mint + nvm?**
- Would require no migration effort
- However: fragmented experience, multiple tools to manage, nvm shell integration overhead
- Recommendation: **Migrate to Mise** for unified developer experience

---

## 4. Mise Fundamentals

### 4.1 Installation

#### macOS Installation

**Recommended: Homebrew**
```bash
brew install mise
```

**Alternative: Install Script**
```bash
curl https://mise.run | sh
```

**Manual Installation**
```bash
# Download latest release
curl -L https://github.com/jdx/mise/releases/latest/download/mise-macos-arm64 -o /usr/local/bin/mise
chmod +x /usr/local/bin/mise
```

**Shell Integration** (adds mise activation to shell profile):
```bash
# For bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc

# For zsh (macOS default)
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# Reload shell
exec $SHELL
```

**Verification**:
```bash
mise --version
# Output: mise 2024.x.x

mise doctor
# Checks installation, shell integration, configuration
```

---

#### Linux Installation (Ubuntu/Debian)

**APT Repository** (Recommended):
```bash
# Add mise repository
curl -fsSL https://mise.jdx.dev/gpg-key.pub | sudo gpg --dearmor -o /usr/share/keyrings/mise-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/mise-archive-keyring.gpg] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list

# Install
sudo apt update
sudo apt install mise
```

**Install Script** (Faster for CI):
```bash
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
```

**Shell Integration**:
```bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
```

---

#### CI/CD Installation

**GitLab CI Bootstrap**:
```yaml
before_script:
  - curl https://mise.run | sh
  - export PATH="$HOME/.local/bin:$PATH"
  - mise install  # Installs all tools from .mise.toml
```

**GitHub Actions (Recommended)**:
```yaml
- uses: jdx/mise-action@v2
  with:
    install: true  # Auto-installs tools from config
    cache: true    # Caches ~/.mise for faster builds
```

**Docker Image**:
```dockerfile
FROM ubuntu:22.04

# Install mise
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:${PATH}"

# Copy project configuration
COPY .mise.toml .
RUN mise install

# Rest of Dockerfile...
```

---

### 4.2 Configuration File Formats

Mise supports two configuration formats. Both can coexist in the same project.

#### Option 1: `.mise.toml` (Recommended for BrightDigit)

**Format**: TOML (Tom's Obvious Minimal Language)

**Advantages**:
- Supports all Mise features: tools, environment variables, tasks, settings
- Type-safe and structured
- Better for complex configurations
- Native format for Mise

**Basic Example**:
```toml
[tools]
swift = "5.9"
node = "20"

[env]
SWIFT_VERSION = "5.9"
NODE_ENV = "development"

[tasks.test]
run = "swift test"
```

---

#### Option 2: `.tool-versions` (asdf-compatible)

**Format**: Plain text, one tool per line

**Advantages**:
- Compatible with asdf users
- Simple and minimal
- Good for projects with only tool version requirements (no tasks/env)

**Example**:
```
swift 5.9
node 20.0.0
ruby 3.2.0
```

**Limitations**:
- Cannot specify environment variables
- Cannot define tasks
- Cannot use advanced mise settings

**Recommendation**: Use `.mise.toml` for BrightDigit repositories to take advantage of tasks and environment management.

---

### 4.3 Configuration File Precedence

Mise searches for configuration files in this order:

1. `.mise.toml` (current directory)
2. `.mise/config.toml` (current directory)
3. `.config/mise/config.toml` (current directory)
4. `.tool-versions` (current directory)
5. **Parent directories** (recursively up to home directory)
6. `~/.config/mise/config.toml` (global configuration)

**Example Directory Structure**:
```
~/Projects/
  └── brightdigit.com/
      ├── .mise.toml              # Project-specific: Swift 5.3, Node 16
      └── Sources/
          └── BrightDigitSite/
              └── (inherits Swift 5.3, Node 16 from parent)
```

**Pro Tip**: Place `.mise.toml` at repository root to ensure all subdirectories inherit tool versions.

---

### 4.4 Core Commands

#### Tool Installation

```bash
# Install all tools from .mise.toml or .tool-versions
mise install

# Install specific tool
mise install swift@5.9
mise install node@20

# Install latest version
mise install swift@latest

# Install and set as default
mise use swift@5.9  # Creates/updates .mise.toml
mise use -g swift@5.9  # Sets globally in ~/.config/mise/config.toml
```

---

#### Listing Tools

```bash
# List all available tools
mise ls-remote swift
mise ls-remote node

# List installed versions
mise ls

# Example output:
# swift 5.9.0 ~/Projects/brightdigit.com/.mise.toml swift 5.9
# node  20.0.0 ~/Projects/brightdigit.com/.mise.toml node 20
```

---

#### Running Commands with Specific Versions

```bash
# Run command with mise-managed tools in PATH
mise exec -- swift build
mise exec -- npm install
mise exec -- swiftlint

# Shorthand (if mise shell integration active)
swift build  # Automatically uses mise-managed Swift
npm install  # Automatically uses mise-managed Node.js
```

**How It Works**:
- `mise exec` temporarily sets PATH to include mise-managed tool directories
- Shell integration (via `mise activate`) automatically does this for every command
- No manual PATH manipulation needed

---

#### Environment Management

```bash
# Show environment variables mise would set
mise env

# Export environment for current shell
eval "$(mise env)"

# Run command with mise environment
mise exec -- printenv | grep SWIFT
```

**Example `.mise.toml` with Environment Variables**:
```toml
[tools]
swift = "5.9"

[env]
SWIFT_VERSION = "5.9"
SWIFT_BUILD_FLAGS = "-c release"
LOG_LEVEL = "debug"

# Template syntax supported
[env]
PROJECT_ROOT = "{{config_root}}"
BUILD_DIR = "{{config_root}}/.build"
```

---

#### Task Runner

```bash
# List available tasks
mise tasks

# Run a task
mise run build
mise run test

# Run with arguments
mise run lint -- --strict
```

**Example `.mise.toml` with Tasks**:
```toml
[tasks.build]
run = "swift build -c release"
description = "Build for release"

[tasks.test]
run = "swift test --parallel"
description = "Run unit tests in parallel"

[tasks.lint]
run = """
swiftformat --lint .
swiftlint lint --strict
"""
description = "Run linting tools"

[tasks.dev-server]
run = "./dev-server.sh"
description = "Start development server with hot reload"
```

**Advantages over Shell Scripts**:
- Self-documenting (descriptions shown in `mise tasks`)
- Automatic tool version management
- Cross-platform (no bash-isms needed)
- Built-in dependency support (tasks can depend on other tasks)

---

### 4.5 Swift-Specific Usage

#### Installing Swift Compiler

```bash
# Install specific version
mise install swift@5.9

# Install latest stable
mise install swift@latest

# Pin version in project
mise use swift@5.9  # Creates/updates .mise.toml
```

**Behind the Scenes**:
- Downloads official toolchain from Swift.org
- Extracts to `~/.mise/installs/swift/5.9/`
- Symlinks binaries (`swift`, `swiftc`, `sourcekit-lsp`) to shim directory
- Adds to PATH via `mise activate` or `mise exec`

---

#### Swift Package Development Workflow

```bash
# Project setup
cd ~/Projects/MistKit
echo '[tools]\nswift = "5.9"' > .mise.toml
mise install

# Development
mise exec -- swift build
mise exec -- swift test
mise exec -- swift run mistkit

# If shell integration active (mise activate), just use:
swift build
swift test
```

---

#### Swift Version Compatibility

**Supported Swift Versions** (as of Mise 2024.x):
- ✅ Swift 5.0 - 5.10 (official releases)
- ✅ macOS and Linux (x86_64, aarch64)
- ⚠️ Windows: Not supported (Swift Windows support is limited)
- ❌ Swift 6.0 snapshots: Requires manual installation

**Fallback for Snapshots**:
```toml
# .mise.toml
[tools]
# Use mise for stable versions
swift = "5.9"

# Use manual installation for snapshots
[env]
TOOLCHAINS = "swift"  # macOS: Use manually installed snapshot

[tasks.use-snapshot]
run = """
export TOOLCHAINS=swift
swift --version
"""
```

---

## 5. Repository-Specific Implementation Guides

### 5.1 brightdigit.com (Polyglot Repository)

#### 5.1.1 Current State Recap

**Repository**: https://gitlab.com/BrightDigit/Public/brightdigit.com
**Purpose**: Static site generator for BrightDigit website (Swift + Node.js)

**Current Version Management**:
- Swift 5.3 (`.swift-version`)
- Node.js 16 (`Styling/.nvmrc`)
- Hardcoded npm path in `dev-server.sh` line 9:
  ```bash
  NPM_PATH=/Users/leo/.nvm/versions/node/v16.14.0/bin/npm swift run brightdigitwg publish
  ```

**Key Files**:
- `/dev-server.sh` - Development server with file watching
- `/.gitlab-ci.yml` - CI/CD pipeline (6 stages)
- `/Package.swift` - Swift package manifest
- `/Styling/package.json` - npm dependencies (webpack, webpack-cli)

---

#### 5.1.2 Migration Strategy

**Approach**: Additive migration with backward compatibility

1. **Phase 1**: Add `.mise.toml` alongside existing version files
2. **Phase 2**: Update `dev-server.sh` to use `mise exec`
3. **Phase 3**: Add mise to GitLab CI (Docker or bootstrap)
4. **Phase 4**: (Optional) Deprecate `.swift-version` and `.nvmrc` after validation

**Why Additive?**
- Existing workflows continue to work during transition
- Allows gradual team adoption
- Easy rollback if issues discovered
- CI remains functional throughout migration

---

#### 5.1.3 Step-by-Step Migration

**Step 1: Create `.mise.toml` Configuration**

Create `.mise.toml` at repository root:

```toml
# .mise.toml for brightdigit.com
# Polyglot project: Swift static site generator + Node.js tooling

[tools]
# Swift compiler for Publish framework
swift = "5.3"

# Node.js for webpack and build tooling
node = "16"

# npm packages (global CLI tools)
"npm:webpack" = "5.69"
"npm:webpack-cli" = "4.9"

[env]
# Environment variables
SWIFT_VERSION = "5.3"
NODE_ENV = "development"
NPM_CONFIG_PREFIX = "{{config_root}}/node_modules"

# Project paths
PROJECT_ROOT = "{{config_root}}"
CONTENT_DIR = "{{config_root}}/Content"
OUTPUT_DIR = "{{config_root}}/Output"

[settings]
# Automatically install tools on directory change
auto_install = true

# Show tool versions in prompt (optional)
verbose = false

[tasks.build]
run = "swift build -c release --product brightdigitwg"
description = "Build brightdigitwg executable for release"

[tasks.test]
run = "swift test"
description = "Run Swift unit tests"

[tasks.dev-server]
run = "./dev-server.sh"
description = "Start development server with hot reload"

[tasks.publish]
run = "swift run brightdigitwg publish"
description = "Generate static site in Output/"

[tasks.import-mailchimp]
run = """
swift run brightdigitwg import mailchimp \
  --mailchimp-api-key=$MAILCHIMP_API_KEY \
  --mailchimp-list-id=$MAILCHIMP_LIST_ID \
  --export-markdown-directory=Content/newsletters
"""
description = "Import newsletters from Mailchimp"

[tasks.import-podcast]
run = """
swift run brightdigitwg import podcast \
  --youtube-api-key=$YOUTUBE_API_KEY \
  --export-markdown-directory Content/episodes
"""
description = "Import podcast episodes from YouTube"
```

**Install Tools**:
```bash
# From repository root
mise install

# Verify installation
mise ls
# Output:
# swift 5.3.0   ~/Projects/brightdigit.com/.mise.toml swift 5.3
# node  16.20.0 ~/Projects/brightdigit.com/.mise.toml node 16
```

---

**Step 2: Update `dev-server.sh`**

**Current Content** (`dev-server.sh`):
```bash
daemon() {
    chsum1=""

    while [[ true ]]
    do
        chsum2=`find Content/ -type f -exec md5 {} \;`
        if [[ $chsum1 != $chsum2 ]] ; then
            if [ -n "$chsum1" ]; then
                NPM_PATH=/Users/leo/.nvm/versions/node/v16.14.0/bin/npm swift run brightdigitwg publish
            fi
            chsum1=$chsum2
        fi
        sleep 2
    done
}

daemon
```

**Updated with Mise** (Option A: mise exec):
```bash
#!/bin/bash
# dev-server.sh - Development server with hot reload
# Uses mise for portable tool version management

daemon() {
    chsum1=""

    while [[ true ]]
    do
        chsum2=`find Content/ -type f -exec md5 {} \;`
        if [[ $chsum1 != $chsum2 ]] ; then
            if [ -n "$chsum1" ]; then
                # Use mise exec to run with correct tool versions
                mise exec -- npm --version >/dev/null && swift run brightdigitwg publish
            fi
            chsum1=$chsum2
        fi
        sleep 2
    done
}

daemon
```

**Updated with Mise** (Option B: mise tasks - Recommended):
```bash
#!/bin/bash
# dev-server.sh - Development server with hot reload
# Uses mise for portable tool version management

daemon() {
    chsum1=""

    while [[ true ]]
    do
        chsum2=`find Content/ -type f -exec md5 {} \;`
        if [[ $chsum1 != $chsum2 ]] ; then
            if [ -n "$chsum1" ]; then
                # Use mise run to execute publish task
                mise run publish
            fi
            chsum1=$chsum2
        fi
        sleep 2
    done
}

daemon
```

**Benefits**:
- No hardcoded paths - works on any machine
- Tool versions automatically match `.mise.toml`
- Same script works locally and in CI

---

**Step 3: Test Local Development Workflow**

```bash
# Activate mise in current shell (if not in shell profile)
eval "$(mise activate bash)"

# Build project
mise run build
# Or directly:
swift build -c release --product brightdigitwg

# Run development server
mise run dev-server
# Or directly:
./dev-server.sh

# Generate site
mise run publish

# Import content
MAILCHIMP_API_KEY=xxx MAILCHIMP_LIST_ID=yyy mise run import-mailchimp
```

**Verification Checklist**:
- [ ] `mise ls` shows Swift 5.3 and Node 16 installed
- [ ] `swift --version` outputs Swift 5.3
- [ ] `node --version` outputs v16.x.x
- [ ] `dev-server.sh` runs without errors
- [ ] Site builds successfully in `Output/`
- [ ] Hot reload triggers on content changes

---

**Step 4: Update GitLab CI Configuration**

**Option A: Bootstrap Mise in CI** (Faster, no Docker changes):

Update `.gitlab-ci.yml`:

```yaml
# Add mise bootstrap to before_script for relevant jobs

.mise_bootstrap: &mise_bootstrap
  - curl https://mise.run | sh
  - export PATH="$HOME/.local/bin:$PATH"
  - mise install
  - mise --version

# Apply to build jobs
build jammy:
  image: brightdigit/publish-xml
  before_script:
    - *mise_bootstrap
  script:
    - mise exec -- swift build
    - mise exec -- swift test

build macos:
  tags:
    - macos
  before_script:
    - *mise_bootstrap
  script:
    - mise exec -- swift build
    - mise exec -- swift test

# Apply to deployment
deploy:
  tags:
    - macos
  before_script:
    - *mise_bootstrap
  script:
    - if [ "$CI_COMMIT_REF_NAME" = "main" ]; then PUBLISHING_MODE=production; else PUBLISHING_MODE=drafts; fi
    - if [ "$CI_COMMIT_REF_NAME" = "main" ]; then PROD_FLAG="--prod"; else PROD_FLAG=""; fi
    - mise run build
    - cp .build/release/brightdigitwg brightdigitwg-`uname`-`arch`
    - ./brightdigitwg-`uname`-`arch` --mode $PUBLISHING_MODE
    - netlify deploy --site $NETLIFY_PRODUCTION_SITE_ID --auth $NETLIFY_AUTH_TOKEN $PROD_FLAG
```

**Option B: Update Docker Image** (Better long-term):

Update `brightdigit/publish-xml` Dockerfile to include mise:

```dockerfile
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install mise
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:${PATH}"

# Install Swift (via mise or traditional method)
RUN mise install swift@5.3

# Set up environment
RUN mise activate bash >> ~/.bashrc

WORKDIR /workspace
```

Then simplify `.gitlab-ci.yml`:
```yaml
build jammy:
  image: brightdigit/publish-xml  # Now includes mise
  script:
    - mise install  # Installs tools from .mise.toml
    - mise exec -- swift build
    - mise exec -- swift test
```

---

**Step 5: Update Documentation**

Add to `CLAUDE.md`:

```markdown
## Development Commands

### Tool Version Management (Mise)

This project uses [Mise](https://mise.jdx.dev) for managing Swift and Node.js versions.

```bash
# Install/update tools to versions specified in .mise.toml
mise install

# Verify installed versions
mise ls

# Run commands with mise-managed tools
mise exec -- swift build
mise exec -- node --version
```

### Building and Testing
```bash
# Using mise tasks (recommended)
mise run build    # Build for release
mise run test     # Run tests
mise run publish  # Generate static site

# Or directly with mise-managed tools
swift build -c release --product brightdigitwg
swift test
```
```

---

#### 5.1.4 Rollback Strategy

If issues arise during migration:

**Step 1: Revert `dev-server.sh`**
```bash
git checkout HEAD -- dev-server.sh
```

**Step 2: Remove Mise from CI**
```bash
git checkout HEAD -- .gitlab-ci.yml
```

**Step 3: Continue using nvm and .swift-version**
- `.mise.toml` can remain in repository (inert if mise not installed)
- No impact on existing workflows

**Step 4: Document Issues**
- Create GitLab issue with error messages
- Share with team before next attempt

---

### 5.2 Swift Package Repositories (MistKit, SyndiKit, etc.)

#### 5.2.1 Current State Recap

**Repositories**: 15+ Swift packages including:
- MistKit (async/await utilities)
- SyndiKit (RSS/Atom parsing)
- BushelKit (Package.swift utilities)
- CelestraKit (OpenAPI client)
- RadiantKit (publishing tooling)
- Spinetail (Mailchimp client)

**Current Version Management**:
```bash
# Typical structure
.swift-version      # Swift 5.9
Mintfile            # SwiftFormat 0.50.4, SwiftLint 0.50.3, Periphery 2.11.0
```

**CI/CD**: GitHub Actions with `swift-actions/setup-swift` and Mint bootstrap

---

#### 5.2.2 Migration Strategy

**Approach**: Hybrid Mise + Mint (transitional)

1. **Phase 1**: Adopt mise for Swift compiler version only
2. **Phase 2**: Keep Mint for development tools (SwiftFormat, SwiftLint)
3. **Phase 3**: (Future) Migrate tools to mise once ecosystem matures

**Why Hybrid?**
- Mint has excellent Swift package support
- Swift tool availability in mise is still maturing
- Reduces risk by changing one thing at a time
- Allows team to validate mise workflow before full migration

---

#### 5.2.3 Step-by-Step Migration (Example: MistKit)

**Step 1: Create `.mise.toml`**

```toml
# .mise.toml for MistKit
# Swift async/await utilities package

[tools]
# Swift compiler version
swift = "5.9"

# Note: SwiftFormat, SwiftLint still managed by Mint (see Mintfile)
# Future: Migrate to mise when plugins mature

[env]
SWIFT_VERSION = "5.9"
LOG_LEVEL = "info"

[settings]
auto_install = true

[tasks.build]
run = "swift build"
description = "Build the package"

[tasks.test]
run = "swift test --parallel"
description = "Run unit tests in parallel"

[tasks.lint]
run = """
mint run swiftformat --lint .
mint run swiftlint lint --strict
"""
description = "Run linting tools (via Mint)"

[tasks.format]
run = "mint run swiftformat ."
description = "Format code with SwiftFormat"

[tasks.ci]
run = """
swift build
swift test --parallel
mint run swiftformat --lint .
mint run swiftlint lint
"""
description = "Full CI pipeline locally"
```

**Keep Existing `Mintfile`** (during transition):
```
yonaskolb/Mint@0.17.0
nicklockwood/SwiftFormat@0.50.4
realm/SwiftLint@0.50.3
peripheryapp/periphery@2.11.0
```

**Install Tools**:
```bash
mise install
mint bootstrap
```

---

**Step 2: Update GitHub Actions Workflow**

**Before** (`.github/workflows/build.yml`):
```yaml
name: Build and Test
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: "5.9"

      - name: Cache Mint
        uses: actions/cache@v3
        with:
          path: ~/.mint
          key: ${{ runner.os }}-mint-${{ hashFiles('**/Mintfile') }}

      - name: Install Mint
        run: |
          brew install mint
          mint bootstrap

      - run: swift build
      - run: swift test
      - run: mint run swiftlint
      - run: mint run swiftformat --lint .
```

**After (with Mise + Mint hybrid)**:
```yaml
name: Build and Test
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Install mise (Swift compiler)
      - uses: jdx/mise-action@v2
        with:
          version: latest
          install: true
          cache: true

      # Cache Mint (development tools)
      - name: Cache Mint
        uses: actions/cache@v3
        with:
          path: ~/.mint
          key: ${{ runner.os }}-mint-${{ hashFiles('**/Mintfile') }}

      # Install Mint
      - name: Install Mint
        run: |
          brew install mint
          mint bootstrap

      # Build and test with mise-managed Swift
      - run: mise exec -- swift build
      - run: mise exec -- swift test --parallel

      # Linting with Mint-managed tools
      - run: mint run swiftlint lint --strict
      - run: mint run swiftformat --lint .
```

**Benefits**:
- Single action (`jdx/mise-action`) replaces `swift-actions/setup-swift`
- Automatic caching of mise installations
- Swift version controlled by `.mise.toml` (single source of truth)
- Mint still available for mature Swift tooling

---

**Step 3: Update README**

Add installation instructions:

```markdown
## Development Setup

### Prerequisites

- [Mise](https://mise.jdx.dev) - Tool version manager
- [Mint](https://github.com/yonaskolb/Mint) - Swift tool installer

### Installation

```bash
# Install mise (macOS)
brew install mise

# Install mint
brew install mint

# Clone repository
git clone https://github.com/brightdigit/MistKit.git
cd MistKit

# Install tools
mise install  # Installs Swift 5.9
mint bootstrap  # Installs SwiftFormat, SwiftLint, Periphery
```

### Development Commands

```bash
# Build
mise run build

# Test
mise run test

# Lint
mise run lint

# Format code
mise run format

# Run full CI pipeline locally
mise run ci
```
```

---

**Step 4: Test Locally**

```bash
# Verify mise-managed Swift
mise ls
swift --version  # Should show Swift 5.9

# Run development tasks
mise run build
mise run test
mise run lint

# Verify Mint tools still work
mint run swiftlint --version
mint run swiftformat --version
```

---

#### 5.2.4 Future Migration: Mint → Mise Fully

**When to Consider**:
- Mise Swift tool plugins mature (asdf-swiftformat, asdf-swiftlint)
- Team comfortable with mise workflow
- Want to eliminate Mint dependency

**How to Migrate**:

1. **Research Plugin Availability**:
```bash
mise registry
mise plugins ls-remote | grep swift
```

2. **Add Tools to `.mise.toml`**:
```toml
[tools]
swift = "5.9"
# Experimental: Use asdf plugins for Swift tools
"asdf:swiftformat" = "0.50.4"
"asdf:swiftlint" = "0.50.3"
```

3. **Remove Mintfile**

4. **Update Workflows to Remove Mint**:
```yaml
# GitHub Actions
- uses: jdx/mise-action@v2
  with:
    install: true  # Installs Swift + all tools from .mise.toml

- run: mise exec -- swift build
- run: mise exec -- swift test
- run: mise exec -- swiftlint lint
- run: mise exec -- swiftformat --lint .
```

---

### 5.3 brightdigit/.github (Organization Templates)

#### 5.3.1 Current State

**Repository**: https://github.com/brightdigit/.github
**Purpose**: Organization-wide GitHub templates, workflows, and shared configurations

**Current Content**:
- Issue templates
- Pull request templates
- Code of conduct, contributing guidelines
- **No tool version management templates**

---

#### 5.3.2 Implementation Plan

**Goal**: Provide standard `.mise.toml` templates for common BrightDigit repository types

**New Files to Create**:

1. `templates/mise/swift-package.mise.toml` - Template for Swift packages
2. `templates/mise/polyglot-project.mise.toml` - Template for multi-language projects
3. `docs/mise-adoption-guide.md` - Organization-wide adoption guide
4. `workflows/mise-build.yml` - GitHub Actions workflow template using mise

---

#### 5.3.3 Template Files

**File 1: `templates/mise/swift-package.mise.toml`**

```toml
# .mise.toml template for BrightDigit Swift Packages
# Copy this file to your repository root and adjust versions as needed

[tools]
# Swift compiler version
# Update to match your Package.swift minimum version
swift = "5.9"

# Optional: Swift development tools (if not using Mint)
# "asdf:swiftformat" = "0.50.4"
# "asdf:swiftlint" = "0.50.3"

[env]
# Environment variables
SWIFT_VERSION = "{{tools.swift}}"
LOG_LEVEL = "info"

[settings]
# Automatically install tools when entering directory
auto_install = true

# Tasks for common development workflows
[tasks.build]
run = "swift build"
description = "Build the package"

[tasks.test]
run = "swift test --parallel"
description = "Run unit tests in parallel"

[tasks.clean]
run = "swift package clean"
description = "Clean build artifacts"

[tasks.resolve]
run = "swift package resolve"
description = "Resolve package dependencies"

[tasks.update]
run = "swift package update"
description = "Update package dependencies"

[tasks.lint]
run = """
mint run swiftformat --lint .
mint run swiftlint lint --strict
"""
description = "Run linting tools (requires Mint)"

[tasks.format]
run = "mint run swiftformat ."
description = "Format code (requires Mint)"

[tasks.ci]
run = """
swift build
swift test --parallel
"""
description = "Full CI pipeline locally"
```

---

**File 2: `templates/mise/polyglot-project.mise.toml`**

```toml
# .mise.toml template for BrightDigit Polyglot Projects
# Supports Swift + Node.js + other languages
# Copy this file to your repository root and adjust as needed

[tools]
# Swift compiler
swift = "5.9"

# Node.js runtime
node = "20"

# Optional: npm global CLI tools
# "npm:webpack" = "latest"
# "npm:eslint" = "8"

# Optional: Other languages
# python = "3.11"
# ruby = "3.2"

[env]
# Environment variables
SWIFT_VERSION = "{{tools.swift}}"
NODE_ENV = "development"
PROJECT_ROOT = "{{config_root}}"

[settings]
auto_install = true

# Tasks
[tasks.build]
run = "swift build"
description = "Build Swift components"

[tasks.build-js]
run = "npm run build"
description = "Build JavaScript/TypeScript components"

[tasks.test]
run = "swift test"
description = "Run Swift tests"

[tasks.test-js]
run = "npm test"
description = "Run JavaScript tests"

[tasks.lint]
run = """
swiftformat --lint .
eslint .
"""
description = "Run all linters"

[tasks.dev]
run = "./dev-server.sh"
description = "Start development server"
```

---

**File 3: `docs/mise-adoption-guide.md`**

```markdown
# Mise Adoption Guide for BrightDigit Repositories

## Overview

This guide helps BrightDigit teams adopt [Mise](https://mise.jdx.dev) for tool version management across repositories.

## Quick Start

### 1. Install Mise

**macOS:**
```bash
brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
exec $SHELL
```

**Linux:**
```bash
curl https://mise.run | sh
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Choose Template

Pick the template that matches your repository:

- **Swift Package**: [swift-package.mise.toml](../templates/mise/swift-package.mise.toml)
- **Polyglot Project**: [polyglot-project.mise.toml](../templates/mise/polyglot-project.mise.toml)

### 3. Copy to Repository

```bash
cd ~/Projects/YourRepo
cp ../brightdigit/.github/templates/mise/swift-package.mise.toml .mise.toml
```

### 4. Install Tools

```bash
mise install
mise ls
```

### 5. Update CI/CD

**GitHub Actions:**
```yaml
- uses: jdx/mise-action@v2
  with:
    install: true
    cache: true
```

**GitLab CI:**
```yaml
before_script:
  - curl https://mise.run | sh
  - export PATH="$HOME/.local/bin:$PATH"
  - mise install
```

## Repository-Specific Guides

See the [full Mise Implementation Guide](https://brightdigit.com/articles/mise-implementation-guide/) for detailed instructions on:

- Migrating brightdigit.com (Swift + Node.js)
- Migrating Swift packages (with Mint hybrid approach)
- CI/CD integration strategies
- Troubleshooting common issues

## Support

Questions? Open an issue in the relevant repository or contact the DevOps team.
```

---

**File 4: `workflows/mise-build.yml`**

```yaml
# GitHub Actions workflow template using Mise
# Copy to .github/workflows/ in your repository

name: Build and Test (Mise)

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install and configure Mise
        uses: jdx/mise-action@v2
        with:
          version: latest
          install: true  # Auto-installs tools from .mise.toml
          cache: true    # Caches ~/.mise for faster builds

      - name: Verify tool versions
        run: |
          mise ls
          swift --version

      - name: Build
        run: mise run build

      - name: Test
        run: mise run test

      - name: Lint (if configured)
        run: mise run lint
        continue-on-error: true
```

---

#### 5.3.4 Rollout Communication

**Create GitHub Discussion** in brightdigit/.github:

**Title**: "Introducing Mise for Tool Version Management"

**Body**:
```markdown
## 🎯 Proposal: Adopt Mise for Tool Version Management

Hi BrightDigit team! We're proposing to adopt [Mise](https://mise.jdx.dev) as our standard tool version manager across all repositories.

### Why Mise?

- **Unified Management**: Single tool replaces nvm, Mint, swiftenv
- **Fast**: Written in Rust, instant activation
- **Polyglot**: Manage Swift, Node.js, Ruby, Python, and 500+ tools
- **CI-Friendly**: Same config works locally and in GitHub Actions/GitLab CI

### What's Available Now

- ✅ [Swift Package Template](templates/mise/swift-package.mise.toml)
- ✅ [Polyglot Project Template](templates/mise/polyglot-project.mise.toml)
- ✅ [Adoption Guide](docs/mise-adoption-guide.md)
- ✅ [GitHub Actions Workflow Template](workflows/mise-build.yml)

### Migration Approach

**Phased rollout**:
1. **Pilot**: brightdigit.com (Leo + volunteers)
2. **Swift Packages**: Start with 2-3 active repos (MistKit, SyndiKit)
3. **Organization-wide**: Roll out to remaining repos

### Backward Compatibility

- `.swift-version` and `Mintfile` remain during transition
- Mint can coexist with Mise (hybrid approach)
- Easy rollback if issues arise

### Get Involved

- **Try it**: Install mise and test with template
- **Feedback**: Comment below with questions/concerns
- **Volunteer**: Help pilot Mise in one of your repositories

Full documentation: [Mise Implementation Guide](https://brightdigit.com/articles/mise-implementation-guide/)
```

---

## 6. Migration Strategy

### 6.1 Phased Rollout Plan

#### Phase 1: Pilot (brightdigit.com) - Q1 2026

**Objective**: Validate Mise in production environment with polyglot project

**Repositories**: 1 (brightdigit.com)

**Steps**:
1. Leo creates `.mise.toml` alongside existing version files
2. Update `dev-server.sh` to use `mise exec`
3. Test local development workflow (1 week)
4. Add mise to GitLab CI (bootstrap approach)
5. Monitor CI performance and stability (2 weeks)
6. Document lessons learned and edge cases

**Success Criteria**:
- [ ] Local development workflow identical to before
- [ ] CI builds pass consistently
- [ ] No performance regression (build times)
- [ ] Team members can replicate environment
- [ ] Documentation complete

**Rollback Plan**: Remove mise from CI, revert `dev-server.sh`, continue using nvm

**Duration**: 4 weeks

---

#### Phase 2: Swift Packages - Q2 2026

**Objective**: Validate Mise for Swift-only projects with GitHub Actions

**Repositories**: 2-3 active packages (MistKit, SyndiKit, BushelKit)

**Steps**:
1. Create `.mise.toml` for Swift version only (keep Mint)
2. Update GitHub Actions to use `jdx/mise-action`
3. Test build, test, and lint workflows
4. Gather feedback from contributors
5. Iterate on templates based on learnings

**Success Criteria**:
- [ ] GitHub Actions workflows faster or equivalent
- [ ] No regressions in test coverage or lint checks
- [ ] Contributors report easier setup process
- [ ] Templates refined based on real-world usage

**Rollback Plan**: Revert to `swift-actions/setup-swift`, keep `.mise.toml` (inert)

**Duration**: 6 weeks

---

#### Phase 3: Organization-Wide Adoption - Q3-Q4 2026

**Objective**: Roll out Mise across all BrightDigit repositories

**Repositories**: Remaining Swift packages (10+), documentation repos, infrastructure repos

**Steps**:
1. Publish templates in brightdigit/.github
2. Create organization-wide announcement (GitHub Discussion)
3. Offer team training sessions (Zoom/recorded)
4. Provide migration support (office hours)
5. Update CLAUDE.md files across repositories
6. Gradual deprecation of `.swift-version` files (6 months buffer)

**Success Criteria**:
- [ ] 80%+ of active repositories using Mise
- [ ] Updated CI/CD configurations
- [ ] Team members comfortable with mise commands
- [ ] Documentation complete and discoverable

**Duration**: 16 weeks (phased per repository)

---

### 6.2 Pre-Migration Checklist

Use this checklist before migrating any repository:

**Environment Audit**:
- [ ] Identify all tools and versions currently in use
- [ ] List version specification files (`.swift-version`, `.nvmrc`, `Mintfile`)
- [ ] Document custom tool installation scripts
- [ ] Identify hardcoded paths in scripts (use `grep -r "/.nvm/\|/.mint/" .`)

**CI/CD Audit**:
- [ ] List all CI platforms (GitHub Actions, GitLab CI, etc.)
- [ ] Document current tool installation methods
- [ ] Identify caching strategies
- [ ] Note any custom Docker images with pre-installed tools

**Team Readiness**:
- [ ] Announce migration plan to team
- [ ] Provide mise installation instructions
- [ ] Schedule optional training session
- [ ] Designate migration lead (point person for questions)

**Backup Plan**:
- [ ] Create feature branch for migration work
- [ ] Document rollback steps
- [ ] Ensure `.swift-version`/`.nvmrc` remain during transition
- [ ] Plan for parallel testing (mise + existing approach)

---

### 6.3 Migration Execution Template

Use this template for each repository migration:

```markdown
## Migration: [Repository Name] to Mise

### Repository Info
- **URL**: [GitHub/GitLab URL]
- **Type**: [Swift Package / Polyglot / Other]
- **Current Tools**: [List tools and versions]
- **CI Platform**: [GitHub Actions / GitLab CI]

### Pre-Migration State
- [ ] Audit complete (checklist above)
- [ ] Branch created: `feature/migrate-to-mise`
- [ ] Team notified

### Migration Steps
- [ ] Create `.mise.toml` from template
- [ ] Install tools locally: `mise install`
- [ ] Verify: `mise ls` matches expected versions
- [ ] Update scripts to use `mise exec` (if needed)
- [ ] Test local build/test/lint workflows
- [ ] Update CI configuration
- [ ] Test CI build (push to feature branch)
- [ ] Update README/documentation
- [ ] Create pull request

### Post-Migration Verification
- [ ] CI builds pass on feature branch
- [ ] Local development workflow tested by 2+ team members
- [ ] Performance benchmarks (build time) within 10% of baseline
- [ ] Documentation reviewed

### Rollback Trigger
If any of these occur within 1 week of merge:
- CI failure rate > 5%
- Team reports broken local workflows
- Performance regression > 20%

Then execute rollback: `git revert [merge commit]`

### Sign-Off
- Migration Lead: [Name]
- Date Completed: [YYYY-MM-DD]
- Issues Encountered: [Link to any bugs filed]
```

---

### 6.4 Rollback Procedures

#### Scenario 1: Local Development Issues

**Symptoms**: Developers unable to build/test locally with mise

**Rollback**:
1. Continue using pre-existing tools (nvm, Mint, swiftenv)
2. `.mise.toml` can remain (inert if mise not installed)
3. Document issue in GitHub/GitLab issue tracker

**Recovery**: Fix issue, re-test locally, resume migration

---

#### Scenario 2: CI Build Failures

**Symptoms**: CI builds fail after mise integration

**Rollback**:
```bash
# Revert CI configuration changes
git revert [commit hash of CI update]

# Or manually restore previous CI config
git checkout [previous commit] -- .github/workflows/build.yml
git checkout [previous commit] -- .gitlab-ci.yml
```

**Recovery**: Debug CI locally using Docker, fix configuration, reapply

---

#### Scenario 3: Tool Version Mismatches

**Symptoms**: Mise installs wrong version, incompatible behavior

**Rollback**:
1. Verify `.mise.toml` versions match previous specs
2. Try manual version install: `mise install swift@5.9.0` (pin exact version)
3. If persistent, use legacy tools temporarily

**Recovery**: File issue with mise project, find workaround or alternative plugin

---

## 7. CI/CD Integration

### 7.1 GitLab CI Integration

#### Option A: Bootstrap Script (Recommended for Pilot)

**Advantages**:
- No Docker image changes required
- Fast to implement
- Easy to revert

**Disadvantages**:
- Adds ~30 seconds to build time (mise download + install)
- Requires internet access during build

**Implementation**:

```yaml
# .gitlab-ci.yml

# Define reusable bootstrap script
.mise_bootstrap:
  before_script:
    - echo "Installing mise..."
    - curl -fsSL https://mise.run | sh
    - export PATH="$HOME/.local/bin:$PATH"
    - mise --version
    - echo "Installing tools from .mise.toml..."
    - mise install
    - echo "Tool versions:"
    - mise ls

# Apply to build job
build jammy:
  stage: build
  image: ubuntu:22.04  # Or continue using brightdigit/publish-xml
  extends: .mise_bootstrap
  script:
    - mise exec -- swift build
    - mise exec -- swift test

# Apply to macOS build
build macos:
  stage: build
  tags:
    - macos
  extends: .mise_bootstrap
  script:
    - mise exec -- swift build
    - mise exec -- swift test

# Apply to deployment
deploy:
  stage: deploy
  tags:
    - macos
  extends: .mise_bootstrap
  script:
    - mise run build
    - mise run publish
    - netlify deploy --site $NETLIFY_SITE_ID --auth $NETLIFY_AUTH_TOKEN --prod
```

**Caching Mise Installations** (optional, reduces build time):

```yaml
cache:
  key: mise-$CI_COMMIT_REF_SLUG
  paths:
    - $HOME/.mise
    - $HOME/.local/bin/mise

.mise_bootstrap:
  before_script:
    - |
      if [ ! -f "$HOME/.local/bin/mise" ]; then
        echo "Installing mise..."
        curl -fsSL https://mise.run | sh
      fi
    - export PATH="$HOME/.local/bin:$PATH"
    - mise --version
    - mise install
```

---

#### Option B: Bake Mise into Docker Image (Best Long-Term)

**Advantages**:
- Fastest build times (no download/install overhead)
- Consistent environment across builds
- Can pre-install common tool versions

**Disadvantages**:
- Requires maintaining custom Docker image
- Image updates needed for mise version bumps

**Implementation**:

**Update `brightdigit/publish-xml` Dockerfile**:

```dockerfile
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    build-essential \
    libsqlite3-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install mise
ARG MISE_VERSION=2024.1.0
RUN curl -fsSL https://mise.run | sh
ENV PATH="/root/.local/bin:${PATH}"

# Verify mise installation
RUN mise --version

# Optional: Pre-install common Swift versions (faster builds)
RUN mise install swift@5.9
RUN mise install swift@5.10

# Set up shell integration
RUN echo 'eval "$(mise activate bash)"' >> ~/.bashrc

WORKDIR /workspace
```

**Build and Push Image**:
```bash
docker build -t brightdigit/publish-xml:mise .
docker push brightdigit/publish-xml:mise
```

**Use in `.gitlab-ci.yml`**:
```yaml
build jammy:
  stage: build
  image: brightdigit/publish-xml:mise
  before_script:
    - mise install  # Fast: reads .mise.toml, tools already cached in image
  script:
    - mise exec -- swift build
    - mise exec -- swift test
```

---

#### Option C: Hybrid (Bootstrap + Runner Caching)

**Best of Both Worlds**:
- No Docker changes
- Fast builds via GitLab Runner cache
- Reliable fallback if cache missed

**Implementation**:

```yaml
cache:
  key:
    files:
      - .mise.toml
  paths:
    - .mise-cache/

.mise_bootstrap:
  before_script:
    # Install mise if not cached
    - |
      if [ ! -f ".mise-cache/bin/mise" ]; then
        mkdir -p .mise-cache/bin
        curl -fsSL https://mise.run | MISE_INSTALL_PATH=.mise-cache sh
      fi
    - export PATH="$PWD/.mise-cache/bin:$PATH"

    # Install tools (uses shared cache)
    - mise install
    - mise ls

build jammy:
  extends: .mise_bootstrap
  image: brightdigit/publish-xml
  script:
    - mise exec -- swift build
```

**Cache Key Strategy**: Cache invalidates when `.mise.toml` changes (tool versions updated)

---

### 7.2 GitHub Actions Integration

#### Using `jdx/mise-action` (Recommended)

**Official Action**: [jdx/mise-action](https://github.com/jdx/mise-action)

**Features**:
- Automatic mise installation
- Tool installation from `.mise.toml` or `.tool-versions`
- Smart caching (invalidates on config change)
- Cross-platform (Linux, macOS, Windows)

**Basic Usage**:

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup mise
        uses: jdx/mise-action@v2
        with:
          version: latest  # Or pin: '2024.1.0'
          install: true    # Auto-install tools from .mise.toml
          cache: true      # Cache ~/.mise for faster builds

      - name: Build
        run: mise exec -- swift build

      - name: Test
        run: mise exec -- swift test
```

---

#### Advanced Configuration

**Example: Swift Package with Linting**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]

    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup mise
        uses: jdx/mise-action@v2
        with:
          install: true
          cache: true
          cache_key_prefix: ${{ runner.os }}-mise  # Per-OS cache

      - name: Verify tool versions
        run: |
          mise ls
          swift --version
          mise --version

      - name: Cache Swift build
        uses: actions/cache@v4
        with:
          path: .build
          key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
          restore-keys: |
            ${{ runner.os }}-spm-

      - name: Build
        run: mise exec -- swift build --build-tests

      - name: Test
        run: mise exec -- swift test --parallel

  lint:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup mise
        uses: jdx/mise-action@v2
        with:
          install: true
          cache: true

      - name: Cache Mint
        uses: actions/cache@v4
        with:
          path: ~/.mint
          key: mint-${{ hashFiles('**/Mintfile') }}

      - name: Install Mint tools
        run: |
          brew install mint
          mint bootstrap

      - name: Run SwiftLint
        run: mint run swiftlint lint --strict

      - name: Run SwiftFormat
        run: mint run swiftformat --lint .
```

---

#### Matrix Strategy for Multiple Swift Versions

**Test Against Multiple Swift Versions**:

```yaml
jobs:
  build:
    strategy:
      matrix:
        swift-version: ['5.9', '5.10', 'latest']
        os: [ubuntu-latest, macos-latest]

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      # Override .mise.toml Swift version with matrix value
      - name: Setup mise with Swift ${{ matrix.swift-version }}
        uses: jdx/mise-action@v2
        with:
          install: false  # Don't auto-install from config
          cache: true

      - name: Install Swift ${{ matrix.swift-version }}
        run: |
          mise install swift@${{ matrix.swift-version }}
          swift --version

      - run: swift build
      - run: swift test
```

---

### 7.3 Caching Strategies

#### What to Cache

| Item | Path | Cache Key | Benefit |
|------|------|-----------|---------|
| **Mise binary** | `~/.local/bin/mise` | `mise-bin-${{ runner.os }}` | Avoid re-download (small file, marginal) |
| **Mise installations** | `~/.mise/installs/` | `mise-tools-${{ hashFiles('.mise.toml') }}` | Skip tool installation (major time save) |
| **Swift build** | `.build/` | `spm-${{ hashFiles('Package.resolved') }}` | Incremental compilation (major time save) |
| **Mint tools** | `~/.mint/` | `mint-${{ hashFiles('Mintfile') }}` | Skip SwiftFormat/SwiftLint install |
| **npm packages** | `node_modules/` | `npm-${{ hashFiles('package-lock.json') }}` | Skip npm install |

---

#### GitHub Actions Cache Example

```yaml
- name: Cache mise installations
  uses: actions/cache@v4
  with:
    path: ~/.mise/installs
    key: ${{ runner.os }}-mise-${{ hashFiles('.mise.toml') }}
    restore-keys: |
      ${{ runner.os }}-mise-

- name: Cache Swift build
  uses: actions/cache@v4
  with:
    path: .build
    key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
    restore-keys: |
      ${{ runner.os }}-spm-
```

**Cache Invalidation**:
- Mise installations cache busts when `.mise.toml` changes
- Swift build cache busts when `Package.resolved` changes
- Use `restore-keys` for partial cache hits

---

#### GitLab CI Cache Example

```yaml
cache:
  key:
    files:
      - .mise.toml
      - Package.resolved
  paths:
    - ~/.mise/installs
    - .build/
  policy: pull-push

build:
  script:
    - mise install
    - swift build
```

**Cache Policies**:
- `pull-push` (default): Download before, upload after
- `pull`: Only download (for jobs that don't modify cache)
- `push`: Only upload (for jobs that populate cache)

---

### 7.4 Performance Benchmarks

**Expected Impact on Build Times**:

| Scenario | Before (nvm + Mint) | After (Mise Bootstrap) | After (Mise in Docker) | Improvement |
|----------|---------------------|------------------------|------------------------|-------------|
| **Cold cache** (no tools installed) | 3m 30s | 4m 00s | 2m 15s | -35% (Docker) |
| **Warm cache** (tools cached) | 2m 00s | 1m 45s | 1m 30s | -25% (Docker) |
| **Hot cache** (full cache hit) | 1m 30s | 1m 20s | 1m 15s | -17% (Docker) |

**Analysis**:
- Bootstrap approach adds ~30s overhead (mise download + install)
- Docker approach with pre-baked mise is fastest
- Caching strategy critical for performance

**Recommendation**: Start with bootstrap (easy), migrate to Docker image once stable

---

## 8. Best Practices

### 8.1 Version Pinning Strategy

#### Always Pin Exact Versions in Production

**Why**: Reproducible builds, no surprises from minor version updates

**Good**:
```toml
[tools]
swift = "5.9.0"        # Exact version
node = "20.11.0"       # Exact version
"npm:webpack" = "5.69.1"
```

**Avoid**:
```toml
[tools]
swift = "5"            # Too vague, could pull 5.10 later
node = "latest"        # Non-reproducible
```

---

#### Use Semantic Version Ranges for Libraries

**For library projects** (consumed by others), test against version range:

```toml
# .mise.toml for MistKit (library)
[tools]
swift = "5.9.0"  # Current development version

# For CI matrix testing (see GitHub Actions section)
# Test against: 5.9.0, 5.10.0, 6.0.0
```

---

#### Document Minimum vs. Development Versions

```toml
# .mise.toml
[tools]
# Development version (what team uses)
swift = "5.10.0"

[env]
# Communicate minimum supported version
SWIFT_MINIMUM_VERSION = "5.9"

# Or use comments
# This project supports Swift 5.9+
# Team develops with Swift 5.10
```

---

### 8.2 Tool Selection Guidelines

#### When to Manage a Tool with Mise

**✅ Add to Mise if:**
- Version-sensitive (different versions have breaking changes)
- Used by multiple team members
- Used in CI/CD pipeline
- Difficult to install manually

**Examples**: Swift compiler, Node.js, Ruby, Python, Go

---

#### When NOT to Manage with Mise

**❌ Don't add to Mise if:**
- Rarely version-sensitive (e.g., `curl`, `jq`, `git`)
- Better managed by OS package manager (e.g., `docker`, `postgres`)
- Large binary with minimal version differences
- Only used by one team member

**Examples**: Docker, PostgreSQL, redis, nginx

---

#### Tool Categories

| Category | Mise Management | Example Tools |
|----------|----------------|---------------|
| **Language Runtimes** | ✅ Always | Swift, Node.js, Python, Ruby, Go, Rust |
| **Language Tools** | ✅ Recommended | SwiftFormat, SwiftLint, eslint, prettier |
| **Build Tools** | ⚠️ If version-sensitive | webpack, vite, cmake, make |
| **CLI Tools** | ⚠️ If team-shared | netlify-cli, gh (GitHub CLI) |
| **System Services** | ❌ Use Docker/Homebrew | postgres, redis, nginx, docker |
| **OS Utilities** | ❌ Use OS package manager | curl, jq, grep, sed |

---

### 8.3 Team Adoption Recommendations

#### Gradual Onboarding

**Week 1: Individual Setup**
- Team members install mise locally
- Test in personal forks/branches
- Share feedback in team chat

**Week 2: Pilot Repository**
- Migrate one low-risk repository
- Entire team uses mise for that repo
- Document any issues

**Week 3-4: Expand**
- Migrate 2-3 more repositories
- Refine templates based on learnings
- Create internal wiki/guide

**Month 2+: Organization-wide**
- Announce mise as standard
- Migrate remaining repositories
- Deprecate old version files (with grace period)

---

#### Training Materials

**Create Short Video Tutorials** (5-10 minutes each):
1. "Installing and Configuring Mise"
2. "Migrating Your First Repository"
3. "Using Mise in CI/CD"
4. "Troubleshooting Common Issues"

**Host Office Hours**:
- Weekly 30-minute sessions for Q&A
- Record and share for asynchronous viewing

**Internal Documentation**:
- FAQ page (common questions + answers)
- Migration checklist
- Troubleshooting guide

---

#### Setting Expectations

**Communicate Clearly**:
- **Timeline**: Phased rollout over 6 months
- **Support**: Point person for questions
- **Backward Compatibility**: Old tools work during transition
- **Opt-Out**: Teams can defer if blocked by critical bug

**Celebrate Wins**:
- Share success stories (faster builds, easier setup)
- Highlight team members who contribute to migration
- Track metrics (repos migrated, CI time savings)

---

### 8.4 Repository Conventions

#### Standard File Naming

**Use `.mise.toml`** (not `.tool-versions` or `.config/mise/config.toml`)

**Reasoning**:
- More visible at repo root
- Supports all mise features (tasks, env vars)
- Consistent across BrightDigit repos

---

#### Configuration File Comments

```toml
# .mise.toml for BrightDigit/MistKit
# Async/await utilities for Swift
#
# Maintained by: Leo Dion <leo@brightdigit.com>
# Last updated: 2026-02-05
#
# For mise documentation: https://mise.jdx.dev
# For BrightDigit mise guide: https://brightdigit.com/articles/mise-implementation-guide/

[tools]
swift = "5.9.0"  # Minimum: Swift 5.9+
```

---

#### Task Naming Conventions

**Use Consistent Task Names** across repositories:

| Task Name | Purpose | Example Command |
|-----------|---------|-----------------|
| `build` | Build project (release mode) | `swift build -c release` |
| `test` | Run unit tests | `swift test --parallel` |
| `lint` | Run linters (SwiftLint, SwiftFormat) | `swiftlint && swiftformat --lint .` |
| `format` | Auto-format code | `swiftformat .` |
| `clean` | Remove build artifacts | `swift package clean` |
| `ci` | Run full CI pipeline locally | `build && test && lint` |
| `dev` | Start development server | `./dev-server.sh` |
| `publish` | Build and deploy | `swift run brightdigitwg publish` |

**Benefits**:
- Muscle memory across repositories
- Easier documentation ("run `mise run test` in any repo")
- Consistent CI/CD configurations

---

#### Documentation Standards

**Every repository with `.mise.toml` should update README**:

Add section before "Development" or "Building":

```markdown
## Prerequisites

This project uses [Mise](https://mise.jdx.dev) for tool version management.

### Install Mise

**macOS:**
```bash
brew install mise
```

**Linux:**
```bash
curl https://mise.run | sh
```

Then configure shell integration:
```bash
# zsh (macOS default)
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
```

### Install Tools

```bash
mise install  # Installs Swift and other tools from .mise.toml
```

## Development

```bash
mise run build   # Build project
mise run test    # Run tests
mise run lint    # Check code formatting
```
```

---

## 9. Tool Ecosystem Mapping

### 9.1 Mint → Mise Migration Reference

| Mint Tool (Mintfile) | Mise Equivalent | Notes |
|---------------------|-----------------|-------|
| `nicklockwood/SwiftFormat@0.50.4` | `"asdf:swiftformat" = "0.50.4"` | Requires asdf-swiftformat plugin |
| `realm/SwiftLint@0.50.3` | `"asdf:swiftlint" = "0.50.3"` | Requires asdf-swiftlint plugin |
| `peripheryapp/periphery@2.11.0` | Not available | Continue using Mint or manual install |
| `apple/swift-format@508.0.1` | `"asdf:swift-format" = "508.0.1"` | Note: apple/swift-format ≠ SwiftFormat |
| `nicklockwood/SwiftFormat@main` | Not recommended | Mise prefers tagged versions |

**Recommendation**: During transition, keep using Mint for Swift development tools. Migrate to mise once plugins mature and team validates workflow.

---

### 9.2 nvm → Mise Migration Reference

| nvm Command | Mise Equivalent | Notes |
|-------------|-----------------|-------|
| `nvm install 16` | `mise install node@16` | Mise auto-detects latest 16.x |
| `nvm use 16` | Automatic (shell integration) | Or `mise exec -- node` |
| `nvm which node` | `mise which node` | Shows path to node binary |
| `nvm ls` | `mise ls node` | Lists installed Node versions |
| `nvm ls-remote` | `mise ls-remote node` | Lists available versions |
| `nvm current` | `mise current node` | Shows active version |

**Key Difference**: nvm requires manual `nvm use` in each shell. Mise activates automatically via shell integration.

---

### 9.3 npm Global Tools → Mise

**Current Approach** (npm global install):
```bash
npm install -g webpack webpack-cli netlify-cli
```

**Problems**:
- Global installs conflict across projects
- No version locking per-project
- Requires npm installed first

**Mise Approach**:
```toml
[tools]
node = "20"
"npm:webpack" = "5.69.1"
"npm:webpack-cli" = "4.9.3"
"npm:netlify-cli" = "12.0.0"
```

**Benefits**:
- Versions locked per-project
- No global pollution
- Works without separate npm install step

---

### 9.4 asdf Compatibility

**Good News**: Mise is asdf-compatible!

**Using asdf Plugins with Mise**:
```bash
# Install asdf plugin
mise plugin add swiftformat https://github.com/sticknein/asdf-swiftformat.git

# Use in .mise.toml
[tools]
"asdf:swiftformat" = "0.50.4"
```

**Common asdf Plugins Available**:
- `asdf-swift` - Swift compiler
- `asdf-nodejs` - Node.js
- `asdf-ruby` - Ruby
- `asdf-python` - Python
- `asdf-golang` - Go

**Mise Native vs. asdf Plugin**:

| Tool | Mise Native | asdf Plugin | Recommendation |
|------|-------------|-------------|----------------|
| Swift | ✅ Core | ✅ Available | Use mise native (faster) |
| Node.js | ✅ Core | ✅ Available | Use mise native |
| Ruby | ✅ Core | ✅ Available | Use mise native |
| SwiftFormat | ❌ Not yet | ✅ Available | Use asdf plugin |
| SwiftLint | ❌ Not yet | ✅ Available | Use asdf plugin |

---

## 10. Complete Configuration Examples

### 10.1 brightdigit.com (Full Production Example)

```toml
# .mise.toml for brightdigit.com
# Static site generator: Swift (Publish) + Node.js (webpack)
#
# Repository: https://gitlab.com/BrightDigit/Public/brightdigit.com
# Maintained by: Leo Dion <leo@brightdigit.com>
# Last updated: 2026-02-05

[tools]
# Swift compiler (Publish framework)
swift = "5.3.0"

# Node.js (webpack, npm scripts)
node = "16.20.0"

# npm global CLI tools
"npm:webpack" = "5.69.1"
"npm:webpack-cli" = "4.9.3"
"npm:netlify-cli" = "17.0.0"

[env]
# Environment variables
SWIFT_VERSION = "5.3"
NODE_ENV = "development"
LOG_LEVEL = "info"

# Project paths (using mise template syntax)
PROJECT_ROOT = "{{config_root}}"
CONTENT_DIR = "{{config_root}}/Content"
OUTPUT_DIR = "{{config_root}}/Output"
STYLING_DIR = "{{config_root}}/Styling"

# Build configuration
SWIFT_BUILD_FLAGS = "-c release"

[settings]
# Automatically install missing tools on directory change
auto_install = true

# Experimental features
experimental = false

# Tasks for common workflows
[tasks.build]
run = "swift build -c release --product brightdigitwg"
description = "Build brightdigitwg executable for release"

[tasks.build-debug]
run = "swift build --product brightdigitwg"
description = "Build brightdigitwg in debug mode"

[tasks.test]
run = "swift test --parallel"
description = "Run Swift unit tests in parallel"

[tasks.clean]
run = """
swift package clean
rm -rf Output/
"""
description = "Clean build artifacts and output directory"

[tasks.dev-server]
run = "./dev-server.sh"
description = "Start development server with hot reload"

[tasks.publish]
run = "swift run brightdigitwg publish"
description = "Generate static site in Output/"

[tasks.publish-drafts]
run = "swift run brightdigitwg --mode drafts"
description = "Generate site including draft content"

[tasks.import-mailchimp]
run = """
swift run brightdigitwg import mailchimp \
  --mailchimp-api-key=$MAILCHIMP_API_KEY \
  --mailchimp-list-id=$MAILCHIMP_LIST_ID \
  --export-markdown-directory=Content/newsletters
"""
description = "Import newsletters from Mailchimp API"
env = { MAILCHIMP_API_KEY = "", MAILCHIMP_LIST_ID = "" }

[tasks.import-podcast]
run = """
swift run brightdigitwg import podcast \
  --youtube-api-key=$YOUTUBE_API_KEY \
  --export-markdown-directory Content/episodes
"""
description = "Import podcast episodes from YouTube"
env = { YOUTUBE_API_KEY = "" }

[tasks.deploy-production]
depends = ["build", "publish"]
run = """
netlify deploy \
  --site $NETLIFY_PRODUCTION_SITE_ID \
  --auth $NETLIFY_AUTH_TOKEN \
  --prod
"""
description = "Deploy to production (Netlify)"

[tasks.deploy-preview]
depends = ["build", "publish-drafts"]
run = """
netlify deploy \
  --site $NETLIFY_PREVIEW_SITE_ID \
  --auth $NETLIFY_AUTH_TOKEN
"""
description = "Deploy preview with drafts"

[tasks.ci]
depends = ["build", "test", "publish"]
description = "Full CI pipeline (local simulation)"

[tasks.doctor]
run = """
echo "=== Tool Versions ==="
mise ls
echo ""
echo "=== Swift ==="
swift --version
echo ""
echo "=== Node.js ==="
node --version
npm --version
echo ""
echo "=== Project Structure ==="
ls -lh
"""
description = "Diagnostic information for troubleshooting"
```

---

### 10.2 Swift Package (MistKit Example)

```toml
# .mise.toml for BrightDigit/MistKit
# Async/await utilities for Swift
#
# Repository: https://github.com/brightdigit/MistKit
# Maintained by: Leo Dion <leo@brightdigit.com>
# Last updated: 2026-02-05

[tools]
# Swift compiler
# Minimum supported: 5.9
# Team development: 5.10
swift = "5.10.0"

# Development tools (via Mint during transition)
# Future: Migrate to mise when plugins mature
# "asdf:swiftformat" = "0.50.4"
# "asdf:swiftlint" = "0.50.3"

[env]
SWIFT_VERSION = "5.10"
SWIFT_MINIMUM_VERSION = "5.9"
LOG_LEVEL = "debug"

[settings]
auto_install = true

[tasks.build]
run = "swift build"
description = "Build the package"

[tasks.build-release]
run = "swift build -c release"
description = "Build for release"

[tasks.test]
run = "swift test --parallel"
description = "Run unit tests in parallel"

[tasks.test-debug]
run = "swift test --parallel --enable-code-coverage"
description = "Run tests with code coverage"

[tasks.clean]
run = "swift package clean"
description = "Remove build artifacts"

[tasks.resolve]
run = "swift package resolve"
description = "Resolve package dependencies"

[tasks.update]
run = "swift package update"
description = "Update package dependencies to latest"

[tasks.lint]
run = """
mint run swiftformat --lint .
mint run swiftlint lint --strict
"""
description = "Run linting tools (SwiftFormat, SwiftLint)"

[tasks.format]
run = "mint run swiftformat ."
description = "Auto-format code with SwiftFormat"

[tasks.lint-fix]
run = """
mint run swiftformat .
mint run swiftlint lint --fix
"""
description = "Auto-fix linting issues"

[tasks.docs]
run = """
swift package --allow-writing-to-directory docs \
  generate-documentation --target MistKit \
  --output-path docs
"""
description = "Generate documentation with DocC"

[tasks.ci]
depends = ["build", "test", "lint"]
description = "Full CI pipeline (local simulation)"

[tasks.prepare-release]
depends = ["clean", "resolve", "lint-fix", "test"]
run = """
echo "✅ Ready for release!"
echo "Next steps:"
echo "  1. Update CHANGELOG.md"
echo "  2. Bump version in MistKit.podspec"
echo "  3. Create git tag: git tag -a 1.x.x -m 'Release 1.x.x'"
echo "  4. Push tag: git push origin 1.x.x"
"""
description = "Prepare package for release"
```

---

### 10.3 Multi-Language Project (Hypothetical)

```toml
# .mise.toml for BrightDigit/FullStackApp
# Full-stack application: Swift backend + TypeScript frontend + Python ML
#
# Hypothetical example showing mise's polyglot capabilities

[tools]
# Backend: Swift
swift = "5.10.0"

# Frontend: Node.js + TypeScript
node = "20.11.0"
"npm:typescript" = "5.3.3"
"npm:vite" = "5.0.0"

# Machine Learning: Python
python = "3.11.7"

# Infrastructure
terraform = "1.7.0"
"npm:serverless" = "3.38.0"

[env]
# Project paths
PROJECT_ROOT = "{{config_root}}"
BACKEND_DIR = "{{config_root}}/backend"
FRONTEND_DIR = "{{config_root}}/frontend"
ML_DIR = "{{config_root}}/ml"

# Environment
NODE_ENV = "development"
FLASK_ENV = "development"
LOG_LEVEL = "debug"

[settings]
auto_install = true

# Backend tasks (Swift)
[tasks.backend-build]
run = "cd backend && swift build"
description = "Build Swift backend"

[tasks.backend-test]
run = "cd backend && swift test"
description = "Test Swift backend"

[tasks.backend-run]
run = "cd backend && swift run"
description = "Run Swift backend server"

# Frontend tasks (TypeScript)
[tasks.frontend-install]
run = "cd frontend && npm install"
description = "Install frontend dependencies"

[tasks.frontend-dev]
run = "cd frontend && npm run dev"
description = "Start frontend dev server (Vite)"

[tasks.frontend-build]
run = "cd frontend && npm run build"
description = "Build frontend for production"

[tasks.frontend-test]
run = "cd frontend && npm test"
description = "Run frontend tests"

# ML tasks (Python)
[tasks.ml-setup]
run = "cd ml && pip install -r requirements.txt"
description = "Install Python ML dependencies"

[tasks.ml-train]
run = "cd ml && python train.py"
description = "Train ML model"

[tasks.ml-serve]
run = "cd ml && python serve.py"
description = "Serve ML model API"

# Composite tasks
[tasks.dev]
depends = ["backend-run", "frontend-dev", "ml-serve"]
description = "Start all services (backend, frontend, ML)"

[tasks.build]
depends = ["backend-build", "frontend-build"]
description = "Build all components"

[tasks.test]
depends = ["backend-test", "frontend-test"]
description = "Run all tests"

[tasks.deploy]
run = """
terraform apply -auto-approve
serverless deploy
"""
description = "Deploy infrastructure and services"
```

---

## 11. Troubleshooting Guide

### 11.1 Installation Issues

#### Issue: `mise: command not found`

**Symptoms**: After installing mise, running `mise` in terminal shows "command not found"

**Causes**:
1. mise not in PATH
2. Shell integration not activated
3. Shell config not reloaded

**Solutions**:

**Check Installation Location**:
```bash
# Find mise binary
which mise
# Should show: /usr/local/bin/mise (Homebrew) or ~/.local/bin/mise (install script)

# If not found, check install method:
brew list mise  # Homebrew install
ls ~/.local/bin/mise  # Install script
```

**Add to PATH** (if using install script):
```bash
# bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Activate Shell Integration**:
```bash
# bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# zsh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Verify**:
```bash
mise --version
# Should show: mise 2024.x.x
```

---

#### Issue: `mise activate` Causes Slow Shell Startup

**Symptoms**: Terminal takes 2-3 seconds to start after adding `eval "$(mise activate)"`

**Causes**:
- mise scanning large directory tree
- Too many tools installed
- Slow disk I/O

**Solutions**:

**Use Lazy Loading** (deferred activation):
```bash
# zsh
# Instead of: eval "$(mise activate zsh)"
# Use deferred activation:
eval "$(mise activate zsh --shims)"
```

**Reduce Directory Scanning**:
```bash
# Set mise to only check current directory (not parent directories)
mise settings set legacy_version_file false
```

**Profile Shell Startup** (find bottleneck):
```bash
# Add to top of ~/.zshrc
zmodload zsh/zprof

# Add to bottom
zprof
```

---

### 11.2 Tool Installation Issues

#### Issue: Swift Version Fails to Install

**Symptoms**:
```bash
$ mise install swift@5.9
Error: Failed to download Swift toolchain
```

**Causes**:
1. Network connectivity issues
2. Invalid version specified
3. Platform not supported (Windows)

**Solutions**:

**Check Available Versions**:
```bash
mise ls-remote swift
# Shows all available Swift versions
```

**Verify Network Access**:
```bash
curl -I https://download.swift.org/
# Should return HTTP 200
```

**Try Exact Version**:
```bash
# Instead of: swift@5.9
mise install swift@5.9.0  # Exact version
```

**Manual Installation** (fallback):
```bash
# macOS: Use Xcode toolchain
xcode-select --install

# Linux: Download from Swift.org
wget https://download.swift.org/swift-5.9-release/ubuntu2204/swift-5.9-RELEASE/swift-5.9-RELEASE-ubuntu22.04.tar.gz
tar xzf swift-5.9-RELEASE-ubuntu22.04.tar.gz
export PATH=$PWD/swift-5.9-RELEASE-ubuntu22.04/usr/bin:$PATH
```

---

#### Issue: npm Tool Version Conflict

**Symptoms**:
```bash
$ mise install npm:webpack@5.69
Error: Version conflict with existing npm installation
```

**Causes**:
- Global npm install conflicts with mise
- Multiple versions requested

**Solutions**:

**Remove Global npm Install**:
```bash
npm uninstall -g webpack webpack-cli
```

**Use Exact Version in `.mise.toml`**:
```toml
[tools]
"npm:webpack" = "5.69.1"  # Exact version, not "5.69" or "5.x"
```

**Clear mise Cache**:
```bash
mise cache clear
mise install
```

---

### 11.3 Runtime Issues

#### Issue: Wrong Tool Version Used

**Symptoms**:
```bash
$ swift --version
Apple Swift version 5.10  # Expected 5.9 from .mise.toml
```

**Causes**:
1. mise shell integration not active
2. System Swift in PATH before mise
3. `.mise.toml` not in current directory

**Solutions**:

**Verify mise is Active**:
```bash
mise current
# Should show versions from .mise.toml
```

**Use `mise exec` Explicitly**:
```bash
mise exec -- swift --version
# Forces use of mise-managed Swift
```

**Check PATH Order**:
```bash
echo $PATH
# mise shims should appear BEFORE /usr/bin
```

**Fix PATH** (if needed):
```bash
# Ensure mise activation is AFTER any PATH modifications in shell config
# Move eval "$(mise activate zsh)" to end of ~/.zshrc
```

**Verify .mise.toml Location**:
```bash
pwd
ls .mise.toml  # Should exist in current directory
```

---

#### Issue: Environment Variables Not Set

**Symptoms**: Variables defined in `.mise.toml` `[env]` section not available in shell

**Causes**:
- Shell integration not using `mise hook-env`
- Variables only available to `mise exec` commands

**Solutions**:

**Test with mise exec**:
```bash
mise exec -- printenv | grep SWIFT_VERSION
# Should show value from .mise.toml
```

**Export mise Environment to Shell**:
```bash
eval "$(mise env)"
# Or add to shell profile for persistence
```

**Use mise Tasks** (recommended):
```toml
[tasks.check-env]
run = """
echo "SWIFT_VERSION=$SWIFT_VERSION"
echo "PROJECT_ROOT=$PROJECT_ROOT"
"""
```

```bash
mise run check-env
```

---

### 11.4 CI/CD Issues

#### Issue: GitLab CI Build Fails with Mise

**Symptoms**:
```
$ mise install
bash: mise: command not found
```

**Causes**:
- mise not installed in CI environment
- PATH not set correctly

**Solutions**:

**Add mise Bootstrap** to `.gitlab-ci.yml`:
```yaml
before_script:
  - curl https://mise.run | sh
  - export PATH="$HOME/.local/bin:$PATH"
  - mise install
```

**Verify in CI**:
```yaml
script:
  - mise --version
  - mise ls
  - which swift
```

---

#### Issue: GitHub Actions Cache Not Working

**Symptoms**: `jdx/mise-action` reinstalls tools every run

**Causes**:
- Cache disabled
- Cache key mismatch
- `.mise.toml` changes frequently

**Solutions**:

**Verify Cache Enabled**:
```yaml
- uses: jdx/mise-action@v2
  with:
    cache: true  # Ensure this is set
```

**Check Cache Hit**:
```yaml
- uses: jdx/mise-action@v2
  id: mise
  with:
    cache: true

- name: Check cache hit
  run: echo "Cache hit ${{ steps.mise.outputs.cache-hit }}"
```

**Use Stable Cache Key**:
```yaml
- uses: jdx/mise-action@v2
  with:
    cache: true
    cache_key_prefix: ${{ runner.os }}-mise-${{ hashFiles('.mise.toml') }}
```

---

### 11.5 Common Error Messages

#### Error: `No version is set for tool 'swift'`

**Meaning**: Running `swift` command but no version specified in `.mise.toml` or parent directories

**Solution**:
```bash
# Verify .mise.toml exists and has [tools] section
cat .mise.toml

# Or set globally
mise use -g swift@5.9
```

---

#### Error: `Plugin 'swift' not installed`

**Meaning**: Swift plugin not available (rare, swift is core plugin)

**Solution**:
```bash
mise plugin install swift
mise install swift@5.9
```

---

#### Error: `Tool version not found: swift@6.0`

**Meaning**: Requested version doesn't exist or not available yet

**Solution**:
```bash
# Check available versions
mise ls-remote swift | grep 6.0

# Use available version
mise install swift@5.10
```

---

## 12. Future Roadmap

### 12.1 Q1 2026: Pilot Phase

**Goals**:
- [ ] Migrate brightdigit.com to mise
- [ ] Document lessons learned
- [ ] Create initial templates
- [ ] Validate CI/CD integration (GitLab)

**Success Metrics**:
- brightdigit.com CI builds stable with mise
- Team comfortable with mise workflow
- No performance regressions

---

### 12.2 Q2 2026: Swift Package Expansion

**Goals**:
- [ ] Migrate 3 Swift packages (MistKit, SyndiKit, BushelKit)
- [ ] Validate GitHub Actions integration
- [ ] Refine templates based on feedback
- [ ] Create team training materials

**Success Metrics**:
- 3+ repositories using mise in production
- GitHub Actions builds faster or equivalent
- Team members report easier setup

---

### 12.3 Q3 2026: Organization-Wide Rollout

**Goals**:
- [ ] Publish templates in brightdigit/.github
- [ ] Migrate 10+ remaining Swift packages
- [ ] Host team training sessions
- [ ] Update all CLAUDE.md files

**Success Metrics**:
- 80%+ of active repositories using mise
- Updated CI/CD configurations
- Team members comfortable with mise commands

---

### 12.4 Q4 2026: Optimization & Tooling

**Goals**:
- [ ] Deprecate `.swift-version` and `.nvmrc` files
- [ ] Migrate Swift tools from Mint to mise (if plugins mature)
- [ ] Optimize CI/CD caching strategies
- [ ] Create custom mise plugins for BrightDigit-specific tools

**Success Metrics**:
- Single source of truth for tool versions
- CI build times improved by 20%
- Zero tooling-related onboarding issues

---

### 12.5 Future Enhancements

**Potential Future Work** (2027+):

1. **Custom Mise Plugins**
   - `mise-brightdigit-tools` plugin for BrightDigit-specific CLI tools
   - Publish to mise plugin registry

2. **Automated Version Updates**
   - Dependabot-style bot for `.mise.toml` version bumps
   - Automated PR creation with changelog

3. **Organization-wide Mise Server**
   - Centralized mise cache for shared CI runners
   - Reduce tool download times across all repos

4. **IDE Integration**
   - Xcode build phase to verify mise versions
   - VS Code extension to show active mise tools

5. **Mise Templates as Code**
   - Swift DSL for generating `.mise.toml` files
   - Template repository with CI/CD best practices

---

## 13. Resources and References

### 13.1 Official Mise Documentation

- **Mise Website**: https://mise.jdx.dev
- **GitHub Repository**: https://github.com/jdx/mise
- **Getting Started Guide**: https://mise.jdx.dev/getting-started.html
- **Configuration Reference**: https://mise.jdx.dev/configuration.html
- **Plugin Registry**: https://mise.jdx.dev/plugins.html

### 13.2 Community Resources

- **Mise Discussion Forum**: https://github.com/jdx/mise/discussions
- **Discord Community**: https://discord.gg/mise
- **r/devtools (Reddit)**: Discussions on mise and alternatives

### 13.3 CI/CD Integration Guides

- **GitHub Actions**: https://mise.jdx.dev/continuous-integration.html#github-actions
- **GitLab CI**: https://mise.jdx.dev/continuous-integration.html#gitlab-ci
- **Docker Integration**: https://mise.jdx.dev/docker.html

### 13.4 Related Tools Documentation

- **Mint**: https://github.com/yonaskolb/Mint
- **asdf**: https://asdf-vm.com
- **nvm**: https://github.com/nvm-sh/nvm
- **swiftenv**: https://swiftenv.fuller.li

### 13.5 BrightDigit Resources

- **This Guide**: https://brightdigit.com/articles/mise-implementation-guide/
- **Organization Repository**: https://github.com/brightdigit/.github
- **brightdigit.com Repository**: https://gitlab.com/BrightDigit/Public/brightdigit.com

---

## 14. Appendix

### 14.1 Glossary

**ASDF**: Universal tool version manager (predecessor to mise)

**Backend**: Plugin system for mise (core, asdf, aqua, cargo, npm, vfox)

**mise exec**: Command to run a program with mise-managed tools in PATH

**mise use**: Command to set tool version in `.mise.toml`

**Mint**: Swift package manager for installing Swift-based CLI tools

**nvm**: Node Version Manager for managing Node.js versions

**Plugin**: Extension that teaches mise how to install a specific tool

**Shell Integration**: Automatic activation of mise in shell via `eval "$(mise activate)"`

**Shim**: Small wrapper script that redirects to mise-managed tool binary

**Task**: Named script defined in `.mise.toml` `[tasks]` section

**Tool Version File**: `.mise.toml` or `.tool-versions` specifying tool versions

**Toolchain**: Complete set of tools for a language (e.g., Swift toolchain includes swift, swiftc, sourcekit-lsp)

---

### 14.2 Decision Matrix: Should I Use Mise?

| Your Situation | Recommendation | Reasoning |
|---------------|----------------|-----------|
| Managing single language (Swift only) | ⚠️ Maybe | mise works but may be overkill; `.swift-version` + Xcode sufficient |
| Managing multiple languages (Swift + Node.js) | ✅ Strongly Recommend | Mise's polyglot capabilities shine here |
| Team of 5+ developers | ✅ Strongly Recommend | Consistency across team environments |
| Solo developer, personal projects | ⚠️ Maybe | Less critical, but still beneficial for CI |
| Need task automation | ✅ Recommend | Mise tasks replace Makefile/npm scripts |
| Using Docker for everything | ❌ Less Valuable | Docker already provides environment isolation |
| CI/CD build times critical | ✅ Recommend | Mise can improve caching and consistency |
| Windows development | ❌ Not Recommended | Mise Windows support experimental |
| Heavy use of Swift tools (SwiftLint, SwiftFormat) | ⚠️ Hybrid Approach | Keep using Mint, migrate runtime versions to mise |

---

### 14.3 Migration Checklist Template

Use this checklist for each repository:

```markdown
## Mise Migration Checklist: [Repository Name]

### Pre-Migration
- [ ] Repository audit complete
  - [ ] Tools identified: _________________
  - [ ] Current version files: _________________
  - [ ] CI platform: _________________
- [ ] Team notified of migration
- [ ] Migration branch created: `feature/migrate-to-mise`

### Configuration
- [ ] `.mise.toml` created from template
- [ ] Tool versions match current specifications
- [ ] Tasks defined for common workflows
- [ ] Environment variables migrated (if applicable)

### Local Testing
- [ ] `mise install` succeeds
- [ ] `mise ls` shows correct versions
- [ ] Build command works: `mise run build`
- [ ] Test command works: `mise run test`
- [ ] Tested by 2+ team members

### CI/CD Integration
- [ ] CI configuration updated (GitHub Actions / GitLab CI)
- [ ] Test build passes on feature branch
- [ ] Caching configured (if applicable)
- [ ] Performance benchmarked (build time ±10%)

### Documentation
- [ ] README updated with mise instructions
- [ ] CLAUDE.md updated (if applicable)
- [ ] Pull request created with migration notes

### Post-Migration
- [ ] Pull request merged
- [ ] CI builds stable for 1 week
- [ ] No rollbacks triggered
- [ ] Lessons learned documented

### Optional Cleanup (after validation period)
- [ ] Deprecate `.swift-version` (if applicable)
- [ ] Deprecate `.nvmrc` (if applicable)
- [ ] Deprecate `Mintfile` (if migrating tools to mise)

**Migration Lead**: _________________
**Date Started**: _________________
**Date Completed**: _________________
**Issues Encountered**: _________________
```

---

### 14.4 Quick Reference: mise Commands

| Task | Command |
|------|---------|
| **Install mise** | `brew install mise` (macOS) |
| **Activate shell** | `eval "$(mise activate zsh)"` |
| **Install all tools** | `mise install` |
| **Install specific tool** | `mise install swift@5.9` |
| **List installed tools** | `mise ls` |
| **List available versions** | `mise ls-remote swift` |
| **Set tool version** | `mise use swift@5.9` |
| **Set global version** | `mise use -g swift@5.9` |
| **Run command with tools** | `mise exec -- swift build` |
| **List tasks** | `mise tasks` |
| **Run task** | `mise run build` |
| **Show current versions** | `mise current` |
| **Check mise status** | `mise doctor` |
| **Clear cache** | `mise cache clear` |
| **Update mise** | `brew upgrade mise` (macOS) |
| **Uninstall tool version** | `mise uninstall swift@5.8` |

---

### 14.5 FAQ

**Q: Can I use mise alongside Mint?**
**A**: Yes! During transition, keep Mint for Swift development tools (SwiftFormat, SwiftLint) and use mise for runtimes (Swift compiler, Node.js). This is the recommended hybrid approach.

**Q: Will mise work with Xcode projects?**
**A**: Yes, but Xcode will use its bundled Swift toolchain by default. Use mise-managed Swift for command-line builds (Swift Package Manager). Set `TOOLCHAINS` environment variable to use specific toolchain in Xcode.

**Q: Do I need to uninstall nvm/Mint/swiftenv?**
**A**: No, they can coexist. However, ensure mise shims appear first in PATH (via shell integration).

**Q: Can mise install Swift snapshot builds?**
**A**: No, mise only installs official Swift.org releases. For snapshots, use manual installation or Xcode.

**Q: How do I update tool versions across multiple repositories?**
**A**: Create script to update `.mise.toml` files, or manually update each repository. Future work: Create automated version bump bot.

**Q: Does mise work offline?**
**A**: Partially. Once tools are installed, mise works offline. Tool installation requires internet to download toolchains.

**Q: Can I use mise on Windows?**
**A**: Experimental support exists but not recommended for production. Use WSL2 with Linux approach instead.

**Q: How do I contribute to mise?**
**A**: Visit https://github.com/jdx/mise, open issues/PRs, join Discord community.

---

## Conclusion

This guide provides a comprehensive roadmap for adopting Mise across BrightDigit repositories. Key takeaways:

1. **Start Small**: Pilot with brightdigit.com before organization-wide rollout
2. **Hybrid Approach**: Keep Mint for Swift tools during transition
3. **Team Buy-In**: Provide training, documentation, and support
4. **Measure Success**: Track CI performance, team feedback, and adoption rates
5. **Iterate**: Refine templates and processes based on real-world usage

**Next Steps**:
1. Install mise locally and test with templates
2. Volunteer for pilot phase (brightdigit.com)
3. Provide feedback and help refine this guide
4. Spread the word within BrightDigit team

Questions? Open an issue in the relevant repository or contact the DevOps team.

---

**Last Updated**: 2026-02-05
**Version**: 1.0
**Maintained by**: Leo Dion <leo@brightdigit.com>
**License**: CC BY 4.0
