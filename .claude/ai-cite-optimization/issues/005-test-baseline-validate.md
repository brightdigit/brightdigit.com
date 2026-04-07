# Test AI-CITE Baseline and Validate Schema

**Status:** Not Started
**Priority:** High (P1)
**Effort:** 2 hours initial + 1 hour/week × 4 weeks
**Labels:** `testing`, `validation`, `measurement`

---

## Description

Establish baseline AI mention metrics before optimization, then validate schema implementation and measure weekly progress toward 60% success rate goal (per Jesse Schoberg's data).

---

## Phase 1: Baseline Testing (Week 1)

### ChatGPT Queries

Test these queries and document whether BrightDigit appears:

```markdown
1. "How to manage dependencies in Swift"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

2. "How to mock dependencies Swift testing"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

3. "Best Swift dependency injection framework"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

4. "How to set up Mise for Swift projects"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

5. "What backend should I use for my iOS app"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

6. "How to set up CI/CD for iOS"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

7. "What iOS architecture pattern should I use"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

8. "Protocol vs closure dependency injection Swift"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

9. "How to mock CoreLocation Swift"
   - [ ] BrightDigit mentioned: Yes/No
   - [ ] If yes, which article?
   - [ ] Quote used:

10. "Swift microapps architecture"
    - [ ] BrightDigit mentioned: Yes/No
    - [ ] If yes, which article?
    - [ ] Quote used:
```

**Save baseline to:** `docs/ai-cite-optimization/testing/baseline-week1.md`

### Google AI Overview Check

For each query above:
1. Google search in incognito mode
2. Check if AI Overview appears
3. Note if BrightDigit is cited

---

## Phase 2: Schema Validation (After Tasks #001, #002)

### Google Rich Results Test

**Test URL:** https://search.google.com/test/rich-results

**Articles to validate:**

1. **dependency-management-swift** (FAQ schema)
   - [ ] Paste URL or HTML
   - [ ] "FAQPage" detected: Yes/No
   - [ ] Errors: (list)
   - [ ] Warnings: (list)
   - Screenshot: (save to docs)

2. **mise-setup-guide** (HowTo schema)
   - [ ] Paste URL or HTML
   - [ ] "HowTo" detected: Yes/No
   - [ ] Errors: (list)
   - [ ] Warnings: (list)
   - Screenshot: (save to docs)

### Schema Validator

**Test URL:** https://validator.schema.org/

1. Extract JSON-LD from HTML: `<script type="application/ld+json">`
2. Paste into validator
3. Verify no errors

### Browser Console Check

```bash
# Start local server
swift run brightdigitwg publish
cd Output
python3 -m http.server 8000

# Open http://localhost:8000/articles/dependency-management-swift/
# Open browser console (Cmd+Opt+J)
# Check for errors
```

---

## Phase 3: Weekly Monitoring (Weeks 2-4)

### Week 2 (After 3 articles optimized)

**Date:** ___________

Re-test ChatGPT queries 1-5:
- Query 1: ☐ BrightDigit mentioned (change from baseline?)
- Query 2: ☐ BrightDigit mentioned (change from baseline?)
- Query 3: ☐ BrightDigit mentioned (change from baseline?)
- Query 4: ☐ BrightDigit mentioned (change from baseline?)
- Query 5: ☐ BrightDigit mentioned (change from baseline?)

**Success rate:** ___/5 (___%)

### Week 3 (After 7 articles optimized)

**Date:** ___________

Re-test all 10 queries:
- Queries with mentions: ___/10
- New mentions: (list)
- Success rate: ___%

### Week 4 (After all 10 articles optimized)

**Date:** ___________

Re-test all 10 queries:
- Queries with mentions: ___/10
- Success rate: ___%
- **Target met:** ☐ Yes (60%+) ☐ No

---

## Analytics Tracking

### Google Analytics

**Custom report:** AI Referral Traffic

**Metrics to track:**
- Sessions from AI sources
- Pages/session
- Bounce rate
- Goal completions (newsletter signup, etc.)

**Dimensions:**
- Source/Medium
- Landing Page
- Device Category

### Google Search Console

**Filter:** Pages with AI Overview appearances

**Track:**
- Impressions in AI Overview
- Clicks from AI Overview
- CTR
- Average position

---

## Acceptance Criteria

- [ ] Baseline documented for all 10 queries
- [ ] Google AI Overview checked for all queries
- [ ] Schema validated for 2+ articles (Rich Results Test)
- [ ] No JavaScript console errors
- [ ] Weekly monitoring template created
- [ ] Analytics tracking configured
- [ ] Final success rate calculated (target: 60%+)

---

## Success Metrics

**Based on Jesse Schoberg's data:**
- 60% of DropInBlog customers got AI mentions within 1 week
- Simple on-page optimizations were sufficient
- DR matters less for AI than traditional SEO

**BrightDigit Target:**
- **Conservative:** 3/10 articles (30%) get AI mentions in 2 weeks
- **Target:** 6/10 articles (60%) get AI mentions in 2-3 weeks
- **Stretch:** Featured in Google AI Overview for 2+ queries

---

## Resources

- Google Rich Results Test: https://search.google.com/test/rich-results
- Schema Validator: https://validator.schema.org/
- Google Search Console: https://search.google.com/search-console
- Google Analytics: https://analytics.google.com/

---

## Testing Template Files

Create these markdown files:

```
docs/ai-cite-optimization/testing/
├── baseline-week1.md
├── monitoring-week2.md
├── monitoring-week3.md
├── monitoring-week4.md
└── final-results.md
```

---

**Created:** 2026-02-06
**Milestone:** Phase 1 - Ongoing
