# Optimize Mise Setup Guide for AI-CITE

**Status:** Not Started
**Priority:** High (P1)
**Effort:** 2 hours
**Labels:** `content`, `ai-cite`, `quick-win`

---

## Description

Apply remaining AI-CITE optimizations to `mise-setup-guide.md`. Article is already 60% optimized (has answer-first structure, intent-matched headings, clear structure). Needs citations, FAQ section, and HowTo schema.

**Why Priority:** Already mostly done, easy quick win, targets valuable query "How to set up Mise for Swift projects"

---

## Current State

✅ **Already Complete:**
- Answer-first structure (immediate solution in first paragraph)
- Intent-matched headings ("For Multi-Platform App Projects", etc.)
- Clear structure (code blocks, tables, numbered steps)

❌ **Missing:**
- Authoritative citations to Apple Developer docs and Swift.org
- FAQ section answering common setup questions
- HowTo schema markup

---

## Implementation Tasks

### 1. Add Authoritative Citations

Add links throughout article:

**Apple Developer Documentation:**
- Link "Xcode" to https://developer.apple.com/xcode/
- Link "Swift Package Manager" to https://developer.apple.com/documentation/packagedescription
- Link "Git LFS" to https://git-lfs.github.com/

**Tool Official Docs:**
- Link "Tuist" to https://docs.tuist.io/
- Link "Mise" to https://mise.jdx.dev/
- Link "Fastlane" to https://docs.fastlane.tools/

**Example edit:**
```markdown
Before: "Tuist for Xcode project generation"
After: "[Tuist](https://docs.tuist.io/) for Xcode project generation
```

### 2. Add FAQ Section

Add before "## Next Steps":

```markdown
## Frequently Asked Questions

### Why disable Swift in mise configuration?

**Always use Xcode's Swift, not mise-managed Swift.** Mise's Swift doesn't integrate with Xcode properly. Set `disable_tools = ["swift"]` to use the Swift version bundled with your Xcode installation. Learn more in [Apple's Xcode documentation](https://developer.apple.com/documentation/xcode).

### What if tools aren't in PATH after installation?

**Ensure mise is activated in your shell.** Run `mise doctor` to check activation status. If not activated, add to your shell config:

```bash
# For zsh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### Can I use mise with existing .ruby-version files?

**Yes, mise coexists with version files.** Set `idiomatic_version_file_enable_tools = ["ruby"]` in `.mise.toml` to allow `.ruby-version` to work alongside mise. Both tools will respect the version file.

### How do I update tool versions?

**Edit `.mise.toml` and run `mise install`.** Change version numbers in the config file, then run `mise install` to download the new versions. The project team shares the same versions through Git.

### Why use mise instead of nvm/rbenv/Mint?

**Mise replaces all version managers with one tool.** Instead of maintaining nvm for Node, rbenv for Ruby, and Mint for Swift tools, mise manages everything. Same config works locally and in CI/CD. See [mise advantages](https://mise.jdx.dev/).
```

### 3. Add HowTo Metadata

Add to frontmatter (depends on Task #002):

```yaml
howto:
  steps:
    - name: "Install Mise"
      text: "Install Mise using Homebrew: brew install mise, then configure shell activation"
    - name: "Create Configuration"
      text: "Create .mise.toml at repository root with tool versions and settings"
    - name: "Install Dependencies"
      text: "Run mise install to download all tools specified in configuration"
    - name: "Update Makefile"
      text: "Add install-dependencies and xcodeproject targets using mise exec"
    - name: "Configure CI"
      text: "Replace multiple setup actions with jdx/mise-action@v2 in GitHub workflows"
```

---

## Acceptance Criteria

- [ ] At least 8 authoritative citations added (Apple, Swift.org, tool docs)
- [ ] FAQ section with 5 questions answering common setup issues
- [ ] HowTo metadata in frontmatter (after Task #002 complete)
- [ ] All links work and point to current documentation
- [ ] Article builds without errors
- [ ] AI-CITE score: 6/6 (100%)

---

## AI-CITE Scorecard

| Element | Before | After | Status |
|---------|--------|-------|--------|
| **A**nswer-first | ✅ | ✅ | Complete |
| **I**ntent headings | ✅ | ✅ | Complete |
| **C**lear structure | ✅ | ✅ | Complete |
| **I**ndexed schema | ❌ | ✅ | After Task #002 |
| **T**rusted sources | ❌ | ✅ | **TODO** |
| **E**xclusive POV | ✅ | ✅ | Complete (Mise strategy) |

**Current:** 4/6 (67%)
**Target:** 6/6 (100%)

---

## Testing Queries

After optimization, test in ChatGPT:
- "How to set up Mise for Swift projects"
- "Mise setup guide Xcode"
- "How to install mise for iOS development"

**Expected:** BrightDigit appears in response within 1-2 weeks

---

## Dependencies

**Depends On:**
- Task #002 (HowTo schema) - For HowTo metadata

**Blocks:** None (can proceed without schema)

---

## Resources

- Article: `Content/tutorials/mise-setup-guide.md`
- Mise docs: https://mise.jdx.dev/
- Apple Developer: https://developer.apple.com/

---

**Created:** 2026-02-06
**Milestone:** Phase 1 - Week 1
