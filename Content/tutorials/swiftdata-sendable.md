---
title: Being Sendable with SwiftData
date: 2024-11-13 00:00
description: How do you use non-Sendable PersistentModel objects in SwiftData? This is where PersistentIdentifier comes in.
featuredImage: /media/tutorials/swiftdata-sendable/top-view-of-female-warehouse-worker-packing-shippi-2023-11-27-05-25-58-utc.webp
---

In the previous article, I showed how to setup a ModelActor which accessed SwiftData on a non-MainActor. 

1. [Using ModelActor in SwiftData](/tutorials/swiftdata-modelactor)
2. [Being Sendable with SwiftData](/tutorials/swiftdata-sendable)

We were left with an implementation that used a `with` pattern which allowed us to use a non-Sendable object within a closure. In this article I'm going to expand on that by resolving the issue with non-Sendable PersistentModel objects.

## Why PersistentModels aren't Sendable

One of the revelations I received from my sessions at WWDC 2024 was that **`PersistentModel` object are not `Sendable`**. This means a `PersistentModel` cannot be passed from one actor to another. In other words, it's difficult to pass them from one function to another unless they are on the same actor so you must do whatever you want with them within that function. This also means - no holding references to a PersistentModel within an `@Observable` object.

Well then how can one hold a reference to a `PersistentModel`? This is where the `persistentIdentifer` come in.

## The Power of PersistentIdentifier

In [a great article from Xu Yang (aka FatBobMan)](https://fatbobman.com/en/posts/nsmanagedobjectid-and-persistentidentifier/) he goes over the different _identifiers_ in Core Data and Swift Data. In our particular case, we'll be using [the `PersistentIdentifier` from `.persistentModelID`](https://developer.apple.com/documentation/swiftdata/persistentmodel/persistentmodelid):

```swift
extension ModelContext {
  func persistentModel<T>(withID objectID: PersistentIdentifier) throws -> T?
    where T: PersistentModel {
    if let registered: T = registeredModel(for: objectID) {
      return registered
    }
    if let notRegistered: T = model(for: objectID) as? T {
      return notRegistered
    }
  
    let fetchDescriptor = FetchDescriptor<T>(
      predicate: #Predicate { $0.persistentModelID == objectID },
      fetchLimit: 1`
`    )
  
    return try fetch(fetchDescriptor).first
  }
}
```

This will work great but we if we used a _Phantom Type_ to store the PersistentModel type we are fetching.

## Introducing the _Model_

In [an article from Majid Jabrayilov](https://swiftwithmajid.com/2021/02/18/phantom-types-in-swift/) he introduces the concept of the _Phantom Type_:

> A phantom type is a generic type that is declared but never used inside a type where it is declared. 

Typically we use a generics we are using it because a property stores a value of that type. However a _Phantom Type_ simply uses it to note _how_ the object is to be used.
In our case we are going to use the generic type to denote what `PersistentModel` type we are fetching:

```swift
public struct Model<T: PersistentModel>: Sendable {
  public let persistentIdentifier: PersistentIdentifier

  public init(persistentIdentifier: PersistentIdentifier) {
    self.persistentIdentifier = persistentIdentifier
  }
}

extension Model {
  public init(_ model: T) {
    self.init(persistentIdentifier: model.persistentModelID)
  }
}
```

What's particularly great about this `Model` type, is that it's actually `Sendable`! We can then store this in SwiftUI or Observable object. Now let's go back and use this with our `ModelContext`:

```swift
extension ModelContext {
  func getOptional<T>(_ model: Model<T>) throws -> T?
    where T: PersistentModel {
      try self.persistentModel(withID: model.persistentIdentifier)
    }
  }
}
```

Putting all this together from our last article, we can use this in our `Database` type:

```swift
let itemModel : Model<Item>
database.withModelContext{ modelContext in 
  guard let item = modelContext.getOptional(itemModel) else {
    // shouldn't happen 😣
  }
  item.timestamp = Date()
  try modelContext.save()
}
```

I'm sure you're already thinking we should use this for some CRUD operations on our `Database` type. Well in the next article we'll explore how to add that to our API.