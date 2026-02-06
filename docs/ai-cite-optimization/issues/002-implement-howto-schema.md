# Implement HowTo Schema Markup in PiHTMLFactory

**Status:** Not Started
**Priority:** High (P1)
**Effort:** 3-4 hours
**Labels:** `schema`, `technical`, `ai-cite`, `tutorials`

---

## Description

Implement JSON-LD HowTo schema generation for tutorial articles with step-by-step instructions. HowTo schema helps AI systems understand procedural content and increases visibility in search results.

**Context:** Tutorial articles like `mise-setup-guide.md` have clear step-by-step structure that should be marked up with HowTo schema for AI parsing.

---

## Current State

- ✅ Technical design complete (`schema-implementation-plan.md`)
- ✅ Target tutorials identified (mise-setup-guide, vapor setup, etc.)
- ❌ No HowTo schema implementation
- ⚠️ Depends on FAQ schema implementation (Task #001)

---

## Implementation Tasks

### 1. Create HowTo Schema Data Models

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

### 2. Extend PageContent with HowTo Property

```swift
public extension PageContent {
  var howToSchema: HowToSchema? {
    // Read from metadata
    guard let howToMeta = metadata["howto"] as? [String: Any],
          let steps = howToMeta["steps"] as? [[String: String]] else {
      return nil
    }

    let howToSteps = steps.compactMap { step -> HowToStep? in
      guard let name = step["name"], let text = step["text"] else {
        return nil
      }
      return HowToStep(name: name, text: text)
    }

    return howToSteps.isEmpty ? nil : HowToSchema(
      name: title,
      description: description,
      step: howToSteps
    )
  }
}
```

### 3. Update Head Generation

**Modify:** `Sources/BrightDigitSite/Nodes/PiHTMLFactory.HTML.swift`

```swift
.unwrap(page.howToSchema) { schema in
  .jsonLDSchema(schema)
},
```

### 4. Add HowTo Metadata to Tutorial

**Modify:** `Content/tutorials/mise-setup-guide.md`

```yaml
---
title: Mise Setup Guide for BrightDigit Projects
date: 2026-02-06 12:00
description: ...
howto:
  steps:
    - name: "Install Mise"
      text: "Install Mise using Homebrew with the command: brew install mise"
    - name: "Configure Shell"
      text: "Add mise activation to your shell: echo 'eval \"$(mise activate zsh)\"' >> ~/.zshrc"
    - name: "Create .mise.toml"
      text: "Create .mise.toml configuration file at repository root with tool versions"
    - name: "Install Tools"
      text: "Run mise install to install all tools from configuration"
    - name: "Generate Xcode Project"
      text: "Use make xcodeproject to generate project with correct tool versions"
---
```

---

## Acceptance Criteria

- [ ] HowToSchema.swift created with all types
- [ ] PageContent extension reads HowTo from metadata
- [ ] `.head()` includes HowTo schema when present
- [ ] `mise-setup-guide.md` has HowTo metadata
- [ ] Site builds successfully
- [ ] Generated HTML includes HowTo schema
- [ ] Schema validates in Google Rich Results Test
- [ ] Shows "HowTo" in validation results

---

## Target Tutorials

1. **mise-setup-guide.md** (5 steps) - Priority #1
2. vapor-heroku-ubuntu-setup-deploy.md
3. swift-build.md
4. full-stack-sign-in-with-apple.md
5. healthkit-getting-started.md

---

## Testing

### Validation
```bash
# Generate site
swift run brightdigitwg publish

# Check schema in output
grep -A 30 "HowTo" Output/tutorials/mise-setup-guide/index.html

# Validate
open https://search.google.com/test/rich-results
```

### Expected Output
```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "Mise Setup Guide for BrightDigit Projects",
  "description": "Complete guide to setting up Mise...",
  "step": [
    {
      "@type": "HowToStep",
      "name": "Install Mise",
      "text": "Install Mise using Homebrew..."
    }
  ]
}
```

---

## Dependencies

**Depends On:**
- Task #001 (FAQ schema) - Uses same `.jsonLDSchema()` helper

**Blocks:**
- Task #10 (Mise Setup Guide) - Needs HowTo schema
- Tutorial optimization tasks

---

## Resources

- Schema.org HowTo: https://schema.org/HowTo
- Technical plan: `docs/ai-cite-optimization/schema-implementation-plan.md`

---

**Created:** 2026-02-06
**Milestone:** Phase 1 - Week 1
