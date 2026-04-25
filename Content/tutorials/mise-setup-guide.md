---
title: Getting Started with Mise for iOS and Swift Development
date: 2026-04-22 12:00
description: A guide to setting up Mise tool version management for Xcode projects
  and Swift Packages, with real-world examples and migration patterns.
tags: mise, tooling, swift, xcode, devops, ci-cd
featuredImage: /media/tutorials/mise-setup-guide/mise-setup-guide-hero.webp
subscriptionCTA: Want to stay up-to-date with the latest Swift tooling and CI/CD
  tips? Sign up for the newsletter to get notified when new tutorials drop.
---

Over the years, I've used a variety of tools from Homebrew to Mint. Each have had their share of issues and perks. Over the past year I've gone with Mise, it seems to be best suited for what I'm looking for.


## What is Mise?

Mise is a tool version manager. There are a lot out there but Mise fit what I was looking for. Here's what I have tried and didn't quite fit:

### HomeBrew

HomeBrew is great for installing tools and apps locally on my computer. I recently purchased a brand new 15-inch M5 MacBook Air and rather than restoring from a backup I used Brew Bundle to restore the list of apps from my old MacBook Air easily. However for development tools, it's not really ideal especially in the case of Continuous Integration (automated build servers like GitHub Actions). **I want an isolated environment when I use CI** in order to have a repeatable environment regardless of OS or where the machine is hosted. So that fell short. Lastly handling multiple versions of language tools (ruby, node, etc...) is not ideal and is better suited with specific tools (rbenv, nvm, etc...).

### Swift Package Plugin

There are several reasons I don't use Swift Package plugins but the biggest is the lack of support distinguishing between a consumer of a swift package vs a developer of a Swift package. I really don't want a consumer to need to pull Swift tools I use (swift-format, swiftlint, xcodegen, periphery, stringslint, etc...) as a develop when trying to consume my library. There are proposals and [tools](https://github.com/shibapm/Rocket) that try to remediate this but it really hasn't stuck. Therefore it's best to configure these outside of Package.swift.

### Mint

Mint is a fantastic tool for installing Swift Package based tools. As a Swift developer, I frequently use tools like swift-format, swiftlint, xcodegen, periphery, and stringslint. To be able to install these tools on my machine is great. However there were a few shortcomings:

1. It's not really meant for continuous integration so you don't get the isolated environment which CI requires.
2. Only suited for Swift Packages. If you have a web application attached (node) or require fastlane for deployment (ruby), you'll need an additional tool to do this.
3. Every swift package is rebuilt; so deployment via binaries is unavailable meaning long build times just to get the tool up and running.

### Why Mise

Mise solves a lot of these issues:

- Single tool replaces multiple version managers
- Same configuration works locally and in CI
- Eliminates hardcoded paths in CI/CD
- Team consistency through version control
- Has support for a swift package registry as a fallback.

For my projects, it manages everything from Node.js to Swift tooling.

---

## Getting Started

The first thing you are going to want to do is install mise.

### 1. Install Mise

```bash
# Via curl
curl https://mise.run | sh

# Via Homebrew
brew install mise

# Configure shell activation (use whichever matches your shell)
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc    # zsh
echo 'eval "$(mise activate bash)"' >> ~/.bashrc  # bash
```

### 2. Create `.mise.toml` at Repository Root

`.mise.toml` is the configuration file that declares which tools and versions your project needs. It lives at the repository root and gets checked into version control alongside your code. Once it's there, any developer — or CI runner — who clones the repo gets the exact same tool versions by running `mise install`. No more "it works on my machine" surprises.

```toml
[settings]
# Enable SPM backend for Swift tools
experimental = true

[tools]
# Swift tools via SPM
"spm:swiftlang/swift-format" = "601.0.0"

# Linting (via core or aqua)
swiftlint = "0.58.0"
```

**Critical Settings Explained:**

- `experimental = true` — Enables the SPM backend for Swift Package tools
- `spm:<org>/<repo>` — Tells mise to install a tool by building it from a Swift Package. The format mirrors a GitHub slug: `spm:swiftlang/swift-format` maps to `github.com/swiftlang/swift-format`.

### 3. Create/Update `Makefile`

```makefile
.PHONY: install-dependencies

# Install all mise tools
install-dependencies:
	@mise install
```

**How It Works:**
- `make install-dependencies` installs all tools from `.mise.toml`

### 4. Update GitHub Actions Workflow

Replace multiple tool setup actions with a single mise-action:

```yaml
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v6

      # This replaces multiple tool setup actions
      - uses: jdx/mise-action@v4
        with:
          install: true
          cache: true
```

### 5. Test Locally

```bash
# Install tools
mise install

# Verify installations
mise list
```


## Key Patterns from Production

### ✅ Always Do This

1. **Enable experimental**: `experimental = true` (for SPM backend)
2. **Pin exact versions**: `swiftlint = "0.58.0"` not `"0.58"`
3. **Use mise-action@v4 in CI**: Replaces 5+ setup actions

### ❌ Common Pitfalls

1. **Version drift**: Pin exact versions — `swiftlint = "0.58.0"` not `"0.58"`

### Backend Selection Guide

| Tool Type          | Backend | Example                                    |
| ------------------ | ------- | ------------------------------------------ |
| Swift tools        | `spm`   | `"spm:swiftlang/swift-format" = "601.0.0"` |
| Fast binaries      | `aqua`  | `"aqua:realm/SwiftLint" = "0.58.0"`        |

**When to use which backend:**
- **core**: First choice for popular tools (Node, Ruby)
- **spm**: Swift Package Manager tools (swift-format, periphery)
- **aqua**: Fast alternative for tools in Aqua registry

---

## Quick Reference Commands

```bash
# Install all tools from .mise.toml
mise install

# List installed tools
mise list

# Run tool explicitly (ensures correct version)
mise exec swiftlint -- swiftlint lint

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
mise exec swiftlint -- swiftlint version
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

# Ensure mise-action@v4 is used in workflow
grep "jdx/mise-action@v4" .github/workflows/*.yml
```

---

## Conclusion

A few things worth keeping in mind as you get started:

- **Commit `.mise.toml`** to version control — that's what makes tool versions consistent across your team and in CI.
- **Use the `spm:` prefix** for Swift Package tools like swift-format and periphery.
- **`mise install` is all you need** — any developer who clones your repo can be up and running with a single command.
- **One step in GitHub Actions** replaces all your individual tool-setup boilerplate. The `jdx/mise-action` reads the same `.mise.toml` your teammates use locally.

---

## Resources

- **Mise Official Docs**: [mise.jdx.dev][2]
- **GitHub Action**: [jdx/mise-action][3]
- **Mise Registry**: [mise.jdx.dev/registry.html][5]

---

This guide is based on production implementations across my app projects.

[2]:	https://mise.jdx.dev
[3]:	https://github.com/jdx/mise-action
[5]:	https://mise.jdx.dev/registry.html
