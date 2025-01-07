---
title: Querying ModelActor in SwiftData
date: 2025-01-20 16:00
description: How can we add CRUD methods to SwiftData ModelActors in an safe way using actors in Swift 6.
featuredImage: /media/tutorials/swiftdata-modelactor/robots-efficiently-sorting-hundreds-of-parcels-per-2023-11-27-05-28-19-utc.webp
subscriptionCTA: If you want to learn more about the latest features in Swift, sign up for the newsletter to get notified.
---

In my previous articles, we explored how to [use ModelActor in SwiftData](/tutorials/swiftdata-modelactor) and [handle Sendable requirements](/tutorials/swiftdata-sendable). Now let's extend our Database type with robust CRUD (Create, Read, Update, Delete) operations that maintain type safety and concurrency correctness.

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

The first step is to define a protocol (i.e. basic requirements) that describes our CRUD operations. We'll call this `Queryable`:

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

## Specifying What to Query with Selectors

You might notice our protocol methods take a `Selector` type. This type provides a type-safe way to specify what data we want to operate on:

```swift
public enum Selector<T: PersistentModel> {
    enum Get: Sendable {
        case model(Model<T>)
        case predicate(Predicate<T>)
    }
    
    enum List: Sendable {
        case descriptor(FetchDescriptor<T>)
    }
    
    enum Delete: Sendable {
        case predicate(Predicate<T>)
        case all
        case model(Model<T>)
    }
}
```

### Get Operations

For fetching single items, we use `Selector.Get`:

```swift
// Fetch by predicate
let activeItem = try await database.get(for: .predicate(#Predicate<Item> { 
    $0.name == "Important Task" && $0.isActive 
}))

// Using complex date conditions
let recentItem = try await database.getOptional(for: .predicate(#Predicate<Item> { 
    $0.timestamp >= Date().addingTimeInterval(-86400) && // Last 24 hours
    $0.category == "work"
}))

// Working with relationships
let projectTask = try await database.get(for: .predicate(#Predicate<Task> { 
    $0.project?.name == "Launch" && 
    $0.assignee?.role == "developer"
}))
```

### List Operations

For fetching multiple items, we use `Selector.List` with `FetchDescriptor`:

```swift
// Basic fetch with sorting
let sortedItems = try await database.fetch(for: .descriptor(
    predicate: #Predicate<Item> { $0.isActive },
    sortBy: [
        SortDescriptor(\Item.priority, order: .reverse),
        SortDescriptor(\Item.timestamp)
    ]
))

// Pagination
let pagedItems = try await database.fetch(for: .descriptor(
    Item.self,
    predicate: #Predicate<Item> { $0.isArchived == false },
    sortBy: [SortDescriptor(\Item.timestamp, order: .reverse)],
    fetchLimit: 20
))

// Complex relationship queries
let teamTasks = try await database.fetch(for: .descriptor(
    predicate: #Predicate<Task> { task in
        task.assignees.contains { $0.team == "Engineering" } &&
        task.project?.status == .active &&
        task.dueDate <= Date().addingTimeInterval(86400 * 7) &&
        !task.isComplete
    }
))
```

### Delete Operations

For removing items, we use `Selector.Delete`:

```swift
// Delete a specific item
try await database.delete(.model(itemModel))

// Delete by condition
try await database.delete(.predicate(#Predicate<Item> { 
    $0.timestamp < oneWeekAgo && $0.isArchived 
}))

// Delete everything
try await database.delete(.all)
```

## Adding Convenience Methods

Our core protocol methods are powerful but can be verbose for common operations. Let's add convenience methods that make the API more ergonomic. These methods fall into several categories based on their return types and error handling:

### Model-Returning Methods

These methods return our `Model` type, making it easy to maintain references to database objects. However, it's crucial to understand that newly inserted models receive temporary IDs until they're saved:

> ⚠️ **Important**: When you insert a new model, SwiftData assigns it a temporary ID. This temporary ID cannot be used across contexts until you explicitly save the changes. Unlike Core Data's `NSManagedObjectID.isTemporaryID`, [SwiftData doesn't provide a way to check if an ID is temporary.](https://fatbobman.com/en/posts/nsmanagedobjectid-and-persistentidentifier/#temporary-ids-and-permanent-ids) Always call `save()` after inserting if you plan to use the model's ID for relationships or cross-context operations.

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

Some operations should fail if the requested item doesn't exist. These methods throw errors instead of returning optionals:

```swift
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

For updates where we don't need the return value, we provide methods that return `Void`:

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

## Handling Batch Operations

Sometimes we need to perform operations on multiple items at once. We can add methods to handle these cases efficiently:

```swift
extension Queryable {
  public func fetch<PersistentModelType, U: Sendable>(
    for selectors: [Selector<PersistentModelType>.Get],
    with closure: @escaping @Sendable (PersistentModelType) throws -> U
  ) async rethrows -> [U] {
    try await withThrowingTaskGroup(of: Optional<U>.self) { group in
      for selector in selectors {
        group.addTask {
          try await self.getOptional(for: selector) { model in
            guard let model else { return nil }
            return try closure(model)
          }
        }
      }
      return try await group.compactMap { $0 }
    }
  }
}
```

## Using the Enhanced API

Now we can perform database operations with much cleaner syntax:

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

## Conclusion

By building on our previous work with ModelActor and Sendable types, we've created a robust, type-safe API for SwiftData operations that:

- Maintains concurrency safety through Sendable constraints
- Provides a clean, ergonomic interface for common operations
- Supports complex queries through type-safe Selectors 
- Handles temporary IDs safely
- Reduces boilerplate while maintaining type safety

This API makes it much easier to work with SwiftData in a concurrent environment while maintaining the safety guarantees that Swift provides. In the next article, we'll explore how to add more advanced features like relationships and cascading deletes.