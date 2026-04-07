# FAQ and HowTo Schema Implementation Plan

**Date:** 2026-02-06
**Status:** Design Phase Complete, Ready for Implementation

---

## Overview

To complete AI-CITE optimization, we need to add JSON-LD schema markup to articles and tutorials. This document outlines the implementation strategy for PiHTMLFactory.

---

## Current State Analysis

### Existing Head Generation

**File:** `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift:115-178`

```swift
public extension Node where Context == HTML.DocumentContext {
  static func head(forPage page: PageContent) -> Node {
    .head(
      .title(page.headTitle),
      .meta(name: "description", content: page.description),
      // ... OpenGraph, Twitter Cards, etc.
      .script(.src("/js/main.js")),
      // ... Google Analytics
    )
  }
}
```

**Current Capabilities:**
- ✅ Title tag
- ✅ Meta descriptions
- ✅ OpenGraph (Facebook) meta tags
- ✅ Twitter Card meta tags
- ✅ Canonical URLs
- ✅ RSS feeds
- ❌ NO structured data (JSON-LD schema)

---

## Required Schema Types

### 1. FAQPage Schema (High Priority)

**Articles with FAQ sections:**
- `dependency-management-swift.md` ← **Already has FAQ section!**
- `best-backend-for-your-ios-app.md` (after optimization)
- `ios-software-architecture.md` (after optimization)

**Example Output:**
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Should I mock Apple frameworks like CoreLocation or UserDefaults?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, always mock external dependencies for unit testing. Even Apple's frameworks are outside your control..."
      }
    },
    {
      "@type": "Question",
      "name": "When should I use protocols vs closures for mocking?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use closures for single functions, protocols for multiple related functions..."
      }
    }
  ]
}
```

### 2. HowTo Schema (Medium Priority)

**Tutorials that are step-by-step:**
- `mise-setup-guide.md`
- `vapor-heroku-ubuntu-setup-deploy.md`
- Tutorial section content

**Example Output:**
```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to Set Up Mise for BrightDigit Projects",
  "description": "Complete guide to setting up Mise tool version management...",
  "step": [
    {
      "@type": "HowToStep",
      "name": "Install Mise",
      "text": "Install Mise using Homebrew",
      "itemListElement": [
        {
          "@type": "HowToDirection",
          "text": "brew install mise"
        }
      ]
    },
    {
      "@type": "HowToStep",
      "name": "Create .mise.toml",
      "text": "Create .mise.toml at repository root..."
    }
  ]
}
```

### 3. Article Schema (Lower Priority, but good baseline)

**All articles should have:**
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Control Your Swift Dependencies Before They Control You",
  "image": "https://brightdigit.com/media/articles/dependency-management-swift/...",
  "author": {
    "@type": "Person",
    "name": "Leo Dion",
    "url": "https://brightdigit.com/about-us"
  },
  "publisher": {
    "@type": "Organization",
    "name": "BrightDigit",
    "logo": {
      "@type": "ImageObject",
      "url": "https://brightdigit.com/media/brightdigit-name.svg"
    }
  },
  "datePublished": "2024-02-27T02:37:00Z",
  "dateModified": "2024-02-27T02:37:00Z"
}
```

---

## Implementation Strategy

### Phase 1: Data Model (Create Schema Types)

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

**New File:** `Sources/BrightDigitSite/Schema/HowToSchema.swift`

```swift
import Foundation

public struct HowToSchema: Codable {
  public let context = "https://schema.org"
  public let type = "HowTo"
  public let name: String
  public let description: String
  public let step: [HowToStep]

  enum CodingKeys: String, CodingKey {
    case context = "@context"
    case type = "@type"
    case name, description, step
  }
}

public struct HowToStep: Codable {
  public let type = "HowToStep"
  public let name: String
  public let text: String

  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case name, text
  }
}
```

**New File:** `Sources/BrightDigitSite/Schema/ArticleSchema.swift`

