---
title: SwiftData CRUD Operations with ModelActor
date: 2025-01-09 00:00
description: How can we add CRUD methods to SwiftData ModelActors in an safe way using actors in Swift 6.
featuredImage: /media/tutorials/swiftdata-crud-operations-modelactor/student-taking-book-in-library-2023-11-27-04-53-22-utc.webp
subscriptionCTA: If you want to learn more about the latest features in Swift, sign up for the newsletter to get notified.
---

In my previous articles, we explored how to:

1. [Use ModelActor in SwiftData](/tutorials/swiftdata-modelactor)
2. [Handle Sendable Requirements with SwiftData](/tutorials/swiftdata-sendable)

Now let's extend our Database type with robust CRUD (Create, Read, Update, Delete) operations that maintain type safety and concurrency correctness.

## The Problem with Raw ModelContext

As I was developing [Bushel], it became exhausting and error-prone to continue using `withModelContext` especially as I was using the same common database operations over and over again. Consider this example:

```swift
let itemModel: Model<Item>
await database.withModelContext { modelContext in 
    guard let item = try modelContext.getOptional(itemModel) else {
        return
    }
    item.timestamp = Date()
    try modelContext.save()
}
```

Let's create a more elegant API that handles these common patterns.

## Introducing the Queryable Protocol

The first step is to define a protocol (i.e. basic requirements) that describes our [CRUD operations](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete). We'll call this `Queryable`:

```swift
public protocol Queryable: Sendable {
    func save() async throws
    
    func insert<PersistentModelType: PersistentModel, U: Sendable>(
        _ insertClosure: @Sendable @escaping () -> PersistentModelType,
        with closure: @escaping @Sendable (PersistentModelType) throws -> U
    ) async rethrows -> U
    
    func getOptional<PersistentModelType, U: Sendable>(
        for selector: Selector<PersistentModelType>.Get,
        with closure: @escaping @Sendable (PersistentModelType?) throws -> U
    ) async rethrows -> U
    
    func fetch<PersistentModelType, U: Sendable>(
        for selector: Selector<PersistentModelType>.List,
        with closure: @escaping @Sendable ([PersistentModelType]) throws -> U
    ) async rethrows -> U
    
    func delete<PersistentModelType>(
        _ selector: Selector<PersistentModelType>.Delete
    ) async throws
}
```

This protocol defines our core CRUD operations with a few key design choices. All methods are async to support background execution or any call which may require async. Secondly we allow a return type by making it `Sendable` and giving the developer the ability to map the `PersistentModel` type to the `Sendable` return type.

### Understanding Selectors

You might notice our protocol methods take a `Selector` type. This type provides a type-safe way to specify what data we want to operate on:

```swift
public enum Selector<T: PersistentModel> {
    enum Get: Sendable {
        /// Retrieve by Model reference
        case model(Model<T>)
        /// Retrieve by predicate condition
        case predicate(Predicate<T>)
    }
    
    enum List: Sendable {
        /// Fetch multiple items with sorting and filtering
        case descriptor(FetchDescriptor<T>)
    }
    
    enum Delete: Sendable {
        /// Delete items matching a predicate
        case predicate(Predicate<T>)
        /// Delete all items of this type
        case all
        /// Delete a specific model
        case model(Model<T>)
    }
}
```

The `Selector` enum provides different ways to specify what we want to query:

1. `Get` - For fetching a single item:
   - `.model()` when you have a Model reference
   - `.predicate()` when querying by condition

2. `List` - For fetching multiple items:
   - Uses `FetchDescriptor` for complex queries with sorting and limits

3. `Delete` - For removing items:
   - `.model()` for a specific item
   - `.predicate()` for items matching a condition
   - `.all` to remove everything

### Implementing Database Operations

Now that we understand Selectors, let's see how our Database type implements these operations:

```swift
extension Database: Queryable {
    public func save() async throws {
        try await withModelContext { try $0.save() }
    }
    
    public func insert<PersistentModelType: PersistentModel, U: Sendable>(
        _ closure: @Sendable @escaping () -> PersistentModelType,
        with transform: @escaping @Sendable (PersistentModelType) throws -> U
    ) async rethrows -> U {
        try await withModelContext { context in
            let model = closure()
            context.insert(model)
            return try transform(model)
        }
    }
    
    // ... other implementations
}
```

## Adding Convenience Methods

