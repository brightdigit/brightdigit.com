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

## Implementing Database Operations

With our protocol defined, we can extend our existing `Database` type to implement these operations:

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

These typically follow the pattern of calling `withModelContext` and then calling the `transform` if passed.

## Adding Convenience Methods

To make our API even more ergonomic, we can add convenience methods that handle common use cases:

```swift
extension Queryable {
	@discardableResult
	public func insert<PersistentModelType: PersistentModel>(
		_ closure: @Sendable @escaping () -> PersistentModelType
	) async -> Model<PersistentModelType> {
		await self.insert(closure, with: Model.init)
	}
	
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
// Create
let newItem = await database.insert { Item(name: "Test", timestamp: Date()) }

// Read
let item = try await database.get(for: .model(newItem))

// Update
try await database.update(for: .model(newItem)) { item in
	item.timestamp = Date()
}

// Delete
try await database.delete(.model(newItem))
```

## Handling Upserts

A common operation is inserting a record only if it doesn't already exist. We can add a dedicated method for this:

```swift
extension Queryable {
	public func insertIf<PersistentModelType>(
		_ model: @Sendable @escaping () -> PersistentModelType,
		notExist selector: @Sendable @escaping (PersistentModelType) ->
			Selector<PersistentModelType>.Get
	) async -> Model<PersistentModelType> {
		let persistentModel = model()
		let selector = selector(persistentModel)
		
		if let existing = await self.getOptional(for: selector) {
			return existing
		}
		
		return await self.insert(model)
	}
}
```

## Conclusion

By building on our previous work with ModelActor and Sendable types, we've created a robust, type-safe API for SwiftData operations that:

- Maintains concurrency safety through Sendable constraints
- Provides a clean, ergonomic interface for common operations
- Supports batch operations efficiently
- Handles common patterns like upserts
- Reduces boilerplate while maintaining type safety

This API makes it much easier to work with SwiftData in a concurrent environment while maintaining the safety guarantees that Swift provides. In the next article, we'll explore how to add more advanced features like relationships and cascading deletes.