```swift
import Foundation

public struct ArticleSchema: Codable {
  public let context = "https://schema.org"
  public let type = "Article"
  public let headline: String
  public let image: String
  public let author: Person
  public let publisher: Organization
  public let datePublished: String  // ISO 8601
  public let dateModified: String   // ISO 8601

  enum CodingKeys: String, CodingKey {
    case context = "@context"
    case type = "@type"
    case headline, image, author, publisher, datePublished, dateModified
  }
}

public struct Person: Codable {
  public let type = "Person"
  public let name: String
  public let url: String

  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case name, url
  }
}

public struct Organization: Codable {
  public let type = "Organization"
  public let name: String
  public let logo: ImageObject

  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case name, logo
  }
}

public struct ImageObject: Codable {
  public let type = "ImageObject"
  public let url: String

  enum CodingKeys: String, CodingKey {
    case type = "@type"
    case url
  }
}
```

### Phase 2: Markdown Parsing (Extract FAQ from Content)

**New File:** `Sources/BrightDigitSite/Markdown/FAQParser.swift`

```swift
import Foundation

public struct FAQParser {
  // Parse FAQ section from markdown
  // Detect patterns:
  // ### Q: ... or **Q:** ... or ### Should I ...?
  // A: ... or following paragraph is the answer

  public static func parseFAQ(from markdown: String) -> FAQSchema? {
    // Implementation strategy:
    // 1. Look for "## FAQ" or "## Frequently Asked Questions" heading
    // 2. Extract everything until next ## heading
    // 3. Parse Q&A pairs using regex or simple state machine
    // 4. Return FAQSchema with parsed questions

    // Regex patterns to detect:
    // - ### Q: (.+)
    // - **Q:** (.+)
    // - ### (.+\?) (question ends with ?)
    // Answer is next paragraph after question

    guard markdown.contains("## Frequently Asked Questions") ||
          markdown.contains("## FAQ") else {
      return nil
    }

    // TODO: Full implementation
    return nil
  }
}
```

### Phase 3: HTML Generation (Add Schema to Head)

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

// Then modify .head() to include schema:
public extension Node where Context == HTML.DocumentContext {
  static func head(forPage page: PageContent) -> Node {
    .head(
      .title(page.headTitle),
      .meta(name: "description", content: page.description),
      // ... existing meta tags ...

      // NEW: Add schema support
      .unwrap(page.faqSchema) { schema in
        .jsonLDSchema(schema)
      },
      .unwrap(page.howToSchema) { schema in
        .jsonLDSchema(schema)
      },
      .unwrap(page.articleSchema) { schema in
        .jsonLDSchema(schema)
      },

      // ... rest of head ...
    )
  }
}
```

### Phase 4: PageContent Extension (Add Schema Properties)

**Modify:** `Sources/PublishType/PageContent.swift` or create extension

```swift
public extension PageContent {
  // These would be computed properties that parse markdown
  var faqSchema: FAQSchema? {
    // Parse FAQ from markdown content if present
    FAQParser.parseFAQ(from: self.body.html)
  }

  var articleSchema: ArticleSchema? {
    // Generate article schema from metadata
    ArticleSchema(
      headline: title,
      image: socialImageURL.absoluteString,
      author: Person(name: "Leo Dion", url: "https://brightdigit.com/about-us"),
      publisher: Organization(
        name: "BrightDigit",
        logo: ImageObject(url: "https://brightdigit.com/media/brightdigit-name.svg")
      ),
      datePublished: date.iso8601String,
      dateModified: date.iso8601String  // TODO: Track actual modification date
    )
  }

  var howToSchema: HowToSchema? {
    // Parse HowTo steps from tutorial markdown
    nil  // TODO: Implement
  }
}
```

---

## Alternative: Manual Metadata Approach (Recommended)

Instead of parsing markdown (complex and error-prone), add schema metadata to article frontmatter:

**Example article frontmatter:**
```markdown
---
title: Control Your Swift Dependencies
date: 2024-02-27 02:37
description: ...
faq:
  - question: "Should I mock Apple frameworks?"
    answer: "Yes, always mock external dependencies..."
  - question: "When should I use protocols vs closures?"
    answer: "Use closures for single functions..."
