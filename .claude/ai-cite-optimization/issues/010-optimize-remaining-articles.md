# Optimize Remaining Priority Articles (Batch)

**Status:** Not Started
**Priority:** High (P1)
**Effort:** 10 hours total (2 hours per article)
**Labels:** `content`, `ai-cite`, `batch`

---

## Description

Apply AI-CITE framework to 5 remaining priority articles in batch. These articles already have good content but need optimization for AI mentions: answer-first rewrites, citations, FAQ sections, and intent-matched headings.

---

## Target Articles

### 1. mise-implementation-guide.md (2 hours)

**Query target:** "How to implement Mise across organization"

**Optimizations needed:**
- Answer-first intro (immediate advice)
- Citations to Mise official docs, Docker docs
- FAQ section (5 questions)
- HowTo schema (if applicable)

**Current issues:**
- Long introduction before practical advice
- Missing links to official documentation
- No FAQ for common implementation problems

---

### 2. swift-dependency-management.md (2 hours)

**Query target:** "How to manage Swift package dependencies"

**Optimizations needed:**
- Answer-first structure (SPM vs CocoaPods vs Carthage upfront)
- Comparison table of dependency managers
- Citations to Swift.org, Apple SPM docs
- FAQ section about dependency resolution issues

**Current issues:**
- Generic introduction
- No clear recommendation at start
- Missing authoritative citations

---

### 3. how-to-become-iOS-developer.md (2 hours)

**Query target:** "How to become an iOS developer in 2026"

**Optimizations needed:**
- Answer-first roadmap (steps 1-5 upfront)
- Updated for 2026 (SwiftUI first, not UIKit)
- Citations to Apple developer resources, WWDC
- FAQ about timeline, bootcamps, portfolio

**Current issues:**
- May be outdated (check UIKit vs SwiftUI emphasis)
- No clear timeline or roadmap upfront
- Missing modern learning resources (2024-2026)

---

### 4. microapps-architecture.md (2 hours)

**Query target:** "What is microapps architecture iOS"

**Optimizations needed:**
- Answer-first definition and when to use
- Comparison: Microapps vs Monolith vs Modular
- Citations to Uber/Lyft engineering blogs
- FAQ about implementation complexity

**Current issues:**
- May not clearly explain "why" upfront
- Missing comparison to alternatives
- No decision framework for "should we use this?"

---

### 5. vapor-review.md (2 hours)

**Query target:** "Is Vapor good for iOS backend"

**Optimizations needed:**
- Answer-first verdict (pros/cons summary)
- Comparison table vs Node.js/Rails/Django
- Citations to Vapor official docs, performance benchmarks
- FAQ about production readiness, hosting costs

**Current issues:**
- Review may not give clear recommendation upfront
- Missing technical comparisons
- No FAQ about common concerns

---

## Implementation Checklist (Per Article)

Use this template for each article:

### Phase 1: Analysis (15 mins)
- [ ] Read current article completely
- [ ] Identify target search query
- [ ] Note current AI-CITE score (0-6)
- [ ] List major issues (missing elements)

### Phase 2: Answer-First Rewrite (30 mins)
- [ ] Rewrite first 2-3 paragraphs with immediate answer
- [ ] Add quick decision guide or summary
- [ ] Move detailed explanation after the answer

### Phase 3: Add Structure (30 mins)
- [ ] Fix 3-5 headings to search-query format
- [ ] Add comparison table (if applicable)
- [ ] Add decision framework or checklist

### Phase 4: Citations (20 mins)
- [ ] Add 8+ authoritative citations
- [ ] Link to official docs (Apple, Swift.org, tool docs)
- [ ] Link to relevant blog posts (engineering blogs)

### Phase 5: FAQ Section (30 mins)
- [ ] Write 5 FAQ questions based on search queries
- [ ] Provide concise answers with citations
- [ ] Focus on common objections/concerns

### Phase 6: Validation (10 mins)
- [ ] Build site (`swift run brightdigitwg publish`)
- [ ] Check all links work
- [ ] Verify AI-CITE score improved to 5-6/6
- [ ] Test target query in ChatGPT

---

## AI-CITE Framework Reference

For each article, ensure:

✅ **Answer-first** - Solution in first 2-3 paragraphs
✅ **Intent headings** - Match search queries ("How to X", "What is Y")
✅ **Clear structure** - Tables, lists, code blocks
✅ **Indexed schema** - FAQ/HowTo metadata (if applicable)
✅ **Trusted sources** - 8+ authoritative citations
✅ **Exclusive POV** - Unique insight or framework

---

## Acceptance Criteria

### Per Article
- [ ] Answer-first structure (solution upfront)
- [ ] 3-5 headings updated to intent-matching format
- [ ] 8+ authoritative citations added
- [ ] FAQ section with 5 questions
- [ ] Comparison table or decision guide (where applicable)
- [ ] Builds without errors
- [ ] AI-CITE score: 5-6/6

### Overall
- [ ] All 5 articles optimized
- [ ] Total effort: 10 hours
- [ ] No broken links
- [ ] All articles pass build

---

## Testing Queries

After batch optimization, test these queries in ChatGPT:

1. "How to implement Mise across organization"
2. "How to manage Swift package dependencies"
3. "How to become an iOS developer in 2026"
4. "What is microapps architecture iOS"
5. "Is Vapor good for iOS backend"

**Expected:** 3-5 articles mentioned in AI responses within 2-3 weeks

---

## Dependencies

**Depends On:**
- Tasks #001-002 (Schema) - Optional, not blocking
- Tasks #003-004 (Example optimizations) - Provides template

**Blocks:** None

---

## Resources

**Articles:**
- `Content/tutorials/mise-implementation-guide.md`
- `Content/articles/swift-dependency-management.md`
- `Content/articles/how-to-become-iOS-developer.md`
- `Content/articles/microapps-architecture.md`
- `Content/articles/vapor-review.md`

**Reference:**
- AI-CITE audit: `docs/ai-cite-optimization/ai-cite-audit.md`
- Completed example: `docs/ai-cite-optimization/issues/003-optimize-mise-setup-guide.md`

---

## Notes

**Why batch these together?**
- Same optimization pattern (answer-first + citations + FAQ)
- Can use template workflow for efficiency
- All are P1 priority articles
- Completing batch gives enough data for Week 3 testing

**Recommended order:**
1. swift-dependency-management (easiest, quick win)
2. vapor-review (review format, straightforward)
3. how-to-become-iOS-developer (may need research for 2026 updates)
4. mise-implementation-guide (technical, builds on 003)
5. microapps-architecture (most complex, do last)

---

**Created:** 2026-02-07
**Milestone:** Phase 1 - Week 3
