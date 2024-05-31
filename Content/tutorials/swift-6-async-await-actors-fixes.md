---
title: Swift 6 Incomplete Migration Guide for Dummies
date: 2024-05-31 00:00
description: Discover the first steps for migrating to Swift 6, focusing on concurrency safety. Learn how to handle mutable properties, use `nonisolated`, and make UI components `@MainActor` for a seamless transition.
featuredImage: /media/tutorials/swift6-migration/futuristic-race-cars-avoiding-data-collision.webp
subscriptionCTA: If you want to learn more about the latest features in Swift, sign up for the newsletter to get notified.
---

If you've been a Swift developer (or a developer in the Apple space), you've experienced your fair share of migrations. Whether it was **Objective-C, SwiftUI, `try...catch` or most recently async/await and actors**, we've had to continue to evolve:

* [Swift 3](https://www.swift.org/migration-guide-swift3/)
* [Swift 4](https://www.swift.org/migration-guide-swift4/)
* [Swift 4.2](https://www.swift.org/migration-guide-swift4.2/)
* [Swift 5](https://www.swift.org/migration-guide-swift5/)

---

The good news is **we'll continue to have a desired skill for the labor force!** Besides that, it means:

1. Swift is still a _living evolving language._
2. Swift continues to strive to be a _safe_ language.

**As we reach a full decade since its introduction, Swift 6 introduces its most bold set of safety features when it comes concurrency.**

[I've been interested in concurrency since the days of Grand Central Dispatch.](/tutorials/asynchronous-multi-threaded-parallel-world-of-swift) With Swift 6, we are seeing the biggest advancements in safety to the language - **which means it's going to break a lot of stuff.**

<figure>
    <img src="/media/tutorials/swift6-migration/top-view-of-young-drunk-woman-lying-on-floor-in-me-2023-11-27-05-20-37-utc.webp"
         alt="top view of young drunk woman lying on floor">
    <figcaption>You after the post WWDC 2024 party realizing how much code you're going to need to clean up.</figcaption>
</figure>

**Swift 6 forces you to make sure that things like data races can't happen while you doom scroll on your $3000 iPad Pro efficiently using processor cores properly.**

Recently I took the deep dive and **begun migrating [Bushel](https://getbushel.app) to Swift 6** and have learned some general lessons which I hope help you with your migration. However before I do, I can't go without mentioning that **the upcoming version of Xcode will include a Swift 5 mode**. In my opinion, **you should take advantage of this** - especially if you are on a big team supporting older operating systems. For the more adventurous developer, you can already 
[enable _Complete_ **Strict Concurrency** in Xcode 15.](https://www.swift.org/documentation/concurrency/)

With that in mind, **here's my very broad guide to fixing Swift 6.** There are exceptions to many of these cases but my hope is **this guide is a starting point for migrating your apps and bringing more efficiency and a better experience for your users.**

## When you have complete control

Let's start by talking about the code you have complete control over which is not connected to third-party code. Let's start with the largest issue where you’ll gain most benefit.

### Mutable Properties should be a Sendable Struct or Actor

```
Stored property 'observations' of 'Sendable'-conforming class 'VirtualizationMachineBuilder' is mutable
```

**A mutable property on Sendable types is a red flag for concurrency issues.** If it can be changed, it can be changed by multiple actors/threads/etc... This is fertile ground for race conditions. Swift 6 looks for these situations and will happily throw you errors. Therefore you have two possible solutions for these properties:

1. Make it an `actor`
2. Mark it as `Sendable`

As you might imagine once you make something `Sendable` or an `actor`, this will spread to its descendants.

Here's a _overly simple rule of thumb:_

* **If `class` make it `actor` or `Sendable`**
* **If `struct` make it `Sendable`**

Of course there are exceptions to this rule and it helps to think about what it means by marking types as `Sendable`. If your type is simple structure with `Sendable` properties it's perfectly fine to make it `Sendable` as well. If your type is a complex class and can be entered simultaneously in any way, it becomes more complicated. You can either mark it as an `actor` which has [repercussions](#start-a-call) or recursively follow the rules stated above for its properties.

By moving your classes to actor there are few restrictions:

* It's `final` which means it can't be subclassed
* Every function becomes asynchronous from the outside in order to prevent race conditions 

By making every function asynchronous, you will run into issues especially when you are trying to implement a Protocol on an actor. Luckily there are a few workarounds for that.

## When you don't have complete control

Most of the time you'll have code you don't have control over a Swift Package, a neglected Apple API, a ... 👻 **Cocoapod** 👻 In these cases, **you'll have to find creative ways to work with them while making them safe for Swift 6.**

### Use `nonisolated` to _start_ a call

<a name="start-a-call"></a>

Let's say you have an asynchronous method in your code base but you need to implement a synchronous method because it has to implement a protocol for instance.The solution I've taken is to __start the asynchronous call within a synchronous call__. In most cases, _I am reacting to a button tap/click which just needs to start a process._ **I don't need to wait for it to be completed.**

Where `nonisolated` fits, is when you've created an `actor` or a type which is marked for a global actor such as `@MainActor`. Every call made to that object will automatically be marked as `async`, since it needs to wait for that actor to be available. By marking a method as `nonisolated` we allow it to be called from outside that actor. However this means we need to _start_ the actual method on a Task:
```
@MainActor
final class MachineObject {
{
  // this can be call syncronously from anywhere
  nonisolated func deleteSnapshot(_ snapshot: Snapshot?, at url: URL?) {
    Task {
      await self.deletingSnapshot(snapshot, at: url)
    }
  }
  
  // this is required to be called from MainActor
  func deletingSnapshot(_ snapshot: Snapshot?, at url: URL?) async
}
```

### `nonisolated` `static` synchronous properties 

If you have a `static` property, especially one that isn't dependent on any data, you can use `nonisolated` since it's a simple return of a value. In my case I was using my library FelinePine to specify a Logger category:

```
internal class VirtualizationInstaller: Loggable {
  internal static var loggingCategory: BushelLogging.Category {
    .machine
  }
  ...
}
```

I was receiving the error:

```
VirtualizationInstaller.swift:15:25 
Main actor-isolated static property 'loggingCategory' cannot be used to satisfy nonisolated protocol requirement
```

In this case the category is hard-coded and not dependent on any other values, therefore it can just be marked as `nonisolated`:

```
internal class VirtualizationInstaller: Loggable {
  internal nonisolated static var loggingCategory: BushelLogging.Category {
    .machine
  }
  ...
}
```

### You Pass an Argument That is Sendable use a @Sendable closure

After I migrated to [my ModelActor API with SwiftData,](/tutorials/swiftdata-modelactor) one Swift 6 related issue remained:

```
Non-sendable type 'FetchDescriptor<T>' in parameter of the protocol requirement satisfied by actor-isolated instance method 'fetch' cannot cross actor boundary
```

Despite ensuring my SwiftData models were Sendable, `FetchDescriptor` remained not `Sendable`. However you can get around this by passing `@Sendable` closure instead.

Therefore my `Database` protocol goes from:

```swift
func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel & Sendable

try await database.fetch(
  FetchDescriptor<SnapshotEntry>(
    predicate: #Predicate { $0.snapshotID == id }
  )
)
```

to:

```swift
func fetch<T>(
  _ descriptor: @Sendable @escaping () -> FetchDescriptor<T>
) async throws -> [T] where T: PersistentModel & Sendable

try await database.fetch{
  FetchDescriptor<SnapshotEntry>(
    predicate: #Predicate { $0.snapshotID == id }
  )
}
```

Matt Massicotte has [a great writeup here on recipes with this solution as well as alternatives.](https://github.com/mattmassicotte/ConcurrencyRecipes/blob/main/Recipes/Isolation.md)

### If it's SwiftUI make it MainActor

```
Stored property '_isNextReady' of 'Sendable'-conforming struct 'SpecificationConfigurationView' has non-sendable type 'Binding<Bool>'
Stored property '_restoreImageImportProgress' of 'Sendable'-conforming class 'DocumentObject' is mutable
Converting non-sendable function value to '@MainActor @Sendable (OpenWindowAction) -> Void' may introduce data races
```

_Back when we were developing Newton apps on punch cards the first issue we ran into was trying to make UI changes on the inappropriate queue._ There was an obvious fix:

```
   dispatch_async(dispatch_get_main_queue(), ^{
       [[self itunespingLabel] setText:[NSString stringWithFormat:@"%@", name]];     
   });
```

**Luckily this is still apt for SwiftUI (and AppKit and UIKit too).** Every SwiftUI View should be run on the `@MainActor`. Matt has [a few suggestions on how to do this.](https://github.com/mattmassicotte/ConcurrencyRecipes/blob/main/Recipes/SwiftUI.md) I've taken the approach to explicitly marking all my views as @MainActor:

```
import SwiftUI

@MainActor
struct SessionToolbarView: View {
```

However this is means **everything** which interacts with SwiftUI will need to be `@MainActor` as well:

### EnvironmentKey value properties which are being interacted with

Anytime you do something which interacts with the UI (i.e. SwiftUI) then it'll need to be a `@MainActor` as well. In this first instance we have potential `Environment` property which calls `openWindow` based on a particular `value` in SwiftUI:

```swift
public struct OpenWindowWithValueAction<ValueType: Sendable>: Sendable {
  let closure: @Sendable @MainActor (ValueType, OpenWindowAction) -> Void
  
  public init(closure: @escaping @MainActor @Sendable (ValueType, OpenWindowAction) -> Void) {
    self.closure = closure
  }

  @MainActor
  public func callAsFunction(_ value: ValueType, with openWindow: OpenWindowAction) {
    closure(value, openWindow)
  }
}
```

Since we are interacting with the UI, the method which calls the `OpenWindowAction` needs to be on `@MainActor`. This means then that the closure also needs to be marked as @MainActor **and** the argument in the `init` as well.

Here's another example:

```swift
public struct ViewValue: Sendable {
  let content: @Sendable @MainActor (Binding<(any InstallImage)?>) -> AnyView

  public init(content: @Sendable @escaping @MainActor (Binding<(any InstallImage)?>) -> some View) {
    self.content = { image in
      AnyView(content(image))
    }
  }

  @MainActor func callAsFunction(_ selectedHubImage: Binding<(any InstallImage)?>) -> some View {
    content(selectedHubImage)
  }
}

private struct HubViewKey: EnvironmentKey {
  typealias Value = ViewValue

  static let defaultValue = ViewValue { _ in
    EmptyView()
  }
}

extension EnvironmentValues {
  public var hubView: ViewValue {
    get { self[HubViewKey.self] }
    set { self[HubViewKey.self] = newValue }
  }
}

extension Scene {
  @MainActor
  public func hubView(
    _ view: @Sendable @escaping @MainActor (Binding<(any InstallImage)?>) -> some View
  ) -> some Scene {
    self.environment(\.hubView, .init(content: view))
  }
}
```

In the code example above, not only does the `content` closure and `callAsFunction` but the `Scene` extension since `Scene` is a UI component from `SwiftUI`.

#### `@Observable` Objects

For the most part `@Observable` objects should be on `@MainActor` since they are acted upon by SwiftUI. Again if you want to [just _start_ a method feel free to use `nonisolated` method stated above.](#start-a-call)

## The most inner circle of Hell

![Planes, Trains, and Automobiles](https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExemZoNzh5YTFhZWJjcHlvOTRtMjZ6Z2I5ZHd4MGxlYXNxaTFwOWJpOSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/hsWz3aJkFYJZm/giphy.gif)

In many cases, you don't have any control. Unfortunately you simply need to wait for updates and can ignore the warning for now. 😭

### This is a bug

```
Cannot form key path to main actor-isolated property 'requestReview'; this is an error in Swift 6
```

In many cases, there are pieces which haven't completed yet. In this case, [it's currently a bug in Swift.](https://github.com/apple/swift/issues/72181) Hopefully these will be updated in time for WWDC 2024 and most importantly I'll follow through and update this post. In any case, **you should take the time file a Feedback Assistant.* **

### It uses DispatchQueue

There still remains plenty of code which still relies on GCD. In the case of Bushel this includes:

* XPC
* Combine
* Virtualization
* SwiftData [(except for ModelActors)](/tutorials/swiftdata-modelactor)

There are two solutions:

1. Stick with GCD and avoid new language features in those types.
2. Wrap your GCD API in a `CheckedContinuation`.

For more info, I highly recommend checking out [Matt Massicotte's recipe for this.](https://github.com/mattmassicotte/ConcurrencyRecipes/blob/main/Recipes/Interoperability.md)

### Server-Side Swift

Luckily, the Server-Side Swift team has been moving steadily forward with Swift 6 compatibility since it's announcement. If you are interested in learning more, I highly recommend:

* [Tim's post a while ago on the next steps for Vapor](https://blog.vapor.codes/posts/vapor-next-steps/)
* [As well as his post on Vapor's Next Steps with async/await](https://blog.vapor.codes/posts/async-next-steps/)
* [Joannis's article on Getting Started with Structured Concurrency in Swift](https://swiftonserver.com/getting-started-with-structured-concurrency-in-swift/)
* [I would also check out the entire site at swiftonserver.com for more great articles by Joannis and Tibor.](https://swiftonserver.com/)
* [For a great example of the real-world challenges with Swift 6, I would check out Gwynne's recent article on Fluent Models and Sendable warnings.](https://blog.vapor.codes/posts/fluent-models-and-sendable/)

### It needs to be synchronous

<img alt="You're screwed" class="icon" src="https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExYWRzOXBxanF2NHFleDR0NXNqZTY1bDRxZWc2bnhtdXhqeDh6NDNtayZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/pWdckHaBKYGZHKbxs6/giphy-downsized.gif"/>

## Now What?

Hopefully this article **helps you get started on migrating your code.** While it won't be simple to migrate your code, here are the simple guidelines:

* **Mutable properties need concurrency safety** either via `Sendable` or `Actor`
* In an `actor`, **use `nonisolated` for starting a task** or for properties with constants
* If type isn't `Sendable` **use a `@Sendable` closure**
* If it's **UI-related make it @MainActor** (i.e. SwiftUI View, Observable, etc...)
* **There are still APIs and frameworks which haven't migrated over** but hopefully soon 🤞

**I'm excited to get the advantages of the concurrency safety** that comes with Swift 6. I'm sure teams will have challenges in migrating. **If you have a large enough team which needs to support older OSes, it's totally worth holding off on migrating.** For those like myself, the hope is that getting in early on these features means improved performance and a safer concurrency implementation. I'm looking forward to following the events of WWDC 2024, as well as the advice from Apple and others. Stay tuned!