While the core protocol methods are powerful, we can add convenience methods to make common operations more ergonomic:

### Model-Returning Methods

These methods return [our `Model` type](/tutorials/swiftdata-sendable), making it easy to maintain references:

```swift
extension Queryable {
    @discardableResult
    public func insert<PersistentModelType: PersistentModel>(
        _ closure: @Sendable @escaping () -> PersistentModelType
    ) async -> Model<PersistentModelType> {
        await self.insert(closure, with: Model.init)
    }
    
    public func getOptional<PersistentModelType>(
        for selector: Selector<PersistentModelType>.Get
    ) async -> Model<PersistentModelType>? {
        await self.getOptional(for: selector) { persistentModel in
            persistentModel.flatMap(Model.init)
        }
    }
}
```

### Throwing Methods

Some operations should fail if the requested item doesn't exist:

```swift
public enum QueryError<PersistentModelType: PersistentModel>: Error {
  case itemNotFound(Selector<PersistentModelType>.Get)
}

extension Queryable {
    public func get<PersistentModelType>(
        for selector: Selector<PersistentModelType>.Get
    ) async throws -> Model<PersistentModelType> {
        try await self.getOptional(for: selector) { persistentModel in
            guard let persistentModel else {
                throw QueryError<PersistentModelType>.itemNotFound(selector)
            }
            return Model(persistentModel)
        }
    }
    
    public func get<PersistentModelType, U: Sendable>(
        for selector: Selector<PersistentModelType>.Get,
        with closure: @escaping @Sendable (PersistentModelType) throws -> U
    ) async throws -> U {
        try await self.getOptional(for: selector) { persistentModel in
            guard let persistentModel else {
                throw QueryError<PersistentModelType>.itemNotFound(selector)
            }
            return try closure(persistentModel)
        }
    }
}
```

### Void-Returning Update Methods

For updates where we don't need the return value:

```swift
extension Queryable {
    public func update<PersistentModelType>(
        for selector: Selector<PersistentModelType>.Get,
        with closure: @escaping @Sendable (PersistentModelType) throws -> Void
    ) async throws {
        try await self.get(for: selector, with: closure)
    }
    
    public func update<PersistentModelType>(
        for selector: Selector<PersistentModelType>.List,
        with closure: @escaping @Sendable ([PersistentModelType]) throws -> Void
    ) async throws {
        try await self.fetch(for: selector, with: closure)
    }
}
```

## Important Note About Temporary IDs

> ⚠️ **Important**: When you insert a new model, SwiftData assigns it a temporary ID. **This temporary ID cannot be used across contexts until you explicitly save the changes.** After saving, you must re-query for the item using a field value (like a name or timestamp) rather than using the Model reference, as the ID may have changed during the save process.

Here's the safe pattern for inserting and retrieving:

```swift
// Create with a known unique value
let timestamp = Date()
let newItem = await database.insert { Item(name: "Test", timestamp: timestamp) }

// IMPORTANT: New items have temporary IDs until saved
try await database.save()  // Save to get permanent ID

// Don't use the original Model reference after save
// Instead, query using a unique field value
let item = try await database.getOptional(for: .predicate(#Predicate<Item> { 
    $0.timestamp == timestamp 
}))
```

I highly recommend [Xu Yang's article on how identifiers work for more details.](https://fatbobman.com/en/posts/nsmanagedobjectid-and-persistentidentifier/#temporary-ids-and-permanent-ids)

![open book and other multi coloured book](/media/tutorials/swiftdata-crud-operations-modelactor/the-open-book-and-other-multi-coloured-books-2024-11-01-10-38-56-utc.webp)


## Making SwiftData Safe and Ergonomic

By building on our previous work with [ModelActor](/tutorials/swiftdata-modelactor) and [Sendable types](/tutorials/swiftdata-sendable), we've created a robust, type-safe API for SwiftData operations that:

- Maintains concurrency safety through Sendable constraints
- Provides a clean, ergonomic interface for common operations
- Supports complex queries through type-safe Selectors 
- Reduces boilerplate while maintaining type safety

This API makes it much easier to work with SwiftData in a concurrent environment while maintaining the safety guarantees that Swift provides. If you'd like to try this out or check out the full code, [the repo for DataThespian is here.](https://github.com/brightdigit/DataThespian) In the next article, we'll explore how to use own new CRUD API to syncronize complex `PersistentModel` objects.