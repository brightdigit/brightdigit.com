# AI-CITE Implementation Issues Index

All developer and research todo items in GitHub issue format.

**Total Issues:** 13
**Completed:** 0
**In Progress:** 1 (FAQ Schema)
**Not Started:** 12

---

## Critical Path (P0) - Week 1

These must be completed first to unblock everything else:

### [001 - Implement FAQ Schema Markup](./001-implement-faq-schema.md) ⚠️ **IN PROGRESS**
**Effort:** 4-6 hours | **Priority:** P0 | **Blocks:** Everything

Implement JSON-LD FAQ schema generation in PiHTMLFactory. Critical blocker for Phase 1.

**Acceptance criteria:**
- FAQSchema.swift created
- `.jsonLDSchema()` helper in HTML.HeadContext
- PageContent reads FAQ from metadata
- dependency-management-swift.md has FAQ metadata
- Validates in Google Rich Results Test

---

## High Priority (P1) - Weeks 1-3

### [002 - Implement HowTo Schema Markup](./002-implement-howto-schema.md)
**Effort:** 3-4 hours | **Priority:** P1 | **Depends on:** #001

Implement JSON-LD HowTo schema for tutorial articles with step-by-step instructions.

**Target tutorials:** mise-setup-guide, vapor setup, swift-build

---

### [003 - Optimize Mise Setup Guide](./003-optimize-mise-setup-guide.md) ⭐ **QUICK WIN**
**Effort:** 2 hours | **Priority:** P1 | **Depends on:** #002

Apply remaining AI-CITE optimizations. Already 60% complete!

**Missing:**
- Authoritative citations (8+)
- FAQ section (5 questions)
- HowTo schema metadata

**AI-CITE Score:** 4/6 → 6/6

---

### [004 - Optimize Best Backend Article](./004-optimize-best-backend-article.md)
**Effort:** 3 hours | **Priority:** P1

High-value article targeting "What backend should I use for my iOS app"

**Tasks:**
- Answer-first rewrite
- Comparison table (CloudKit vs Firebase vs Vapor)
- Fix 5 headings
- FAQ section
- 10+ citations

**AI-CITE Score:** 2/6 → 6/6

---

### [005 - Test Baseline & Validate](./005-test-baseline-validate.md)
**Effort:** 2 hours + 1 hr/week × 4 | **Priority:** P1

Establish baseline, validate schema, measure weekly progress toward 60% success rate.

**Phases:**
1. Test 10 queries in ChatGPT (baseline)
2. Validate schema (Rich Results Test)
3. Weekly monitoring (measure improvement)

---

## Content Optimization (P1) - Week 2-3

### 008 - Optimize iOS CI/CD Article
**Article:** `ios-continuous-integration-avoid-merge-hell.md`
**Effort:** 2 hours | **Priority:** P1

- Answer-first rewrite
- Convert "How to get started" to numbered checklist
- Add HowTo schema
- Citations: GitHub Actions, Bitrise, Fastlane docs

---

### 009 - Optimize iOS Architecture Article
**Article:** `ios-software-architecture.md`
**Effort:** 3 hours | **Priority:** P1

- Answer-first intro with recommendations
- MVC vs MVVM vs Microapps comparison table
- "How to Choose" decision guide
- Citations: Apple WWDC sessions

---

### 010 - Optimize Remaining Priority Articles (Batch)
**Articles:** mise-implementation-guide, swift-dependency-management, how-to-become-iOS-developer, microapps-architecture, vapor-review
**Effort:** 10 hours total | **Priority:** P1

Apply AI-CITE framework to 5 remaining priority articles.

---

## Medium Priority (P2) - Month 2+

### [006 - YouTube Video Strategy](./006-youtube-video-strategy.md)
**Effort:** 40-60 hours total | **Priority:** P2

Create 5 companion YouTube videos for top articles.

**Priority videos:**
1. Mise Setup Guide (10 hours)
2. Mocking Swift Dependencies (12 hours)
3. Choosing iOS Backend (10 hours)
4. iOS CI/CD Setup (12 hours)
5. iOS Architecture Patterns (10 hours)

**Why:** Google transcribes YouTube for AI Overview. Easy way to "crowd the SERP."

