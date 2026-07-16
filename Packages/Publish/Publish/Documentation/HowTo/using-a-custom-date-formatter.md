# How to use a custom date parse strategy

If you’d like Publish to use a custom `Date.ParseStrategy`, rather than its built-in one (which decodes dates using the `yyyy-MM-dd HH:mm` format), then you can assign a new strategy to the current `PublishingContext` within a custom step:

```swift
try await MyWebsite().publish(using: [
    ...
    .step(named: "Use custom date parse strategy") { context in
        context.dateParseStrategy = Date.ParseStrategy(
            format: "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits)",
            locale: .current,
            timeZone: .current
        )
    }
])
```

> **BrightDigit note:** the previous `context.dateFormatter: DateFormatter` API was replaced so `PublishingContext` can be fully `Sendable`.
