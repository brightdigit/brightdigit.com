---
title: Control Your Swift Dependencies Before They Control You
date: 2024-02-27 02:37
description: Mock Swift dependencies using protocols, dependency injection frameworks, or closure-based injection to enable unit testing and prevent coupling to external systems.
featuredImage: /media/articles/dependency-management-swift/asian-man-buried-in-a-cardboard-box-2023-11-27-05-19-48-utc.webp
subscriptionCTA: Subscribe for more articles about building great apps in Swift
---

**How do you manage dependencies in Swift?** Mock dependencies using protocols, [dependency injection frameworks](https://swift.libhunt.com/libs/dependency-injection), or closure-based injection. This enables unit testing and prevents coupling to external systems like databases, network APIs, and hardware. The key is balancing ergonomics (ease of use) with safety (type checking and compile-time guarantees).

**Why it matters:** As [Brandon Williams from Point-Free](https://www.pointfree.co) explained in [my conversation with him on EmpowerApps](https://brightdigit.com/episodes/159-it-depends-with-brandon-williams/), we often underappreciate how much we rely on code we can't control. Even [Apple's frameworks like CoreLocation](https://developer.apple.com/documentation/corelocation) are dependencies that need proper management for effective testing.

In this article, you'll learn three proven strategies for mocking dependencies in Swift, when to use each approach, and how to maintain testability without sacrificing developer experience.

> transistor https://share.transistor.fm/s/0c634d11

## What Counts as a Dependency in Swift Apps?

Despite most of us having a definite idea of what a dependency is in our minds, it is more than what you think. In the broadest sense, **a dependency is anything in your app that requires an outside system that you do not directly control**.

According to [Apple's Testing documentation](https://developer.apple.com/documentation/testing), dependencies include:

- **Apple frameworks** like [CoreLocation](https://developer.apple.com/documentation/corelocation), [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults), or [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- **Network APIs** (REST, GraphQL, WebSocket connections)
- **Databases** (Core Data, SwiftData, SQLite, Realm)
- **File system** operations and document storage
- **Date and time** (Date(), Calendar, Clock)
- **Hardware** (camera, GPS, sensors, biometrics)
- **Third-party packages** from Swift Package Manager, CocoaPods, or Carthage

Even Apple's own code is a dependency—we don't control how `CoreLocation` is implemented. We trust it works (because it's in Apple's interest), but we still need to mock it for effective unit testing.


## Why Mock Dependencies for Unit Testing in Swift?

Mocking is an important part of testing with any dependency. As a general rule, **you should be mocking anything that’s persistent or external.** If you’re testing components that aren’t yet ready for your production app, mocking is a simple way to isolate this code for testing.

The real power of well-controlled dependencies is you can quickly and accurately predict what should happen in testing. If you have lots of code constantly calling for external resources, like location data or network requests, you’ll probably make your work very difficult for yourself. You might also make it impossible to effectively unit test those components of your app.

**The most important thing to remember is to test how your code deals with various results, both passing and failing, and what is returned.** Your goal should be to test code behavior based on what you need to get from a call.

So what do you need to know: if you’re making a call and expecting data to come back, then **you need to focus on how that data is filtered and changed into something your app can use. You can only test that by having some control over the dependency.**

If you’re new to unit testing in Swift, you’ve probably struggled with managing database and network calls. A lot of people fall into this trap and slow themselves down. A great way of escaping this trap is to think of it like you’re dealing with Apple’s own code. No one tests Apple’s APIs – we trust that they will work because it’s strongly in Apple’s interest that they do so. All you need to do is mock the data that you trust you will get.


### XCode Previews

XCode Preview is worth mentioning here as, like unit testing, they’re a valuable way of testing views without spinning up your whole app. While they are similar in a general sense, Previews also present a couple of challenges:

The first thing is that the more you add to your project, the more likely you are to break your preview. To avoid that happening, you want to, as much as possible, break your projects up into lots of small, stable modules. This uses the principle of [microapp architecture](https://brightdigit.com/articles/microapps-architecture/) (also known as modular architecture). This has the added benefit of making it much easier to [scale your app later on](https://brightdigit.com/articles/scale-ios-app/) without sending your build time sky-high.

The other challenge is that there are a lot of APIs that will also break your preview. If the user needs to grant permission for something to work, XCode Previews doesn’t support that – it’s just how it works. So, if you need to iterate your views, you must find a way to mock the dependencies.


<figure>
<img src="/media/articles/dependency-management-swift/TestingDiagram-Full-Trim.webp" class="full-size"/>
</figure>


## Three Ways to Mock Swift Dependencies

In my chat with [Brandon Williams](https://brightdigit.com/episodes/159-it-depends-with-brandon-williams/) on EmpowerApps, we discussed dependency control. Brandon has a great way of framing how to weigh different considerations when mocking dependencies as a tradeoff between **ergonomics** (developer ease) and **safety** (type checking and compile-time guarantees).

Every dependency mocking approach makes this tradeoff differently. Here are three proven strategies, from simplest to most robust:

### Ergonomics vs. Safety Tradeoff

| Approach | Ergonomics | Safety | Best For |
|----------|-----------|--------|----------|
| Closure Injection | ⭐⭐⭐⭐⭐ | ⭐⭐ | Single function mocks |
| Protocol-Based | ⭐⭐⭐ | ⭐⭐⭐⭐ | Multiple related functions |
| DI Framework | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Large projects, team consistency |

**Quick decision guide:**
- Need to mock one function? → **Use closures**
- Need to mock 2-5 related functions? → **Use protocols**
- Large project with many dependencies? → **Use a [dependency injection framework](https://swift.libhunt.com/libs/dependency-injection)** like [Swinject](https://github.com/Swinject/Swinject), [Needle](https://github.com/uber/needle), or [Factory](https://github.com/hmlongco/Factory)


### Option 1: Closure Injection (Simplest)

**When to use:** Mocking a single function (e.g., network call, date provider, UUID generator)

**How it works:** Pass a closure directly instead of creating a protocol.

```swift
// ❌ Over-engineered for a single function
protocol Adder {
    func doTheThing(x : Int, y: Int) -> Int
}

struct TheThing {
    let adder: Adder
}

// ✅ Simple closure injection
struct TheThing {
    let adder: (Int, Int) -> Int

    // Production usage
    static func live() -> TheThing {
        TheThing(adder: { $0 + $1 })
    }

    // Test usage
    static func mock() -> TheThing {
        TheThing(adder: { _, _ in 42 })
    }
}
```

**Pros:**
- Minimal boilerplate
- No protocol overhead
- Easy to understand

**Cons:**
- Only works for single functions
- Less discoverability than protocols
- No interface documentation

### Option 2: Protocol-Based Injection (Most Common)

**When to use:** Mocking multiple related functions (e.g., network client with GET/POST/DELETE)

**How it works:** Define a protocol that describes the dependency interface. Implement one version for production and one for tests.

```swift
protocol NetworkClient {
    func fetch(url: URL) async throws -> Data
    func post(url: URL, body: Data) async throws -> Data
}

struct URLSessionClient: NetworkClient {
    func fetch(url: URL) async throws -> Data {
        try await URLSession.shared.data(from: url).0
    }
    // ... other methods
}

struct MockNetworkClient: NetworkClient {
    var mockData: Data = Data()

    func fetch(url: URL) async throws -> Data {
        mockData
    }
    // ... other methods
}
```

**Pros:**
- Clear interface definition
- Works with multiple functions
- Self-documenting through protocol requirements
- [Swift protocol-oriented programming](https://developer.apple.com/videos/play/wwdc2015/408/) best practice

**Cons:**
- More boilerplate than closures
- Requires creating mock types

### Option 3: Dependency Injection Frameworks (Most Robust)

**When to use:** Large projects with many dependencies, team projects requiring consistency

**Popular frameworks:**
- **[Swinject](https://github.com/Swinject/Swinject)** - Container-based DI with auto-wiring
- **[Needle](https://github.com/uber/needle)** - Compile-time DI by Uber
- **[Factory](https://github.com/hmlongco/Factory)** - Swift property wrapper-based DI
- **[The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture)** - Includes dependency management

**How it works (Factory example):**
```swift
import Factory

extension Container {
    var networkClient: Factory<NetworkClient> {
        Factory(self) { URLSessionClient() }
    }
}

struct MyViewModel {
    @Injected(\.networkClient) var networkClient

    // In tests, override with:
    // Container.shared.networkClient.register { MockNetworkClient() }
}
```

**Pros:**
- Centralized dependency management
- Easy to swap implementations globally
- Supports scopes (singleton, transient, etc.)
- Team consistency

**Cons:**
- Learning curve for framework
- Additional dependency in your project
- Can obscure dependency graph if overused

> youtube https://youtu.be/nxpyAso6_vI

## Frequently Asked Questions

### Should I mock Apple frameworks like CoreLocation or UserDefaults?

**Yes, always mock external dependencies for unit testing.** Even Apple's frameworks are outside your control. You don't test whether CoreLocation works (trust Apple's testing), but you do test how your code handles location data. Mock the dependency so you can test with predictable data—both success cases and error cases.

### When should I use protocols vs closures for mocking?

**Use closures for single functions, protocols for multiple related functions.** If you're only mocking one thing (like a date provider), closures are simpler. If you're mocking a service with 3+ methods (like a network client), protocols provide better structure and documentation.

### What's the best dependency injection framework for Swift?

**It depends on your project size and team:**
- **Small projects:** Start with manual protocol-based injection (no framework needed)
- **Medium projects:** [Factory](https://github.com/hmlongco/Factory) or [Swinject](https://github.com/Swinject/Swinject) for ease of use
- **Large teams:** [Needle](https://github.com/uber/needle) for compile-time safety
- **SwiftUI/TCA projects:** [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) includes dependency management

### How do I mock dependencies in SwiftUI Previews?

**Use the same strategies (protocols/closures) and inject mock implementations.** For example:

```swift
struct ContentView: View {
    let networkClient: NetworkClient

    var body: some View { /* ... */ }
}

#Preview {
    ContentView(networkClient: MockNetworkClient())
}
```

SwiftUI Previews can't access hardware (camera, microphone) or require user permissions, so mocking is essential for iterating on UI.

### What's the difference between mocking and stubbing?

**Mocking provides controlled test data; stubbing provides minimal implementations.**
- **Mock:** Returns predictable data for testing specific scenarios (e.g., "return this error")
- **Stub:** Minimal implementation that does nothing or returns defaults

In Swift testing, the terms are often used interchangeably. [Swift Testing best practices](https://developer.apple.com/documentation/testing) recommend using mocks for external dependencies.

## Further Reading and Resources

**Official Apple Documentation:**
- [Testing in Xcode](https://developer.apple.com/documentation/testing) - Apple's official testing guide
- [Protocol-Oriented Programming in Swift (WWDC 2015)](https://developer.apple.com/videos/play/wwdc2015/408/) - Foundational talk on protocols
- [Modern Swift API Design (WWDC 2019)](https://developer.apple.com/videos/play/wwdc2019/415/) - Best practices for designing testable APIs

**Dependency Injection Frameworks:**
- [Swinject](https://github.com/Swinject/Swinject) - Container-based dependency injection
- [Needle](https://github.com/uber/needle) - Compile-time safe DI by Uber
- [Factory](https://github.com/hmlongco/Factory) - Modern Swift property wrapper DI
- [Swift Dependency Injection Comparison](https://swift.libhunt.com/libs/dependency-injection) - Framework comparisons

**Advanced Topics:**
- [Point-Free](https://www.pointfree.co) - Advanced Swift videos by Brandon Williams and Stephen Celis
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) - Includes dependency management system
- [Swift Testing Best Practices](https://www.swift.org/blog/swift-testing/) - Swift.org official testing guidance

## Special Thanks to Brandon Williams

Thanks again to Brandon Williams, whose thoughts and conversation were valuable in putting this article together. If you enjoyed this article, I encourage you to listen to my conversation with him [on EmpowerApps](https://brightdigit.com/episodes/159-it-depends-with-brandon-williams/). Brandon publishes videos on advanced Swift through his own brand, [Point-Free](https://www.pointfree.co), which are always worth a watch.
