import Contribute
import Foundation
import Spinetail

/// The newsletter content type, importing BrightDigit newsletters from
/// Mailchimp campaigns via the swift-openapi-generator async client.
@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public enum Newsletter: ContentType {
  public typealias SourceType = Source
  public typealias ContentURLGeneratorType = BasicContentURLGenerator
  public typealias MarkdownExtractorType = MarkdownExtractor
  public typealias FrontMatterTranslatorType = FrontMatterTranslator
}

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
extension Newsletter {
  /// The result of fetching one selected campaign's archive content.
  private enum CampaignOutcome: Sendable {
    case imported(Source)
    case contentUnavailable(campaignID: String, reason: String)
  }

  /// Builds newsletter sources from the sent campaigns of a Mailchimp list.
  ///
  /// Lists the list's sent campaigns and hands the whole list to `select`, which
  /// returns the campaign metadata to import (filtering + issue numbering happen
  /// there, where global ordering is available). Each selected campaign's archive
  /// HTML is then fetched and converted concurrently.
  ///
  /// A single campaign whose archive content is unavailable (e.g. a cached 503 at
  /// Mailchimp's storage layer — see issue #108) is logged to stderr and skipped,
  /// not fatal, so one bad campaign never aborts the whole import.
  ///
  /// - Parameters:
  ///   - client: The Mailchimp client.
  ///   - listID: The Mailchimp list (audience) id.
  ///   - select: Maps the full sent-campaign list into the ``Source/Campaign``
  ///     metadata to import (with issue numbers assigned).
  ///   - htmlToMarkdown: Converts a campaign's archive HTML into Markdown.
  /// - Returns: The built newsletter sources.
  public static func sources(
    from client: MailchimpClient,
    listID: String,
    selectingWith select:
      @Sendable ([MailchimpCampaign]) throws -> [Source.Campaign],
    processedWith htmlToMarkdown: @escaping @Sendable (String) throws -> String
  ) async throws -> [Source] {
    let campaigns = try await client.sentCampaigns(forListID: listID)
    let selected = try select(campaigns)

    let outcomes = try await withThrowingTaskGroup(
      of: CampaignOutcome.self
    ) { group in
      for campaign in selected {
        group.addTask {
          do {
            let html = try await client.archiveHTML(forCampaignID: campaign.campaignID)
            let markdown = try htmlToMarkdown(html)
            return .imported(Source(campaign: campaign, html: html, markdown: markdown))
          } catch {
            // #108: one campaign's archive content can be permanently
            // unavailable (cached 503). Skip it instead of aborting the import.
            return .contentUnavailable(
              campaignID: campaign.campaignID,
              reason: String(describing: error)
            )
          }
        }
      }
      var collected: [CampaignOutcome] = []
      for try await outcome in group {
        collected.append(outcome)
      }
      return collected
    }

    var sources: [Source] = []
    var skipped: [String] = []
    for outcome in outcomes {
      switch outcome {
      case let .imported(source):
        sources.append(source)
      case let .contentUnavailable(campaignID, reason):
        skipped.append(campaignID)
        FileHandle.standardError.write(
          Data("⚠️  import mailchimp: skipping campaign \(campaignID) — content unavailable: \(reason)\n".utf8)
        )
      }
    }
    if !skipped.isEmpty {
      FileHandle.standardError.write(
        Data("⚠️  import mailchimp: skipped \(skipped.count) campaign(s) with unavailable content: \(skipped.joined(separator: ", "))\n".utf8)
      )
    }
    return sources
  }
}
