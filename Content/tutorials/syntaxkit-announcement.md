---
title: "Announcing SyntaxKit: From SwiftSyntax Frustration to AI-Assisted Development"
date: 2025-09-29 00:00
description: Learn how SyntaxKit simplifies Swift code generation with a declarative, type-safe approach. Discover the journey from SwiftSyntax frustration to AI-assisted development, including lessons learned about working with AI tools and building better developer experiences.
tags: swift, swift-syntax, macros, ai-assisted-development, dsl, code-generation, swift-package-manager
featuredImage: /media/tutorials/syntaxkit/syntaxkit-hero.webp
subscriptionCTA: Want to stay up-to-date with the latest Swift development tools and AI-assisted development techniques? Sign up for our newsletter to get notified about new tutorials and tools.
---

# Announcing SyntaxKit: From SwiftSyntax Frustration to AI-Assisted Development

When Swift Macros were released in 2023, I thought it would be a great opportunity to augment existing Swift code effectively. However, working with SwiftSyntax quickly made me realize the challenge I was going to face. I had encountered SwiftSyntax before and knew exactly how difficult it was to use its various patterns for programmatic Swift code generation. In many ways, [those of us not on the Apple payroll aren't the target audience for creating Macros](https://youtu.be/MroBR2ProT0?si=ZaT77u2hj8fpgjIi). If only there were an easier way to create Swift code that was simpler than SwiftSyntax but more type-safe than creating mere strings.

That's where **SyntaxKit** comes in - a Swift package I built to provide a declarative, type-safe approach to programmatic Swift code generation. Instead of wrestling with SwiftSyntax's verbose AST manipulation or risking string concatenation errors, SyntaxKit uses result builders to make code generation feel natural and Swift-like.

## The SwiftSyntax Challenge

Working with SwiftSyntax feels like writing assembly code when you want to write Swift. Consider this simple example - creating a basic struct:

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

## My Fascination with DSLs

Before diving into the solution, I should mention my fascination with Domain Specific Languages (DSLs). Ever since I saw Zach's presentation on DeckUI, I've been captivated by the power of Swift's result builders. SwiftUI itself is a perfect example - it makes UI creation feel natural and declarative. I've previously built PackageDSL to simplify creating large Swift packages using a similar approach.

The elegance of these DSLs inspired me: what if we could bring that same declarative simplicity to Swift code generation?

## Discovering AI as a Development Tool

Like many developers, I was initially skeptical of AI tools. I'd been burnt by trending technologies before - VR, Bitcoin, NFTs, and countless failed startups built on questionable foundations. So when AI development tools started gaining traction, I approached them with healthy skepticism.

However, after experiencing ChatGPT's capabilities firsthand, and later working with tools like Cursor and Claude Code, I began to see their potential. These weren't just fancy autocomplete tools - they were capable coding partners that could understand context, generate complex implementations, and iterate on solutions.

The turning point came when I realized I had a perfect use case: building SyntaxKit. I had three clear pieces:

1. **The desired Swift code output** (what developers want to generate)
2. **The SwiftSyntax AST structure** (what SwiftSyntax needs)
3. **My ideal API design** (how it should feel to use SyntaxKit)

This was a perfect scenario for AI-assisted development.

## Building SyntaxKit with AI Tools

### The Failed LLM Approach

My first instinct was ambitious: create a custom LLM specifically trained to generate Swift Macro code. I was inspired by the [Swift AST Explorer](https://swift-ast-explorer.com) - a fantastic tool that visualizes Swift code as Abstract Syntax Trees. I spent considerable time researching fine-tuning approaches, mapping out training pipelines, and even discussing comprehensive training strategies with Claude.

The Swift AST Explorer became crucial for understanding the relationship between Swift code and its SwiftSyntax representation. I could input simple Swift constructs and immediately see the corresponding AST structure, which seemed perfect for generating training data.

This approach failed for several practical reasons:
- **Training data scarcity**: Swift Macros were brand new - there weren't enough examples to train on
- **Over-engineering**: The ML effort far exceeded the complexity of building a better API
- **Swift-specific challenges**: The model would need deep understanding of SwiftSyntax patterns and macro contexts

This failure taught me an important lesson: sometimes the "AI solution" isn't the right solution. While LLMs excel at generating code from natural language, creating better development tools often requires traditional software engineering approaches.

### Success with Cursor

My breakthrough came with Cursor. Instead of training a custom model, I used Cursor's interactive LLM capabilities to iteratively build SyntaxKit components.

The process was surprisingly effective:

1. **Extract the AST**: I built a terminal console application that could generate clean JSON from SwiftSyntax ASTs, making them easily consumable by the LLM. This was inspired by the Swift AST Explorer's ability to show the relationship between Swift code and its AST representation
2. **Teach through examples**: I provided the three key pieces - desired output, SwiftSyntax structure, and my API design
3. **Iterate and refine**: Cursor helped me implement each SyntaxKit component, learning from previous patterns

The key was breaking the problem down into manageable pieces rather than trying to solve everything at once.

### Unit Tests: Where LLMs Shine

One area where AI tools particularly excel is generating comprehensive unit tests. I created tests not just for each SyntaxKit component, but for various scenarios - structs with generics, protocols with attributes, complex inheritance hierarchies.

These tests became crucial for validating that the generated SwiftSyntax code compiled correctly and produced the expected Swift output.

### Transitioning to Claude Code

As SyntaxKit grew more complex, I transitioned from Cursor to Claude Code for more sophisticated project management and planning capabilities. Claude Code's ability to understand project context and maintain consistency across multiple components proved invaluable for the larger architectural decisions.

## What is SyntaxKit?

SyntaxKit transforms SwiftSyntax's verbose approach into something that feels like writing Swift code:

```swift
// SyntaxKit - declarative and readable
let userModel = Struct("User") {
    Variable(.let, name: "id", type: "UUID")
    Variable(.let, name: "name", type: "String")
    Variable(.let, name: "email", type: "String")
}
.inherits("Equatable")
```

The difference is night and day - SyntaxKit reads like Swift code, while SwiftSyntax reads like assembly.

## Why Use SyntaxKit?

SyntaxKit addresses several key pain points in Swift macro and code generation development:

- **Readability**: Code generation logic is clear and maintainable
- **Type Safety**: Compile-time checking prevents many runtime errors
- **Swift-like**: Uses familiar patterns and result builders
- **Composable**: Easy to build complex structures from simple components
- **Testable**: Generated code can be validated and tested easily

## Lessons Learned Building with AI

Working with AI tools to build SyntaxKit taught me several important lessons:

### Plan and Break Down Projects
One of the most crucial lessons is the importance of planning and breaking projects into smaller, manageable pieces. AI tools work best when given specific, focused tasks rather than trying to generate entire systems at once. Taking time to plan the overall architecture and then breaking it down into discrete components makes AI assistance much more effective.

This is why tools like Cursor and Claude Code include built-in todo list functionality - they recognize that breaking work into smaller, trackable pieces is essential for effective AI-assisted development. There are even specialized tools like [Task Master](https://www.task-master.dev) that focus specifically on creating detailed task breakdowns from Product Requirements Documents (PRDs), making the planning process more systematic and comprehensive.

### Hold Your AI's Hand
While AI can build entire applications, unless you're creating a quick prototype, you're best served by guiding the AI through each step of implementation. AI-generated code often lacks the architectural decisions and patterns that make code maintainable and extensible over time. The iterative approach works much better than trying to generate everything at once - think of AI as a coding partner that needs clear direction and regular feedback to produce code you'll actually want to build upon.

### Be Wary of Over-Engineering
LLMs can build APIs you don't need or overcomplicate simple problems. It's crucial to review generated code carefully and remove anything out of scope. Sometimes the AI wants to be "helpful" by adding features you never requested.

### Context and Consistency Matter
Understanding context windows, pricing, and when to switch between models becomes important for larger projects. Maintaining consistency across components requires careful prompting and sometimes manual oversight.

### Human Code Reviews Are Essential
AI-generated code still needs human review. While the tools are incredibly capable, they can introduce subtle bugs or architectural issues that only human experience can catch.

## Future Plans

SyntaxKit is just the beginning. I'm already exploring similar DSL approaches for other Swift development challenges:

- **PackageDSL improvements**: Building on the success of SyntaxKit's patterns
- **MistKit revival**: Using AI tools to enhance CloudKit development workflows
- **Advanced macro capabilities**: Expanding SyntaxKit to handle more complex Swift constructs

The combination of thoughtful API design and AI-assisted implementation opens up exciting possibilities for developer tooling.

## Getting Started with SyntaxKit

SyntaxKit is available as a Swift package and can be integrated into your macro projects today. The documentation includes examples for common use cases, from simple data structures to complex generic types with protocol conformances.

Whether you're building your first Swift macro or looking to simplify existing SwiftSyntax code, SyntaxKit provides a more approachable path to programmatic Swift code generation.

---

The journey from SwiftSyntax frustration to SyntaxKit success illustrates how AI tools, when used thoughtfully, can accelerate development without replacing good engineering practices. The key is understanding when to lean on AI assistance and when to rely on traditional software design principles.

*SyntaxKit represents not just a better API for Swift code generation, but a new model for AI-assisted tool development that prioritizes developer experience while maintaining the precision and reliability that Swift developers expect.*