import Contribute
import Foundation
import SpinetailOpenAPI

/// The newsletter content type, importing BrightDigit newsletters from
/// Mailchimp campaigns via the swift-openapi-generator async client.
public enum Newsletter: ContentType {
  public typealias SourceType = Source
  public typealias ContentURLGeneratorType = BasicContentURLGenerator
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

extension Newsletter {
  /// Builds newsletter sources from the sent campaigns of a Mailchimp list.
  ///
  /// Lists the list's sent campaigns, then concurrently fetches and processes
  /// each campaign that the `factory` accepts into a ``Source``.
  ///
  /// - Parameters:
  ///   - client: The Mailchimp client.
  ///   - listID: The Mailchimp list (audience) id.
  ///   - factory: Maps a campaign into ``Source/Campaign`` metadata, or `nil`
  ///     to skip the campaign.
  ///   - htmlToMarkdown: Converts a campaign's archive HTML into Markdown.
  /// - Returns: The built newsletter sources.
  public static func sources(
    from client: MailchimpClient,
    listID: String,
    withFactory factory:
      @escaping @Sendable (MailchimpCampaign) throws -> Source
      .Campaign?,
    processedWith htmlToMarkdown: @escaping @Sendable (String) throws -> String
  ) async throws -> [Source] {
    let campaigns = try await client.sentCampaigns(forListID: listID)
    return try await withThrowingTaskGroup(
      of: Source?.self
    ) { group in
      for campaign in campaigns {
        group.addTask {
          try await source(
            from: campaign,
            client: client,
            withFactory: factory,
            processedWith: htmlToMarkdown
          )
        }
      }
      var sources: [Source] = []
      for try await source in group {
        if let source {
          sources.append(source)
        }
      }
      return sources
    }
  }

  /// Builds a single newsletter source from a campaign, or `nil` if the factory
  /// rejects the campaign.
  private static func source(
    from campaign: MailchimpCampaign,
    client: MailchimpClient,
    withFactory factory: @Sendable (MailchimpCampaign) throws -> Source.Campaign?,
    processedWith htmlToMarkdown: @Sendable (String) throws -> String
  ) async throws -> Source? {
    guard let campaignProperties = try factory(campaign) else {
      return nil
    }
    let html = try await client.archiveHTML(
      forCampaignID: campaignProperties.campaignID
    )
    let markdown = try htmlToMarkdown(html)
    return Source(campaign: campaignProperties, html: html, markdown: markdown)
  }
}
