# Optimize iOS Architecture Article for AI-CITE

**Status:** Not Started
**Priority:** High (P1)
**Effort:** 3 hours
**Labels:** `content`, `ai-cite`, `high-value`

---

## Description

Apply AI-CITE framework to `ios-software-architecture.md`. Article targets query "What iOS architecture pattern should I use" and needs answer-first intro, comparison table, decision guide, and citations to Apple WWDC sessions.

---

## Current Issues

❌ **No immediate recommendation** - Long explanation before advice
❌ **No comparison table** - MVC vs MVVM vs VIPER vs Microapps buried in text
❌ **Missing decision guide** - No clear "When to use X" framework
❌ **No FAQ section**
❌ **No citations** - Missing links to Apple docs, WWDC sessions
❌ **Generic headings** - Need search-query format

---

## Implementation Tasks

### 1. Rewrite Introduction (Answer-First)

**Replace opening with:**

```markdown
**What iOS architecture pattern should you use?** For most teams, start with **MVVM** (Model-View-ViewModel) using SwiftUI. It's Apple's recommended approach, works naturally with SwiftUI's reactive patterns, and balances simplicity with testability. **MVC is fine for small UIKit apps.** Only use VIPER or Clean Architecture for very large, complex apps with 5+ engineers.

**Quick decision guide:**
- **Small app (1-2 engineers, simple screens)** → MVC with UIKit or SwiftUI defaults
- **Medium app (3-5 engineers, moderate complexity)** → MVVM with SwiftUI
- **Large app (5+ engineers, complex business logic)** → MVVM + Coordinators or Microapps
- **Enterprise (10+ engineers, multiple teams)** → VIPER or Clean Architecture

Here's the complete breakdown of each pattern:
```

### 2. Add Architecture Comparison Table

Add after introduction:

```markdown
## iOS Architecture Pattern Comparison

| Pattern | Best For | Complexity | Testability | SwiftUI Fit | Learning Curve |
|---------|----------|------------|-------------|-------------|----------------|
| **MVC** | Small UIKit apps | Low | Medium | Poor | Easy (Apple default) |
| **MVVM** | Medium apps, SwiftUI | Medium | High | Excellent | Medium |
| **VIPER** | Large enterprise apps | High | Very High | Medium | Steep |
| **Clean Architecture** | Complex business logic | High | Very High | Good | Steep |
| **Microapps** | Multi-team apps | Very High | High | Excellent | Very Steep |
| **Redux/TCA** | State-heavy apps | Medium-High | Very High | Excellent | Steep |

### Key Comparisons

**MVC (Model-View-Controller)**
- ✅ Built into UIKit, no setup needed
- ✅ Fast development for simple apps
- ❌ "Massive View Controller" problem at scale
- ❌ Hard to test view controllers
- 📚 [Apple's MVC guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html)

**MVVM (Model-View-ViewModel)**
- ✅ Clean separation, better testing
- ✅ Natural fit for SwiftUI (ObservableObject)
- ✅ Apple's recommended pattern
- ❌ More boilerplate than MVC
- 📚 [WWDC 2019: Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226/)

**VIPER (View-Interactor-Presenter-Entity-Router)**
- ✅ Extreme separation of concerns
- ✅ Very testable (each layer mockable)
- ❌ Lots of boilerplate (5 files per screen)
- ❌ Overkill for small teams
- 📚 [objc.io VIPER guide](https://www.objc.io/issues/13-architecture/viper/)

**Microapps Architecture**
- ✅ Team independence (multiple apps in one)
- ✅ Clear module boundaries
- ❌ Complex build setup
- ❌ Requires infrastructure investment
- 📚 [BrightDigit's Microapps guide](/articles/microapps-architecture/)
```

### 3. Add "How to Choose" Decision Guide

```markdown
## How to Choose the Right iOS Architecture

### Step 1: Assess Your Team Size

**1-2 engineers:** MVC or SwiftUI defaults
- Don't over-architect
- Focus on shipping features
- Extract ViewModels only when controllers get large (> 300 lines)

**3-5 engineers:** MVVM
- Standard choice for most iOS teams
- Good balance of structure and simplicity
- Works perfectly with SwiftUI's ObservableObject

**5-10 engineers:** MVVM + Coordinators
- Add coordinators for navigation flow
- Keep modules loosely coupled
- Consider feature-based modules

**10+ engineers (multiple teams):** VIPER, Clean Architecture, or Microapps
- Need strong boundaries between team codebases
- Investment in architecture pays off at scale
- Consider multi-module workspace

### Step 2: Consider Your UI Framework

**Using SwiftUI?**
→ MVVM with ObservableObject (Apple's recommendation)
→ Or TCA (The Composable Architecture) for complex state

**Using UIKit?**
→ MVVM with protocols and closures
→ Or MVC if app is simple (< 20 screens)

### Step 3: Evaluate Business Logic Complexity

**Simple CRUD app:**
→ MVC or basic MVVM sufficient

**Complex workflows (multi-step forms, business rules):**
→ MVVM + Interactors/Use Cases
→ Or Clean Architecture

**Heavy state management (real-time updates, offline sync):**
→ Redux/TCA for predictable state
→ Or MVVM with Combine

### Step 4: Plan for Growth

**Prototype/MVP:**
→ Start simple (MVC/basic MVVM)
→ Refactor later if needed

**Long-term product:**
→ Invest in MVVM upfront
→ Easier to maintain over years

**Multi-year enterprise project:**
→ VIPER or Clean Architecture
→ Architecture pays off in Year 2+
```

