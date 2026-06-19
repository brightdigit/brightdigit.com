import BrightDigitSite
import Contribute
import ContributeMailchimp
import Foundation
import Spinetail

extension Import.MailchimpCommand {
  // Canonical newsletter number only: the digits must follow "BrightDigit"
  // (optionally "BrightDigit Newsletter") with an optional `#`. Matches
  // "BrightDigit #98", "BrightDigit 103", "BrightDigit #113", and the older
  // "BrightDigit Newsletter #18" form; it deliberately does NOT match numbers
  // elsewhere in a subject (e.g. "Rebuilding MistKit … in 3 Months",
  // "Bushel v2.3.0"), so those campaigns are treated as unnumbered and numbered
  // by date order instead.
  private static let issueNoRegexPatternString =
    #"(?i)brightdigit\s*(?:newsletter)?\s*#?\s*(\d+)"#

  private static let issueNoRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(pattern: issueNoRegexPatternString, options: [])
    } catch {
      preconditionFailure("Invalid issueNoRegex pattern: \(error)")
    }
  }()

  /// Logs an `import mailchimp:` diagnostic line to stderr.
  internal static func logImport(_ message: String) {
    FileHandle.standardError.write(Data("import mailchimp: \(message)\n".utf8))
  }

  internal static func fileNameWithoutExtensionFromSource(
    _ source: ContributeMailchimp.Newsletter.Source
  ) -> String {
    let paddedIssue = source.issueNo.description.padLeft(totalWidth: 3, byString: "0")
    return "\(paddedIssue)-\(source.slug)"
  }

  /// Whether a markdown file for `issueNo` already exists in `directory`.
  ///
  /// Matched by the zero-padded `NNN-` filename prefix (slug-independent), so the
  /// importer can skip fetching the archive content of issues already on disk —
  /// which keeps incremental catch-up runs from hammering (and being rate-limited
  /// by) Mailchimp's archive-content endpoint.
  internal static func fileExists(forIssueNo issueNo: Int, in directory: URL) -> Bool {
    let prefix = issueNo.description.padLeft(totalWidth: 3, byString: "0") + "-"
    let names =
      (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
    return names.contains { $0.hasPrefix(prefix) }
  }

  internal static func parseIssueNumber(from subject: String) -> Int? {
    let range = NSRange(subject.startIndex..<subject.endIndex, in: subject)
    guard
      let match = issueNoRegex.firstMatch(in: subject, options: [], range: range),
      match.numberOfRanges > 1,
      let numberRange = Range(match.range(at: 1), in: subject),
      let issueNumber = Int(subject[numberRange])
    else {
      return nil
    }
    return issueNumber
  }

  /// Selects the BrightDigit newsletters to import from the full sent-campaign
  /// list and assigns each an issue number.
  ///
  /// Numbering needs global ordering, so this runs as one pass over every
  /// campaign: keep the BrightDigit newsletters (with a `sendTime`), sort
  /// oldest-first, and assign each the explicit number parsed from its subject.
  /// Recent campaigns dropped the `#NNN` convention (e.g. "Introducing
  /// swift-build", "Bushel v2.3.0", "Rebuilding MistKit"); those sent *after the
  /// last explicitly-numbered issue* are numbered sequentially from there. An
  /// **interior** unnumbered campaign (older than the last numbered issue) is
  /// skipped — those are one-off broadcasts (e.g. a 2020 "Blog Updates" blast),
  /// not numbered newsletters, and guessing a number would mis-file them.
  internal static func selectCampaigns(
    _ campaigns: [MailchimpCampaign]
  ) throws -> [Newsletter.Source.Campaign] {
    let newsletters = campaigns
      .compactMap { campaign -> (campaign: MailchimpCampaign, sendTime: Date)? in
        let subjectLine = campaign.subjectLine ?? ""
        guard
          isBrightDigitNewsletter(campaign: campaign, subjectLine: subjectLine),
          let sendTime = campaign.sendTime
        else {
          return nil
        }
        return (campaign, sendTime)
      }
      .sorted { $0.sendTime < $1.sendTime }

    let anchor = numberingAnchor(for: newsletters)
    var result: [Newsletter.Source.Campaign] = []
    var trailingIssueNo = anchor.maxExplicit
    for (campaign, sendTime) in newsletters {
      let subjectLine = campaign.subjectLine ?? ""
      let issueNo: Int
      if let explicit = parseIssueNumber(from: subjectLine) {
        issueNo = explicit
      } else if let lastDate = anchor.lastNumberedDate, sendTime > lastDate {
        trailingIssueNo += 1
        issueNo = trailingIssueNo
      } else {
        logImport("skipping interior unnumbered (not a newsletter): \(subjectLine)")
        continue
      }
      logImport("#\(issueNo) ← \(subjectLine)")
      result.append(
        try campaignSource(from: campaign, subjectLine: subjectLine, issueNo: issueNo)
      )
    }
    return result
  }

  /// Numbers every newsletter, then keeps only the issues missing from disk
  /// (unless `overwriteExisting`), so an incremental catch-up doesn't refetch —
  /// and get rate-limited on — issues we already have.
  internal static func missingCampaigns(
    from campaigns: [MailchimpCampaign],
    in directory: URL,
    overwriteExisting: Bool
  ) throws -> [Newsletter.Source.Campaign] {
    let numbered = try selectCampaigns(campaigns)
    guard !overwriteExisting else {
      return numbered
    }
    let missing = numbered.filter { !fileExists(forIssueNo: $0.issueNo, in: directory) }
    let alreadyPresent = numbered.count - missing.count
    if alreadyPresent > 0 {
      logImport("\(alreadyPresent) already on disk; fetching \(missing.count) missing.")
    }
    return missing
  }

  /// The latest explicitly-numbered newsletter's send date and the highest
  /// explicit issue number — the anchor for numbering trailing unnumbered issues.
  private static func numberingAnchor(
    for newsletters: [(campaign: MailchimpCampaign, sendTime: Date)]
  ) -> (lastNumberedDate: Date?, maxExplicit: Int) {
    let numbers = newsletters.compactMap {
      parseIssueNumber(from: $0.campaign.subjectLine ?? "")
    }
    let lastNumberedDate = newsletters
      .filter { parseIssueNumber(from: $0.campaign.subjectLine ?? "") != nil }
      .map(\.sendTime)
      .max()
    return (lastNumberedDate, numbers.max() ?? 0)
  }

  /// Whether a campaign is a BrightDigit newsletter, by segment or subject line.
  private static func isBrightDigitNewsletter(
    campaign: MailchimpCampaign,
    subjectLine: String
  ) -> Bool {
    let brightdigitSent =
      campaign.segmentText?.contains("brightdigit-business") == true
    return brightdigitSent || subjectLine.contains("BrightDigit Newsletter")
  }

  /// Extracts the required campaign fields into a newsletter source.
  private static func campaignSource(
    from campaign: MailchimpCampaign,
    subjectLine: String,
    issueNo: Int
  ) throws -> Newsletter.Source.Campaign {
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
    guard let sendTime = campaign.sendTime else {
      throw ImportError.newsletterMissingField(.sendTime)
    }
    // Some campaigns have an empty internal title (the slug source); fall back to
    // the subject so the filename never degenerates to "NNN-.md".
    let slugSource = title.isEmpty ? subjectLine : title
    let featuredImageURL = campaign.socialCardImageURL.flatMap(URL.init(string:))
    return Newsletter.Source.Campaign(
      slug: slugSource.convertedToSlug(),
      issueNo: issueNo,
      campaignID: campaignID,
      longArchiveURL: longArchiveURL,
      featuredImageURL: featuredImageURL,
      title: title,
      subjectLine: subjectLine,
      previewText: campaign.previewText,
      sendTime: sendTime
    )
  }
}