---

### [007 - Create Unique Frameworks](./007-create-unique-frameworks.md)
**Effort:** 8-12 hours | **Priority:** P2

Create branded BrightDigit methodologies (AI-CITE "E" - Exclusive POV).

**Frameworks to create:**
1. **The SWIFT Method** - Package development (6-8 hrs)
2. **5-Layer Architecture Pattern** - iOS architecture (4-6 hrs)
3. **Mise Production Patterns** - Tooling lessons (2-3 hrs)
4. **Microapp Decision Framework** - Architecture choice (3-4 hrs)

---

## Issue Status Summary

| # | Title | Effort | Priority | Status | Sprint |
|---|-------|--------|----------|--------|--------|
| 001 | FAQ Schema | 4-6h | P0 | In Progress | Week 1 |
| 002 | HowTo Schema | 3-4h | P1 | Not Started | Week 1 |
| 003 | Mise Setup Guide | 2h | P1 | Not Started | Week 1 |
| 004 | Best Backend | 3h | P1 | Not Started | Week 2 |
| 005 | Test & Validate | 2h+4h | P1 | Not Started | Weeks 1-4 |
| 008 | iOS CI/CD | 2h | P1 | Not Started | Week 2 |
| 009 | iOS Architecture | 3h | P1 | Not Started | Week 2 |
| 010 | Remaining Articles | 10h | P1 | Not Started | Week 3 |
| 006 | YouTube Videos | 40-60h | P2 | Not Started | Month 2 |
| 007 | Unique Frameworks | 8-12h | P2 | Not Started | Month 2-3 |

**Total Phase 1 Effort:** 29-35 hours
**Total Phase 2 Effort:** 48-72 hours

---

## Sprint Planning

### Sprint 1 (This Week) - Quick Wins
**Goal:** Get 3 articles to 100% AI-CITE score

**Issues:** #001, #002, #003, #005 (baseline)
**Effort:** 11-14 hours
**Outcome:** 3 fully optimized articles with schema

---

### Sprint 2 (Next Week) - Scale Up
**Goal:** Optimize 4 more articles (7 total)

**Issues:** #004, #008, #009
**Effort:** 8 hours
**Outcome:** 7 articles optimized (70% of priority list)

---

### Sprint 3 (Week 3) - Complete Phase 1
**Goal:** Finish all 10 priority articles

**Issues:** #010
**Effort:** 10 hours
**Outcome:** 100% of priority articles optimized

---

### Sprint 4+ (Month 2) - YouTube & Frameworks
**Goal:** Create video content and unique frameworks

**Issues:** #006, #007
**Effort:** 48-72 hours
**Outcome:** 5 videos, 1-2 unique frameworks

---

## Quick Reference

**Issue Template Location:** `docs/ai-cite-optimization/issues/`

**Related Documents:**
- [00-README.md](../00-README.md) - Overview and quick links
- [complete-status.md](../complete-status.md) - Full status report
- [ai-cite-audit.md](../ai-cite-audit.md) - Content audit results
- [schema-implementation-plan.md](../schema-implementation-plan.md) - Technical design

**Source Material:**
- `06_Jesse Schoberg_MicroConf Europe 2025/` - Original presentation

---

## How to Use These Issues

### For Developers

1. **Start with #001** (FAQ Schema) - Critical blocker
2. **Read issue completely** - Includes implementation code
3. **Check acceptance criteria** - Know when you're done
4. **Test thoroughly** - Use testing section
5. **Update issue status** - Mark complete when done

### For Content Writers

1. **Start with #003** (Mise Setup Guide) - Quick win
2. **Follow AI-CITE framework** - Answer-first, intent headings, etc.
3. **Add citations** - Link to Apple docs, official sources
4. **Write FAQ** - 5 questions per article minimum
5. **Test queries** - Check if article appears in ChatGPT

### For Project Managers

1. **Track in GitHub Projects** - Import these as issues
2. **Monitor weekly progress** - Use Sprint planning above
3. **Measure success rate** - Issue #005 provides testing framework
4. **Adjust priorities** - Based on which articles get AI mentions first

---

**Last Updated:** 2026-02-06
**Next Review:** After Sprint 1 completion
