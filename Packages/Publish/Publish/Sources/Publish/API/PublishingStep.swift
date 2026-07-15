/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files
import Foundation
import Plot

/// Type used to implement a publishing pipeline step.
/// Each Publish website is generated and deployed using steps, which can also
/// be combined into groups, and conditionally executed. Publish ships with many
/// built-in steps, and new ones can easily be defined using `step(named:body:)`.
/// Steps are added when calling `Website.publish`.
public struct PublishingStep<Site: Website>: Sendable {
  /// Closure type used to define the main body of a publishing step.
  public typealias Closure = @Sendable (inout PublishingContext<Site>) async throws -> Void

  internal let body: Body
}

// MARK: - Core

extension PublishingStep {
  /// An empty step that does nothing. Can be used as a conditional fallback.
  public static var empty: Self {
    PublishingStep(body: .empty)
  }

  /// Group an array of steps into one.
  /// - parameter steps: The steps to use to form a group.
  /// - Returns: The configured publishing step.
  public static func group(_ steps: [Self]) -> Self {
    PublishingStep(body: .group(steps))
  }

  /// Conditionally run a step if an expression evaluates to `true`.
  /// - Parameters:
  ///   - condition: The condition that determines whether the
  ///       step should be run or not.
  ///   - step: The step to run if the condition is `true`.
  /// - Returns: The configured publishing step.
  public static func `if`(_ condition: Bool, _ step: Self) -> Self {
    condition ? step : .empty
  }

  /// Conditionally run a step if an optional isn't `nil`.
  /// - Parameters:
  ///   - optional: The optional to unwrap.
  ///   - transform: A closure that transforms any unwrapped
  /// - Returns: The configured publishing step.
  ///       value into a `PublishingStep` instance.
  public static func unwrap<T>(_ optional: T?, _ transform: (T) -> Self) -> Self {
    optional.map(transform) ?? .empty
  }

  /// Convert a step into an optional one, making it silently fail in
  /// - Returns: The configured publishing step.
  /// case it encountered an error.
  /// - parameter step: The step to turn into an optional one.
  public static func optional(_ step: Self) -> Self {
    switch step.body {
    case .empty, .group:
      return step
    case .operation(let name, let closure):
      return .step(named: name) { context in
        do { try await closure(&context) } catch {}
      }
    }
  }

  /// Install a plugin into this publishing process.
  /// - parameter plugin: The plugin to install.
  /// - Returns: The configured publishing step.
  public static func installPlugin(_ plugin: Plugin<Site>) -> Self {
    step(
      named: "Install plugin '\(plugin.name)'",
      body: plugin.installer
    )
  }

  /// Create a custom step.
  /// - Returns: The configured publishing step.
  /// - Parameters:
  ///   - name: A human-readable name for the step.
  ///   - body: The step's closure body, which is used to
  ///       to mutate the current `PublishingContext`.
  public static func step(named name: String, body: @escaping Closure) -> Self {
    PublishingStep(body: .operation(name: name, closure: body))
  }
}

// MARK: - Implementation details

extension PublishingStep {
  internal enum Body: Sendable {
    case empty
    case operation(name: String, closure: Closure)
    case group([PublishingStep])
  }
}