### 4. Fix Headings to Intent-Match

| Before (Generic) | After (Search Query) |
|------------------|---------------------|
| "Understanding iOS Architecture" | "What Are the Main iOS Architecture Patterns?" |
| "MVC Explained" | "When Should You Use MVC for iOS?" |
| "Alternatives to MVC" | "What Are the Alternatives to MVC in iOS?" |
| "Best Practices" | "What Are iOS Architecture Best Practices?" |
| "Conclusion" | "Which iOS Architecture Should You Choose?" |

### 5. Add Citations

Link to official Apple resources:
- [Apple's App Architecture Guide](https://developer.apple.com/documentation/swiftui/model-data)
- [WWDC 2019: Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226/)
- [WWDC 2020: App Essentials in SwiftUI](https://developer.apple.com/videos/play/wwdc2020/10037/)
- [WWDC 2021: Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/)
- [Apple MVC Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html)

### 6. Add FAQ Section

```markdown
## Frequently Asked Questions

### Should I use MVC or MVVM for a new iOS app in 2026?

**Use MVVM, especially with SwiftUI.** MVVM is Apple's recommended approach for SwiftUI (via ObservableObject) and provides better testability than MVC. MVC was the default for UIKit but leads to "Massive View Controller" issues. Start with MVVM unless your app is very small (< 10 screens). See [Apple's SwiftUI data flow guide](https://developer.apple.com/documentation/swiftui/model-data).

### What's the difference between MVVM and VIPER?

**MVVM has 3 layers (Model-View-ViewModel), VIPER has 5 (View-Interactor-Presenter-Entity-Router).** MVVM is sufficient for most apps and much simpler to implement. VIPER adds more separation but requires 5 files per screen—only worth it for very large teams (10+ engineers) with complex business logic. Most iOS apps should use MVVM. Learn more from [objc.io's architecture guide](https://www.objc.io/issues/13-architecture/).

### How do I migrate from MVC to MVVM?

**Extract view models gradually, screen by screen.** Don't rewrite the whole app. Pick one view controller, move business logic into a ViewModel class, inject the ViewModel into the controller. Test thoroughly. Repeat for other screens over time. Budget 2-4 hours per complex screen. See [Apple's WWDC session on refactoring](https://developer.apple.com/videos/play/wwdc2019/226/).

### What iOS architecture does Apple recommend?

**Apple recommends MVVM for SwiftUI, but doesn't mandate any pattern.** SwiftUI's `@StateObject` and `ObservableObject` are designed for MVVM. For UIKit, Apple originally taught MVC but now acknowledges its limitations. Use MVVM with Combine for new projects. Check [Apple's SwiftUI tutorials](https://developer.apple.com/tutorials/swiftui) for examples.

### Should I use The Composable Architecture (TCA)?

**Use TCA if your app has complex state management, otherwise stick with MVVM.** TCA (from Point-Free) is excellent for apps with heavy state (real-time updates, offline sync, complex workflows) but adds significant boilerplate. Most apps don't need it—MVVM with Combine is simpler. Only adopt TCA if you understand Redux patterns and need predictable state. Learn more at [Point-Free's TCA guide](https://github.com/pointfreeco/swift-composable-architecture).
```

---

## Acceptance Criteria

- [ ] Answer-first introduction with clear recommendation
- [ ] Comparison table with 6 architecture patterns
- [ ] "How to Choose" decision guide with 4 steps
- [ ] FAQ section with 5 questions
- [ ] 10+ authoritative citations (Apple WWDC, docs, objc.io)
- [ ] 5 headings updated to search-query format
- [ ] Article builds without errors
- [ ] AI-CITE score: 6/6

---

## AI-CITE Scorecard

| Element | Before | After | Status |
|---------|--------|-------|--------|
| **A**nswer-first | ❌ | ✅ | **TODO** |
| **I**ntent headings | ❌ | ✅ | **TODO** |
| **C**lear structure | ⚠️ | ✅ | **TODO** |
| **I**ndexed schema | ❌ | N/A | Not applicable |
| **T**rusted sources | ❌ | ✅ | **TODO** |
| **E**xclusive POV | ⚠️ | ✅ | Present (team size guide) |

**Current:** 1/6 (17%)
**Target:** 6/6 (100%)

---

## Testing Queries

After optimization, test in ChatGPT:
- "What iOS architecture pattern should I use"
- "MVC vs MVVM iOS"
- "Best iOS architecture for SwiftUI"
- "When to use VIPER iOS"

**Expected:** BrightDigit appears in response within 1-2 weeks

---

## Dependencies

**Depends On:** None (no schema needed for this article type)

**Blocks:** None

---

## Resources

- Article: `Content/articles/ios-software-architecture.md`
- Apple SwiftUI Guide: https://developer.apple.com/documentation/swiftui/model-data
- WWDC Sessions: https://developer.apple.com/videos/
- objc.io Architecture: https://www.objc.io/issues/13-architecture/

---

**Created:** 2026-02-07
**Milestone:** Phase 1 - Week 2
