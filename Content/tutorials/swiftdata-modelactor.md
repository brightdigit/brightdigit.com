---
title: Using ModelActor in SwiftData
date: 2024-03-09 16:00
description: How to adopt SwiftData using ModelActor instead of MainActor in your SwiftUI application with Environment values for seamless and efficient user experience.
featuredImage: /media/tutorials/swiftdata-modelactor/robots-efficiently-sorting-hundreds-of-parcels-per-2023-11-27-05-28-19-utc.webp
subscriptionCTA: If you want to learn more about the latest features in Swift, sign up for the newsletter to get notified.
---

With [the introduction of SwiftData at WWDC 2023](https://developer.apple.com/videos/play/wwdc2023/10187/), we have seen the further _Swift-ifaction_ of older APIs. While Core Data is a tried and true technology, SwiftData allows for the use of Swift in defining models and relationships. This is as opposed to Core Data's own format just as SwiftUI eliminated the need for Storyboards and Xibs. 

One of the major challenges with using SwiftData is its introduction in a post-async-await world. This introduces its own challenges. Challenges which can be difficult to decipher since Apple has abstracted much of that away in layers of Macros and Property Wrappers.

1. [Using ModelActor in SwiftData](/tutorials/swiftdata-modelactor)
2. [Being Sendable with SwiftData](/tutorials/swiftdata-sendable)

> youtube https://www.youtube.com/watch?v=rN23Ygvy47E

## Beta Testing SwiftData

During my (second) attempt at [building Bushel](https://getbushel.app/), SwiftData was one of the leading reasons to target Sonoma as opposed to older operating systems. As I built Bushel while SwiftData was in beta, I began to realize there was some I was missing in my implementation. It become all too evident to me what I was doing wrong: Threading. If you've run into crashes while integrating SwiftData. You've seen these crashes all too much. My last minute fix was simple: [`@MainActor`](https://developer.apple.com/documentation/swiftdata/modelactor).

This _fixed_ the problem but it was clear to me that this wasn't ideal. Moving database work to the main thread _fixed_ the problem but it seemed sub-optimal and inefficient. There had to be a better way.

## Creating Our ModelActor

This is where [`@ModelActor`](https://developer.apple.com/documentation/swiftdata/modelactor) comes in. **ModelActor** introduces a way to interface with the database (i.e. `ModelContext`) in a mutually-exclusive way. **This means the database can only be accessed one at a time as required by SwiftData.** In other words I no longer require all database actions be run on the `MainActor` but a background actor shared by the application.

It was unclear to me when in development ModelActor was introduced as I couldn't find a WWDC video or much documentation on the subject. However there were a two sources which  helped spark the beginning of this transition.  

[This article from Vyacheslav Ansimov](https://medium.com/@vyacheslavansimov/swift-utilities-working-with-swiftdata-in-the-background-02e28c3b6908) introduces the how a background ModelActor would work. 

More importantly Franz Busch's talk at Server Side Swift 2024 showcases the important `with` pattern to structured concurrent which we'll use here:

> youtube https://www.youtube.com/watch?v=JmrnE7HUaDE

The way we'll implement our ModelActor is by essentially **using the `with` pattern to interface with the `ModelContext`:** 

```swift
extension ModelActor {
  public func withModelContext<T: Sendable>(
    _ closure: @Sendable @escaping (ModelContext) throws -> T
  ) async rethrows -> T {
    let modelContext = self.modelContext
    return try closure(modelContext)
  }
}
```

This will easily work in our application however there are a few remaining things I need to do the application:

* Create a **Protocol** for this type to remove direct references to this type
* Create an **`@Environment` value** so I can use this throughout the application

## Abstracting Our ModelActor

There are several reason I want to abstract our `ModelActor` extension into a protocol. Such as *easier mocking for unit tests* as well as *removing direct references* [(as I use a lot)](/articles/bushel-launch-part-3/#packagedsl). If you are interested in learning more about dependency management, I highly recommend checking [this article out.](/articles/dependency-management-swift) 

So let's create a abstract `Database` protocol:

```swift
public protocol Database: Sendable {
  func withModelContext<T>(_ closure: @Sendable @escaping (ModelContext) throws -> T)
    async rethrows -> T
}

extension ModelActor where Self: Database {
  public func withModelContext<T: Sendable>(
    _ closure: @Sendable @escaping (ModelContext) throws -> T
  ) async rethrows -> T {
    let modelContext = self.modelContext
    return try closure(modelContext)
  }
}
```

I want to note that **the method is async**. This is to take into account the fact that if this is implemented by an actor when the method will be called outside of the actor it will be required to be asynchronous to ensure exclusivity.

Now we can let the compiler know that `ModelActorDatabase` implements `Database`:

```swift
@ModelActor
public actor ModelActorDatabase: Database {}
```

This is a great step but now we need to make sure that our SwiftUI Views have access to this object. The best way to do this is by creating a new `EnvironmentKey`.

## Environmentally Friendly

SwiftUI provides an API to add new values to the `@Environment property` wrapper. However we'll need to implement a [`defaultValue`](https://developer.apple.com/documentation/swiftui/environmentkey/defaultvalue) for our `Database`. What do we want if the developer (me) forgets to setup the `Database`? Taking a page from what `.modelContainer` does I'll create a `DefaultDatabase`:

```swift
private struct DefaultDatabase: Database {
  static let instance = DefaultDatabase()

  // swiftlint:disable:next unavailable_function
  func withModelContext<T>(_ closure: (ModelContext) throws -> T) async rethrows -> T {
    assertionFailure("No Database Set.")
    fatalError("No Database Set.")
  }
}
```

In this implementation, the method crashes. This ensures the developer (me) doesn't forget to set the `Database`. Now we can setup our `Environment` value:

```swift
extension EnvironmentValues {
  @Entry public var database: any Database = DefaultDatabase.instance
}

extension Scene {
  public func database(_ database: any Database) -> some Scene {
    environment(\.database, database)
  }
}

extension View {
  public func database(_ database: any Database) -> some View {
    environment(\.database, database)
  }
}
```

Now in the root SwiftUI Scene we can call the modifier to pass our `ModelActorDatabase`:

```swift
var body: some Scene {
  WindowGroup {
    RootView()
  }.database(ModelActorDatabase(modelContainer: ...))
}
```

and then reference it in our SwiftUI View:

```swift
@Environment(\.database) private var database
```

However we'll notice two issues with this approach:

1. That our calls are still running on the main thread. 😫
2. We'll receive a slightly opaque crashing message:

> An NSManagedObjectContext cannot delete objects in other contexts.

<figure>
<img src="/media/tutorials/swiftdata-modelactor/model-contexts.webp"/>
</figure>

## Context Switching

If you are familiar with Core Data, you probably know that you should use a single `NSManagedObjectContext` throughout your app. The issue here is that our initializer for `ModelActorDatabase` will be called each time the SwiftUI View is redraw. So if we look at the expanded `@ModelActor` Macro for our `ModelActorDatabase`, we see that a new `ModelContext` (SwiftData wrapper or abstraction, etc.  of `NSManagedObjectContext`) is created each time:

```swift
public init(modelContainer: SwiftData.ModelContainer) {
    let modelContext = ModelContext(modelContainer)
    self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    self.modelContainer = modelContainer
}
```

This means if we pass SwiftData models throughout our app, we will be running our models through a variety of `ModelContext` objects which will result in a crash. The best approach to this is create a singleton for the `Database` and `ModelContainer` which ensures it to be shared across the `.environment` and application:

```swift
 public struct SharedDatabase {
  public static let shared: SharedDatabase = .init()

  public let schemas: [any PersistentModel.Type]
  public let modelContainer: ModelContainer
  public let database: any Database

  private init(
    schemas: [any PersistentModel.Type] = .all,
    modelContainer: ModelContainer? = nil,
    database: (any Database)? = nil
  ) {
    self.schemas = schemas
    let modelContainer = modelContainer ?? .forTypes(schemas)
    self.modelContainer = modelContainer
    self.database = database ?? ModelActorDatabase(modelContainer: modelContainer)
  }
}
```

Then in our SwiftUI code, we call:

```swift
var body: some Scene {
  WindowGroup {
    RootView()
  }
  .database(SharedDatabase.shared.database)
  /* if we wish to continue using @Query
  .modelContainer(SharedDatabase.shared.modelContainer)
  */
}
```

---

The other issue of course is **that our calls are still running on the main thread.**

*What is happening?* **My thought is that all methods of an actor are called on the thread the object is created on.** Therefore if we create `ModelActorDatabase` on the main actor (which is likely with SwiftUI) every method inside the actor will be called on the main thread. This is not ideal when it comes to the user experience of the app.

**To resolve this we'll need to allow the `Database` initializer on the MainActor but ensure the database calls will be run in the background.** 

## Moving to the Background

This is where a new `Database` implementation for wrapping our `ModelActorDatabase` comes in. 
Introducing the `BackgroundDatabase`:

```swift
public class BackgroundDatabase: Database {
  private actor DatabaseContainer {
    private let factory: @Sendable () -> any Database
    private var wrappedTask: Task<any Database, Never>?
  
    fileprivate init(factory: @escaping @Sendable () -> any Database) {
      self.factory = factory
    }
  
    fileprivate var database: any Database {
      get async {
        if let wrappedTask {
          return await wrappedTask.value
        }
        let task = Task {
          factory()
        }
        self.wrappedTask = task
        return await task.value
      }
    }
  }


  private let container: DatabaseContainer

  private var database: any Database {
    get async {
      await container.database
    }
  }

  internal init(_ factory: @Sendable @escaping () -> any Database) {
    self.container = .init(factory: factory)
  }
  
  public func withModelContext<T>(_ closure: @Sendable @escaping (ModelContext) throws -> T)
    async rethrows -> T
  { try await self.database.withModelContext(closure) }
}
...
```

What is this doing to ensure background execution? Firstly we create an inner actor type which will provide exclusivity into the actual `Database` implementation while ensuring the `Database` is initialized on a background thread. We are using [Matt Massicotte's recipe for Structure Concurrency using an unstructured Task here.](https://github.com/mattmassicotte/ConcurrencyRecipes/blob/main/Recipes/Structured.md#solution-1-use-an-unstructured-task) *Check out [his episode here for more details on the complexities of concurrency.](/episodes/158-edge-of-concurrency-with-matt-massicotte/)*

> youtube https://www.youtube.com/watch?v=0VlwWhBd7pE

With this update, every time the `container.database` is accessed the `ModelActorDatabase` will be on a background actor. 

Then we update our `SharedDatabase` single:

```swift
public struct SharedDatabase {
  private init(
    schemas: [any PersistentModel.Type] = .all,
    modelContainer: ModelContainer? = nil,
    database: (any Database)? = nil
  ) {
    self.schemas = schemas
    let modelContainer = modelContainer ?? .forTypes(schemas)
    self.modelContainer = modelContainer
    self.database = database ?? BackgroundDatabase(modelContainer: modelContainer)
  }
}
```

This time our new database works perfectly! 🥳

## How to be a Model Actor within SwiftData

Adopting ModelActor with SwiftData presents a significant enhancement to the efficiency within SwiftUI applications. By transitioning database work to a background thread, we ensure a smoother user experience, particularly in scenarios where database interactions are involved.

* Relying solely on `@MainActor` seemed to solve one problem but created new ones when it came to user experience. 
* By using ModelActor and creating an abstraction into a protocol (i.e. `Database`), we've modularized database interactions, making our codebase cleaner and more maintainable. 
* Use the same ModelContext throughout your app to avoid crashes due to context switching.
* The introduction of `BackgroundDatabase` further refines this, ensuring that database operations occur asynchronously on a separate thread, enhancing responsiveness within our SwiftUI application.

While the transition to ModelActor and BackgroundDatabase necessitated some refactoring and adjustments, the end result significantly improves the scalability and responsiveness of our application. As we get closer to Swift 6, perhaps there will be less ambiguity with regard the Actors and Concurrency. Hopefully you found this article helpful for you, it underscores the importance of continuously refining our code in order to deliver exceptional user experiences. 
