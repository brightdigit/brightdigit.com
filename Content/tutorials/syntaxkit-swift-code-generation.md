---
title: "Building SyntaxKit with AI: A Developer's Journey"
date: 2025-09-27 00:00
description: Follow the journey of building SyntaxKit using AI tools like Cursor and Claude. Learn practical lessons about AI-assisted development, from failed LLM approaches to successful iterative workflows, and discover how AI can help create better developer tools.
tags: swift, swift-syntax, macros, ai-assisted-development, dsl, code-generation, swift-package-manager
featuredImage: /media/tutorials/syntaxkit-swift-code-generation/syntaxkit-hero.webp
subscriptionCTA: Want to stay up-to-date with the latest Swift development tools and AI-assisted development techniques? Sign up for our newsletter to get notified about new tutorials and tools.
---

When [Swift Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/) were released in 2023, I thought it would be a great opportunity to augment existing Swift code effectively. However, working with SwiftSyntax quickly made me realize the challenge I was going to face. I had encountered SwiftSyntax before and knew exactly how difficult it was to use its various patterns for programmatic Swift code generation. In many ways, [those of us not on the Apple payroll aren't the target audience for creating Macros](https://youtu.be/MroBR2ProT0?si=ZaT77u2hj8fpgjIi). If only there were an easier way to create Swift code that was simpler than SwiftSyntax but more type-safe than creating mere strings.

This is the story of how I used AI tools like [Cursor](https://cursor.sh/) and [Claude Code](https://claude.ai/) to build **[SyntaxKit](https://github.com/brightdigit/SyntaxKit)** - a Swift package that transforms SwiftSyntax's verbose approach into something that feels like writing Swift code.

---

**In this series:**

* _Building SyntaxKit with AI_
* [Rebuilding MistKit with Claude Code (Part 1)](https://brightdigit.com/tutorials/rebuilding-mistkit-claude-code-part-1/)
* Coming soon: Rebuilding MistKit with Claude Code (Part 2)

---

📚 **[View Documentation](https://swiftpackageindex.com/brightdigit/SyntaxKit/main/documentation/syntaxkit)** | 🐙 **[GitHub Repository](https://github.com/brightdigit/SyntaxKit)**

- [The SwiftSyntax Challenge](#the-swiftsyntax-challenge)
- [My Fascination with DSLs](#my-fascination-with-dsls)
- [Discovering AI as a Development Tool](#discovering-ai-as-a-development-tool)
- [Building SyntaxKit with AI Tools](#building-syntaxkit-with-ai-tools)
  - [The Failed LLM Approach](#the-failed-llm-approach)
  - [Success with Cursor](#success-with-cursor)
  - [Transitioning to Claude Code](#transitioning-to-claude-code)
  
- [The Result: SyntaxKit](#the-result-syntaxkit)
- [Lessons Learned Building with AI](#lessons-learned-building-with-ai)
- [Future Plans](#future-plans)
- [Getting Started with SyntaxKit](#getting-started-with-syntaxkit)

<a id="the-swiftsyntax-challenge"></a>
## The SwiftSyntax Challenge

**SwiftSyntax** is Apple's official Swift library that provides a source-accurate tree representation of Swift source code. It enables developers to parse, inspect, generate, and transform Swift code programmatically, making it the foundation for creating Swift macros and other code generation tools.

**Key Concepts:**
- **Abstract Syntax Tree (AST)**: SwiftSyntax represents Swift code as a tree structure where each node corresponds to a language construct
- **Source Accuracy**: The representation maintains exact formatting and trivia (whitespace, comments) from the original source
- **Programmatic Generation**: You can build Swift code by constructing the AST nodes programmatically

**Documentation and Resources:**
- **[Official SwiftSyntax Documentation](https://swiftpackageindex.com/swiftlang/swift-syntax/601.0.1/documentation/swiftsyntax)** - Complete API reference
- **[SwiftSyntax Tutorial](https://swiftinit.org/docs/swift-syntax/swiftsyntax/)** - Getting started guide
- **[SwiftSyntax: Parse and Generate Swift Source Code](https://www.avanderlee.com/swift/swiftsyntax-parse-and-generate-swift-source-code/)** - Practical tutorial by Antoine van der Lee
- **[SwiftSyntax - NSHipster](https://nshipster.com/swiftsyntax/)** - In-depth explanation of how SwiftSyntax works

### Swift Macros: The Primary Use Case

Swift macros are the biggest use case for SwiftSyntax, using it as their foundation to generate code at compile time. When [Swift Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/) were released in 2023, they opened up new possibilities for augmenting existing Swift code effectively. However, working with SwiftSyntax quickly revealed the challenges developers would face.

> youtube https://www.youtube.com/watch?v=MroBR2ProT0

**Swift Macros Documentation:**
- **[Swift Macros Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)**
- **[Swift Macros WWDC Session](https://developer.apple.com/videos/play/wwdc2023/10166/)**

Working with SwiftSyntax is very procedural and verbose when you want to write Swift. Consider this simple example - creating a basic struct:

```swift
// SwiftSyntax - creating a simple struct
let structKeyword = TokenSyntax.keyword(.struct, trailingTrivia: .space)
let identifier = TokenSyntax.identifier("User", trailingTrivia: .space)
let leftBrace = TokenSyntax.leftBrace(leadingTrivia: .space, trailingTrivia: .newline)

let members = MemberDeclListSyntax([
    MemberDeclListSyntax.Element(
        decl: VariableDeclSyntax(
            bindingKeyword: .keyword(.let),
            bindings: PatternBindingListSyntax([
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("id")),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: SimpleTypeIdentifierSyntax(name: .identifier("UUID"))
                    )
                )
            ])
        )
    )
])

let structDecl = StructDeclSyntax(
    structKeyword: structKeyword,
    identifier: identifier,
    leftBrace: leftBrace,
    members: members,
    rightBrace: TokenSyntax.rightBrace(leadingTrivia: .newline)
)
```

That's just for creating a single property! The SwiftSyntax AST for even a simple `User` struct can be nearly 2,100 lines when prettified. It's precise, but it's not human-friendly.

To put this in perspective, here's what a simple `User` struct looks like in regular Swift:

```swift
struct User {
    let id: UUID
    let name: String
}
```

But to generate this same struct using SwiftSyntax requires the verbose 80+ lines of code shown above.

<a id="my-fascination-with-dsls"></a>
## My Fascination with DSLs

Before diving into the solution, I should mention my fascination with Domain Specific Languages (DSLs). Ever since I saw [Zach's presentation on DeckUI](https://github.com/joshdholtz/deckui), I've been captivated by the power of Swift's [result builders](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/resultbuilders/). [SwiftUI](https://developer.apple.com/xcode/swiftui/) itself is a perfect example - it makes UI creation feel natural and declarative. I've previously built [PackageDSL](https://github.com/brightdigit/PackageDSL) to simplify creating large Swift packages using a similar approach.

### Understanding Result Builders

**Result builders** (introduced with the `@resultBuilder` attribute) are a Swift feature that enables the creation of domain-specific languages (DSLs) by allowing functions to build up a result from a sequence of components. This is what makes SwiftUI's declarative syntax possible.

**How Result Builders Work:**
- They transform a block of code into a single result value
- Use `buildBlock`, `buildExpression`, and other builder methods to combine components
- Enable natural, declarative syntax for complex data structures

**Documentation and Tutorials:**
- **[Swift Result Builders - Official Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/resultbuilders/)** - Apple's official guide
- **[Result Builders in Swift](https://www.avanderlee.com/swift/result-builders/)** - Comprehensive tutorial by Antoine van der Lee
- **[SwiftUI and Result Builders](https://developer.apple.com/xcode/swiftui/)** - See result builders in action with SwiftUI

The elegance of these DSLs inspired me: what if we could bring that same declarative simplicity to Swift code generation?

> youtube https://www.youtube.com/watch?v=uFybZNvDE_I

<a id="discovering-ai-as-a-development-tool"></a>
## Discovering AI as a Development Tool

Like many developers, I was initially skeptical of AI tools. I'd been burnt by trending technologies before - VR, Bitcoin, NFTs, and countless failed startups built on questionable foundations. So when AI development tools started gaining traction, I approached them with healthy skepticism.

However, after experiencing [ChatGPT](https://chat.openai.com/)'s capabilities firsthand, and later working with tools like [Cursor](https://cursor.sh/) and [Claude Code](https://claude.ai/), I began to see their potential. These weren't just fancy autocomplete tools - they were capable coding partners that could understand context, generate complex implementations, and iterate on solutions.

The turning point came when I realized I had a perfect use case: building SyntaxKit. I had three clear pieces:

1. **The desired Swift code output** (what developers want to generate)
2. **The SwiftSyntax AST structure** (what SwiftSyntax needs)
3. **My ideal API design** (how it should feel to use SyntaxKit)

This was a perfect scenario for AI-assisted development.

<a id="building-syntaxkit-with-ai-tools"></a>
## Building SyntaxKit with AI Tools

<a id="the-failed-llm-approach"></a>
### The Failed LLM Approach

My first instinct was ambitious: create a custom LLM specifically trained to generate Swift Macro code. I was inspired by the [Swift AST Explorer](https://swift-ast-explorer.com) - a fantastic tool that visualizes Swift code as Abstract Syntax Trees. I spent considerable time researching fine-tuning approaches, mapping out training pipelines, and even discussing comprehensive training strategies with [Claude](https://claude.ai/) or using the Claude Workbench to build prompts.

The Swift AST Explorer became crucial for understanding the relationship between Swift code and its SwiftSyntax representation. I could input simple Swift constructs and immediately see the corresponding AST structure, which seemed perfect for generating training data. The workflow was elegant: write Swift code → feed it through the AST Explorer → get the exact SwiftSyntax tree structure → use that mapping to teach the LLM what SwiftSyntax code generates what Swift output.

This approach failed for several practical reasons:
- **Training data scarcity**: Swift Macros were brand new - there weren't enough examples to train on
- **Over-engineering**: The ML effort far exceeded the complexity of building a better API
- **Swift-specific challenges**: The model would need deep understanding of SwiftSyntax patterns and macro contexts

This failure taught me an important lesson: sometimes the "AI solution" isn't the right solution. While LLMs excel at generating code from natural language, creating better development tools often requires traditional software engineering approaches.

<a id="success-with-cursor"></a>
### Success with Cursor

My breakthrough came with [Cursor](https://cursor.sh/). Instead of training a custom model, I used Cursor's interactive LLM capabilities to iteratively build SyntaxKit components.

The process was surprisingly effective:

1. **Extract the AST**: I built a terminal console application that could generate clean JSON from SwiftSyntax ASTs, making them easily consumable by the LLM. This was inspired by the Swift AST Explorer's ability to show the relationship between Swift code and its AST representation. The tool would take Swift code as input and output a simplified JSON structure showing the exact SwiftSyntax nodes needed to recreate that code.
2. **Teach through examples**: I provided the three key pieces - desired output, SwiftSyntax structure, and my API design
3. **Iterate and refine**: Cursor helped me implement each SyntaxKit component, learning from previous patterns

![Teaching Cursor how to do SwiftSyntax](/media/tutorials/syntaxkit-swift-code-generation/cursor-example.webp)

The key was breaking the problem down into manageable pieces rather than trying to solve everything at once. You can see more examples of these [here.](https://github.com/brightdigit/SyntaxKit/tree/main/Examples)

<a id="transitioning-to-claude-code"></a>
### Transitioning to Claude Code

As SyntaxKit grew more complex, I transitioned from [Cursor](https://cursor.sh/) to [Claude Code](https://claude.ai/) for more sophisticated project management and planning capabilities. Here's why: **Cursor excels at editing specific pieces of code within an IDE** - perfect for implementing individual components and making targeted changes. **Claude Code is better for bigger changes that don't necessarily need IDE integration** - ideal for architectural decisions, project-wide refactoring, and maintaining consistency across multiple components. Claude Code's ability to understand project context and maintain consistency across multiple components proved invaluable for the larger architectural decisions.

### The Result: SyntaxKit

After weeks of AI-assisted development, the result was **SyntaxKit** - a Swift package that transforms SwiftSyntax's verbose approach into something that feels like writing Swift code:

```swift
// SyntaxKit - declarative and readable
let userModel = Struct("User") {
    Variable(.let, name: "id", type: "UUID")
    Variable(.let, name: "name", type: "String")
    Variable(.let, name: "email", type: "String")
}
.inherits("Equatable")
```

The difference is night and day - SyntaxKit reads like SwiftUI code for creating Swift code, while SwiftSyntax reads like UIKit code for building an interface. This addresses several key pain points in Swift macro and code generation development:

- **Readability**: Code generation logic is clear and maintainable
- **Type Safety**: Compile-time checking prevents many runtime errors
- **Swift-like**: Uses familiar patterns and result builders
- **Composable**: Easy to build complex structures from simple components
- **Testable**: Generated code can be validated and tested easily

> youtube https://www.youtube.com/watch?v=Dem0pG1WIfk

<a id="lessons-learned-building-with-ai"></a>
## Lessons Learned Building with AI

Working with AI tools to build SyntaxKit taught me several important lessons:

<a id="unit-tests-where-llms-shine"></a>
### Unit Tests: Where LLMs Shine

One area where AI tools particularly excel is generating comprehensive unit tests. I created tests not just for each SyntaxKit component, but for various scenarios - structs with generics, protocols with attributes, complex inheritance hierarchies.

These tests became crucial for validating that the generated SwiftSyntax code compiled correctly and produced the expected Swift output.

<a id="plan-and-break-down-projects"></a>
### Plan and Break Down Projects
One of the most crucial lessons is the importance of planning and breaking projects into smaller, manageable pieces. AI tools work best when given specific, focused tasks rather than trying to generate entire systems at once. Taking time to plan the overall architecture and then breaking it down into discrete components makes AI assistance much more effective.

This is why tools like [Cursor](https://cursor.sh/) and [Claude Code](https://claude.ai/) include built-in todo list functionality - they recognize that breaking work into smaller, trackable pieces is essential for effective AI-assisted development. There are even specialized tools like [Task Master](https://www.task-master.dev) that focus specifically on creating detailed task breakdowns from Product Requirements Documents (PRDs), making the planning process more systematic and comprehensive.

<a id="hold-your-ais-hand"></a>
### Hold Your AI's Hand
While AI can build entire applications, unless you're creating a quick prototype, you're best served by guiding the AI through each step of implementation. AI-generated code often lacks the architectural decisions and patterns that make code maintainable and extensible over time. The iterative approach works much better than trying to generate everything at once - think of AI as a coding partner that needs clear direction and regular feedback to produce code you'll actually want to build upon.

<a id="be-wary-of-over-engineering"></a>
### Be Wary of Over-Engineering
LLMs can build APIs you don't need or overcomplicate simple problems. It's crucial to review generated code carefully and remove anything out of scope. Sometimes the AI wants to be "helpful" by adding features you never requested.

<a id="context-and-consistency-matter"></a>
### Context and Consistency Matter
Understanding context windows, pricing, and when to switch between models becomes important for larger projects. Maintaining consistency across components requires careful prompting and sometimes manual oversight.

<a id="human-code-reviews-are-essential"></a>
### Human Code Reviews Are Essential
AI-generated code still needs human review. While the tools are incredibly capable, they can introduce subtle bugs or architectural issues that only human experience can catch.

<a id="a-healthy-continuous-integration-system-is-critical"></a>
### A Healthy Continuous Integration System Is Critical
When building with AI, having a robust continuous integration system becomes even more important. AI-generated code can introduce subtle issues that only surface during compilation or testing across different platforms. A healthy CI system acts as a safety net, catching problems early and ensuring that AI-assisted code changes don't break existing functionality. This is especially crucial when iterating quickly with AI tools, as the rapid pace of development can easily introduce regressions.

For Swift development specifically, I've created [swift-build](https://github.com/brightdigit/swift-build) - a comprehensive GitHub Action that simplifies CI setup for Swift packages across multiple platforms, which I've detailed in my latest article on [building Swift CI/CD with swift-build](https://brightdigit.com/tutorials/swift-build/).

You can also integrate AI-powered code review tools like [Claude Code](https://claude.ai/) or [CodeRabbit](https://coderabbit.ai/) into your CI pipeline for automated PR reviews. These tools can catch common issues, suggest improvements, and provide feedback on code quality. However, it's always important to have a human check your code - AI review tools are excellent supplements but should never replace human judgment and domain expertise. Understanding the fundamentals of [continuous integration](https://brightdigit.com/articles/ios-continuous-integration-avoid-merge-hell/) helps establish the right practices from the start.

<a id="future-plans"></a>
## Future Plans

SyntaxKit is just the beginning. I'm already exploring similar DSL approaches for other Swift development challenges:

- **[PackageDSL](https://github.com/brightdigit/PackageDSL) improvements**: Building on the success of SyntaxKit's patterns
- **[MistKit](https://github.com/brightdigit/MistKit) revival**: Using AI tools to enhance [CloudKit](https://developer.apple.com/documentation/cloudkit) development workflows
- **Advanced capabilities**: Expanding SyntaxKit to handle more complex Swift constructs

The combination of thoughtful API design and AI-assisted implementation opens up exciting possibilities for developer tooling. Tools like [Sosumi.ai](https://sosumi.ai) for Apple API exploration and [llm.codes](https://llm.codes) for converting documentation to LLM-friendly formats will be invaluable for building more sophisticated Swift packages and developer tools that integrate deeply with Apple's ecosystem.

> youtube https://www.youtube.com/watch?v=BnsPUjcDSik

<a id="getting-started-with-syntaxkit"></a>
## Getting Started with SyntaxKit

SyntaxKit is available as a [Swift package](https://swift.org/package-manager/) and can be integrated into your macro projects today. The [documentation](https://swiftpackageindex.com/brightdigit/SyntaxKit/main/documentation/syntaxkit) includes examples for common use cases, from simple data structures to complex generic types with protocol conformances.

Whether you're building your first Swift macro or looking to simplify existing SwiftSyntax code, SyntaxKit provides a more approachable path to programmatic Swift code generation.

---

The journey from SwiftSyntax frustration to SyntaxKit success illustrates how AI tools, when used thoughtfully, can accelerate development without replacing good engineering practices. The key is understanding when to lean on AI assistance and when to rely on traditional software design principles.

*SyntaxKit represents not just a better API for Swift code generation, but a new model for AI-assisted tool development that prioritizes developer experience while maintaining the precision and reliability that Swift developers expect.*