---
```

**Then in Publish:**
```swift
// Item metadata extension
extension Item {
  var faqMetadata: [(question: String, answer: String)]? {
    // Read from metadata["faq"]
  }
}
```

**Pros:**
- ✅ More reliable than parsing
- ✅ Author controls exactly what goes in schema
- ✅ Easy to maintain
- ✅ Clear separation of concerns

**Cons:**
- ❌ Requires updating article frontmatter
- ❌ Duplication (FAQ in content AND in metadata)

---

## Recommended Implementation Path

### Week 1: Quick Win (Manual Approach)

1. **Add FAQ metadata to `dependency-management-swift.md`**
   ```yaml
   faq:
     - q: "Should I mock Apple frameworks?"
       a: "Yes, always mock external dependencies..."
   ```

2. **Create schema types** (FAQSchema.swift, ArticleSchema.swift)

3. **Add JSON-LD generation to head** (.jsonLDSchema() helper)

4. **Parse FAQ metadata** and generate schema

5. **Validate** with Google Rich Results Test

### Week 2-3: Full Automation

1. **Build FAQParser** to extract from markdown (optional enhancement)

2. **Add HowTo schema** for tutorials

3. **Implement Article schema** baseline for all articles

4. **Add Breadcrumb schema** for navigation

---

## Testing & Validation

### Tools:
- **Google Rich Results Test**: https://search.google.com/test/rich-results
- **Schema.org Validator**: https://validator.schema.org/
- **JSON-LD Playground**: https://json-ld.org/playground/

### Test Cases:
1. ✅ FAQ schema validates
2. ✅ HowTo schema validates
3. ✅ Article schema validates
4. ✅ All @type fields present
5. ✅ All required properties present
6. ✅ Valid JSON syntax
7. ✅ Escaping works (quotes, newlines in text)

---

## Example: Complete Head Output (After Implementation)

```html
<head>
  <title>Control Your Swift Dependencies | BrightDigit</title>
  <meta name="description" content="Mock Swift dependencies...">
  <!-- OpenGraph, Twitter, etc. -->

  <!-- NEW: FAQ Schema -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": [
      {
        "@type": "Question",
        "name": "Should I mock Apple frameworks?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Yes, always mock external dependencies..."
        }
      }
    ]
  }
  </script>

  <!-- NEW: Article Schema -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "Control Your Swift Dependencies",
    "author": {"@type": "Person", "name": "Leo Dion"},
    "publisher": {"@type": "Organization", "name": "BrightDigit"},
    "datePublished": "2024-02-27T02:37:00Z"
  }
  </script>

  <!-- Existing scripts -->
  <script src="/js/main.js"></script>
</head>
```

---

## Files to Create/Modify

### New Files:
- [ ] `Sources/BrightDigitSite/Schema/FAQSchema.swift`
- [ ] `Sources/BrightDigitSite/Schema/HowToSchema.swift`
- [ ] `Sources/BrightDigitSite/Schema/ArticleSchema.swift`
- [ ] `Sources/BrightDigitSite/Markdown/FAQParser.swift` (optional)

### Modified Files:
- [ ] `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift`
  - Add `.jsonLDSchema()` helper
  - Modify `.head()` to include schema
- [ ] `Sources/PublishType/PageContent.swift` (or create extension)
  - Add `faqSchema`, `articleSchema`, `howToSchema` properties
- [ ] `Content/articles/dependency-management-swift.md`
  - Add FAQ metadata to frontmatter (if using manual approach)

---

## Success Criteria

- [ ] FAQ schema validates in Google Rich Results Test
- [ ] Article schema validates
- [ ] Schema appears in page source (`view-source:` in browser)
- [ ] No JavaScript errors
- [ ] Site builds successfully
- [ ] ChatGPT testing shows improvement (re-test queries)

---

## Next Action

**DECISION NEEDED:** Choose implementation approach:

**Option A: Manual Metadata (Recommended for Week 1)**
- Add FAQ to article frontmatter
- Simpler, more reliable
- Can ship in 1-2 days

**Option B: Auto-Parsing (Future Enhancement)**
- Parse FAQ from markdown content
- More complex, risk of parsing errors
- Better long-term (less maintenance)

**Recommendation:** Start with Option A (manual metadata) to get quick wins, then enhance with Option B (auto-parsing) in Week 2-3.

---

**Status:** Design complete, ready for implementation
**Estimated Effort:** 4-6 hours for Option A, 8-12 hours for Option B
**Priority:** High (blocks AI-CITE "I" - Indexed Schema)

---

**End of Plan** | Generated: 2026-02-06
