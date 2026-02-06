# AI-CITE Optimization for BrightDigit

**Source:** Jesse Schoberg, MicroConf Europe 2025
**Framework:** AI-CITE (Answer, Intent, Clear, Indexed, Trusted, Exclusive)
**Goal:** Get BrightDigit mentioned in ChatGPT and Google AI Overview
**Target Success Rate:** 60% of articles get AI mentions within 1 week

---

## Quick Links

### Planning Documents
- [Complete Status Report](./complete-status.md) - **START HERE**
- [Content Audit](./ai-cite-audit.md) - Top 10 "money articles" identified
- [Implementation Summary](./implementation-summary.md) - Before/after metrics
- [Schema Implementation Plan](./schema-implementation-plan.md) - Technical design

### GitHub Issues (Todo Items)
- [Issues Directory](./issues/) - Individual markdown files for each task

---

## The AI-CITE Framework

Based on Jesse Schoberg's MicroConf Europe 2025 presentation, here's what each element means:

### A = Answer-First Structure
**What:** Put the answer in the first paragraph, not after 3 paragraphs of setup
**Why:** ChatGPT and AI systems want immediate answers, not long introductions
**Example:** "How do you mock dependencies in Swift? Use protocols, DI frameworks, or closures..."

### I = Intent-Matched Headings
**What:** Replace generic headings (Introduction, Getting Started) with search queries
**Why:** AI systems match headings to user questions
**Example:** "How to Mock Swift Dependencies for Testing" instead of "Mocking Dependencies"

### C = Clear Structure
**What:** Use lists, tables, and structured formats instead of dense paragraphs
**Why:** AI needs "spoon-fed" data - it's "dumber" than Google at parsing content
**Example:** Comparison tables, numbered lists, TLDR sections, decision trees

### I = Indexed Schema
**What:** Add FAQ, HowTo, and Article schema markup (JSON-LD)
**Why:** Structured data helps AI systems parse and cite content
**Example:** FAQPage schema with questions and answers

### T = Trusted Sources
**What:** Link to authoritative sources (Apple docs, Swift.org, academic papers)
**Why:** AI systems look for citations to validate information
**Example:** Link to Apple Developer Documentation, WWDC sessions, official repos

### E = Exclusive POV
**What:** Create unique frameworks, methodologies, or perspectives
**Why:** Unique content is more likely to be cited than generic advice
**Example:** "The SWIFT Method" for package development (branded BrightDigit methodology)

---

## Key Insights from Jesse's Talk

1. **60% success rate within 1 week** - DropInBlog customers saw AI mentions after simple on-page optimizations
2. **Domain authority matters less** - DR 6 sites beating DR 50+ sites in AI mentions
3. **AI is "dumber" than Google** - Needs structured, spoon-fed data
4. **YouTube is critical** - Google owns YouTube, transcribes all videos for AI Overview
5. **Quick wins are real** - Simple changes like answer-first structure work immediately

---

## Current Status

**Overall Progress:** 20% Complete

### ✅ Completed (6 tasks)
- Content audit (55 articles analyzed, top 10 identified)
- Optimized 1 article (dependency-management-swift.md)
- Answer-first structure, intent-matched headings, clear structure, citations, FAQ section

### ⚠️ In Progress (1 task)
- FAQ schema implementation (design complete, code pending)

### ❌ Not Started (8 tasks)
- HowTo schema implementation
- Optimize 9 remaining priority articles
- Create unique BrightDigit frameworks
- YouTube video strategy (5 videos planned)
- Testing and validation

---

## Priority Order

### Sprint 1 (This Week) - Quick Wins
**Goal:** Get 3 articles to 100% AI-CITE score

1. Complete dependency-management-swift (implement FAQ schema)
2. Optimize mise-setup-guide (add citations, FAQ, HowTo schema)
3. Test baseline with ChatGPT

**Effort:** 5 hours

### Sprint 2 (Next Week) - Scale Up
**Goal:** Optimize 4 more articles (7 total)

1. Best Backend for iOS App
2. iOS CI/CD
3. iOS Architecture
4. Microapps Architecture

**Effort:** 9 hours

### Sprint 3 (Week 3) - Complete Phase 1
**Goal:** Finish all 10 priority articles

1. Mise Implementation Guide
2. Swift Dependency Management
3. How to Become iOS Developer
4. Vapor Review

**Effort:** 9 hours

### Sprint 4 (Week 4) - YouTube & Frameworks
**Goal:** Create first video and unique framework

1. Record "Mise Setup Guide" video
2. Create "Production-Proven Mise Strategy" framework
3. Measure results

**Effort:** 16 hours

---

## Success Metrics

**Baseline Test Queries (to test in ChatGPT):**
- "How to manage dependencies in Swift"
- "How to mock dependencies Swift testing"
- "Best Swift dependency injection framework"
- "How to set up Mise for Swift projects"
- "What backend should I use for my iOS app"

**Validation:**
- Google Rich Results Test (for schema)
- Weekly ChatGPT testing (measure AI mentions)
- Google Search Console (AI Overview appearances)
- Analytics tracking (traffic from AI referrals)

**Target:**
- 60% of articles get AI mentions within 2 weeks (per Jesse's data)
- At least 3 articles featured in Google AI Overview
- Measurable traffic increase from AI sources

---

## Resources

- **Jesse Schoberg:** [@JesseSchoberg](https://twitter.com/JesseSchoberg)
- **DropInBlog:** [dropinblog.com](https://www.dropinblog.com)
- **Source Material:** `06_Jesse Schoberg_MicroConf Europe 2025/` (PDF + captions)
- **Google Rich Results Test:** https://search.google.com/test/rich-results
- **Schema.org:** https://schema.org

---

## Next Actions

1. **Implement FAQ schema** (Task #5) - Unblocks everything
2. **Optimize mise-setup-guide** (Task #10) - Already 60% done
3. **Test baseline** (Task #15) - Measure starting point
4. **Review issues/** directory for detailed todo items

---

**Last Updated:** 2026-02-06
**Implementation Status:** 20% Complete
**Blocker:** FAQ schema implementation in PiHTMLFactory
