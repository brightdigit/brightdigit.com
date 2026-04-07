# Implement FAQ Schema Markup in PiHTMLFactory

**Status:** In Progress
**Priority:** Critical (P0)
**Effort:** 4-6 hours
**Labels:** `schema`, `technical`, `blocker`, `ai-cite`

---

## Description

Implement JSON-LD FAQ schema generation in PiHTMLFactory to enable structured FAQ data for AI systems (ChatGPT, Google AI Overview). This is the **critical blocker** for Phase 1 completion.

**Context:** Jesse Schoberg's AI-CITE framework emphasizes "Indexed Schema" as essential for AI mentions. Articles with FAQ sections need FAQPage schema markup to be parsed effectively by LLMs.

---

## Current State

- ✅ Technical design complete (`schema-implementation-plan.md`)
- ✅ Target article has FAQ section (`dependency-management-swift.md`)
- ❌ No schema implementation in PiHTMLFactory
- ❌ No JSON-LD generation code

**Files:**
- `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift` - Head generation
- `Sources/BrightDigitSite/PiHTMLFactory.swift` - Main factory

---

## Implementation Tasks

### 1. Create Schema Data Models

**New File:** `Sources/BrightDigitSite/Schema/FAQSchema.swift`

```swift
import Foundation

public struct FAQSchema: Codable {
  public let context = "https://schema.org"
  public let type = "FAQPage"
  public let mainEntity: [FAQQuestion]

  enum CodingKeys: String, CodingKey {
    case context = "@context"
    case type = "@type"
    case mainEntity
  }
}

public struct FAQQuestion: Codable {
  public let type = "Question"
  public let name: String  // The question text
  public let acceptedAnswer: FAQAnswer

  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case name
    case acceptedAnswer
  }
}

public struct FAQAnswer: Codable {
  public let type = "Answer"
  public let text: String  // The answer text

  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case text
  }
}
```

### 2. Add JSON-LD Helper to Head

**Modify:** `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift`

```swift
public extension Node where Context == HTML.HeadContext {
  /// Generate JSON-LD schema script tag
  static func jsonLDSchema<T: Encodable>(_ schema: T) -> Node {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    guard let jsonData = try? encoder.encode(schema),
          let jsonString = String(data: jsonData, encoding: .utf8) else {
      return .empty
    }

    return .script(
      .type("application/ld+json"),
      .raw(jsonString)
    )
  }
}
```

### 3. Extend PageContent with Schema Property

**New File or Extension:** `Sources/PublishType/PageContent+Schema.swift`

```swift
public extension PageContent {
  var faqSchema: FAQSchema? {
    // Option A: Parse from markdown (complex)
    // Option B: Read from metadata (recommended)
    guard let faqMetadata = metadata["faq"] as? [[String: String]] else {
      return nil
    }

    let questions = faqMetadata.compactMap { item -> FAQQuestion? in
      guard let question = item["q"], let answer = item["a"] else {
        return nil
      }
      return FAQQuestion(
        name: question,
        acceptedAnswer: FAQAnswer(text: answer)
      )
    }

    return questions.isEmpty ? nil : FAQSchema(mainEntity: questions)
  }
}
```

### 4. Update Head Generation

**Modify:** `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift:115-178`

```swift
public extension Node where Context == HTML.DocumentContext {
  static func head(forPage page: PageContent) -> Node {
    .head(
      .title(page.headTitle),
      .meta(name: "description", content: page.description),
      // ... existing meta tags ...

      // NEW: Add FAQ schema if present
      .unwrap(page.faqSchema) { schema in
        .jsonLDSchema(schema)
      },

      // ... rest of head ...
    )
  }
}
```

### 5. Add FAQ Metadata to Article

**Modify:** `Content/articles/dependency-management-swift.md` frontmatter

```yaml
---
title: Control Your Swift Dependencies Before They Control You
date: 2024-02-27 02:37
description: ...
faq:
  - q: "Should I mock Apple frameworks like CoreLocation or UserDefaults?"
    a: "Yes, always mock external dependencies for unit testing. Even Apple's frameworks are outside your control..."
  - q: "When should I use protocols vs closures for mocking?"
    a: "Use closures for single functions, protocols for multiple related functions..."
  - q: "What's the best dependency injection framework for Swift?"
    a: "It depends on your project size: Small projects use manual injection, medium projects use Factory or Swinject, large teams use Needle..."
  - q: "How do I mock dependencies in SwiftUI Previews?"
    a: "Use the same strategies (protocols/closures) and inject mock implementations..."
  - q: "What's the difference between mocking and stubbing?"
    a: "Mocking provides controlled test data; stubbing provides minimal implementations..."
---
```

---

## Acceptance Criteria

- [ ] FAQSchema.swift created with all types
- [ ] `.jsonLDSchema()` helper added to HTML.HeadContext
- [ ] PageContent extension reads FAQ from metadata
- [ ] `.head()` method includes FAQ schema when present
- [ ] `dependency-management-swift.md` has FAQ metadata in frontmatter
- [ ] Site builds successfully (`swift build`)
- [ ] Generated HTML includes `<script type="application/ld+json">` with valid FAQPage schema
- [ ] Schema validates in Google Rich Results Test (https://search.google.com/test/rich-results)
- [ ] No JavaScript errors in browser console

---

## Testing

### 1. Build Test
```bash
swift build
```

### 2. Generate Site
```bash
swift run brightdigitwg publish
```

### 3. Inspect Output
```bash
# Find the generated HTML
open Output/articles/dependency-management-swift/index.html

# Verify schema in source
grep -A 20 "application/ld+json" Output/articles/dependency-management-swift/index.html
```

### 4. Validate Schema
1. Visit https://search.google.com/test/rich-results
2. Enter URL or paste HTML
3. Verify "FAQPage" detected
4. Check for errors/warnings

### 5. Test in ChatGPT
```
Query: "Should I mock Apple frameworks like CoreLocation in Swift?"
Expected: BrightDigit article appears in response (within 1-2 weeks)
```

---

## Dependencies

**Blocks:**
- Task #10 (Mise Setup Guide optimization)
- Task #11-14 (All article optimizations)
- Task #15 (Baseline testing)

**Blocked By:** None

---

## Resources

- Technical design: `docs/ai-cite-optimization/schema-implementation-plan.md`
- Schema.org FAQPage: https://schema.org/FAQPage
- Google Rich Results Test: https://search.google.com/test/rich-results
- Publish framework docs: https://github.com/JohnSundell/Publish

---

## Notes

**Decision:** Using manual metadata approach (Option B) for initial implementation because:
- ✅ More reliable than markdown parsing
- ✅ Clear control over schema content
- ✅ Easier to maintain
- ✅ Can ship in 1-2 days

Auto-parsing from markdown can be added as future enhancement.

**Success Metric:** Article validates in Rich Results Test and builds without errors.

---

**Created:** 2026-02-06
**Updated:** 2026-02-06
**Assignee:** TBD
**Milestone:** Phase 1 - Week 1
