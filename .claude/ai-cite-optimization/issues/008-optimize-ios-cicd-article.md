# Optimize iOS CI/CD Article for AI-CITE

**Status:** Not Started
**Priority:** High (P1)
**Effort:** 2 hours
**Labels:** `content`, `ai-cite`, `howto`

---

## Description

Apply AI-CITE framework to `ios-continuous-integration-avoid-merge-hell.md`. Article targets query "How to set up CI/CD for iOS" and needs answer-first rewrite, numbered checklist, HowTo schema, and authoritative citations.

---

## Current Issues

❌ **No immediate answer** - Long introduction before solution
❌ **Prose instead of checklist** - "How to get started" section needs numbered steps
❌ **Missing HowTo schema** - Perfect candidate for step-by-step markup
❌ **No citations** - Missing links to GitHub Actions, Bitrise, Fastlane official docs
❌ **Generic headings** - Need intent-matched format

---

## Implementation Tasks

### 1. Rewrite Introduction (Answer-First)

**Replace opening paragraphs with:**

```markdown
**How do you set up CI/CD for iOS to avoid merge hell?** Use automated continuous integration with **[GitHub Actions](https://docs.github.com/en/actions)** (free, built-in) or **[Bitrise](https://www.bitrise.io/)** (specialized for mobile). Run automated tests on every pull request, use feature branches, and merge frequently (daily) to prevent integration conflicts.

**Quick setup checklist:**
1. Choose CI service (GitHub Actions for simple, Bitrise for advanced)
2. Configure automated testing with [Fastlane](https://docs.fastlane.tools/)
3. Require passing tests before merge
4. Use trunk-based development (short-lived branches)
5. Merge to main at least daily

Here's how to implement each step:
```

### 2. Convert "How to Get Started" to Numbered Checklist

Transform prose section into actionable steps:

```markdown
## How to Set Up iOS CI/CD (Step-by-Step)

**Step 1: Choose Your CI Service**

For iOS projects, recommended options:
- **[GitHub Actions](https://docs.github.com/en/actions)** - Free for public repos, macOS runners available
- **[Bitrise](https://www.bitrise.io/)** - iOS-specialized, visual workflow editor
- **[CircleCI](https://circleci.com/)** - Good macOS support, generous free tier

Most teams start with GitHub Actions for simplicity.

**Step 2: Set Up Fastlane**

Install [Fastlane](https://docs.fastlane.tools/) for iOS automation:

```bash
# Install Fastlane
brew install fastlane

# Initialize in project
cd your-project
fastlane init
```

**Step 3: Create Test Lane**

Add to `fastlane/Fastfile`:

```ruby
lane :test do
  run_tests(scheme: "YourApp")
