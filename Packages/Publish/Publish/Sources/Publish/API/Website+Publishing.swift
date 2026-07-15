/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Dispatch
import Foundation
import Plot

extension Website {
  /// Publish this website using a default pipeline. To build a completely
  /// custom pipeline, use the `publish(using:)` method.
  /// - Parameters:
  ///   - theme: The HTML theme to generate the website using.
  ///   - indentation: How to indent the generated files.
  ///   - path: Any specific path to generate the website at.
  ///   - rssFeedSections: What sections to include in the site's RSS feed.
  ///   - rssFeedConfig: The configuration to use for the site's RSS feed.
  ///   - additionalSteps: Any additional steps to add to the publishing
  ///       pipeline. Will be executed right before the HTML generation process begins.
  ///   - plugins: Plugins to be installed at the start of the publishing process.
  ///   - file: The file that this method is called from (auto-inserted).
  /// - Returns: A representation of the published website.
  /// - Throws: An error if the publishing process fails.
  @discardableResult
  public func publish(
    withTheme theme: Theme<Self>,
    indentation: Indentation.Kind? = nil,
    at path: Path? = nil,
    rssFeedSections: Set<SectionID> = Set(SectionID.allCases),
    rssFeedConfig: RSSFeedConfiguration? = .default,
    additionalSteps: [PublishingStep<Self>] = [],
    plugins: [Plugin<Self>] = [],
    file: StaticString = #filePath
  ) throws -> PublishedWebsite<Self> where Self: Sendable {
    try publish(
      at: path,
      using: [
        .group(plugins.map(PublishingStep.installPlugin)),
        .optional(.copyResources()),
        .addMarkdownFiles(),
        .sortItems(by: \.date, order: .descending),
        .group(additionalSteps),
        .generateHTML(withTheme: theme, indentation: indentation),
        .unwrap(rssFeedConfig) { config in
          .generateRSSFeed(
            including: rssFeedSections,
            config: config
          )
        },
        .generateSiteMap(indentedBy: indentation),
      ],
      file: file
    )
  }

  /// Publish this website using a custom pipeline.
  /// - Parameters:
  ///   - path: Any specific path to generate the website at.
  ///   - steps: The steps to use to form the website's publishing pipeline.
  ///   - file: The file that this method is called from (auto-inserted).
  /// - Returns: A representation of the published website.
  /// - Throws: An error if the publishing process fails.
  @discardableResult
  public func publish(
    at path: Path? = nil,
    using steps: [PublishingStep<Self>],
    file: StaticString = #filePath
  ) throws -> PublishedWebsite<Self> where Self: Sendable {
    let pipeline = PublishingPipeline(
      steps: steps,
      originFilePath: Path("\(file)")
    )

    let semaphore = DispatchSemaphore(value: 0)
    let resultBox = ResultBox<PublishedWebsite<Self>>()

    Task {
      do {
        let website = try await pipeline.execute(for: self, at: path)
        resultBox.value = .success(website)
      } catch {
        resultBox.value = .failure(error)
      }

      semaphore.signal()
    }

    semaphore.wait()
    // The task always assigns `resultBox.value` before signalling the
    // semaphore, so it is guaranteed to be non-nil once `wait()` returns.
    guard let result = resultBox.value else {
      preconditionFailure("Publishing task finished without a result")
    }
    return try result.get()
  }

  /// Publish this website using a default pipeline. To build a completely
  /// custom pipeline, use the `publish(using:)` method.
  /// - Parameters:
  ///   - theme: The HTML theme to generate the website using.
  ///   - indentation: How to indent the generated files.
  ///   - path: Any specific path to generate the website at.
  ///   - rssFeedSections: What sections to include in the site's RSS feed.
  ///   - rssFeedConfig: The configuration to use for the site's RSS feed.
  ///   - additionalSteps: Any additional steps to add to the publishing
  ///       pipeline. Will be executed right before the HTML generation process begins.
  ///   - plugins: Plugins to be installed at the start of the publishing process.
  ///   - file: The file that this method is called from (auto-inserted).
  /// - Returns: A representation of the published website.
  /// - Throws: An error if the publishing process fails.
  @discardableResult
  public func publish(
    withTheme theme: Theme<Self>,
    indentation: Indentation.Kind? = nil,
    at path: Path? = nil,
    rssFeedSections: Set<SectionID> = Set(SectionID.allCases),
    rssFeedConfig: RSSFeedConfiguration? = .default,
    additionalSteps: [PublishingStep<Self>] = [],
    plugins: [Plugin<Self>] = [],
    file: StaticString = #filePath
  ) async throws -> PublishedWebsite<Self> {
    try await publish(
      at: path,
      using: [
        .group(plugins.map(PublishingStep.installPlugin)),
        .optional(.copyResources()),
        .addMarkdownFiles(),
        .sortItems(by: \.date, order: .descending),
        .group(additionalSteps),
        .generateHTML(withTheme: theme, indentation: indentation),
        .unwrap(rssFeedConfig) { config in
          .generateRSSFeed(
            including: rssFeedSections,
            config: config
          )
        },
        .generateSiteMap(indentedBy: indentation),
      ],
      file: file
    )
  }

  /// Publish this website using a custom pipeline.
  /// - Parameters:
  ///   - path: Any specific path to generate the website at.
  ///   - steps: The steps to use to form the website's publishing pipeline.
  ///   - file: The file that this method is called from (auto-inserted).
  /// - Returns: A representation of the published website.
  /// - Throws: An error if the publishing process fails.
  @discardableResult
  public func publish(
    at path: Path? = nil,
    using steps: [PublishingStep<Self>],
    file: StaticString = #filePath
  ) async throws -> PublishedWebsite<Self> {
    let pipeline = PublishingPipeline(
      steps: steps,
      originFilePath: Path("\(file)")
    )
    return try await pipeline.execute(for: self, at: path)
  }
}
