import ArgumentParser
import BrightDigitSite
import Contribute
import ContributeMailchimp
import Foundation
import Spinetail
import Tagscriber

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension BrightDigitSiteCommand.ImportCommand {
  public struct Mailchimp: AsyncParsableCommand {
    public init() {}

    @Option(help: "Destination directory for markdown files.")
    public var exportMarkdownDirectory: String

    @Option(help: "Mailchimp API Key")
    public var mailchimpAPIKey: String

    @Option(help: "Mailchimp List ID")
    public var mailchimpListID: String

    @Flag
    public var overwriteExisting: Bool = false

    @Flag
    public var includeMissingPrevious: Bool = false

    var contentPathURL: URL {
      URL(fileURLWithPath: exportMarkdownDirectory)
    }

    static let issueNoRegexPatternString = #"(?:^|\s)#?(\d+)(?:\s|$)"#

    static let issueNoRegex: NSRegularExpression = {
      do {
        return try NSRegularExpression(
          pattern: issueNoRegexPatternString,
          options: []
        )
      } catch {
        preconditionFailure("Invalid issueNoRegex pattern: \(error)")
      }
    }()

    static func fileNameWithoutExtensionFromSource(
      _ source: ContributeMailchimp.Newsletter.Source
    ) -> String {
      let paddedIssue = source.issueNo.description.padLeft(
        totalWidth: 3,
        byString: "0"
      )
      return "\(paddedIssue)-\(source.slug)"
    }

    static func parseIssueNumber(from subject: String) -> Int? {
      let range = NSRange(subject.startIndex..<subject.endIndex, in: subject)
      guard
        let match = issueNoRegex.firstMatch(
          in: subject,
          options: [],
          range: range
        ),
        match.numberOfRanges > 1
      else {
        return nil
      }

      let numberRange = match.range(at: 1)
      guard let range = Range(numberRange, in: subject),
        let issueNumber = Int(subject[range])
      else {
        return nil
      }

      return issueNumber
    }

    static func sourceFrom(
      campaign: MailchimpCampaign
    ) throws -> Newsletter.Source.Campaign? {
      guard let subjectLine = campaign.subjectLine else {
        throw ImportError.newsletterMissingField(.subjectLine)
      }

      guard let issueNo = parseIssueNumber(from: subjectLine) else {
        return nil
      }

      let brightdigitSent =
        campaign.segmentText?.contains("brightdigit-business") == true
      let isBrightDigitNewsletter = subjectLine.contains("BrightDigit Newsletter")

      guard brightdigitSent || isBrightDigitNewsletter else {
        return nil
      }

      guard let campaignID = campaign.id else {
        throw ImportError.newsletterMissingField(.id)
      }
      guard let longArchiveURL = campaign.longArchiveURL.flatMap(URL.init(string:))
      else {
        throw ImportError.newsletterMissingField(.longArchiveURL)
      }
      guard let title = campaign.title else {
        throw ImportError.newsletterMissingField(.title)
      }
      let previewText = campaign.previewText

      guard let sendTime = campaign.sendTime else {
        throw ImportError.newsletterMissingField(.sendTime)
      }

      let featuredImageURL = campaign.socialCardImageURL.flatMap(URL.init(string:))
      let slug = title.convertedToSlug()

      return Newsletter.Source.Campaign(
        slug: slug,
        issueNo: issueNo,
        campaignID: campaignID,
        longArchiveURL: longArchiveURL,
        featuredImageURL: featuredImageURL,
        title: title,
        subjectLine: subjectLine,
        previewText: previewText,
        sendTime: sendTime
      )
    }

    public func run() async throws {
      let client = try MailchimpClient(apiKey: mailchimpAPIKey)
      let htmlToMarkdown = BrightDigitSiteCommand.ImportCommand
        .markdownGenerator.markdown(fromHTML:)

      let newsletters = try await Newsletter.sources(
        from: client,
        listID: mailchimpListID,
        withFactory: Self.sourceFrom(campaign:),
        processedWith: htmlToMarkdown
      )
      .sorted { $0.issueNo < $1.issueNo }

      let options = MarkdownContentBuilderOptions(
        shouldOverwriteExisting: overwriteExisting,
        includeMissingPrevious: includeMissingPrevious
      )

      try Newsletter.write(
        from: newsletters,
        atContentPathURL: contentPathURL,
        fileNameWithoutExtension: Self.fileNameWithoutExtensionFromSource(_:),
        using: htmlToMarkdown,
        options: options
      )
    }
  }
}