end
```

**Step 4: Configure GitHub Actions Workflow**

Create `.github/workflows/test.yml`:

```yaml
name: iOS CI
on: [pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: fastlane test
```

**Step 5: Require Passing Tests**

In GitHub repository settings:
1. Go to Settings → Branches
2. Add branch protection rule for `main`
3. Check "Require status checks to pass"
4. Select your CI workflow

**Step 6: Adopt Trunk-Based Development**

- Create feature branches from `main`
- Keep branches alive < 24 hours
- Merge to `main` daily (or more)
- Delete branches after merge
```

### 3. Add HowTo Metadata

Add to frontmatter (depends on Task #002):

```yaml
howto:
  steps:
    - name: "Choose CI Service"
      text: "Select GitHub Actions for free macOS runners or Bitrise for iOS-specialized workflows"
    - name: "Install Fastlane"
      text: "Install Fastlane via Homebrew and initialize in project: brew install fastlane && fastlane init"
    - name: "Create Test Lane"
      text: "Add test lane to Fastfile that runs unit tests for your iOS scheme"
    - name: "Configure CI Workflow"
      text: "Create GitHub Actions workflow that runs Fastlane tests on every pull request"
    - name: "Enable Branch Protection"
      text: "Require passing CI checks before allowing pull request merges to main branch"
    - name: "Adopt Trunk-Based Development"
      text: "Use short-lived feature branches merged daily to prevent integration conflicts"
```

### 4. Fix Headings to Intent-Match

| Before (Generic) | After (Search Query) |
|------------------|---------------------|
| "What is Continuous Integration?" | "What Does Continuous Integration Mean for iOS Development?" |
| "The Benefits" | "Why Use CI/CD for iOS Projects?" |
| "How to Get Started" | "How to Set Up iOS CI/CD in 6 Steps" |
| "Conclusion" | "Should Every iOS Team Use CI/CD?" |

### 5. Add Citations

Throughout article, link to:
- **GitHub:** [GitHub Actions docs](https://docs.github.com/en/actions)
- **Fastlane:** [Official Fastlane docs](https://docs.fastlane.tools/)
- **Bitrise:** [Bitrise documentation](https://devcenter.bitrise.io/)
- **Apple:** [Xcode Cloud](https://developer.apple.com/xcode-cloud/)
- **CircleCI:** [CircleCI iOS guide](https://circleci.com/docs/testing-ios/)

### 6. Add FAQ Section

```markdown
## Frequently Asked Questions

### Should I use GitHub Actions or Bitrise for iOS CI/CD?

**Use GitHub Actions if your code is on GitHub, Bitrise for complex mobile workflows.** GitHub Actions is free for public repos and well-integrated with GitHub. Bitrise specializes in mobile with visual workflow builder and better iOS tooling. Most small teams prefer GitHub Actions for simplicity. See [GitHub Actions pricing](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions) vs [Bitrise pricing](https://www.bitrise.io/pricing).

### How often should I merge to main branch?

**At least daily (trunk-based development).** Frequent small merges prevent integration conflicts. Keep feature branches alive < 24 hours. Merge multiple times per day if possible. This is the core practice that avoids "merge hell." Learn more in [Martin Fowler's trunk-based development guide](https://martinfowler.com/articles/continuousIntegration.html).

### What tests should run in iOS CI pipeline?

**Run unit tests on every PR, UI tests nightly.** Unit tests are fast (< 5 min) and catch most issues. UI tests are slow (20-60 min) so run them on scheduled builds or before releases. Always run tests before merging. Configure with [Fastlane's run_tests action](https://docs.fastlane.tools/actions/run_tests/).

### Do I need code signing in CI for testing?

**No, unit tests don't need code signing.** Tests run in simulator without provisioning profiles. Only need code signing for: building release binaries, running on physical devices, or uploading to TestFlight. See [Apple's code signing guide](https://developer.apple.com/support/code-signing/).

### How much does iOS CI/CD cost?

**Free for public repos on GitHub Actions, $0-50/month for private projects.** GitHub Actions includes 2,000 free macOS minutes/month for private repos (about 20 hours). Bitrise has free tier for small teams. Most indie iOS projects pay $0. Enterprise teams budget $50-200/month. Check current pricing: [GitHub Actions](https://github.com/pricing), [Bitrise](https://www.bitrise.io/pricing).
```

---

## Acceptance Criteria

- [ ] Answer-first introduction (< 3 paragraphs)
- [ ] "How to Get Started" converted to 6 numbered steps
- [ ] HowTo metadata in frontmatter
- [ ] 8+ authoritative citations (GitHub, Fastlane, Apple docs)
- [ ] 4 headings updated to search-query format
- [ ] FAQ section with 5 questions
- [ ] Article builds without errors
- [ ] AI-CITE score: 6/6

---

## AI-CITE Scorecard

| Element | Before | After | Status |
|---------|--------|-------|--------|
| **A**nswer-first | ❌ | ✅ | **TODO** |
| **I**ntent headings | ❌ | ✅ | **TODO** |
| **C**lear structure | ⚠️ | ✅ | **TODO** |
| **I**ndexed schema | ❌ | ✅ | After Task #002 |
| **T**rusted sources | ❌ | ✅ | **TODO** |
| **E**xclusive POV | ⚠️ | ✅ | Present (trunk-based dev) |

**Current:** 1/6 (17%)
**Target:** 6/6 (100%)

---

## Testing Queries

After optimization, test in ChatGPT:
- "How to set up CI/CD for iOS"
- "iOS continuous integration GitHub Actions"
- "Fastlane CI/CD setup"
- "How to avoid merge conflicts iOS team"

**Expected:** BrightDigit appears in response within 1-2 weeks

---

## Dependencies

**Depends On:**
- Task #002 (HowTo schema) - For schema metadata

**Blocks:** None

---

## Resources

- Article: `Content/articles/ios-continuous-integration-avoid-merge-hell.md`
- GitHub Actions: https://docs.github.com/en/actions
- Fastlane: https://docs.fastlane.tools/
- Bitrise: https://www.bitrise.io/

---

**Created:** 2026-02-07
**Milestone:** Phase 1 - Week 2
